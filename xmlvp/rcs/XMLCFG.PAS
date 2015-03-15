head	1.3;
access;
symbols;
locks;
comment	@ * @;


1.3
date	2006.11.19.14.16.18;	author Average;	state Exp;
branches;
next	1.2;

1.2
date	2006.11.19.13.19.06;	author Average;	state Exp;
branches;
next	1.1;

1.1
date	2006.11.19.13.18.22;	author Average;	state Exp;
branches;
next	;


desc
@@


1.3
log
@xmlwrite.pasÇèëë÷Ç¶
àÍâûDOCTYPEwo
èëÇ≠ÇÊÇ§Ç…
@
text
@{
    $Id: xmlcfg.pp,v 1.1.2.1 2000/07/29 14:20:54 sg Exp $
    This file is part of the Free Component Library

    Implementation of TXMLConfig class
    Copyright (c) 1999-2000 by Sebastian Guenther, sg@@freepascal.org

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{
  TXMLConfig enables applications to use XML files for storing their
  configuration data
}

{$H+}

UNIT XMLCfg;

INTERFACE
USES DOM, XMLRead, XMLWrite;

TYPE

  {"APath" is the path and name of a value: A XML configuration file is
   hierarchical. "/" is the path delimiter, the part after the last "/"
   is the name of the value. The path components will be mapped to XML
   elements, the name will be an element attribute.}

  TXMLConfig = CLASS
  PROTECTED
    doc: TXMLDocument;
    FileName: String;
    PrevPath,PrevAPath,PrevName:string;
    PrevNode:TDOMNode;
  PUBLIC
    constructor Create(CONST AFileName: String);
    destructor Destroy; override;
    PROCEDURE Flush;    // Writes the XML file
    PROCEDURE ClearDoc;
    FUNCTION  GetValue(CONST APath, ADefault: String): String;
    FUNCTION  GetNextValue(CONST APath, ADefault: String): String;
    FUNCTION  GetValueInteger(CONST APath: String; ADefault: INTEGER): INTEGER;
    FUNCTION  GetValueBool(CONST APath: String; ADefault: BOOLEAN): BOOLEAN;
    PROCEDURE SetValue(CONST APath, AValue: String);
    PROCEDURE SetNextValue(CONST APath, AValue: String);
    PROCEDURE SetValueInteger(CONST APath: String; AValue: INTEGER);
    PROCEDURE SetValueBool(CONST APath: String; AValue: BOOLEAN);
  END;


// ===================================================================

IMPLEMENTATION

USES SysUtils;


constructor TXMLConfig.Create(CONST AFileName: String);
VAR
  f: File;
  cfg: TDOMElement;
BEGIN
  FileName := AFileName;
  Assign(f, AFileName);
  {$I-}
  Reset(f, 1);
  {$I+}
  IF IOResult = 0 THEN BEGIN
    try
      ReadXMLFile(doc, f);
    except
      on e: EXMLReadError DO
        WRITELN(//StdErr,
                'Warning: XML config parsing error: ', e.Message);
    END;
    Close(f);
  END;

  IF NOT Assigned(doc) THEN
    doc := TXMLDocument.Create;

  cfg :=TDOMElement(doc.FindNode('CONFIG'));
  IF NOT Assigned(cfg) THEN BEGIN
    cfg := doc.CreateElement('CONFIG');
    doc.AppendChild(cfg);
  END;
  PrevPath:='';
  PrevAPath:='';
END;

destructor TXMLConfig.Destroy;
BEGIN
  Flush;
  IF Assigned(doc) THEN
    doc.Free;
  inherited Destroy;
END;

PROCEDURE TXMLConfig.ClearDoc;
BEGIN
    doc.RemoveChild(doc.FirstChild);
    doc.AppendChild(doc.CreateElement('CONFIG') );
END;

PROCEDURE TXMLConfig.Flush;
VAR
  f: Text;
BEGIN
  Assign(f, FileName);
  Rewrite(f);
  WriteXMLFile(doc, f);
  Close(f);
END;

FUNCTION TXMLConfig.GetValue(CONST APath, ADefault: String): String;
VAR
  node, subnode, attr: TDOMNode;
  i: INTEGER;
  aname, path: String;
BEGIN
  node := doc.DocumentElement;
  path := APath;
  WHILE True DO BEGIN
    i := Pos('/', path);
    IF i = 0 THEN break;
    aname := Copy(path, 1, i - 1);
    path := Copy(path, i + 1, Length(path));
    subnode := node.FindNode(aname);
    IF NOT Assigned(subnode) THEN BEGIN
      Result := ADefault;
      EXIT;
    END;
    node := subnode;
  END;
  attr := node.Attributes.GetNamedItem(path);
  IF Assigned(attr) THEN
    Result := attr.NodeValue
  ELSE
    Result := ADefault;
  PrevPath:=path;
  PrevAPath:=APath;
  PrevNode:=node;
  PrevName:=aname;
END;

FUNCTION TXMLConfig.GetNextValue(CONST APath, ADefault: String): String;
VAR
  subnode,node, attr: TDOMNode;
  name, path: String;
BEGIN
    IF APath=PrevAPath THEN BEGIN
        node:=PrevNode.NextSibling;
        IF NOT Assigned(node) THEN BEGIN
            result:='';
            EXIT;
        END;
        IF node.NodeName<>PrevName THEN BEGIN
            result:='';
            EXIT;
        END;
        attr := node.Attributes.GetNamedItem(PrevPath);
        IF Assigned(attr) THEN
          Result := attr.NodeValue
        ELSE
          Result := ADefault;
        PrevNode:=node;
    END
    ELSE BEGIN
        result:='';
    END;
END;

FUNCTION  TXMLConfig.GetValueInteger(CONST APath: String; ADefault: INTEGER): INTEGER;
BEGIN
  Result := StrToInt(GetValue(APath, IntToStr(ADefault)));
END;

FUNCTION TXMLConfig.GetValueBool(CONST APath: String; ADefault: BOOLEAN): BOOLEAN;
VAR
  s: String;
BEGIN
  IF ADefault THEN
    s := 'True'
  ELSE
    s := 'False';

  s := GetValue(APath, s);

  IF UpperCase(s) = 'TRUE' THEN
    Result := True
  ELSE IF UpperCase(s) = 'FALSE' THEN
    Result := FALSE
  ELSE
    Result := ADefault;
END;

PROCEDURE TXMLConfig.SetValue(CONST APath, AValue: String);
VAR
  node, subnode, attr: TDOMNode;
  i: INTEGER;
  aname, path: String;
BEGIN
  node := doc.DocumentElement;
  path := APath;
  WHILE True DO
  BEGIN
    i := Pos('/', path);
    IF i = 0 THEN
      break;
    aname := Copy(path, 1, i - 1);
    path := Copy(path, i + 1, Length(path));
    subnode := node.FindNode(aname);
    IF NOT Assigned(subnode) THEN
    BEGIN
      subnode := doc.CreateElement(aname);
      node.AppendChild(subnode);
    END;
    node := subnode;
  END;
  TDOMElement(node).SetAttribute(path, AValue);
  attr := node.Attributes.GetNamedItem(path);
  IF NOT Assigned(attr) THEN BEGIN
    attr := doc.CreateAttribute(path);
    node.Attributes.SetNamedItem(attr);
  END;
  attr.NodeValue := AValue;
  PrevPath:=path;
  PrevAPath:=APath;
  PrevNode:=node;
  PrevName:=aname;
END;

PROCEDURE TXMLConfig.SetNextValue(CONST APath, AValue: String);
VAR
  node, subnode, attr: TDOMNode;
  i: INTEGER;
  name, path: String;
  isNewMake:BOOLEAN;
BEGIN
  IF APath<>PrevAPath THEN BEGIN
     SetValue(APath,AValue);
     EXIT;
  END;
  path:=PrevPath;
  IF NOT(Assigned(PrevNode.NextSibling)) THEN BEGIN
    node:=PrevNode;
    subnode := doc.CreateElement(PrevName);
    node.ParentNode.AppendChild(subNode);
    node:=SubNode;
    attr := doc.CreateAttribute(path);
    node.Attributes.SetNamedItem(attr);
    attr.NodeValue := AValue;
    PrevNode:=Node;
    EXIT;
  END;
  node:=PrevNode.NextSibling;
  TDOMElement(node).SetAttribute(path, AValue);
  attr := node.Attributes.GetNamedItem(path);
  IF NOT Assigned(attr) THEN BEGIN
    attr := doc.CreateAttribute(path);
    node.Attributes.SetNamedItem(attr);
  END;
  attr.NodeValue := AValue;
  PrevNode:=Node;
END;

PROCEDURE TXMLConfig.SetValueInteger(CONST APath: String; AValue: INTEGER);
BEGIN
  SetValue(APath, IntToStr(AValue));
END;

PROCEDURE TXMLConfig.SetValueBool(CONST APath: String; AValue: BOOLEAN);
BEGIN
  IF AValue THEN
    SetValue(APath, 'True')
  ELSE
    SetValue(APath, 'False');
END;


END.


{
  $Log: xmlcfg.pp,v $
  Revision 1.1.2.1  2000/07/29 14:20:54  sg
  * Modified the copyright notice to remove ambiguities

  Revision 1.1  2000/07/13 06:33:49  michael
  + Initial import

  Revision 1.10  2000/05/04 18:24:22  sg
  * Bugfixes: In some cases the DOM node tree was invalid
  * Simplifications
  * Minor optical improvements

  Revision 1.9  2000/02/13 10:03:31  sg
  * Hopefully final fix for TDOMDocument.DocumentElement:
    - Reading this property always delivers the first element in the document
    - Removed SetDocumentElement. Use "AppendChild" or one of the other
      generic methods for TDOMNode instead.

  Revision 1.8  2000/01/30 22:20:08  sg
  * TXMLConfig now frees its XML document (major memory leak...)

  Revision 1.7  2000/01/07 01:24:34  peter
    * updated copyright to 2000

  Revision 1.6  2000/01/06 01:20:37  peter
    * moved out of packages/ back to topdir

  Revision 1.1  2000/01/03 19:33:11  peter
    * moved to packages dir

  Revision 1.4  1999/12/22 13:38:01  sg
  * Lots of cosmetic changes (strings -> const AnsiStrings etc.)

  Revision 1.3  1999/07/25 16:24:13  michael
  + Fixes from Sebastiam Guenther - more error-proof

  Revision 1.2  1999/07/09 21:05:50  michael
  + fixes from Guenther Sebastian

  Revision 1.1  1999/07/09 08:35:09  michael
  + Initial implementation by Sebastian Guenther

}
@


1.2
log
@doctypeêÈåæì«Ç›çûÇ›(ÇΩÇæÇµxhtmlÇÃÇ›)
@
text
@@


1.1
log
@Initial revision
@
text
@@
