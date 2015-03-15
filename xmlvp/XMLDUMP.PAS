// $Id: XMLDUMP.PAS 1.5 2006/11/22 16:17:24 Average Exp $

{$H+}

PROGRAM xmldump;
USES sysutils, DOM, xmlread,xmlWrite;
CONST
  NodeNames: ARRAY[ELEMENT_NODE..NOTATION_NODE] OF String = (
    'Element',
    'Attribute',
    'Text',
    'CDATA section',
    'Entity reference',
    'Entity',
    'Processing instruction',
    'Comment',
    'Document',
    'Document type',
    'Document fragment',
    'Notation'
  );

PROCEDURE DumpNode(node: TDOMNode; spc: String);
VAR
  i: INTEGER;
  attr: TDOMNode;
BEGIN
  WRITE(spc, NodeNames[node.NodeType]);
  IF Copy(node.NodeName, 1, 1) <> '#' THEN
    WRITE(' "', node.NodeName, '"');
  IF node.NodeValue <> '' THEN
    WRITE(' "', node.NodeValue, '"');

  IF (node.Attributes <> NIL) AND (node.Attributes.Length > 0) THEN BEGIN
    WRITE(',');
    FOR i := 0 TO node.Attributes.Length - 1 DO BEGIN
      attr := node.Attributes.Item[i];
      WRITE(' ', attr.NodeName, ' = "', attr.NodeValue, '"');
    END;
  END;
  WRITELN;

  IF node.FirstChild <> NIL THEN
    DumpNode(node.FirstChild, spc + '  ');
  IF node.NextSibling <> NIL THEN
    DumpNode(node.NextSibling, spc);
END;

VAR
  xml: TXMLDocument;
BEGIN
  IF ParamCount <> 1 THEN BEGIN
    WRITELN('xmldump <xml or dtd file>');
    EXIT;
  END;

  IF UpperCase(ExtractFileExt(ParamStr(1))) = '.DTD' THEN
    ReadDTDFileName(xml,ParamStr(1))
  ELSE
    ReadXMLFileName(xml,ParamStr(1));

  WRITELN('Successfully parsed the document. Structure:');
  WRITELN;
  DumpNode(xml, '| ');

  WRITELN('test xmlwrite');
  WriteXMLFileName(xml,'test.htm');
  xml.Free;
END.


{
  $Log: XMLDUMP.PAS $
  Revision 1.5  2006/11/22 16:17:24  Average
  xhtmlサポートの導入

  Revision 1.3  2006/11/19 14:16:18  Average
  xmlwrite.pasを書替え
  一応DOCTYPEwo
  書くように

  Revision 1.1  2000/07/13 06:33:48  michael
  + Initial import

  Revision 1.6  2000/06/29 16:45:51  sg
  * Now also dumps the document type

  Revision 1.5  2000/01/30 22:20:57  sg
  * The XML config object is now freed at the end of the program
    (this enables us to detect memory leaks with this test program)

  Revision 1.4  2000/01/06 01:20:36  peter
    * moved out of packages/ back to topdir

  Revision 1.1  2000/01/03 19:33:10  peter
    * moved to packages dir

  Revision 1.2  1999/08/27 15:52:49  michael
  * Adapted to new xmlread

  Revision 1.1  1999/07/09 21:06:59  michael
  + Initial implementation by sebastian Guenther

}
