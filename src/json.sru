HA$PBExportHeader$json.sru
forward
global type json from nonvisualobject
end type
type json_pair from structure within json
end type
type jsonparser_state from structure within json
end type
end forward

type json_pair from structure
	string		name
	any		value
end type

type jsonparser_state from structure
	integer		state
	json		obj
	string pair_name
	any		ary[]
	boolean		elt_pending
end type

shared variables
string ss_dec_sep, ss_dec_not_sep
end variables

global type json from nonvisualobject
end type
global json json

type variables
private:
	any ia_value
	json_pair pairs[]
	string pair_index
	string parsed_string
end variables

forward prototypes
public function string parse (readonly string as_json)
public subroutine setattribute (readonly string as_name, readonly any aa_value)
public subroutine setnull ()
public subroutine settrue ()
public subroutine setfalse ()
public subroutine setarray (readonly any ary)
public function string error (readonly string as_json, readonly long al_index, readonly string as_error)
public subroutine setnumber (readonly decimal number)
public subroutine setobject (readonly json object)
public subroutine setstring (readonly string str)
public function boolean isnull ()
public function boolean isstring ()
public function boolean isnumber ()
public function boolean isobject ()
public function boolean isarray ()
public function boolean isbool ()
public function string tostring (readonly string str)
public function boolean isarray (readonly any value)
public function boolean isbool (readonly any value)
public function boolean isnumber (any value)
public function boolean isobject (any value)
public function boolean isstring (any value)
public function any getattribute (readonly string as_name)
public function long getattributes (ref string as_names[])
public function decimal tonumber (string str)
public function string dectostring (readonly decimal value)
public function boolean getbool ()
public function string getstring ()
public function decimal getnumber ()
public function any getarray ()
public function long getarray (ref any ary[])
public function json getobject ()
private subroutine _init ()
public function any getvalue ()
public function boolean retrieve (readonly string key, ref any value)
public function any getarrayelement (any ary[], long index)
public function any getobjectattribute (json object, string as_name)
private function boolean retrieve (readonly any value, string path, ref any value_out)
public function boolean isobjectattributepresent (readonly json object, readonly string as_name)
public function boolean isattibutepresent (readonly string as_name)
public function string parsedstring ()
public function long findpairindex (readonly string as_name)
public function string tojson (any value)
public function string tojson ()
public function string parseurl (readonly string as_url)
public function string parsefile (readonly string as_filename)
end prototypes

public function string parse (readonly string as_json);//Parse as_json as a json input and fill current object to reflect parsed structure
//Return an empty string on success, otherwhise it contain parse error message.
//Parser variables

long i, size
constant int STATE_VAL = 0
constant int STATE_OBJ = 1
constant int STATE_ARY = 2
constant int STATE_STR = 3
constant int STATE_NUM = 4
constant int STATE_TRU = 5
constant int STATE_FAL = 6
constant int STATE_NIL = 7
jsonparser_state states[], state
states[1] = state
states[1].state = STATE_VAL
parsed_string = as_json
long sidx = 1
size = len(as_json)
string int_type = ''
char c
//temp accumulator vars
string str = ""
any new_ary[]
any value
boolean ignore_next = false	//str: a char is being escaped

