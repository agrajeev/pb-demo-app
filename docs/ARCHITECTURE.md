# Developer Notes — PBDemo ERP Architecture

## Application Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      w_main (MDI Frame)                     │
│  Menu: m_main                                               │
│  ┌─────────────┐ ┌──────────────┐ ┌───────────┐ ┌────────┐ │
│  │ w_dashboard │ │ w_customers  │ │ w_products│ │w_orders│ │
│  │  (child)    │ │  (child)     │ │  (child)  │ │(child) │ │
│  └─────────────┘ └──────────────┘ └───────────┘ └────────┘ │
│                                    ┌──────────┐             │
│                                    │w_reports │             │
│                                    └──────────┘             │
└─────────────────────────────────────────────────────────────┘
         │
         │  SQLCA (global Transaction Object)
         │
┌────────▼──────────┐
│   SQL Server DB   │
│   (PBDemoDB)      │
│                   │
│  Tables:          │
│  customers        │
│  products         │
│  product_categories│
│  orders           │
│  order_items      │
│  users            │
│                   │
│  Views:           │
│  v_order_summary  │
│  v_low_stock      │
│                   │
│  Stored Procs:    │
│  sp_dashboard_summary│
│  sp_customer_orders  │
│  sp_login            │
└───────────────────┘
```

---

## Key Design Decisions

### Transaction Handling
- Single global `SQLCA` transaction object configured at app startup
- All windows share the same connection
- Explicit `COMMIT`/`ROLLBACK` after every DML operation
- `AutoCommit = False` throughout

### DataWindow Strategy

| DataWindow | Type | Notes |
|---|---|---|
| `d_customer_list` | Grid | Read-only list, filtered by search |
| `d_customer_detail` | Freeform | Editable, single customer |
| `d_order_list` | Grid | Uses `v_order_summary` view, read-only |
| `d_order_header` | Freeform | Editable header fields |
| `d_order_items` | Grid | Editable line items, computed line_total |
| `d_product_list` | Grid | Colour-coded low-stock rows |
| `d_product_detail` | Freeform | Editable with category DDLB |
| `d_report_order_history` | Group | Print/PDF/Excel, date-range filtered |
| `d_report_inventory` | Group | Print/PDF/Excel, grouped by category |
| `d_ddlb_*` | Grid | Lookup DWs for DDLB edit styles |

### Role-Based Access

```
gnv_app.s_role = "admin"  →  full access (all CRUD + admin menu)
gnv_app.s_role = "user"   →  limited (no delete, no admin menu)
```

### Session State
Stored in `gnv_app` — a global instance of `n_app_session` NVO:
- `i_user_id`, `s_username`, `s_fullname`, `s_role`

Declare in Application object globals:
```
gnv_app  n_app_session
```

---

## File Map

```
src/
├── pbdemo.sra                    Application object
├── windows/
│   ├── w_login.srw               Login dialog
│   ├── w_main.srw                MDI frame
│   ├── m_main.srm                Main menu
│   ├── w_dashboard.srw           KPI dashboard
│   ├── w_customers.srw           Customer CRUD
│   ├── w_products.srw            Product / inventory
│   ├── w_orders.srw              Order list + status workflow
│   ├── w_order_entry.srw         New order popup
│   └── w_reports.srw             Report preview / export
├── datawindows/
│   ├── d_customer_list.srd       Customer grid
│   ├── d_customer_detail.srd     Customer form
│   ├── d_order_list.srd          Order grid (v_order_summary)
│   ├── d_order_header.srd        Order header form
│   ├── d_order_items.srd         Order line items grid
│   ├── d_product_list.srd        Product grid
│   ├── d_product_detail.srd      Product form
│   ├── d_dashboard_datawindows.srd  Dashboard grids (2 DWs)
│   ├── d_ddlb_lookups.srd        Lookup DWs (3 DWs)
│   └── d_reports.srd             Report DWs (2 reports)
├── userobjects/
│   └── n_app_session.sru         Session state NVO
└── functions/
    └── gf_global_functions.srf   Global utility functions
```

---

## Extending the App

### Add a New Module
1. Create a new MDI child window `.srw` under `src/windows/`
2. Add a DataWindow `.srd` for its data
3. Add a menu item in `m_main.srm`
4. Add a `TriggerEvent()` handler in `w_main.srw`

### Change Database Server
Update `SQLCA.DBParm` in `pbdemo.sra` and the ODBC DSN.
All DataWindows and cursors use `USING SQLCA` so no other changes needed.

### Production Security
Replace the `gf_sha256` stub with a real SHA-256 DLL call:
```
FUNCTION string sha256(string s) LIBRARY "crypto_helper.dll"
```
