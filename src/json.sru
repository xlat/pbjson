$PBExportHeader$json.sru
forward
global type json from internetresult
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
	string		pair_name
	any		ary[]
	boolean		elt_pending
end type

shared variables
string ss_dec_sep, ss_dec_not_sep
end variables

global type json from internetresult
end type
global json json

type variables
private:
	any ia_value
	json_pair pairs[]
	string pair_index
	string parsed_string
	blob ibl_data			//for retrieve data from url
end variables

forward prototypes
public function string parse (readonly string as_json)
public function boolean isnull ()
public function boolean isstring ()
public function boolean isnumber ()
public function boolean isobject ()
public function boolean isarray ()
public function boolean isbool ()
public function boolean isarray (readonly any value)
public function boolean isbool (readonly any value)
public function boolean isnumber (any value)
public function boolean isobject (any value)
public function boolean isstring (any value)
public function any getattribute (readonly string as_name)
public function long getattributes (ref string as_names[])
public function decimal tonumber (string str)
public function boolean getbool ()
public function string getstring ()
public function decimal getnumber ()
public function any getarray ()
public function long getarray (ref any ary[])
public function any getvalue ()
public function boolean retrieve (readonly string key, ref any value)
public function any getarrayelement (any ary[], long index)
public function any getobjectattribute (json object, string as_name)
private function boolean retrieve (readonly any value, string path, ref any value_out)
public function boolean isobjectattributepresent (readonly json object, readonly string as_name)
public function boolean isattibutepresent (readonly string as_name)
public function string parsedstring ()
public function string tojson (any value)
public function string tojson ()
public function string parseurl (readonly string as_url)
public function string parsefile (readonly string as_filename)
public function integer internetdata (blob data)
public function string getstringdata ()
public function blob getdata ()
public function string getstringdata (encoding encodingtype)
public function string parse (readonly string as_json, boolean ab_relaxed)
public function string parsefile (readonly string as_filename, boolean ab_relaxed)
public function string parseurl (readonly string as_url, boolean ab_relaxed)
public function string tostring (readonly character str[])
protected function string dectostring (readonly decimal value)
protected subroutine _init ()
protected function string error (readonly string as_json, readonly long al_index, readonly string as_error)
protected function long findpairindex (readonly string as_name)
public function boolean update (string path, any new_value)
private function boolean update (any value, string path, any value_out, any new_value)
public function json getobject ()
public function boolean getobjects (string as_name, ref json an_objects[])
public function json setarray (readonly any ary[])
public function json setarrayelement (long index, any new_value)
protected function json setarrayelement (ref any ary[], long index, any new_value)
public function json setfalse ()
public function json setnull ()
public function json setnumber (readonly decimal number)
public function json setobject ()
public function json setstring (readonly string str)
public function json settrue ()
public function json setobject (readonly json object)
public function json setattribute (readonly string as_name, readonly any aa_value)
public function json setattribute (readonly string as_name, readonly any aa_value, readonly string as_str_fmt)
public function json newroot ()
public function json new (any aa_value)
public function json newobject ()
public function json newarray ()
public function json push (any la_value)
public function json setarray ()
public function json pushto (json la_ary, any la_value)
end prototypes

public function string parse (readonly string as_json);return parse(as_json, false)
end function

public function boolean isnull ();return isnull(ia_value)
end function

public function boolean isstring ();return isstring(ia_value)
end function

public function boolean isnumber ();return isnumber(ia_value)
end function

public function boolean isobject ();return isobject(ia_value)
end function

public function boolean isarray ();return isarray(ia_value)
end function

public function boolean isbool ();return isbool(ia_value)
end function

public function boolean isarray (readonly any value);if upperbound(value) > 0 then return true
if lowerbound(value) = 1 and upperbound(value) = 0 then return true	//empty array
//return classname(value)='any'
return false

end function

public function boolean isbool (readonly any value);return classname(value)='boolean'
end function

