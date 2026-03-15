$PBExportHeader$w_login.srw
$PBExportComments$Login Window

forward
global type w_login from window
end type
end forward

global type w_login from window
  integer width = 3200
  integer height = 2400
  WindowType WindowType = Response!
  string title = "PBDemo ERP — Login"
  boolean Center = true
  boolean TitleBar = false
  boolean ControlMenu = false
  boolean MaxBox = false
  boolean MinBox = false

  /* Controls */
  statictext   st_title
  statictext   st_user
  statictext   st_pass
  singlelineedit sle_username
  singlelineedit sle_password
  commandbutton cb_login
  commandbutton cb_cancel
  statictext   st_version
end type

global w_login w_login

/* ── Window Open ── */
event open();
  st_title.text   = "PBDemo ERP System"
  st_user.text    = "Username:"
  st_pass.text    = "Password:"
  sle_password.Password = True
  cb_login.text   = "&Login"
  cb_cancel.text  = "&Exit"
  st_version.text = "Version 1.0  |  © 2025 PBDemo"

  // Connect DB early to verify DSN
  CONNECT USING SQLCA;
  IF SQLCA.SQLCode <> 0 THEN
    MessageBox("Connection Error", &
      "Cannot connect to database." + &
      "~nPlease check ODBC DSN 'PBDemoDB'." + &
      "~n~nDetail: " + SQLCA.SQLErrText, &
      StopSign!, OKButton!)
  END IF
end event

/* ── Login button ── */
event clicked() for cb_login;
  string ls_user, ls_pass, ls_hash
  string ls_fullname, ls_role
  integer li_userid

  ls_user = Trim(sle_username.Text)
  ls_pass = Trim(sle_password.Text)

  IF ls_user = "" OR ls_pass = "" THEN
    MessageBox("Validation", "Please enter username and password.", Exclamation!)
    RETURN
  END IF

  // Hash password (SHA256 — use gf_sha256 global function)
  ls_hash = gf_sha256(ls_pass)

  // Call stored procedure
  SELECT user_id, full_name, role
    INTO :li_userid, :ls_fullname, :ls_role
    FROM users
    WHERE username     = :ls_user
      AND password_hash = :ls_hash
      AND is_active    = 1
    USING SQLCA;

  IF SQLCA.SQLCode = 0 AND li_userid > 0 THEN
    // Store in global variables
    gnv_app.i_user_id   = li_userid
    gnv_app.s_username  = ls_user
    gnv_app.s_fullname  = ls_fullname
    gnv_app.s_role      = ls_role

    // Update last login
    UPDATE users SET last_login = GETDATE()
      WHERE user_id = :li_userid USING SQLCA;
    COMMIT USING SQLCA;

    Close(This)
    Open(w_main)
  ELSE
    MessageBox("Login Failed", &
      "Invalid username or password.~nPlease try again.", &
      Exclamation!, OKButton!)
    sle_password.Text = ""
    sle_password.SetFocus()
  END IF
end event

/* ── Cancel / Exit button ── */
event clicked() for cb_cancel;
  DISCONNECT USING SQLCA;
  Halt
end event

/* ── Allow Enter key on password field ── */
event key() for sle_password;
  IF Key = KeyEnter! THEN
    cb_login.TriggerEvent("clicked")
  END IF
end event
