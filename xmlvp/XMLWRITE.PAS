{
    $Id: xmlwrite.pas 1.7 2007/07/30 15:26:57 Average Exp $
    This file is part of the Free Component Library

    XML writing routines
    Copyright (c) 1999-2000 by Sebastian Guenther, sg@freepascal.org

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}


UNIT XMLWrite;

{$H+}

INTERFACE

USES
    Classes, DOM;

type
    TCharacters = set OF CHAR;
    TSpecialCharCallback = PROCEDURE(c: CHAR);
    TConvTextClass=Class
        function ConvText(CONST s:DOMString;
                          CONST SpecialChars: TCharacters;
                          CONST SpecialCharCallback: TSpecialCharCallback):DOMString;virtual;
    END;

PROCEDURE WriteXMLFileName(doc: TXMLDocument; CONST AFileName: String);
PROCEDURE WriteXMLFile(doc: TXMLDocument; VAR AFile: Text);
PROCEDURE WriteXMLFileStream(doc: TXMLDocument; VAR AStream: TStream);

PROCEDURE WriteXMLName(Element: TDOMElement; CONST AFileName: String);
PROCEDURE WriteXML(Element: TDOMElement; VAR AFile: Text);
PROCEDURE WriteXMLStream(Element: TDOMElement; VAR AStream: TStream);

var
    CVText:TConvTextClass;

// ===================================================================

IMPLEMENTATION

// -------------------------------------------------------------------
//   Writers FOR the different node types
// -------------------------------------------------------------------

PROCEDURE WriteElement(node: TDOMNode); forward;
PROCEDURE WriteAttribute(node: TDOMNode); forward;
PROCEDURE WriteText(node: TDOMNode); forward;
PROCEDURE WriteCDATA(node: TDOMNode); forward;
PROCEDURE WriteEntityRef(node: TDOMNode); forward;
PROCEDURE WriteEntity(node: TDOMNode); forward;
PROCEDURE WritePI(node: TDOMNode); forward;
PROCEDURE WriteComment(node: TDOMNode); forward;
PROCEDURE WriteDocument(node: TDOMNode); forward;
PROCEDURE WriteDocumentType(node: TDOMNode); forward;
PROCEDURE WriteDocumentFragment(node: TDOMNode); forward;
PROCEDURE WriteNotation(node: TDOMNode); forward;


TYPE
  TWriteNodeProc = PROCEDURE(node: TDOMNode);

CONST
  WriteProcs: ARRAY[ELEMENT_NODE..NOTATION_NODE] OF TWriteNodeProc =
    (WriteElement, WriteAttribute, WriteText, WriteCDATA, WriteEntityRef,
     WriteEntity, WritePI, WriteComment, WriteDocument, WriteDocumentType,
     WriteDocumentFragment, WriteNotation);

PROCEDURE WriteNode(node: TDOMNode);
BEGIN
  WriteProcs[node.NodeType](node);
END;


// -------------------------------------------------------------------
//   Text file AND TStream support
// -------------------------------------------------------------------

TYPE
  TOutputProc = PROCEDURE(s: String);

VAR
  f: ^Text;
  stream: TStream;
  wrt, wrtln: TOutputProc;
  InsideTextNode: BOOLEAN;


PROCEDURE Text_Write(s: String);
BEGIN
  WRITE(f^, s);
END;

PROCEDURE Text_WriteLn(s: String);
BEGIN
  WRITELN(f^, s);
END;

PROCEDURE Stream_Write(s: String);
BEGIN
  IF Length(s) > 0 THEN
    stream.WRITE(s[1], Length(s));
END;

PROCEDURE Stream_WriteLn(s: String);
VAR
    st:string;
BEGIN
  IF Length(s) > 0 THEN
    stream.WRITE(s[1], Length(s));
  St:=#10;
  stream.WRITE(st[1],1);
END;

var
    NilStr:string;
procedure NilWrt(s:string);
begin
    NilStr:=s;
end;
procedure NilWrtLn(s:string);
begin
    NilStr:=s;
end;

// -------------------------------------------------------------------
//   Indent handling
// -------------------------------------------------------------------

VAR
  Indent: String;


PROCEDURE IncIndent;
BEGIN
  Indent := Indent + '  ';
END;

PROCEDURE DecIndent;
BEGIN
  IF Length(Indent) >= 2 THEN
    SetLength(Indent, Length(Indent) - 2);
END;


// -------------------------------------------------------------------
//   String conversion
// -------------------------------------------------------------------


CONST
  AttrSpecialChars = ['"', '&'];
  TextSpecialChars = ['<', '>', '&'];


function ConvWrite(CONST s: String;
                   CONST SpecialChars: TCharacters;
                   CONST SpecialCharCallback: TSpecialCharCallback):DOMString;
VAR
  StartPos, EndPos: INTEGER;
  wSt:DOMString;
