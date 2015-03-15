head	1.1;
access;
symbols;
locks; strict;
comment	@ * @;


1.1
date	2006.11.20.13.05.03;	author Average;	state Exp;
branches;
next	;


desc
@@


1.1
log
@Initial revision
@
text
@{
    This file is part of the Free Component Library

    XHTML helper classes
    Copyright (c) 2000 by
      Areca Systems GmbH / Sebastian Guenther, sg@@freepascal.org

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}


UNIT XHTML;

{$H+}

INTERFACE

USES DOM, xmlRead,xmlWrite;

TYPE
  TXHTMLElement=CLASS(TDOMElement)
    PROCEDURE SetNodeName(st:DOMString);
  END;

  TXHTMLDocumentType = CLASS(TDOMDocumentType)
  PUBLIC
    property Name: DOMString READ FNodeName WRITE FNodeName;
  END;

  TXHTMLDocument = CLASS(TXMLDocument)
    PROCEDURE CreateRoot(lang:DOMString);
    PROCEDURE SetDocType(ADocType: TDOMDocumentType);
  END;


IMPLEMENTATION

PROCEDURE TXHTMLElement.SetNodeName(st:DOMString);
BEGIN
    FNodeName:=St;
END;

PROCEDURE TXHTMLDocument.CreateRoot(lang:DOMString);
VAR
  PubSt,SysSt: DOMString;
  HtmlEl: TDOMElement;
  Node:TXHTMLElement;
  s:DOMString;
  DocType:TXHTMLDocumentType;
BEGIN
    PubSt:= '-//W3C//DTD XHTML 1.1//EN';
    SysSt:='http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd';
    DocType:=TXHTMLDocumentType.Create(self);
    SetDocType(DocType);
    AppendChild(DocType);
    SetXHTMLDocType(self,'html',PubSt,SysSt);
    HtmlEl := CreateElement('html');
    AppendChild(HtmlEl);
    HtmlEl['xmlns'] := 'http://www.w3.org/1999/xhtml';
    HtmlEl['xml:lang']:=lang;
    htmlEl['lang']:=lang;
    Node:=TXHTMLElement.Create(self);
    Node.SetNodeName('head');
    htmlEl.AppendChild(Node);
    Node:=TXHTMLElement.Create(self);
    Node.SetNodeName('body');
    htmlEl.AppendChild(node);
END;

PROCEDURE TXHTMLDocument.SetDocType(ADocType: TDOMDocumentType);
BEGIN
  FDocType := ADocType;
END;

BEGIN
END.
@
