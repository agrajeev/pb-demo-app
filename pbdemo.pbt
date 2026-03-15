$PBExportHeader$pbdemo.pbt
$PBExportComments$PowerBuilder Demo ERP Application Target

; PowerBuilder Target Configuration
; Application: PBDemo ERP
; Version: 1.0
; Target Type: Application

[Target]
LibraryList=pbdemo.pbl
DefaultLibrary=pbdemo.pbl
ApplicationObject=pbdemo

[Database]
DBMS=ODBC
DBParm=ConnectString='DSN=PBDemoDB'
LogID=sa
AutoCommit=false
