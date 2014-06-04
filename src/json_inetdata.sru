HA$PBExportHeader$json_inetdata.sru
forward
global type json_inetdata from internetresult
end type
end forward

global type json_inetdata from internetresult
end type
global json_inetdata json_inetdata

type variables
private blob ibl_data
end variables

forward prototypes
public function integer internetdata (blob data)
public function string getstringdata ()
public function blob getdata ()
public function string getstringdata (encoding encodingtype)
end prototypes

public function integer internetdata (blob data);ibl_data = data
return 1
end function

public function string getstringdata ();return string( ibl_data, encodingansi! )
end function

public function blob getdata ();return ibl_data
end function

public function string getstringdata (encoding encodingtype);return string( ibl_data, encodingtype )
end function

on json_inetdata.create
call super::create
TriggerEvent( this, "constructor" )
end on

on json_inetdata.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

