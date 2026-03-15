# PowerBuilder Demo Application — ERP Sample

A fully functional **PowerBuilder ERP demo application** showcasing customers, orders, and inventory management. Designed for demo, training, and POC purposes.

---

## 📁 Project Structure

```
pb-demo-app/
├── src/
│   ├── windows/          # PowerBuilder Window source files (.srw)
│   ├── datawindows/      # DataWindow source files (.srd)
│   ├── userobjects/      # User Object source files (.sru)
│   └── functions/        # Global function source files (.srf)
├── database/
│   ├── schema/           # DDL scripts (CREATE TABLE, indexes)
│   └── sampledata/       # DML scripts (INSERT sample records)
├── docs/                 # Setup guides and screenshots
├── pbdemo.pbt            # PowerBuilder Target file
├── pbdemo.pbw            # PowerBuilder Workspace file
└── README.md
```

---

## 🔧 Prerequisites

| Requirement | Version |
|---|---|
| PowerBuilder | 2019 R3 / 2022 or later |
| SQL Server | 2016 or later (Express is fine) |
| ODBC Driver | SQL Server ODBC Driver 17+ |

---

## 🚀 Quick Start

### 1. Set Up the Database

```sql
-- Run in order:
database/schema/01_create_database.sql
database/schema/02_create_tables.sql
database/schema/03_create_indexes.sql
database/sampledata/04_insert_customers.sql
database/sampledata/05_insert_products.sql
database/sampledata/06_insert_orders.sql
```

### 2. Configure ODBC

Create a **System DSN** named `PBDemoDB`:
- Driver: `ODBC Driver 17 for SQL Server`
- Server: `localhost` (or your SQL Server instance)
- Database: `PBDemoDB`
- Authentication: SQL Server or Windows Auth

### 3. Open in PowerBuilder

1. Open `pbdemo.pbw` in PowerBuilder IDE
2. Right-click the target → **Properties** → update DB profile if needed
3. Click **Run (F5)**

---

## 🖥️ Application Modules

| Module | Description |
|---|---|
| **Login** | User authentication with role-based access |
| **Dashboard** | Summary KPIs — open orders, low stock alerts |
| **Customers** | Full CRUD — search, add, edit, delete customers |
| **Products** | Inventory management with stock level tracking |
| **Orders** | Order entry with line items and status workflow |
| **Reports** | Order history and inventory reports via DataWindows |

---

## 🗄️ Database Schema Overview

```
customers    — customer master data
products     — product catalog with stock levels
orders       — order header (customer, date, status)
order_items  — order line items (product, qty, price)
users        — app login credentials
```

---

## ⚙️ DB Profile (in PowerBuilder)

```
Profile Name : PBDemoDB
DBMS         : ODBC
DSN          : PBDemoDB
Login ID     : sa   (or your SQL login)
Password     : (your password)
```

---

## 📝 Notes

- All DataWindows use **stored procedures or SQL Select** — easy to swap the backend
- The app uses a **single global Transaction object** (`SQLCA`) configured at login
- Role logic: `admin` sees all menus; `user` role hides delete/admin options
- Compatible with PowerBuilder Classic and PowerBuilder .NET targets

---

## 📄 License

MIT — free to use for demos, training, and internal POCs.