_init( )
//main loop
for i = 1 to size
	c = mid(as_json,i,1)
	if sidx<1 then sidx=1//to consume trailing whitespaces
	if states[sidx].state<>STATE_STR then
		//skip whitechars
		if c=' ' or c='~r' or c='~n' or c='~t' then
			continue
		end if
	end if
	choose case states[sidx].state
		case STATE_VAL
			choose case c
				case '{'
					states[sidx].state = STATE_OBJ
					states[sidx].obj = create json
					states[sidx].pair_name = ""
				case '['
					states[sidx].state = STATE_ARY
					states[sidx].ary[] = new_ary[]
				case '"'
					states[sidx].state = STATE_STR
					str = ""
				case '0' to '9', '-'
					i --
					states[sidx].state = STATE_NUM
					int_type=''
					str = ""
				case 'n'
					if mid(as_json,i,4)='null' then
						states[sidx].state = STATE_NIL
						i+=3
						setnull(value)
					else
						return error(as_json,i,"unexpexted token")
					end if
				case 't'
					if mid(as_json,i,4)='true' then
						states[sidx].state = STATE_TRU
						i+=3
						value=true
					else
						return error(as_json,i,"unexpexted token")
					end if
				case 'f'
					if mid(as_json,i,5)='false' then
						states[sidx].state = STATE_FAL
						i+=4
						value = false
					else
						return error(as_json,i,"unexpexted token")
					end if
			end choose
		case STATE_OBJ		
			choose case c
				case '}'
					if states[sidx].pair_name<>"" then
						states[sidx].obj.setattribute( states[sidx].pair_name, value)
						states[sidx].pair_name = ""
					end if
					value = states[sidx].obj
					sidx --
				case '"'
					sidx ++
					states[sidx].state = STATE_STR
					str = ""
				case ','
					states[sidx].obj.setattribute( states[sidx].pair_name, value)
					states[sidx].pair_name = ""
					//TODO: assert next non whitechar is a "
				case ':'
					states[sidx].pair_name = str
					sidx ++
					states[sidx].state = STATE_VAL
			end choose
		case STATE_ARY
			choose case c
				case ']'
					if states[sidx].elt_pending then
						states[sidx].ary[upperbound(states[sidx].ary[])+1] = value
						states[sidx].elt_pending = false
					end if
					value = states[sidx].ary[]
					sidx --
				case ','
					states[sidx].ary[upperbound(states[sidx].ary[])+1] = value
					states[sidx].elt_pending = false
				case else
					i --
					states[sidx].elt_pending = true
					sidx ++
					states[sidx].state = STATE_VAL
			end choose
		case STATE_STR
			choose case c
				case '"'
					if ignore_next then
						str += string(c)
					else
						value = str
						sidx --
					end if
				case '\'
					//ignore char
					ignore_next = true
				case else
					if ignore_next then
						ignore_next = false
						choose case c
							case 'u'
								string ls_hexa_value
								ls_hexa_value = upper(mid(as_json, i + 1, 4))
								if match(ls_hexa_value,"[0-9A-F]") then
									ulong unicode_value = asc('?')
									//build matching char
									//unicode_value = fromhexa(ls_hexa_value)
									//SignalError(42, "UNICODE escapement not implemented yet!")
									constant string hex="0123456789ABCDEF"
									unicode_value  = pos(hex,mid(ls_hexa_value,1,1)) -1
									unicode_value *= 16
									unicode_value += pos(hex,mid(ls_hexa_value,2,1)) -1
									unicode_value *= 16
									unicode_value += pos(hex,mid(ls_hexa_value,3,1)) -1
									unicode_value *= 16
									unicode_value += pos(hex,mid(ls_hexa_value,4,1)) -1
									str += string(char(unicode_value))
									i+=4
								else
									return error(as_json,i,"unexpected token")
								end if
							case /*'"',*/ '\', '/', 'b', 'f', 'n', 'r', 't'
								str += string(c)
							case else
								return error(as_json,i,"unexpected token")
						end choose
					else
						str += string(c)
						ignore_next = false
					end if
			end choose
		case STATE_NUM
			choose case c
				case '+'
					if int_type<>'e' then
						return error(as_json,i,"unexpected token")
					end if
					int_type+='+'
					str += string(c)
				case '-'
					if int_type='e' then
						int_type+='-'
					elseif int_type='e-' or int_type='e+' or int_type='ed' then
						return error(as_json,i,"unexpected token")
					end if
					str += string(c)
				case '0'
					if int_type='' then
						int_type='0'
					end if
					str += string(c)
				case '.'
					if match(int_type,'[.e]') then
						return error(as_json,i,"unexpected token")
					end if
					int_type='.'
					str += string(c)
				case 'e', 'E'
					if left(int_type,1)='e' then
						return error(as_json,i,"unexpected token")
					end if
					int_type='e'					
					str += string(c)
				case '1' to '9'
					choose case int_type
						case '0'
							return error(as_json,i,"unexpected token")
						case '.', '', 'd', 'e', 'e-', 'e+', 'ed'
							if int_type='' then
								int_type = 'd'
							elseif left(int_type,1)='e' then
								int_type = 'ed'
							end if
							str += string(c)
					end choose
				case else
					//end of int
					value = toNumber(str)
					i --
					sidx --
			end choose
		case STATE_FAL, STATE_TRU, STATE_NIL
			//resync
			sidx --
			i --
		case else
			return error(as_json,i,"Expected state: "+string(states[sidx])+"!")
	end choose
