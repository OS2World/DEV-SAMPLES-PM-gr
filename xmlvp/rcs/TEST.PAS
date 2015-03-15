head	1.3;
access;
symbols;
locks;
comment	@ * @;


1.3
date	2007.07.30.15.11.43;	author Average;	state Exp;
branches;
next	1.2;

1.2
date	2006.11.23.08.20.48;	author Average;	state Exp;
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
@*** empty log message ***
@
text
@PROGRAM TEST;
{$H+}
USES
    SysUtils,xmlwrite,xmlread,dom;
const
    tName:String='A';
VAR
    Doc,Doc2:TXMLDocument;
    St:string;
    Node:TDOMNode;
    wNode,e2Node:TDOMElement;
BEGIN
    ReadXMLFileName(doc,'test.xml');
    WriteXMLFileName(doc,'test2.xml');
END.
@


1.2
log
@evのxmlフォーマットからXHTML文書の導出
@
text
@d1 1
a1 1
PROGRAM xhtmlapp;
d4 3
a6 3
    SysUtils,xhtml,xmlwrite,xmlread,dom;


d8 7
a14 86
    xhtmlDoc:TXHTMLDocument;
    refIndex:ARRAY[1..7] OF INTEGER;

    PROCEDURE evNodeToXHTMLNode(SourceNode:TDOMNode;
                                isContent:boolean;ContentNode:TDOMNode);
    VAR
        ulNode,aNode,eNode,scNode:TDOMElement;
        ChildContentNode:TDOMNode;
        st:string;
        lev:INTEGER;
        FUNCTION LevToIndex(l:INTEGER):string;
        VAR
            i:INTEGER;
        BEGIN
            FOR i:=1 TO l DO BEGIN
                result:=result+'-'+IntToStr(RefIndex[i]);
            END;
            system.Delete(result,1,1);
        END;
    BEGIN
        scNode:=TDOMElement(SourceNode.FirstChild);
        st:=TDOMElement(SourceNode).GetAttribute('Level');
        lev:=StrToInt(st);
        WHILE scNode<>NIL DO BEGIN
            IF scNode.NodeName ='header' THEN BEGIN
                inc(RefIndex[lev]);
                IF isContent THEN BEGIN
                    eNode:=xhtmlDoc.CreateElement('li');
                    aNode:=xhtmlDoc.CreateElement('a');
                    aNode.SetAttribute('href','#'+LevToIndex(lev));
                END
                ELSE BEGIN
                    eNode:=xhtmlDoc.CreateElement('h'+st);
                    aNode:=xhtmlDoc.CreateElement('a');
                    aNode.SetAttribute('name',LevToIndex(lev));
                END;
                ContentNode.AppendChild(eNode);
                eNode.AppendChild(aNode);
                st:=scNode.FirstChild.NodeValue;
                aNode.AppendChild(xhtmlDoc.CreateTextNode(st));
            END
            ELSE IF scNode.NodeName='p' THEN BEGIN
                IF isContent=FALSE THEN BEGIN
                    eNode:=xhtmlDoc.CreateElement('p');
                    st:=scNode.FirstChild.NodeValue;
                    eNode.AppendChild(xhtmlDoc.CreateTextNode(st));
                    XHTMLDoc.BodyNode.AppendChild(eNode);
                END;
            END
            ELSE IF scNode.NodeName='item' THEN BEGIN
                IF isContent THEN BEGIN
                    ChildContentNode:=xhtmlDoc.CreateElement('ul');
                    ContentNode.AppendChild(ChildContentNode);
                END
                ELSE BEGIN
                    ChildContentNode:=ContentNode;
                END;
                evNodeToXHTMLNode(scNode,isContent,ChildContentNode);
            END;
            scNode:=TDOMElement(scNode.NextSibling);
        END;
        refIndex[lev+1]:=0;
    END;
VAR
    evDoc:TXMLDocument;
    i:INTEGER;
    titleSt:DOMString;
    wNode:TDOMNode;
BEGIN
    evDoc:=TXMLDocument.Create;
    ReadXMLFileName(evDoc,'evnew.xml');

    wNode:=evDoc.FirstChild.FindNode('item').FindNode('header');
    TitleSt:=wNode.FirstChild.NodeValue;
    xhtmlDoc:=TXHTMLDocument.Create('ja',TitleSt);

    FOR i:=1 TO 7 DO refIndex[i]:=0;
    evNodeToXHTMLNode(TDOMELement(evDoc.FirstChild.FindNode('item')),
                      TRUE,xhtmlDoc.BodyNode);
    
    FOR i:=1 TO 7 DO refIndex[i]:=0;
    evNodeToXHTMLNode(TDOMELement(evDoc.FirstChild.FindNode('item')),
                      FALSE,xhtmlDoc.BodyNode);
    
    WriteXMLFileName(xhtmlDoc,'test.htm');

@


1.1
log
@Initial revision
@
text
@d1 1
a1 2
// $Id: cfgtest.pp,v 1.1 2000/07/13 06:33:46 michael Exp $

d3 2
a5 1
PROGRAM test;
d7 3
a9 1
USES DOM,xmlread,xmlwrite,encmap,Strings;
d11 60
a70 1
PROCEDURE ReadXMLFileEnc(VAR ADoc: TXMLDocument; st:string);
d72 4
a75 5
  buf: PChar;
  BufSize: LONGINT;
  i:LONGINT;
  f: File;
  OrgSt,NewSt:string;
d77 16
a92 21
  Assign(f,st);reset(f,1);
  ADoc := NIL;
  BufSize := FileSize(f) + 1;
  IF BufSize <= 1 THEN EXIT;

  GetMem(buf, BufSize);
  BlockRead(f, buf^, BufSize - 1);
  buf[BufSize - 1] := #0;
  OrgSt:='';i:=0;
  WHILE i<BufSize-1 DO BEGIN
      OrgSt:=OrgSt+Buf[i];
      inc(i);
  END;
  i:=Length(OrgSt);
  NewSt:=SJisToUTF(OrgSt)+#0;
  FreeMem(buf, BufSize);
  GetMem(buf,length(NewSt));
  system.move(NewSt[1],Buf,length(NewSt));
  FreeMem(buf, BufSize);
  close(f);
END;
a93 4
VAR
    doc: TXMLDocument;
BEGIN
    ReadXMLFileEnc(doc,'in.xml');
@
