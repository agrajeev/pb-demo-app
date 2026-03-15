$PBExportHeader$n_app_session.sru
$PBExportComments$Global Application Session NVO — holds login state

forward
global type n_app_session from nonvisualobject
end type
end forward

global type n_app_session from nonvisualobject
end type

/* ─── Instance Variables ─── */
long    i_user_id
string  s_username
string  s_fullname
string  s_role
datetime idt_login_time

on n_app_session.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_app_session.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event constructor();
  i_user_id = 0
  s_username = ""
  s_fullname = ""
  s_role     = "user"
  idt_login_time = Now()
end event

function boolean f_is_admin();
  RETURN (Lower(s_role) = "admin")
end function

function string f_display_name();
  RETURN s_fullname + " (" + s_username + ")"
end function

/* ──────────────────────────────────────────
   Declare global instance in pbdemo.sra:
     gnv_app   n_app_session
   ────────────────────────────────────────── */
