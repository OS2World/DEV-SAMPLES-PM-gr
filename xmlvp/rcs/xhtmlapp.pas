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
@PROGRAM xhtmlapp;
{$H+}
USES
    xhtml,xmlwrite;
VAR
    xhtmlDoc:TXHTMLDocument;

BEGIN
    xhtmlDoc:=TXHTMLDocument.Create;
    xhtmlDoc.CreateRoot('ja');
    WriteXMLFileName(xhtmlDoc,'test.htm');

END.
@
