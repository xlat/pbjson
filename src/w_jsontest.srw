HA$PBExportHeader$w_jsontest.srw
forward
global type w_jsontest from window
end type
type st_status from statictext within w_jsontest
end type
type cb_parse from commandbutton within w_jsontest
end type
type cb_close from commandbutton within w_jsontest
end type
type cbx_retrievetojson from checkbox within w_jsontest
end type
type cb_get_path from commandbutton within w_jsontest
end type
type cb_get_url from commandbutton within w_jsontest
end type
type mle_target from multilineedit within w_jsontest
end type
type st_target from statictext within w_jsontest
end type
type sle_path from singlelineedit within w_jsontest
end type
type st_jspath from statictext within w_jsontest
end type
type mle_json from multilineedit within w_jsontest
end type
type st_json from statictext within w_jsontest
end type
type ddlb_url from dropdownlistbox within w_jsontest
end type
type st_url from statictext within w_jsontest
end type
end forward

global type w_jsontest from window
integer width = 2683
integer height = 1788
boolean titlebar = true
string title = "JSON test app"
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
long backcolor = 67108864
string icon = "WebPBWizard!"
boolean center = true
st_status st_status
cb_parse cb_parse
cb_close cb_close
cbx_retrievetojson cbx_retrievetojson
cb_get_path cb_get_path
cb_get_url cb_get_url
mle_target mle_target
st_target st_target
sle_path sle_path
st_jspath st_jspath
mle_json mle_json
st_json st_json
ddlb_url ddlb_url
st_url st_url
end type
global w_jsontest w_jsontest

type variables
json in_json
end variables

on w_jsontest.create
this.st_status=create st_status
this.cb_parse=create cb_parse
this.cb_close=create cb_close
this.cbx_retrievetojson=create cbx_retrievetojson
this.cb_get_path=create cb_get_path
this.cb_get_url=create cb_get_url
this.mle_target=create mle_target
this.st_target=create st_target
this.sle_path=create sle_path
this.st_jspath=create st_jspath
this.mle_json=create mle_json
this.st_json=create st_json
this.ddlb_url=create ddlb_url
this.st_url=create st_url
this.Control[]={this.st_status,&
this.cb_parse,&
this.cb_close,&
this.cbx_retrievetojson,&
this.cb_get_path,&
this.cb_get_url,&
this.mle_target,&
this.st_target,&
this.sle_path,&
this.st_jspath,&
this.mle_json,&
this.st_json,&
this.ddlb_url,&
this.st_url}
end on

on w_jsontest.destroy
destroy(this.st_status)
destroy(this.cb_parse)
destroy(this.cb_close)
destroy(this.cbx_retrievetojson)
destroy(this.cb_get_path)
destroy(this.cb_get_url)
destroy(this.mle_target)
destroy(this.st_target)
destroy(this.sle_path)
destroy(this.st_jspath)
destroy(this.mle_json)
destroy(this.st_json)
destroy(this.ddlb_url)
destroy(this.st_url)
end on

event open;in_json = create json
end event

event close;destroy in_json
end event

type st_status from statictext within w_jsontest
integer x = 2258
integer y = 252
integer width = 402
integer height = 64
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
boolean focusrectangle = false
end type

type cb_parse from commandbutton within w_jsontest
integer x = 2249
integer y = 136
integer width = 402
integer height = 112
integer taborder = 30
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Parse"
end type

event clicked;string ls_error
st_status.text = ""
ls_error = in_json.parse( mle_json.text )
if ls_error <> "" then
	st_status.text = "Error"
	messagebox("json parse error", ls_error, exclamation!)
else
	st_status.text = "Ok"
end if

end event

type cb_close from commandbutton within w_jsontest
integer x = 2249
integer y = 1576
integer width = 402
integer height = 112
integer taborder = 40
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Close"
boolean cancel = true
end type

event clicked;close( parent )
end event

type cbx_retrievetojson from checkbox within w_jsontest
integer x = 2249
integer y = 1072
integer width = 402
integer height = 80
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "to JSON box"
end type

type cb_get_path from commandbutton within w_jsontest
integer x = 2249
integer y = 940
integer width = 402
integer height = 112
integer taborder = 30
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Retrieve"
end type

event clicked;any la_val
if in_json.retrieve( sle_path.text, ref la_val ) then
	mle_target.text = in_json.toJson( la_val )
	if cbx_retrievetojson.checked then
		mle_json.text = mle_target.text
	end if
else
	messagebox("json retrieve", "key not found!")
end if
end event

type cb_get_url from commandbutton within w_jsontest
integer x = 2249
integer y = 24
integer width = 402
integer height = 112
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Get"
end type

event clicked;string ls_error
if match(ddlb_url.text, ':') then
	ls_error = in_json.parseurl(ddlb_url.text)
else
	ls_error = in_json.parsefile(ddlb_url.text)
end if

if ls_error = "" then
	mle_json.text = in_json.parsedString()
else
	messagebox("json parse error", ls_error, exclamation!)
end if
end event

type mle_target from multilineedit within w_jsontest
integer x = 302
integer y = 1068
integer width = 1938
integer height = 624
integer taborder = 30
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
boolean hscrollbar = true
boolean vscrollbar = true
boolean autohscroll = true
boolean autovscroll = true
borderstyle borderstyle = stylelowered!
boolean ignoredefaultbutton = true
end type

type st_target from statictext within w_jsontest
integer x = 32
integer y = 1088
integer width = 233
integer height = 64
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "Target:"
boolean focusrectangle = false
end type

type sle_path from singlelineedit within w_jsontest
integer x = 302
integer y = 936
integer width = 1938
integer height = 112
integer taborder = 30
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
string text = "bar/1"
borderstyle borderstyle = stylelowered!
end type

type st_jspath from statictext within w_jsontest
integer x = 37
integer y = 948
integer width = 238
integer height = 64
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "JSPATH:"
boolean focusrectangle = false
end type

type mle_json from multilineedit within w_jsontest
integer x = 302
integer y = 136
integer width = 1938
integer height = 776
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
string text = "{ ~"foo~": true, ~"bar~": [ false, 42, null ] }"
boolean hscrollbar = true
boolean vscrollbar = true
boolean autohscroll = true
boolean autovscroll = true
borderstyle borderstyle = stylelowered!
boolean ignoredefaultbutton = true
end type

type st_json from statictext within w_jsontest
integer x = 37
integer y = 148
integer width = 238
integer height = 64
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "JSON:"
boolean focusrectangle = false
end type

type ddlb_url from dropdownlistbox within w_jsontest
integer x = 302
integer y = 28
integer width = 1938
integer height = 884
integer taborder = 10
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
boolean allowedit = true
boolean autohscroll = true
boolean vscrollbar = true
string item[] = {"http://md5.jsontest.com/?text=example_text","http://validate.jsontest.com/?json={~"key~":~"value~"}","http://echo.jsontest.com/key/value/one/two","http://date.jsontest.com","http://time.jsontest.com","http://headers.jsontest.com","http://ip.jsontest.com","big.json"}
borderstyle borderstyle = stylelowered!
end type

type st_url from statictext within w_jsontest
integer x = 37
integer y = 36
integer width = 201
integer height = 64
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
long backcolor = 67108864
string text = "URL:"
boolean focusrectangle = false
end type