BEGIN
  wSt:='';
  StartPos := 1;
  EndPos := 1;
  WHILE EndPos <= Length(s) DO
  BEGIN
    IF s[EndPos] IN SpecialChars THEN BEGIN
        wSt:=Copy(s, StartPos, EndPos - StartPos);
        wrt(wSt);
        result:=result+wSt;
        SpecialCharCallback(s[EndPos]);
        StartPos := EndPos + 1;
    END;
    Inc(EndPos);
  END;
  IF EndPos > StartPos THEN begin
    wSt:=Copy(s, StartPos, EndPos - StartPos);
    wrt(wSt);
    result:=result+wSt;
  end;
END;

PROCEDURE AttrSpecialCharCallback(c: CHAR);
BEGIN
  IF c = '"' THEN
    wrt('&quot;')
  ELSE IF c = '&' THEN
    wrt('&amp;')
  ELSE
    wrt(c);
END;

PROCEDURE TextnodeSpecialCharCallback(c: CHAR);
BEGIN
  IF c = '<' THEN
    wrt('&lt;')
  ELSE IF c = '>' THEN
    wrt('&gt;')
  ELSE IF c = '&' THEN
    wrt('&amp;')
  ELSE
    wrt(c);
END;


// -------------------------------------------------------------------
//   Node writers implementations
// -------------------------------------------------------------------

PROCEDURE WriteElement(node: TDOMNode);
VAR
  i: INTEGER;
  attr, child: TDOMNode;
  SavedInsideTextNode: BOOLEAN;
  s: String;
BEGIN
  IF NOT InsideTextNode THEN
    wrt(Indent);
  wrt('<' + node.NodeName);
  FOR i := 0 TO node.Attributes.Length - 1 DO
  BEGIN
    attr := node.Attributes.Item[i];
    wrt(' ' + attr.NodeName + '=');
    s := attr.NodeValue;
    // !!!: Replace special characters IN "s" such as '&', '<', '>'
    wrt('"');
    ConvWrite(s, AttrSpecialChars, AttrSpecialCharCallback);
    wrt('"');
  END;
  Child := node.FirstChild;
  IF Child = NIL THEN
    IF InsideTextNode THEN
      wrt('/>')
    ELSE
      wrtln('/>')
  ELSE
  BEGIN
    SavedInsideTextNode := InsideTextNode;
    IF InsideTextNode OR Child.InheritsFrom(TDOMText) THEN
      wrt('>')
    ELSE
      wrtln('>');
    IncIndent;
    REPEAT
      IF Child.InheritsFrom(TDOMText) THEN
        InsideTextNode := True;
      WriteNode(Child);
      Child := Child.NextSibling;
    UNTIL child = NIL;
    DecIndent;
    IF NOT InsideTextNode THEN
      wrt(Indent);
    InsideTextNode := SavedInsideTextNode;
    s := '</' + node.NodeName + '>';
    IF InsideTextNode THEN
      wrt(s)
    ELSE
      wrtln(s);
  END;
END;

PROCEDURE WriteAttribute(node: TDOMNode);
BEGIN
  WRITELN('WriteAttribute');
END;

PROCEDURE WriteText(node: TDOMNode);
var
    s:DOMString;
BEGIN
    s:=CVText.ConvText(node.NodeValue,
                          TextSpecialChars,
                          TextnodeSpecialCharCallback);
    wrt(s);
END;

PROCEDURE WriteCDATA(node: TDOMNode);
BEGIN
  IF InsideTextNode THEN
    wrt('<![CDATA[' + node.NodeValue + ']]>')
  ELSE
    wrtln(Indent + '<![CDATA[' + node.NodeValue + ']]>')
END;

PROCEDURE WriteEntityRef(node: TDOMNode);
BEGIN
  wrt('&' + node.NodeName + ';');
END;

PROCEDURE WriteEntity(node: TDOMNode);
BEGIN
  WRITELN('WriteEntity');
END;

PROCEDURE WritePI(node: TDOMNode);
BEGIN
  WRITELN('WritePI');
END;

PROCEDURE WriteComment(node: TDOMNode);
BEGIN
  IF InsideTextNode THEN
    wrt('<!--' + node.NodeValue + '-->')
  ELSE
    wrtln(Indent + '<!--' + node.NodeValue + '-->')
END;

PROCEDURE WriteDocument(node: TDOMNode);
BEGIN
  WRITELN('WriteDocument');
END;

PROCEDURE WriteDocumentType(node: TDOMNode);
VAR
    DocType:TDOMDocumentType;
BEGIN
    IF node.NodeType=DOCUMENT_TYPE_NODE THEN BEGIN
        DocType:=TDOMDocumentType(DocType);
        IF DocType.Name='html' THEN BEGIN
            Wrtln('<!DOCTYPE '+DocType.Name+' PUBLIC '+
                '"'+TDOMEntity(DocType.Entities.Item[0]).PublicID+'" '+
                '"'+TDOMEntity(DocType.Entities.Item[0]).SystemID+'" >');
        END;

    END
END;

PROCEDURE WriteDocumentFragment(node: TDOMNode);
BEGIN
  WRITELN('WriteDocumentFragment');
END;

PROCEDURE WriteNotation(node: TDOMNode);
BEGIN
  WRITELN('WriteNotation');
END;


