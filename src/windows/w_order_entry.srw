$PBExportHeader$w_order_entry.srw
$PBExportComments$New Order Entry Window — popup dialog style

forward
global type w_order_entry from window
end type
end forward

global type w_order_entry from window
  integer width  = 7200
  integer height = 5500
  WindowType WindowType = Popup!
  string title = "New Order Entry"
  boolean TitleBar = true
  boolean MaxBox   = false
  boolean MinBox   = false
  boolean Center   = true

  /* Header controls */
  statictext       st_customer
  dropdownlistbox  ddlb_customer
  statictext       st_orderdate
  singlelineedit   sle_order_date
  statictext       st_reqdate
  singlelineedit   sle_req_date
  statictext       st_ship_to
  singlelineedit   sle_ship_to
  statictext       st_notes
  editbox          eb_notes

  /* Line items DataWindow */
  datawindow       dw_new_items

  /* Footer controls */
  statictext       st_total_label
  statictext       st_total_value
  commandbutton    cb_add_line
  commandbutton    cb_remove_line
  commandbutton    cb_save_order
  commandbutton    cb_cancel
end type

global w_order_entry w_order_entry

/* ── Open ── */
event open();
  dw_new_items.DataObject = "d_order_items_entry"
  dw_new_items.SetTransObject(SQLCA)

  // Populate customers dropdown
  of_load_customers()

  // Default dates
  sle_order_date.Text = String(Today(), "mm/dd/yyyy")
  sle_req_date.Text   = String(RelativeDate(Today(), 7), "mm/dd/yyyy")

  st_total_label.Text = "Order Total:"
  st_total_value.Text = "$0.00"

  cb_add_line.Text    = "+ Add Line"
  cb_remove_line.Text = "- Remove Line"
  cb_save_order.Text  = "Save Order"
  cb_cancel.Text      = "Cancel"
end event

/* ── Load customer dropdown ── */
function of_load_customers();
  long   ll_id
  string ls_name
  DECLARE cur_cust CURSOR FOR
    SELECT customer_id, company_name
    FROM customers WHERE is_active = 1
    ORDER BY company_name USING SQLCA;
  OPEN cur_cust;
  FETCH cur_cust INTO :ll_id, :ls_name;
  DO WHILE SQLCA.SQLCode = 0
    ddlb_customer.AddItem(ls_name)
    FETCH cur_cust INTO :ll_id, :ls_name;
  LOOP
  CLOSE cur_cust;
end function

/* ── Add a blank line ── */
event clicked() for cb_add_line;
  long ll_row
  ll_row = dw_new_items.InsertRow(0)
  dw_new_items.SetItem(ll_row, "quantity", 1)
  dw_new_items.SetItem(ll_row, "discount_pct", 0.00)
  dw_new_items.ScrollToRow(ll_row)
  dw_new_items.SetFocus()
end event

/* ── Remove selected line ── */
event clicked() for cb_remove_line;
  long ll_row
  ll_row = dw_new_items.GetRow()
  IF ll_row < 1 THEN RETURN
  IF gf_confirm("Remove this line item?", "Confirm") THEN
    dw_new_items.DeleteRow(ll_row)
    of_recalc_total()
  END IF
end event

/* ── Recalc total ── */
function of_recalc_total();
  decimal ld_total
  long ll_rows, ll_i
  ll_rows  = dw_new_items.RowCount()
  ld_total = 0
  FOR ll_i = 1 TO ll_rows
    decimal ld_qty, ld_price, ld_disc
    ld_qty   = dw_new_items.GetItemDecimal(ll_i, "quantity")
    ld_price = dw_new_items.GetItemDecimal(ll_i, "unit_price")
    ld_disc  = dw_new_items.GetItemDecimal(ll_i, "discount_pct")
    ld_total += ld_qty * ld_price * (1 - ld_disc / 100)
  NEXT
  st_total_value.Text = gf_format_currency(ld_total)
end function

/* ── Itemchanged — auto-fill unit price when product selected ── */
event itemchanged(long row, dwobject dwo, string data) for dw_new_items;
  IF dwo.Name = "product_id" THEN
    long ll_pid
    decimal ld_price
    ll_pid = Long(data)
    SELECT unit_price INTO :ld_price FROM products
      WHERE product_id = :ll_pid USING SQLCA;
    IF SQLCA.SQLCode = 0 THEN
      dw_new_items.SetItem(row, "unit_price", ld_price)
    END IF
    of_recalc_total()
  ELSEIF dwo.Name = "quantity" OR dwo.Name = "discount_pct" THEN
    of_recalc_total()
  END IF
end event

/* ── Save Order ── */
event clicked() for cb_save_order;
  // Validate header
  IF ddlb_customer.Text = "" THEN
    MessageBox("Validation", "Please select a Customer.", Exclamation!)
    RETURN
  END IF
  IF dw_new_items.RowCount() = 0 THEN
    MessageBox("Validation", "Please add at least one line item.", Exclamation!)
    RETURN
  END IF

  // Get customer_id
  long ll_cust_id
  SELECT customer_id INTO :ll_cust_id FROM customers
    WHERE company_name = :ddlb_customer.Text USING SQLCA;
  IF gf_db_error_check("Order Entry - customer lookup") THEN RETURN

  // Insert order header
  long ll_new_order_id
  date ld_order_date, ld_req_date
  ld_order_date = Date(sle_order_date.Text)
  ld_req_date   = Date(sle_req_date.Text)
  string ls_notes, ls_ship_to

  ls_notes   = eb_notes.Text
  ls_ship_to = sle_ship_to.Text

  INSERT INTO orders (customer_id, order_date, required_date, status, ship_to_name, notes, created_by)
    VALUES (:ll_cust_id, :ld_order_date, :ld_req_date, 'PENDING', :ls_ship_to, :ls_notes, :gnv_app.i_user_id)
    USING SQLCA;

  IF gf_db_error_check("Order Entry - insert header") THEN
    ROLLBACK USING SQLCA;
    RETURN
  END IF

  // Get new order ID
  SELECT @@IDENTITY INTO :ll_new_order_id FROM orders USING SQLCA;

  // Insert line items
  long ll_rows, ll_i
  ll_rows = dw_new_items.RowCount()
  FOR ll_i = 1 TO ll_rows
    long    ll_pid, ll_qty
    decimal ld_price, ld_disc
    ll_pid   = dw_new_items.GetItemNumber(ll_i, "product_id")
    ll_qty   = dw_new_items.GetItemNumber(ll_i, "quantity")
    ld_price = dw_new_items.GetItemDecimal(ll_i, "unit_price")
    ld_disc  = dw_new_items.GetItemDecimal(ll_i, "discount_pct")

    INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct)
      VALUES (:ll_new_order_id, :ll_pid, :ll_qty, :ld_price, :ld_disc) USING SQLCA;

    IF gf_db_error_check("Order Entry - insert line " + String(ll_i)) THEN
      ROLLBACK USING SQLCA;
      RETURN
    END IF
  NEXT

  COMMIT USING SQLCA;
  MessageBox("Order Saved", "Order #" + String(ll_new_order_id) + " created successfully.", Information!)
  Close(This)
  // Refresh the orders window if open
  IF IsValid(w_orders) THEN w_orders.dw_orders.Retrieve()
end event

/* ── Cancel ── */
event clicked() for cb_cancel;
  Close(This)
end event