public function boolean isnumber (any value);choose case classname(value)
	case 'decimal', 'double', 'real', 'dec', &
			'long', 'longlong', 'longptr', &
			'integer', 'unsignedlong', 'unsignedinteger', &
			'uint', 'ulong', 'unsginedint'
		return true
end choose

return false
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

public function any getvalue ();return ia_value
end function

public function boolean retrieve (readonly string key, ref any value);return retrieve( ia_value, key, ref value )
end function

public function any getarrayelement (any ary[], long index);if index > upperbound(ary[]) then
	//allow autovivication
	any undef
	setnull(undef)
	ary[index] = undef
end if
return ary[index]
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

public function string tojson (any value);//return the json serialised string of the current json value
string ls_json
long i, size

if isNull(value) then return 'null'

if classname(value) = "json" then
	json ln_tmp
	ln_tmp = value
	if ln_tmp.isArray() then
		return ln_tmp.toJson()
	end if
end if

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

if isString(value) then return toString(string(value))
if isNumber(value) then return decToString(dec(value))
if isBool(value) then return string(value)

if NOT isObject(value) then
	SignalError(42, "to_json: unknow value type!" )
end if
ls_json = "{ "
string ls_names[]
if classname(value)="json" then
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
else
	SignalError(42, "tojson: incompatible object type `" + classname(value) + "`")
end if
ls_json += "}"
return ls_json
end function

public function string tojson ();return tojson( ia_value )
end function

public function string parseurl (readonly string as_url);return parseurl(as_url, false)
end function

public function string parsefile (readonly string as_filename);return parsefile(as_filename, false)
end function

public function integer internetdata (blob data);ibl_data = data
return 1
end function

public function string getstringdata ();return string( ibl_data, encodingansi! )
end function

public function blob getdata ();return ibl_data
end function

public function string getstringdata (encoding encodingtype);return string( ibl_data, encodingtype )
end function

public function string parse (readonly string as_json, boolean ab_relaxed);//Parse as_json as a json input and fill current object to reflect parsed structure
//If ab_relaxed is true is allow to parse relaxed syntax ( single quoted string, javascript comments )
//Return an empty string on success, otherwhise it contain parse error message.
//Parser variables

long i, size, j
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
char c, string_delim = '"'
string expected_tokens = ''
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
					expected_tokens =  char(34) + char(39)
				case '['
					states[sidx].state = STATE_ARY
					states[sidx].ary[] = new_ary[]
				case "'"//single quote
					if ab_relaxed then					
						string_delim = c
						states[sidx].state = STATE_STR
						str = ""
					else
						goto label_unexpected_value_char
					end if
				case '"' //double quote
					string_delim = c
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
				case '/'
					if ab_relaxed and mid(as_json,i,2) = '//' then
						j = pos(as_json, '~n', i+2)
						if j > 0 then
							i = j + 1
						else 
							i+=2
						end if
						continue
					elseif mid(as_json,i,2) = '/*' then
						j = pos(as_json, '*/', i+2)
						if j > 0 then
							i = j + 1
						else
							i+=2
						end if
						continue
					else
						return error(as_json,i,"unexpexted token")
					end if
				case else