PROCEDURE InitWriter;
BEGIN
  InsideTextNode := FALSE;
END;

PROCEDURE RootWriter(doc: TXMLDocument);
VAR
  Child: TDOMNode;
BEGIN
  InitWriter;
  wrt('<?xml version="');
  IF doc.XMLVersion <> '' THEN
    wrt(doc.XMLVersion)
  ELSE
    wrt('1.0');
  wrt('"');
  IF doc.Encoding <> '' THEN
    wrt(' encoding="' + doc.Encoding + '"');
  wrtln('?>');

  indent := '';

  child := doc.FirstChild;
  WHILE Assigned(Child) DO
  BEGIN
    WriteNode(Child);
    Child := Child.NextSibling;
  END;
END;


// -------------------------------------------------------------------
//   INTERFACE IMPLEMENTATION
// -------------------------------------------------------------------

PROCEDURE WriteXMLFileName(doc: TXMLDocument; CONST AFileName: String);
BEGIN
  Stream := TFileStream.Create(AFileName, fmCreate);
  wrt := Stream_Write;
  wrtln := Stream_WriteLn;
  RootWriter(doc);
  Stream.Free;
END;

PROCEDURE WriteXMLFile(doc: TXMLDocument; VAR AFile: Text);
BEGIN
  f := @AFile;
  wrt := Text_Write;
  wrtln := Text_WriteLn;
  RootWriter(doc);
END;

PROCEDURE WriteXMLFileStream(doc: TXMLDocument; VAR AStream: TStream);
BEGIN
  Stream := AStream;
  wrt := Stream_Write;
  wrtln := Stream_WriteLn;
  RootWriter(doc);
END;


PROCEDURE WriteXMLName(Element: TDOMElement; CONST AFileName: String);
BEGIN
  Stream := TFileStream.Create(AFileName, fmCreate);
  wrt := Stream_Write;
  wrtln := Stream_WriteLn;
  InitWriter;
  WriteNode(Element);
  Stream.Free;
END;

PROCEDURE WriteXML(Element: TDOMElement; VAR AFile: Text);
BEGIN
  f := @AFile;
  wrt := Text_Write;
  wrtln := Text_WriteLn;
  InitWriter;
  WriteNode(Element);
END;

PROCEDURE WriteXMLStream(Element: TDOMElement; VAR AStream: TStream);
BEGIN
  stream := AStream;
  wrt := Stream_Write;
  wrtln := Stream_WriteLn;
  InitWriter;
  WriteNode(Element);
END;

function TConvTextClass.ConvText(const s:DOMString;
                                 CONST SpecialChars: TCharacters;
                                 CONST SpecialCharCallback: TSpecialCharCallback):DOMString;
VAR
  StartPos, EndPos: INTEGER;
  wSt:DOMString;
  TempWrt,TempWriteln:TOutPutProc;
BEGIN
    wSt:='';
    result:='';
    StartPos := 1;
    EndPos := 1;
    TempWrt:=wrt;
    TempWriteln:=wrtln;

    WHILE EndPos <= Length(s) DO BEGIN
        IF s[EndPos] IN SpecialChars THEN BEGIN
            result:=result+Copy(s, StartPos, EndPos - StartPos);
            TempWrt:=wrt;TempWriteln:=wrtln;wrt:=NilWrt;wrtln:=NilWrtln;
            result:=result+wSt;
            SpecialCharCallBack(s[EndPos]);
            result:=result+NilStr;
            StartPos := EndPos + 1;
            wrt:=TempWrt;wrtln:=TempWriteln;
        END;
        Inc(EndPos);
    END;
    IF EndPos > StartPos THEN begin
        result:=result+Copy(s, StartPos, EndPos - StartPos);
    end;
END;


BEGIN
    CVText:=TConvTextClass.Create;
END.


{
  $Log: xmlwrite.pas $
  Revision 1.7  2007/07/30 15:26:57  Average
  xml書き込みのフックを作った。(NilWrt)

  Revision 1.6  2007/07/30 15:11:43  Average
  TTextConvクラスの導入

  Revision 1.5  2006/11/22 16:17:24  Average
  xhtmlサポートの導入

  Revision 1.3  2006/11/19 14:16:18  Average
  xmlwrite.pasを書替え
  一応DOCTYPEwo
  書くように

  Revision 1.1.2.2  2000/07/29 14:20:54  sg
  * Modified the copyright notice to remove ambiguities

  Revision 1.1.2.1  2000/07/25 09:13:54  sg
  * Fixed some small bugs
    - some methods where 'virtual' instead of 'override' in dom.pp
    - corrections regaring wether NodeName or NodeValue is used, for
      some node types (Entity, EntityReference)

  Revision 1.1  2000/07/13 06:33:50  michael
  + Initial import

  Revision 1.9  2000/07/09 11:40:09  sg
  * ">" and "&" in text nodes are now replaced by "&gt;" and "&amp;"

  Revision 1.8  2000/06/29 08:45:32  sg
  * Now produces _much_ better output...!

  Revision 1.7  2000/04/20 14:15:45  sg
  * Minor bugfixes
  * Started support for DOM level 2
}
