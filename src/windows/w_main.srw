$PBExportHeader$w_main.srw
$PBExportComments$Main MDI Frame Window

forward
global type w_main from window
end type
end forward

global type w_main from window
  integer width  = 10000
  integer height = 7500
  WindowType WindowType = Main!
  boolean TitleBar = true
  boolean MaxBox   = true
  boolean MinBox   = true
  boolean Resizable = true
  string  title    = "PBDemo ERP"
  boolean MDIFrame = true
  menu m_main
end type

global w_main w_main

/* ── Window Open ── */
event open();
  // Set title with logged-in user
  This.title = "PBDemo ERP  —  " + gnv_app.s_fullname + &
               "  [" + Upper(gnv_app.s_role) + "]"

  // Open Dashboard as default MDI child
  Open(w_dashboard, This)

  // Disable admin menus for non-admin
  IF gnv_app.s_role <> "admin" THEN
    m_main.m_admin.Enabled = False
  END IF
end event

/* ── Window Close ── */
event close();
  IF MessageBox("Exit", "Are you sure you want to exit?", &
                Question!, YesNo!) = 1 THEN
    DISCONNECT USING SQLCA;
    Halt
  END IF
end event

/* ── Toolbar / Menu handlers ── */

// Customers
event ue_open_customers();
  IF IsValid(w_customers) THEN
    w_customers.SetFocus()
  ELSE
    Open(w_customers, w_main)
  END IF
end event

// Products / Inventory
event ue_open_products();
  IF IsValid(w_products) THEN
    w_products.SetFocus()
  ELSE
    Open(w_products, w_main)
  END IF
end event

// Orders
event ue_open_orders();
  IF IsValid(w_orders) THEN
    w_orders.SetFocus()
  ELSE
    Open(w_orders, w_main)
  END IF
end event

// Reports
event ue_open_reports();
  Open(w_reports, w_main)
end event

// About
event ue_about();
  MessageBox("About PBDemo ERP", &
    "PBDemo ERP v1.0~n" + &
    "Built with PowerBuilder 2022~n" + &
    "A sample/demo application.", &
    Information!)
end event
