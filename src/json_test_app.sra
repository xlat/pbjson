HA$PBExportHeader$json_test_app.sra
$PBExportComments$Generated Application Object
forward
global type json_test_app from application
end type
global transaction sqlca
global dynamicdescriptionarea sqlda
global dynamicstagingarea sqlsa
global error error
global message message
end forward

global type json_test_app from application
string appname = "json_test_app"
end type
global json_test_app json_test_app

on json_test_app.create
appname="json_test_app"
message=create message
sqlca=create transaction
sqlda=create dynamicdescriptionarea
sqlsa=create dynamicstagingarea
error=create error
end on

on json_test_app.destroy
destroy(sqlca)
destroy(sqlda)
destroy(sqlsa)
destroy(error)
destroy(message)
end on

event open;open( w_jsontest )
end event

