$PBExportHeader$pbdemo.sra
$PBExportComments$Application Object — PBDemo ERP

forward
global type pbdemo from application
end type
end forward

global type pbdemo from application
end type

global pbdemo pbdemo

on pbdemo.create
call super::create
TriggerEvent( this, "constructor" )
end on

on pbdemo.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

/* ──────────────────────────────────────────────────────────
   Application Open event
   ────────────────────────────────────────────────────────── */
event open(commandline string);

// Set application defaults
this.MicroHelpDefault = "Ready"
this.ToolbarFrameTitle = "PB Demo ERP"

// Initialise global DB transaction
SQLCA.DBMS     = "ODBC"
SQLCA.DBParm   = "ConnectString='DSN=PBDemoDB'"
SQLCA.AutoCommit = False

// Show login window — application flow starts there
Open(w_login)

end event

/* ──────────────────────────────────────────────────────────
   Application SystemError event — global error handler
   ────────────────────────────────────────────────────────── */
event systemerror(object pObject, string pMethodName, string pErrorText, ref boolean pAbort);

string ls_msg
ls_msg = "An unexpected error occurred:" + &
         "~n~nObject : " + pObject.ClassName() + &
         "~nMethod : " + pMethodName + &
         "~nError  : " + pErrorText

MessageBox("System Error", ls_msg, StopSign!, OKButton!)
pAbort = True

end event
