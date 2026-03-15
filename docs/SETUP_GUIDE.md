# Setup Guide — PBDemo ERP

## Step-by-Step Setup

---

### Step 1: Clone the Repository

```bash
git clone https://github.com/your-org/pb-demo-app.git
cd pb-demo-app
```

---

### Step 2: SQL Server — Create the Database

Open **SQL Server Management Studio (SSMS)** or `sqlcmd` and run the scripts in order:

```bash
sqlcmd -S localhost -E -i "database/schema/01_create_database.sql"
sqlcmd -S localhost -E -i "database/schema/02_create_tables.sql"
sqlcmd -S localhost -E -i "database/schema/03_create_indexes.sql"
sqlcmd -S localhost -E -i "database/sampledata/04_insert_customers.sql"
sqlcmd -S localhost -E -i "database/sampledata/05_insert_products.sql"
sqlcmd -S localhost -E -i "database/sampledata/06_insert_orders.sql"
```

> If using Windows Authentication change `-E` to `-U sa -P <password>`

---

### Step 3: Create the ODBC DSN

1. Open **ODBC Data Sources (64-bit)** from Windows Control Panel
2. Click **System DSN → Add**
3. Select: `ODBC Driver 17 for SQL Server`
4. Fill in:

| Field | Value |
|---|---|
| Name | `PBDemoDB` |
| Description | PB Demo ERP Database |
| Server | `localhost` or `.\SQLEXPRESS` |

5. Authentication: choose **SQL Server** or **Windows** as appropriate
6. Database: `PBDemoDB`
7. Click **Test Data Source** — should say *TESTS COMPLETED SUCCESSFULLY*

---

### Step 4: Open in PowerBuilder IDE

1. Launch PowerBuilder 2019 R3 / 2022
2. **File → Open Workspace** → select `pbdemo.pbw`
3. In the System Tree, expand **pbdemo** target
4. Right-click target → **Properties** → **Database** tab
5. Verify or update the DB profile:
   - DBMS: `ODBC`
   - DBParm: `ConnectString='DSN=PBDemoDB'`
   - Login ID / Password: as per your SQL Server auth

6. Hit **F5** (or click the Run button) → Login screen appears

---

### Step 5: Login

| Username | Password | Role |
|---|---|---|
| `admin` | `demo1234` | Admin (full access) |
| `jsmith` | `demo1234` | User |
| `mjones` | `demo1234` | User |

---

### Step 6: Rebuild PBLs (first time)

If you see "Object not found" errors:

1. Right-click the library (`pbdemo.pbl`) in the System Tree
2. **Regenerate** → select all objects → OK

This compiles all source files into the PBL.

---

## DB Profile Quick Reference

```
Profile Name  : PBDemoDB
DBMS          : ODBC
DBParm        : ConnectString='DSN=PBDemoDB'
LogID         : sa
AutoCommit    : false
```

---

## Pushing to Git

```bash
git init
git remote add origin https://github.com/your-org/pb-demo-app.git
git add .
git commit -m "Initial PBDemo ERP codebase"
git push -u origin main
```

The `.gitignore` is pre-configured to exclude `.pbl` binaries and IDE temp files, while committing all source files (`.srw`, `.srd`, `.sru`, `.srm`, `.srf`, `.sra`) and SQL scripts.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Cannot connect — DSN not found | Re-check ODBC System DSN name is exactly `PBDemoDB` |
| Login fails | Re-run script `04_insert_customers.sql`, verify `users` table has rows |
| Object not found in PBL | Right-click PBL → Regenerate all |
| DataWindow shows no data | Confirm stored procedures and views were created (script 03) |
| Export to Excel fails | Ensure `C:\Temp` directory exists or change path in `gf_dw_to_excel` |
