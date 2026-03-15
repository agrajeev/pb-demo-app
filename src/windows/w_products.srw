$PBExportHeader$w_products.srw
$PBExportComments$Products / Inventory MDI Child Window

forward
global type w_products from window
end type
end forward

global type w_products from window
  integer width  = 8800
  integer height = 6000
  WindowType WindowType = Child!
  string title = "Products & Inventory"

  /* Controls */
  dropdownlistbox  ddlb_category
  singlelineedit   sle_search
  commandbutton    cb_search
  commandbutton    cb_new
  commandbutton    cb_save
  commandbutton    cb_delete
  commandbutton    cb_show_lowstock
  datawindow       dw_products
  datawindow       dw_product_detail
  statictext       st_stock_status
end type

global w_products w_products

event open();
  dw_products.DataObject      = "d_product_list"
  dw_product_detail.DataObject = "d_product_detail"

  dw_products.SetTransObject(SQLCA)
  dw_product_detail.SetTransObject(SQLCA)

  // Populate category dropdown
  of_load_categories()

  dw_products.Retrieve()
  cb_save.Enabled   = False
  cb_delete.Enabled = False
end event

event clicked() for cb_search;
  string ls_text, ls_cat
  ls_text = Trim(sle_search.Text)
  ls_cat  = ddlb_category.Text

  string ls_filter
  ls_filter = ""

  IF ls_text <> "" THEN
    ls_filter = "Upper(product_name) LIKE '%" + Upper(ls_text) + "%'" + &
                " OR Upper(product_code) LIKE '%" + Upper(ls_text) + "%'"
  END IF

  IF ls_cat <> "ALL" AND ls_cat <> "" THEN
    IF ls_filter <> "" THEN ls_filter += " AND "
    ls_filter += "category_name = '" + ls_cat + "'"
  END IF

  dw_products.SetFilter(ls_filter)
  dw_products.Filter()
end event

event clicked() for cb_show_lowstock;
  dw_products.SetFilter("stock_qty <= reorder_level")
  dw_products.Filter()
  st_stock_status.Text = "Showing LOW STOCK items only  |  " + &
    String(dw_products.RowCount()) + " item(s)"
end event

event rowfocuschanged(long row) for dw_products;
  IF row < 1 THEN RETURN
  long ll_pid
  ll_pid = dw_products.GetItemNumber(row, "product_id")
  dw_product_detail.Retrieve(ll_pid)
  cb_save.Enabled   = True
  cb_delete.Enabled = (gnv_app.s_role = "admin")
  of_show_stock_status(row)
end event

event clicked() for cb_new;
  dw_product_detail.Reset()
  dw_product_detail.InsertRow(0)
  dw_product_detail.SetItem(1, "is_active", 1)
  dw_product_detail.SetItem(1, "unit_of_measure", "EA")
  dw_product_detail.SetItem(1, "stock_qty", 0)
  dw_product_detail.SetItem(1, "reorder_level", 10)
  dw_product_detail.SetFocus()
  cb_save.Enabled   = True
  cb_delete.Enabled = False
end event

event clicked() for cb_save;
  string ls_code, ls_name
  ls_code = Trim(dw_product_detail.GetItemString(1, "product_code"))
  ls_name = Trim(dw_product_detail.GetItemString(1, "product_name"))

  IF ls_code = "" OR ls_name = "" THEN
    MessageBox("Validation", "Product Code and Product Name are required.", Exclamation!)
    RETURN
  END IF

  dw_product_detail.AcceptText()
  IF dw_product_detail.Update() = 1 THEN
    COMMIT USING SQLCA;
    dw_products.Retrieve()
    MessageBox("Saved", "Product saved successfully.", Information!)
  ELSE
    ROLLBACK USING SQLCA;
    MessageBox("Error", "Save failed: " + SQLCA.SQLErrText, StopSign!)
  END IF
end event

event clicked() for cb_delete;
  long ll_pid
  ll_pid = Long(dw_product_detail.GetItemString(1, "product_id"))
  IF ll_pid <= 0 THEN RETURN

  IF MessageBox("Confirm Delete", "Delete this product?", Question!, YesNo!) <> 1 THEN RETURN

  long ll_count
  SELECT COUNT(*) INTO :ll_count FROM order_items
    WHERE product_id = :ll_pid USING SQLCA;

  IF ll_count > 0 THEN
    MessageBox("Cannot Delete", &
      "This product appears on " + String(ll_count) + " order line(s)." + &
      "~nSet it to Inactive instead.", Exclamation!)
    RETURN
  END IF

  DELETE FROM products WHERE product_id = :ll_pid USING SQLCA;
  IF SQLCA.SQLCode = 0 THEN
    COMMIT USING SQLCA;
    dw_product_detail.Reset()
    dw_products.Retrieve()
    cb_save.Enabled   = False
    cb_delete.Enabled = False
  ELSE
    ROLLBACK USING SQLCA;
    MessageBox("Error", SQLCA.SQLErrText, StopSign!)
  END IF
end event

function of_load_categories();
  ddlb_category.AddItem("ALL")
  string ls_cat
  DECLARE cur_cat CURSOR FOR
    SELECT category_name FROM product_categories ORDER BY category_name
    USING SQLCA;
  OPEN cur_cat;
  FETCH cur_cat INTO :ls_cat;
  DO WHILE SQLCA.SQLCode = 0
    ddlb_category.AddItem(ls_cat)
    FETCH cur_cat INTO :ls_cat;
  LOOP
  CLOSE cur_cat;
  ddlb_category.SelectItem("ALL")
end function

function of_show_stock_status(long al_row);
  long ll_stock, ll_reorder
  ll_stock   = dw_products.GetItemNumber(al_row, "stock_qty")
  ll_reorder = dw_products.GetItemNumber(al_row, "reorder_level")

  IF ll_stock <= 0 THEN
    st_stock_status.Text = "⚠ OUT OF STOCK"
    st_stock_status.TextColor = RGB(200,0,0)
  ELSEIF ll_stock <= ll_reorder THEN
    st_stock_status.Text = "⚠ LOW STOCK (" + String(ll_stock) + " remaining)"
    st_stock_status.TextColor = RGB(200,120,0)
  ELSE
    st_stock_status.Text = "✔ In Stock (" + String(ll_stock) + " units)"
    st_stock_status.TextColor = RGB(0,140,0)
  END IF
end function