label_unexpected_value_char:					
					return error(as_json,i,"unexpexted token")
			end choose
		case STATE_OBJ		
			choose case c
				case '}'
					if states[sidx].pair_name<>"" then
						states[sidx].obj.setattribute( states[sidx].pair_name, value)
						states[sidx].pair_name = ""
					end if
					expected_tokens = ''
					value = states[sidx].obj
					sidx --
				case "'" //single quote
					if ab_relaxed and pos(expected_tokens, c) > 0 then
						sidx ++
						string_delim = c
						states[sidx].state = STATE_STR
						str = ""
						if states[sidx].pair_name = "" then 
							expected_tokens = ':'
						else
							expected_tokens = ','
						end if
					else
						goto label_obj_parse_error
					end if
				case '"' //double quote
					if pos(expected_tokens, c) > 0 then
						sidx ++
						string_delim = c
						states[sidx].state = STATE_STR
						str = ""
						if states[sidx].pair_name = "" then 
							expected_tokens = ':'
						else
							expected_tokens = ','
						end if
					else
						goto label_obj_parse_error
					end if
				case ','
					states[sidx].obj.setattribute( states[sidx].pair_name, value)
					states[sidx].pair_name = ""
					//TODO: assert next non whitechar is a "
					expected_tokens = char(34) + char(39)	//single or double quotes
				case ':'
					states[sidx].pair_name = str
					sidx ++
					states[sidx].state = STATE_VAL
					expected_tokens = ''
				case '/'
					if ab_relaxed and mid(as_json,i,2) = '//' then
						j = pos(as_json, '~n', i+2)
						if j > 0 then
							i = j + 1
						else 
							i+=2
						end if
						continue
					elseif mid(as_json,i,2) = '/*' then
						j = pos(as_json, '*/', i+2)
						if j > 0 then
							i = j + 1
						else
							i+=2
						end if
						continue
					else
						return error(as_json,i,"unexpexted token")
					end if
				case else
label_obj_parse_error:					
					return error(as_json,i,"unexpexted token")
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
				case '/'
					if ab_relaxed and mid(as_json,i,2) = '//' then
						j = pos(as_json, '~n', i+2)
						if j > 0 then
							i = j + 1
						else 
							i+=2
						end if
						continue
					elseif mid(as_json,i,2) = '/*' then
						j = pos(as_json, '*/', i+2)
						if j > 0 then
							i = j + 1
						else
							i+=2
						end if
						continue
					else
						return error(as_json,i,"unexpexted token")
					end if
				case else
					i --
					states[sidx].elt_pending = true
					sidx ++
					states[sidx].state = STATE_VAL
			end choose
		case STATE_STR
			choose case c
				case "'" //single quote
					if ab_relaxed and string_delim = c and NOT ignore_next then
						if ignore_next then
							str += string(c)
						else
							value = str
							sidx --
						end if
					else
						goto label_not_relaxed_string
					end if
				case '"' //double quote
					if ((ab_relaxed and string_delim = c ) or NOT ab_relaxed) and NOT ignore_next then
						if ignore_next then
							str += string(c)
						else
							value = str
							sidx --
						end if
					else
						goto label_not_relaxed_string
					end if
				case '\'
					if ignore_next then goto label_not_relaxed_string
					//ignore char
					ignore_next = true
				case else
label_not_relaxed_string:
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
							case /*'"',*/ '\', '/', "'", '"'
								str += string(c)
							case 'b' ; str += "~h08"
							case 'f' ; str += "~h0C"
							case 'n' ; str += "~n"
							case 'r' ; str += "~r"
							case 't' ; str += "~t"
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

public function string parsefile (readonly string as_filename, boolean ab_relaxed);string ls_json, ls_error
long ll_handle
if not FileExists(as_filename) then
	return "File not found"
end if
ll_handle = fileopen(as_filename, textmode! )
if ll_handle > 0 then
	if FileReadEx( ll_handle, ref ls_json ) > 0 then
		ls_error = parse( ls_json, ab_relaxed )
	else
		ls_error = "Error reading file"
	end if
	fileclose( ll_handle )
else
	ls_error = "Error reading file"
end if
return ls_error
end function

public function string parseurl (readonly string as_url, boolean ab_relaxed);string ls_json
inet linet
if getContextservice( "internet", ref linet) = 1 then
	if linet.getUrl( as_url, this ) = 1 then
		ls_json = this.getStringdata( )
		destroy linet
		return parse( ls_json, ab_relaxed )
	end if
end if
destroy linet
return "Error retrieving url"
end function

