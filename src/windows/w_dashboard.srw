$PBExportHeader$w_dashboard.srw
$PBExportComments$Dashboard MDI Child Window — KPI summary

forward
global type w_dashboard from window
end type
end forward

global type w_dashboard from window
  integer width  = 7500
  integer height = 5000
  WindowType WindowType = Child!
  string title = "Dashboard"

  /* KPI controls */
  statictext  st_lbl_open_orders
  statictext  st_val_open_orders
  statictext  st_lbl_shipped
  statictext  st_val_shipped
  statictext  st_lbl_lowstock
  statictext  st_val_lowstock
  statictext  st_lbl_customers
  statictext  st_val_customers
  statictext  st_lbl_sales30
  statictext  st_val_sales30

  /* DataWindow grids */
  datawindow  dw_recent_orders
  datawindow  dw_low_stock

  commandbutton cb_refresh
  statictext    st_last_refresh
end type

global w_dashboard w_dashboard

event open();
  dw_recent_orders.DataObject = "d_dashboard_recent_orders"
  dw_low_stock.DataObject     = "d_dashboard_low_stock"

  dw_recent_orders.SetTransObject(SQLCA)
  dw_low_stock.SetTransObject(SQLCA)

  // Set KPI labels
  st_lbl_open_orders.Text = "Open Orders"
  st_lbl_shipped.Text     = "Orders Shipped"
  st_lbl_lowstock.Text    = "Low Stock Items"
  st_lbl_customers.Text   = "Active Customers"
  st_lbl_sales30.Text     = "Sales (Last 30 Days)"

  of_refresh()
end event

event clicked() for cb_refresh;
  of_refresh()
end event

function of_refresh();
  long   ll_open, ll_shipped, ll_lowstock, ll_customers
  decimal ld_sales30

  // Fetch KPIs via stored procedure
  DECLARE sp_dash PROCEDURE FOR sp_dashboard_summary USING SQLCA;
  EXECUTE sp_dash;
  FETCH sp_dash INTO :ll_open, :ll_shipped, :ll_lowstock, :ll_customers, :ld_sales30;
  CLOSE sp_dash;

  st_val_open_orders.Text = String(ll_open)
  st_val_shipped.Text     = String(ll_shipped)
  st_val_lowstock.Text    = String(ll_lowstock)
  st_val_customers.Text   = String(ll_customers)
  st_val_sales30.Text     = "$" + String(ld_sales30, "#,##0.00")

  // Colour low-stock warning
  IF ll_lowstock > 0 THEN
    st_val_lowstock.TextColor = RGB(200, 60, 0)
  ELSE
    st_val_lowstock.TextColor = RGB(0, 140, 0)
  END IF

  // Refresh grids
  dw_recent_orders.Retrieve()
  dw_low_stock.Retrieve()

  st_last_refresh.Text = "Last refreshed: " + String(Now(), "HH:MM:SS")
end function

/* ── Double-click on recent order to open order detail ── */
event doubleclicked(long row, long col, dwobject dwobj) for dw_recent_orders;
  IF row < 1 THEN RETURN
  long ll_order_id
  ll_order_id = dw_recent_orders.GetItemNumber(row, "order_id")
  // Pass order_id to orders window
  OpenWithParm(w_orders, ll_order_id, w_main)
end event

/* ── Double-click low stock to open product ── */
event doubleclicked(long row, long col, dwobject dwobj) for dw_low_stock;
  IF row < 1 THEN RETURN
  Open(w_products, w_main)
end event
