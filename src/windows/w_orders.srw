$PBExportHeader$w_orders.srw
$PBExportComments$Orders MDI Child Window — Order entry and management

forward
global type w_orders from window
end type
end forward

global type w_orders from window
  integer width  = 9000
  integer height = 6500
  WindowType WindowType = Child!
  string title = "Orders"

  /* Controls */
  dropdownlistbox  ddlb_status_filter
  commandbutton    cb_filter
  commandbutton    cb_new_order
  commandbutton    cb_save
  commandbutton    cb_confirm
  commandbutton    cb_ship
  commandbutton    cb_cancel_order
  datawindow       dw_orders       // Order list (v_order_summary)
  datawindow       dw_header       // Order header detail
  datawindow       dw_items        // Order line items
  statictext       st_total
end type

global w_orders w_orders

/* ── Open ── */
event open();
  dw_orders.DataObject = "d_order_list"
  dw_header.DataObject = "d_order_header"
  dw_items.DataObject  = "d_order_items"

  dw_orders.SetTransObject(SQLCA)
  dw_header.SetTransObject(SQLCA)
  dw_items.SetTransObject(SQLCA)

  // Status filter dropdown
  ddlb_status_filter.AddItem("ALL")
  ddlb_status_filter.AddItem("PENDING")
  ddlb_status_filter.AddItem("CONFIRMED")
  ddlb_status_filter.AddItem("SHIPPED")
  ddlb_status_filter.AddItem("DELIVERED")
  ddlb_status_filter.AddItem("CANCELLED")
  ddlb_status_filter.SelectItem("ALL")

  dw_orders.Retrieve()
  of_update_buttons("")
end event

/* ── Filter orders by status ── */
event clicked() for cb_filter;
  string ls_status
  ls_status = ddlb_status_filter.Text
  IF ls_status = "ALL" THEN
    dw_orders.SetFilter("")
  ELSE
    dw_orders.SetFilter("status = '" + ls_status + "'")
  END IF
  dw_orders.Filter()
end event

/* ── Select order from list ── */
event rowfocuschanged(long row) for dw_orders;
  long ll_order_id
  IF row < 1 THEN RETURN

  ll_order_id = dw_orders.GetItemNumber(row, "order_id")
  dw_header.Retrieve(ll_order_id)
  dw_items.Retrieve(ll_order_id)
  of_update_total()
  of_update_buttons(dw_orders.GetItemString(row, "status"))
end event

/* ── New Order ── */
event clicked() for cb_new_order;
  Open(w_order_entry, w_main)
end event

/* ── Confirm Order ── */
event clicked() for cb_confirm;
  of_update_status("CONFIRMED")
end event

/* ── Ship Order ── */
event clicked() for cb_ship;
  of_update_status("SHIPPED")
end event

/* ── Cancel Order ── */
event clicked() for cb_cancel_order;
  IF MessageBox("Confirm", "Cancel this order?", Question!, YesNo!) = 1 THEN
    of_update_status("CANCELLED")
  END IF
end event

/* ── Save changes to line items ── */
event clicked() for cb_save;
  dw_items.AcceptText()
  IF dw_items.Update() = 1 THEN
    COMMIT USING SQLCA;
    of_update_total()
    MessageBox("Saved", "Order lines saved.", Information!)
  ELSE
    ROLLBACK USING SQLCA;
    MessageBox("Error", "Save failed: " + SQLCA.SQLErrText, StopSign!)
  END IF
end event

/* ──────────────────────────────────────────────────────────
   User Functions
   ────────────────────────────────────────────────────────── */

function of_update_status(string as_status);
  long ll_order_id
  ll_order_id = Long(dw_header.GetItemString(1, "order_id"))
  IF ll_order_id <= 0 THEN RETURN

  string ls_shipped
  IF as_status = "SHIPPED" THEN ls_shipped = "GETDATE()" ELSE ls_shipped = "NULL"

  UPDATE orders
    SET status       = :as_status,
        shipped_date  = CASE WHEN :as_status = 'SHIPPED' THEN GETDATE() ELSE shipped_date END,
        updated_at    = GETDATE()
    WHERE order_id   = :ll_order_id
    USING SQLCA;

  IF SQLCA.SQLCode = 0 THEN
    COMMIT USING SQLCA;
    dw_orders.Retrieve()
    dw_header.Retrieve(ll_order_id)
    of_update_buttons(as_status)
  ELSE
    ROLLBACK USING SQLCA;
    MessageBox("Error", SQLCA.SQLErrText, StopSign!)
  END IF
end function

function of_update_total();
  decimal ld_total
  long    ll_rows, ll_i
  ll_rows = dw_items.RowCount()
  ld_total = 0
  FOR ll_i = 1 TO ll_rows
    ld_total += dw_items.GetItemDecimal(ll_i, "line_total")
  NEXT
  st_total.Text = "Order Total:  $" + String(ld_total, "#,##0.00")
end function

function of_update_buttons(string as_status);
  boolean lb_pending    = (as_status = "PENDING")
  boolean lb_confirmed  = (as_status = "CONFIRMED")
  boolean lb_is_admin   = (gnv_app.s_role = "admin")

  cb_confirm.Enabled     = lb_pending
  cb_ship.Enabled        = lb_confirmed
  cb_cancel_order.Enabled = (lb_pending OR lb_confirmed) AND lb_is_admin
  cb_save.Enabled         = lb_pending OR lb_confirmed
end function
