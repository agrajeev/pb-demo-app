$PBExportHeader$w_customers.srw
$PBExportComments$Customers MDI Child Window — full CRUD

forward
global type w_customers from window
end type
end forward

global type w_customers from window
  integer width  = 8500
  integer height = 6000
  WindowType WindowType = Child!
  string title = "Customers"
  boolean TitleBar = true
  boolean MaxBox   = true
  boolean MinBox   = true

  /* Controls */
  singlelineedit  sle_search
  commandbutton   cb_search
  commandbutton   cb_new
  commandbutton   cb_save
  commandbutton   cb_delete
  commandbutton   cb_refresh
  datawindow      dw_list       // Customer list grid
  datawindow      dw_detail     // Customer detail form
end type

global w_customers w_customers

/* ── Window Open ── */
event open();
  // Assign DataObjects
  dw_list.DataObject   = "d_customer_list"
  dw_detail.DataObject = "d_customer_detail"

  dw_list.SetTransObject(SQLCA)
  dw_detail.SetTransObject(SQLCA)

  // Load customer list
  dw_list.Retrieve()

  // Button states
  cb_save.Enabled   = False
  cb_delete.Enabled = False

  sle_search.SetFocus()
end event

/* ── Search button ── */
event clicked() for cb_search;
  string ls_filter
  ls_filter = Trim(sle_search.Text)

  IF ls_filter = "" THEN
    dw_list.SetFilter("")
  ELSE
    dw_list.SetFilter("Upper(company_name) LIKE '%" + Upper(ls_filter) + "%'" + &
                      " OR Upper(contact_name) LIKE '%" + Upper(ls_filter) + "%'")
  END IF
  dw_list.Filter()
end event

/* ── New Customer button ── */
event clicked() for cb_new;
  dw_detail.Reset()
  dw_detail.InsertRow(0)
  dw_detail.SetItem(1, "is_active", 1)
  dw_detail.SetItem(1, "country", "USA")
  dw_detail.SetItem(1, "credit_limit", 5000.00)
  dw_detail.SetFocus()
  cb_save.Enabled   = True
  cb_delete.Enabled = False
end event

/* ── Row selected in list — load detail ── */
event rowfocuschanged(long row) for dw_list;
  long ll_custid
  IF row < 1 THEN RETURN

  ll_custid = dw_list.GetItemNumber(row, "customer_id")
  dw_detail.Retrieve(ll_custid)
  cb_save.Enabled   = True
  cb_delete.Enabled = (gnv_app.s_role = "admin")
end event

/* ── Save button ── */
event clicked() for cb_save;
  // Validate required fields
  IF Trim(dw_detail.GetItemString(1, "company_name")) = "" THEN
    MessageBox("Validation", "Company Name is required.", Exclamation!)
    dw_detail.SetFocus()
    RETURN
  END IF

  dw_detail.AcceptText()
  IF dw_detail.Update() = 1 THEN
    COMMIT USING SQLCA;
    MessageBox("Saved", "Customer record saved successfully.", Information!)
    dw_list.Retrieve()
    cb_save.Enabled = False
  ELSE
    ROLLBACK USING SQLCA;
    MessageBox("Error", "Save failed: " + SQLCA.SQLErrText, StopSign!)
  END IF
end event

/* ── Delete button ── */
event clicked() for cb_delete;
  long ll_custid
  ll_custid = Long(dw_detail.GetItemString(1, "customer_id"))

  IF ll_custid <= 0 THEN RETURN

  IF MessageBox("Confirm Delete", &
    "Delete this customer? This cannot be undone.", &
    Question!, YesNo!) <> 1 THEN RETURN

  // Check for linked orders
  long ll_count
  SELECT COUNT(*) INTO :ll_count FROM orders
    WHERE customer_id = :ll_custid USING SQLCA;

  IF ll_count > 0 THEN
    MessageBox("Cannot Delete", &
      "This customer has " + String(ll_count) + " order(s) on file." + &
      "~nSoft-delete by un-checking 'Active' instead.", &
      Exclamation!)
    RETURN
  END IF

  DELETE FROM customers WHERE customer_id = :ll_custid USING SQLCA;
  IF SQLCA.SQLCode = 0 THEN
    COMMIT USING SQLCA;
    dw_detail.Reset()
    dw_list.Retrieve()
    cb_save.Enabled   = False
    cb_delete.Enabled = False
  ELSE
    ROLLBACK USING SQLCA;
    MessageBox("Error", "Delete failed: " + SQLCA.SQLErrText, StopSign!)
  END IF
end event

/* ── Refresh button ── */
event clicked() for cb_refresh;
  dw_list.Retrieve()
  dw_detail.Reset()
  cb_save.Enabled   = False
  cb_delete.Enabled = False
end event

/* ── Track changes in detail DataWindow ── */
event modified() for dw_detail;
  cb_save.Enabled = True
end event

/* ── Prevent close with unsaved changes ── */
event closequery();
  IF dw_detail.ModifiedCount() > 0 OR dw_detail.DeletedCount() > 0 THEN
    IF MessageBox("Unsaved Changes", &
      "You have unsaved changes. Close without saving?", &
      Question!, YesNo!) <> 1 THEN
      Action = 1  // Prevent close
    END IF
  END IF
end event
