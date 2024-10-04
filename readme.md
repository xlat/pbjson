README
======

JSON for PowerBuilder classic, a JSON implementation in pure PowerBuilder.
Parsers accepts an ab_relaxed Boolean parameter to allow a superset of JSON 
that include single quoted string and comments (inline and stream).


PREREQUIRE
==========

PB10+, the test project was tested using PB11.5 and the bootstrap-pbl.cmd 
initialisation files is configurated for PB115, to switch to another IDE 
version, edit this file and change the line containing "set pbver=115" by
the appropriate value (100, 110, 115, 120, 125, 170, 190, ..., 220).

INSTALLATION
============

* run bootstrap-pbl.cmd 
* open the workspace json.pbw in pbide

SYNOPSIS
========

```
//First, create a JSON parser
json ln_json
ln_json = create json
string ls_error

/*
//to read from an URL
ls_error = ln_json.parseURL("http://date.jsontest.com")
*/

/*
//to read from a file
ls_error = ln_json.parseFile('c:\fixtures\json\test-date.json')
*/

//to read from string
ls_error = ln_json.parse('{                    &
    "time": "07:30:18 PM",                     &
    "milliseconds_since_epoch": 1401910218155, &
    "date": "06-04-2014",                      &
    "person": {                                &
        "name":  "Nicolas",                    &
        "age": 39,                             &
        "languages": [ "fr", "en" ],           &
    }                                          &
}')

//check for parse error
if ls_error <> "" then
    messagebox("Parse error", ls_error, stopSign!, ok!)
    destroy ln_json
    return
end if

//working with parsed data
any la_data
if ln_json.retrieve("date", ref la_data) then
    messagebox("date", string(la_data))
end if

//using XPath like expression to travers JSON structures : object with key name, array with index (1 based)
if ln_json.retrieve("person/languages/2", ref la_data) then
    messagebox("Person language n#2", string(la_data))
end if

//using OOP
la_data = ln_json.getObject().getAttribute( "date" )
messagebox("date", string(la_data))

//then destroy parser
destroy ln_json

//TODO: add a Delete method that works with an XPath-like expression to delete an element
//Build a JSON structure
//Don't need a `ln_json.reset()` 'cause setObject will change the root
json ln_root, ln_person, ln_languages
ln_root = create json
ln_person = create json
ln_person.setattribute( "name", "Nicolas")
ln_person.setattribute( "age", 39)
ln_person.setattribute( "languages", { "fr", "en" })
ln_root.setAttribute( "person", ln_person)
ln_root.setAttribute( "time", "07:30:18 PM")
ln_root.setAttribute( "milliseconds_sinc_epoch", 1401910218155)
ln_root.setAttribute( "date", now(), "dd/mm/yyyy")

ln_root.setObject( ln_root )
messageBox("JSON created from OOP", ln_root.toJson( ) )
destroy ln_root
destroy ln_person
```

Another example to produce JSON using OOP
=========================================

```
json ln_root
ln_root = create json
ln_root.setObject( ln_root )
ln_root.setAttribute("cooperative", 1000)
ln_root.setAttribute("templateName", "BankStatement")
//add an array using OOP
json ln_ary
ln_ary = create json
json ln_tran1, ln_tran2, ln_tran3
ln_tran1 = create json
ln_tran1.setAttribute("date", "2023-05-02")
ln_tran1.setAttribute("description", "PIX Lorem ipsum dolor sit amet")
ln_tran1.setAttribute("amount", -100)
ln_ary.setArrayelement( 1, ln_tran1)
ln_tran2 = create json
ln_tran2.setAttribute("date", "2024-01-01")
ln_tran2.setAttribute("description", "Fatura Cartão Lorem ipsum dolor sit amet")
ln_tran2.setAttribute("amount", 200)
ln_ary.setArrayelement(2, ln_tran2)
ln_tran3 = create json
ln_tran3.setAttribute("date", "2024-01-01")
ln_tran3.setAttribute("description", "Saldo do dia")
ln_tran3.setAttribute("amount", 0)
ln_ary.setArrayelement(3, ln_tran3)
json ln_templateProps 
ln_templateProps = create json
ln_templateProps.setAttribute("list", ln_ary)
json ln_user
ln_user = create json
ln_user.setAttribute("userName", "Fulano da Silva")
ln_user.setAttribute("accountNumber", "619132")
ln_user.setAttribute("emissionDate", "2024-04-25T11:22:05.354823")
ln_user.setAttribute("period", "7 dias")
ln_templateProps.setAttribute("user", ln_user)
ln_root.setAttribute("templateProps", ln_templateProps)

mle_target.text = ln_root.toJson()

destroy ln_tran1
destroy ln_tran2
destroy ln_tran3
destroy ln_templateProps
destroy ln_user
destroy ln_ary
destroy ln_root
```

Same as previous example but using OOP Chainng
==============================================

Note: for this to works you need to add the following line in the very begining of your application open script: `json = create json`

```
mle_target.text = &
JSON.NewRoot() &
	.setAttribute("cooperative", 1000) &
	.setAttribute("templateName", "BankStatement") &
	.setAttribute("templateProps", JSON.NewObject() &
		.setAttribute("list", 	JSON.NewArray() &
			.push( JSON.NewObject() &
							.setAttribute("date", "2023-05-02") &
							.setAttribute("description", "PIX Lorem ipsum dolor sit amet") &
							.setAttribute("amount", -100) &
			) /* tran1 */ &
			.push( JSON.NewObject() &
							.setAttribute("date", "2024-01-01") &
							.setAttribute("description", "Fatura Cartão Lorem ipsum dolor sit amet") &
							.setAttribute("amount", 200) &
			) /* tran2 */ &
			.push( JSON.NewObject() &
							.setAttribute("date", "2024-01-01") &
							.setAttribute("description", "Saldo do dia") &
							.setAttribute("amount", 0) &
			) /* tran3 */ &
		) /* list */ &
		.setAttribute("user", JSON.NewObject() &
			.setAttribute("userName", "Fulano da Silva") &
			.setAttribute("accountNumber", "619132") &
			.setAttribute("emissionDate", "2024-04-25T11:22:05.354823") &
			.setAttribute("period", "7 dias") &
		) /* user */ &
	) /* templateProps */ &
.toJson()

```

TODO
====
* Handle \u generation in toString() -> toJson() method
* Add unquotted indentifier as object attribut name in relaxed syntax
* Implement a Delete( JSPath ) method
* Improve documentation

LICENSE
=======

The MIT License (MIT)

Copyright (c) 2014, 2021, 2022 Nicolas Georges (xlat@cpan.org)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
