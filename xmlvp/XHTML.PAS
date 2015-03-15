{
    This file is part of the Free Component Library

    XHTML helper classes
    Copyright (c) 2000 by
      Areca Systems GmbH / Sebastian Guenther, sg@freepascal.org

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
        property Name: DOMString READ FNodeName WRITE FNodeName;
    END;

    TDOMNameElement=CLASS(TDOMElement)
        PROCEDURE SetNodeName(aName:DOMString);
    END;

    TXHTMLDocument = CLASS(TXMLDocument)
      protected
        FhtmlNode:TDOMNameElement;
        FHeadNode:TDOMNameElement;
        FBodyNode:TDOMNameElement;
      public
        constructor Create(lang,TitleStr:DOMString);virtual;
        PROCEDURE CreateRoot(lang:DOMString);
        PROCEDURE SetDocType(ADocType: TDOMDocumentType);
        property  HTMLNode: TDOMNameElement READ FHTMLNode;
        property   HeadNode: TDOMNameElement READ FHeadNode;
        property   BodyNode: TDOMNameElement READ FBodyNode;
    END;



IMPLEMENTATION

PROCEDURE TDOMNameElement.SetNodeName(aName:DOMString);
BEGIN
    FNodeName:=aName;
END;
PROCEDURE TXHTMLElement.SetNodeName(st:DOMString);
BEGIN
    FNodeName:=St;
END;

constructor TXHTMLDocument.Create(lang,TitleStr:DOMString);
var
    wNode:TDOMElement;
    xNode:TDOMNode;
begin
    inherited Create;
    CreateRoot(lang);
    xNode:=FirstChild;
    xNode:=xNode.NextSibling.FindNode('head');
    wNode:=CreateElement('title');
    wNode.AppendChild(CreateTextNode(TitleStr));
    xNode.AppendChild(wNode);
end;

PROCEDURE TXHTMLDocument.CreateRoot(lang:DOMString);
VAR
  PubSt,SysSt: DOMString;
  DocType:TXHTMLDocumentType;
BEGIN
    PubSt:= '-//W3C//DTD XHTML 1.1//EN';
    SysSt:='http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd';
    DocType:=TXHTMLDocumentType.Create(self);
    SetDocType(DocType);
    AppendChild(DocType);
    SetXHTMLDocType(self,'html',PubSt,SysSt);
    FHTMLNode := TDOMNameElement(CreateElement('html'));
    AppendChild(FHTMLNode);
    FHTMLNode['xmlns'] := 'http://www.w3.org/1999/xhtml';
    FHTMLNode['xml:lang']:=lang;
    FHTMLNode['lang']:=lang;
    FHeadNode:=TDOMNameElement(TXHTMLElement.Create(self));
    FHeadNode.SetNodeName('head');
    FHTMLNode.AppendChild(FHeadNode);
    FBodyNode:=TDOMNameElement(TXHTMLElement.Create(self));
    FBodyNode.SetNodeName('body');
    FHTMLNode.AppendChild(FBodyNode);
END;

PROCEDURE TXHTMLDocument.SetDocType(ADocType: TDOMDocumentType);
BEGIN
  FDocType := ADocType;
END;

BEGIN
END.