next

//set(value)
choose case states[1].state
	case STATE_OBJ
		setObject(states[1].obj)
	case STATE_ARY
		setArray(states[1].ary[])
	case STATE_STR
		setString(str)
	case STATE_NUM
		setNumber(toNumber(str))
	case STATE_TRU
		setTrue()
	case STATE_FAL
		setFalse()
	case STATE_NIL
		setNull()
	case else
		return error(as_json,i,"Expected state: "+string(states[1])+"!")
end choose

return ""
end function

public subroutine setattribute (readonly string as_name, readonly any aa_value);long index
index = findpairindex(as_name)
if index < 1 then
	index = 1 + upperbound(pairs[])
	json_pair pair
	pairs[index] = pair
	pairs[index].name = as_name
	pair_index += ";"+as_name+"="+string(index)
end if
pairs[index].value = aa_value
end subroutine

public subroutine setnull ();setnull(ia_value)
end subroutine

public subroutine settrue ();ia_value = true
end subroutine

public subroutine setfalse ();ia_value = false
end subroutine

public subroutine setarray (readonly any ary);ia_value = ary
end subroutine

public function string error (readonly string as_json, readonly long al_index, readonly string as_error);//error(as_json,i,"unexpexted token")
string ls_near
long ll_end
ll_end = len(as_json)
if ll_end > al_index+40 then
	ll_end = al_index+40
end if
ls_near = mid(as_json,al_index,ll_end)
return "Syntax Error: " + as_error + " at pos "+string(al_index)+" near "+ls_near
end function

public subroutine setnumber (readonly decimal number);ia_value = number
end subroutine

public subroutine setobject (readonly json object);ia_value = object
end subroutine

public subroutine setstring (readonly string str);ia_value = str
end subroutine

public function boolean isnull ();return isnull(ia_value)
end function

public function boolean isstring ();return classname(ia_value)='string'
end function

public function boolean isnumber ();return classname(ia_value)='decimal'
end function

public function boolean isobject ();return classname(ia_value)='json'
end function

public function boolean isarray ();return classname(ia_value)='any'
end function

public function boolean isbool ();return classname(ia_value)='boolean'
end function

public function string tostring (readonly string str);//format a string to json string format
string ls_string
//TODO: does not handle \u, \r, \n, etc... chars : need to use pos/mid/replace...
ls_string = '"'+str+'"'
return ls_string
end function

public function boolean isarray (readonly any value);return classname(value)='any'
end function

public function boolean isbool (readonly any value);return classname(value)='boolean'
end function

public function boolean isnumber (any value);return classname(value)='decimal'
end function

public function boolean isobject (any value);return classname(value)='json'
end function

public function boolean isstring (any value);return classname(value)='string'
end function

public function any getattribute (readonly string as_name);long index
index = findpairindex(as_name)
if index = 0 then
	SignalError(42,"JSON.getAttribute: attribute "+string(as_name,"[general]")+" does not exists!")
	return "!ERROR!"
end if
return pairs[index].value
end function

public function long getattributes (ref string as_names[]);long i, size
size = upperbound( pairs[] )
if size > 0 then
	for i = size to 1 step -1
		as_names[i] = pairs[i].name
	next
else
	string ls_empty[]
	as_names[] = ls_empty[]
end if
return size
end function

public function decimal tonumber (string str);long p
p = pos(str,ss_dec_not_sep)
if p > 0 then
	str = replace(str,p,len(ss_dec_not_sep),ss_dec_sep)
end if
return dec(str)
end function

public function string dectostring (readonly decimal value);string str
str = string(value)
if ss_dec_sep<> '.' then
	long p
	p = pos( str, ss_dec_sep )
	if p > 0 then
		str = replace( str, p, 1, '.' )
	end if
end if

return str
end function

public function boolean getbool ();return ia_value
end function

public function string getstring ();return ia_value
end function

public function decimal getnumber ();return ia_value
end function

public function any getarray ();return ia_value
end function

public function long getarray (ref any ary[]);ary[] = ia_value
return upperbound(ary[])
end function

public function json getobject ();return ia_value
end function

private subroutine _init ();json_pair no_pairs[]
pairs[] = no_pairs[]
pair_index=""
setnull(ia_value)
end subroutine

public function any getvalue ();return ia_value
end function

public function boolean retrieve (readonly string key, ref any value);return retrieve( ia_value, key, ref value )
end function