public function string tostring (readonly character str[]);//format a string to json string format
char ls_string[], c
long s, size, t = 1
size = upperbound(str[])
ls_string[size+1] = char(0)	//preallocate array (may have additional growing for \)
ls_string[t]='"' ; t++
for s = 1 to size
	c = str[s]
	choose case c
		case  '/' ; ls_string[t] = '\'; ls_string[t+1] = '/'; t++
		case  '\' ; ls_string[t] = '\'; ls_string[t+1] = '\'; t++
		case  '"' ; ls_string[t] = '\'; ls_string[t+1] = '"'; t++
		case "~n" ; ls_string[t] = '\'; ls_string[t+1] = 'n'; t++
		case "~r" ; ls_string[t] = '\'; ls_string[t+1] = 'r'; t++
		case "~t" ; ls_string[t] = '\'; ls_string[t+1] = 't'; t++
		case "~b" ; ls_string[t] = '\'; ls_string[t+1] = 'b'; t++
		case "~f" ; ls_string[t] = '\'; ls_string[t+1] = 'f'; t++
		case else
			//does not handle \uXXXX generation; don't know unicode ranges that should apply.
			ls_string[t] = c
	end choose
	t++
next
ls_string[t]='"'
ls_string[t+1]=char(0)
return string(ls_string[])
end function

protected function string dectostring (readonly decimal value);string str
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

protected subroutine _init ();json_pair no_pairs[]
pairs[] = no_pairs[]
pair_index=""
setnull(ia_value)
end subroutine

protected function string error (readonly string as_json, readonly long al_index, readonly string as_error);//error(as_json,i,"unexpexted token")
string ls_near
long ll_end
ll_end = len(as_json)
if ll_end > al_index+40 then
	ll_end = al_index+40
end if
ls_near = mid(as_json,al_index,ll_end)
return "Syntax Error: " + as_error + " at pos "+string(al_index)+" near "+ls_near
end function

protected function long findpairindex (readonly string as_name);long p1, p2, index

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

public function boolean update (string path, any new_value);any la_val_out
return update( ia_value, path, la_val_out, new_value)
end function

private function boolean update (any value, string path, any value_out, any new_value);long p1, p2, p3, fix = 0
string key, sep_type = ""
any la_new_ary[]
json obj, tmp
json_pair val_ref

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
sep_type =  mid(path, p2, 1)
path =mid(path, p2 + 1 + fix)
if sep_type = "]" then 
	sep_type = left(path, 1)
	path = mid(path, 2)
end if

if classname(value) = "json_pair" then
	//hack in progress ...
	val_ref = value
	obj = val_ref.value
	value = getObjectAttribute(obj, val_ref.name)
end if

if isArray( value ) then
	long index
	index = long( key )
	if index < 1 or index > upperbound( value ) then
		if index < 1 then
			return false
		end if
		//autovivication (perlish)
		if sep_type = "/" then
			tmp = create json
			setArrayElement(ref value, index, tmp)
			if classname(value) = "json_pair" then obj.setAttribute(val_ref.name, value)
		elseif sep_type = "[" then
			setArrayElement(ref value, index, la_new_ary[])
			if classname(value) = "json_pair" then obj.setAttribute(val_ref.name, value)
		end if
	end if
	if path = "" then
		setArrayElement(ref value, index, new_value)
		if classname(value) = "json_pair" then obj.setAttribute(val_ref.name, value)
		return true
	else
		value_out = getArrayElement(value, index)
		if classname(value) = "json_pair" then DebugBreak()	//not handled case...
	end if
elseif isObject( value ) then
	obj = value
	if not isObjectAttributePresent(value, key) then
		//should do autovivication (perlish)
		if path <> "" then
			if sep_type = '/' then
				// eg:  { } and update( obj, 'session/x', ref any_tmp, 142)
				// -> there is no session and path begin with / => should add session as an object
				tmp = create json
				obj.setAttribute(key, tmp)
			elseif sep_type = '[' then
				obj.setAttribute(key, la_new_ary[])
			else
				return false
			end if
		else
			obj.setAttribute(key, new_value)
			return true
		end if
	end if
	if path = "" then
		obj.setAttribute(key, new_value)
		return true
	end if
	//Ca ne peut pas fonctionner ici lorsque l'attribut est un array!
	//car l'array retourné n'est qu'une copie de la valeur de l'attribut de l'objet, et donc toutes modifictions qui suivront dans les appels de update() seront caduques!!!
	//-> il faudrait pouvoir garder une trace de [json:value, key] dans une structure json_ary_ref par exemple, utilisée uniquement pour update( ... )
	value_out = getObjectAttribute( value, key )	
	if isArray(value_out) then
		val_ref.name = key
		val_ref.value = value
		value_out = val_ref
	end if
