$PBExportHeader$w_reports.srw
$PBExportComments$Reports Window — print preview and export

forward
global type w_reports from window
end type
end forward

global type w_reports from window
  integer width  = 7000
  integer height = 5200
  WindowType WindowType = Child!
  string title = "Reports"

  /* Report selector */
  radiobutton  rb_order_history
  radiobutton  rb_inventory

  /* Date range (for order history) */
  statictext      st_from
  singlelineedit  sle_date_from
  statictext      st_to
  singlelineedit  sle_date_to

  /* Buttons */
  commandbutton   cb_preview
  commandbutton   cb_print
  commandbutton   cb_export_excel
  commandbutton   cb_export_pdf

  /* Preview DataWindow */
  datawindow      dw_report
end type

global w_reports w_reports

event open();
  rb_order_history.Text  = "Order History by Customer"
  rb_inventory.Text      = "Inventory Status"
  rb_order_history.Checked = True

  st_from.Text = "From:"
  st_to.Text   = "To:"
  sle_date_from.Text = String(RelativeDate(Today(), -30), "mm/dd/yyyy")
  sle_date_to.Text   = String(Today(), "mm/dd/yyyy")

  cb_preview.Text       = "Preview"
  cb_print.Text         = "Print"
  cb_export_excel.Text  = "Export Excel"
  cb_export_pdf.Text    = "Export PDF"

  dw_report.SetTransObject(SQLCA)
end event

/* ── Toggle date range visibility based on report type ── */
event clicked() for rb_order_history;
  sle_date_from.Enabled = True
  sle_date_to.Enabled   = True
end event

event clicked() for rb_inventory;
  sle_date_from.Enabled = False
  sle_date_to.Enabled   = False
end event

/* ── Preview ── */
event clicked() for cb_preview;
  of_run_report()
end event

/* ── Print ── */
event clicked() for cb_print;
  IF of_run_report() THEN
    dw_report.Print(False)
  END IF
end event

/* ── Export to Excel ── */
event clicked() for cb_export_excel;
  IF of_run_report() THEN
    string ls_file
    ls_file = "C:\Temp\PBDemo_Report_" + String(Now(), "YYYYMMDD_HHMMSS") + ".xlsx"
    gf_dw_to_excel(dw_report, ls_file)
  END IF
end event

/* ── Export to PDF ── */
event clicked() for cb_export_pdf;
  IF of_run_report() THEN
    string ls_file
    ls_file = "C:\Temp\PBDemo_Report_" + String(Now(), "YYYYMMDD_HHMMSS") + ".pdf"
    integer li_rc
    li_rc = dw_report.SaveAs(ls_file, PDF!, True)
    IF li_rc = 1 THEN
      MessageBox("Export", "PDF saved to:~n" + ls_file, Information!)
    ELSE
      MessageBox("Export Error", "Could not save PDF.", StopSign!)
    END IF
  END IF
end event

function boolean of_run_report();
  IF rb_order_history.Checked THEN
    date ld_from, ld_to
    ld_from = Date(sle_date_from.Text)
    ld_to   = Date(sle_date_to.Text)
    IF NOT gf_date_range_validate(ld_from, ld_to) THEN RETURN False
    dw_report.DataObject = "d_report_order_history"
    dw_report.Retrieve(ld_from, ld_to)
  ELSE
    dw_report.DataObject = "d_report_inventory"
    dw_report.Retrieve()
  END IF

  IF gf_db_error_check("Reports - Retrieve") THEN RETURN False
  RETURN True
end function