public function any getarrayelement (any ary[], long index);return ary[index]
end function

public function any getobjectattribute (json object, string as_name);return object.getAttribute(as_name)
end function

private function boolean retrieve (readonly any value, string path, ref any value_out);long p1, p2, p3, fix = 0
string key
if left(path,1)='[' then
	p2 = pos(path,']')
	p1 = 2
else
	p2 = pos(path,'/')
	p3 = pos(path,'[')	//allow syntaxic sugar: bar[1]
	if p2 = 0 then 
		p2 = len(path) + 1
	end if
	if p3>0 and p3 < p2 then
		p2 = p3
		fix = -1
	end if
	p1 = 1
end if
key = mid(path, p1, p2 - p1)
path =mid(path, p2 + 1 + fix)
if isArray( value ) then
	long index
	index = long( key )
	if index < 1 or index > upperbound( value ) then
		return false
	end if
	value_out = getArrayElement(value, index)	
elseif isObject( value ) then
	if not isObjectAttributePresent(value, key) then
		return false
	end if
	value_out = getObjectAttribute( value, key )
else
	return false
end if
if path = "" then
	return true
end if
return retrieve( value_out, path, ref value_out )
end function

public function boolean isobjectattributepresent (readonly json object, readonly string as_name);return object.isAttibutePresent(as_name)
end function

public function boolean isattibutepresent (readonly string as_name);return findpairindex(as_name) > 0
end function

public function string parsedstring ();return parsed_string
end function

public function long findpairindex (readonly string as_name);long p1, p2, index

p1 = pos( pair_index, ';'+as_name + "=" )
if p1 < 1 then
	return 0
end if
p1 += 2 + len(as_name)
p2 = pos(pair_index,';',p1)
if p2 < 1 then 
	p2 = len( pair_index ) + 1
end if
index = long( mid( pair_index, p1, p2 - p1 ) )
return index
end function

public function string tojson (any value);//return the json serialised string of the current json value
string ls_json
long i, size
if isNull(value) then return 'null'
if isString(value) then return toString(value)
if isNumber(value) then return decToString(value)
if isBool(value) then return string(value)
if isArray(value) then 
	any ary[]
	ary[] = value
	size = upperbound( ary[] )
	ls_json = "[ "
	for i = 1 to size
		ls_json += tojson( ary[i] )
		if i < size then
			ls_json += ", "
		end if
	next
	ls_json += "]"
	return ls_json
end if
if NOT isObject(value) then
	SignalError(42, "to_json: unknow value type!" )
end if
ls_json = "{ "
string ls_names[]
json obj
obj = value
size = obj.getAttributes(ref ls_names[])
for i = 1 to size
	ls_json += toString( ls_names[i] ) + ': '
	ls_json += tojson( obj.getAttribute(ls_names[i]) )
	if i < size then
		ls_json += ", "
	end if
next
ls_json += "}"
return ls_json
end function

public function string tojson ();return tojson( ia_value )
end function

public function string parseurl (readonly string as_url);string ls_json
inet linet
if getContextservice( "internet", ref linet) = 1 then
	json_inetdata linetdata
	linetdata = create json_inetdata
	if linet.getUrl( as_url, ref linetdata ) = 1 then
		ls_json = linetdata.getStringdata( )
		destroy linetdata
		destroy linet
		return parse( ls_json )
	end if
	destroy linetdata
end if
destroy linet
return "Error retrieving url"
end function

public function string parsefile (readonly string as_filename);string ls_json, ls_error
long ll_handle
if not FileExists(as_filename) then
	return "File not found"
end if
ll_handle = fileopen(as_filename, textmode! )
if ll_handle > 0 then
	if FileReadEx( ll_handle, ref ls_json ) > 0 then
		ls_error = parse( ls_json )
	else
		ls_error = "Error reading file"
	end if
	fileclose( ll_handle )
else
	ls_error = "Error reading file"
end if
return ls_error
end function

on json.create
call super::create
TriggerEvent( this, "constructor" )
end on

on json.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event constructor;if ss_dec_sep = '' then
	ss_dec_sep = mid(string(1.1),2,1)
	//does not handle other decimal separator than . and ,
	if ss_dec_sep = ',' then
		ss_dec_not_sep = '.'
	else
		ss_dec_not_sep = ','
	end if
end if

_init()
end event