else
	//unhandled/path error
	return false
end if
if path = "" then
	return true
end if
return update( value_out, path, ref value_out, new_value )
end function

public function json getobject ();return ia_value
end function

public function boolean getobjects (string as_name, ref json an_objects[]);any la_attr, la_ary[]
long i, li_count
json ln_null
ln_null = create json
::setnull(ln_null)
la_attr = getattribute(as_name)
if isarray(la_attr) then
	la_ary[] = la_attr
	li_count = upperbound(la_ary[])	
	for i = li_count to 1 step -1
		if IsObject(la_ary[i]) then
			an_objects[i] = la_ary[i]
		else
			an_objects[i] = ln_null
			//this.new(la_ary[i])
		end if		
	next
	return true
end if
return false
end function

public function json setarray (readonly any ary[]);ia_value = ary
return this
end function

public function json setarrayelement (long index, any new_value);boolean lb_res
any laa_ary[]
if IsArray(ia_value) then
	laa_ary[] = ia_value
end if
lb_res = upperbound(laa_ary[]) < index
laa_ary[index] = new_value
ia_value = laa_ary[]
return this
end function

protected function json setarrayelement (ref any ary[], long index, any new_value);boolean lb_res
lb_res = upperbound(ary[]) < index
ary[index] = new_value
return this
end function

public function json setfalse ();ia_value = false
return this
end function

public function json setnull ();setnull(ia_value)
return this
end function

public function json setnumber (readonly decimal number);ia_value = number
return this
end function

public function json setobject ();ia_value = this
return this
end function

public function json setstring (readonly string str);ia_value = str
return this
end function

public function json settrue ();ia_value = true
return this

end function

public function json setobject (readonly json object);ia_value = object
return this
end function

public function json setattribute (readonly string as_name, readonly any aa_value);return setattribute( as_name, aa_value, "[general]")
end function

public function json setattribute (readonly string as_name, readonly any aa_value, readonly string as_str_fmt);long index
index = findpairindex(as_name)
if index < 1 then
	index = 1 + upperbound(pairs[])
	json_pair pair
	pairs[index] = pair
	pairs[index].name = as_name
	pair_index += ";"+as_name+"="+string(index)
end if

boolean lb_native = false
lb_native = isnull(aa_value)
if not lb_native then lb_native = isarray(aa_value)
if not lb_native then lb_native = isobject(aa_value)
if not lb_native then lb_native = isbool(aa_value)
if not lb_native then lb_native = isnumber(aa_value)
if lb_native then
	pairs[index].value = aa_value
else
	//date, time, datetime, char(s), byes, blob, and so on are stringified too or may die with an unhandled error :-/
	pairs[index].value = string( aa_value, as_str_fmt )
end if

return this
end function

public function json newroot ();json ln_root
ln_root = create json
ln_root.setObject(ln_root)
return ln_root
end function

public function json new (any aa_value);json ln_new
ln_new = create json
ln_new.ia_value = aa_value
return ln_new
end function

public function json newobject ();json ln_obj
ln_obj = create json
return ln_obj
end function

public function json newarray ();json ln_ary
ln_ary = create json
any ary[]
setArray(ary[])
return ln_ary
end function

public function json push (any la_value);if not isArray() then
	setArray()
end if

any ary[]
ary[] = ia_value
ary[upperbound(ary[]) + 1] = la_value
ia_value = ary[]

return this
end function

public function json setarray ();any ary[]
ia_value = ary
return this
end function

public function json pushto (json la_ary, any la_value);if isnull(la_ary) then
	SignalError(42, "pushto: given json object is not an array!")
end if

la_ary.push(la_value)

return this
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

