{
    $Id: XMLREAD.PAS 1.5 2006/11/22 16:17:24 Average Exp $
    This file is part of the Free Component Library

    XML reading routines.
    Copyright (c) 1999-2000 by Sebastian Guenther, sg@freepascal.org

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{$H+}

UNIT XMLRead;

INTERFACE

USES DOS,SysUtils, Classes, DOM;

TYPE

  EXMLReadError = CLASS(Exception);

PROCEDURE ReadXMLFileName(VAR ADoc: TXMLDocument;
                          CONST AFilename: String);
PROCEDURE ReadXMLFile(VAR ADoc: TXMLDocument;
                      VAR f: File);
PROCEDURE ReadXMLFileStream(VAR ADoc: TXMLDocument; VAR f: TStream);
PROCEDURE ReadXMLFileStreamName(VAR ADoc: TXMLDocument;
                                VAR f: TStream;
                                CONST AFilename: String);

PROCEDURE ReadDTDFileName(VAR ADoc: TXMLDocument; CONST AFilename: String);
PROCEDURE ReadDTDFile(VAR ADoc: TXMLDocument; VAR f: File);
PROCEDURE ReadDTDFileStream(VAR ADoc: TXMLDocument; VAR f: TStream);
PROCEDURE ReadDTDFileStreamName(VAR ADoc: TXMLDocument; VAR f: TStream;
  CONST AFilename: String);

PROCEDURE SetReaderEntity2Space;
PROCEDURE SetReaderNoEntity2Space;

// =======================================================

IMPLEMENTATION

CONST

  Letter = ['A'..'Z', 'a'..'z'];
  Digit = ['0'..'9'];
  PubidChars: set OF CHAR = [' ', #13, #10, 'a'..'z', 'A'..'Z', '0'..'9',
    '-', '''', '(', ')', '+', ',', '.', '/', ':', '=', '?', ';', '!', '*',
    '#', '@', '$', '_', '%'];
  WhitespaceChars: set OF CHAR = [#9, #10, #13, ' ',#26];

  NmToken: set OF CHAR = Letter + Digit + ['.', '-', '_', ':'];

TYPE

  TXMLReaderDocument = CLASS(TXMLDocument)
  PUBLIC
    PROCEDURE SetDocType(ADocType: TDOMDocumentType);
  END;

  TXMLReaderDocumentType = CLASS(TDOMDocumentType)
  PUBLIC
    property Name: DOMString READ FNodeName WRITE FNodeName;
  END;
  TSetOfChar = set OF CHAR;

  TXMLReader = CLASS
  PROTECTED
    buf, BufStart: PChar;
    Filename: String;

    PROCEDURE RaiseExc(descr: String);
    FUNCTION  SkipWhitespace: BOOLEAN;
    PROCEDURE ExpectWhitespace;
    PROCEDURE ExpectString(s: String);
    FUNCTION  CheckFor(s: PChar): BOOLEAN;
    FUNCTION  GetString(ValidChars: TSetOfChar): String;

    FUNCTION  GetName(VAR s: String): BOOLEAN;
    FUNCTION  ExpectName: String;                                       // [5]
    PROCEDURE ExpectAttValue(attr: TDOMAttr);                           // [10]
    FUNCTION  ExpectPubidLiteral: String;                               // [12]
    FUNCTION  ParseComment(AOwner: TDOMNode): BOOLEAN;                  // [15]
    FUNCTION  ParsePI: BOOLEAN;                                         // [16]
    PROCEDURE ExpectProlog;                                             // [22]
    FUNCTION  ParseEq: BOOLEAN;                                         // [25]
    PROCEDURE ExpectEq;
    PROCEDURE ParseMisc(AOwner: TDOMNode);                              // [27]
    FUNCTION  ParseMarkupDecl: BOOLEAN;                                 // [29]
    FUNCTION  ParseElement(AOwner: TDOMNode): BOOLEAN;                  // [39]
    PROCEDURE ExpectElement(AOwner: TDOMNode);
    FUNCTION  ParseReference(AOwner: TDOMNode): BOOLEAN;                // [67]
    PROCEDURE ExpectReference(AOwner: TDOMNode);
    FUNCTION  ParsePEReference: BOOLEAN;                                // [69]
    FUNCTION  ParseExternalID: BOOLEAN;                                 // [75]
    PROCEDURE ExpectExternalID;
    FUNCTION  ParseEncodingDecl: String;                                // [80]

    PROCEDURE ResolveEntities(RootNode: TDOMNode);virtual;
  PUBLIC
    doc: TXMLReaderDocument;
    PROCEDURE ProcessXML(ABuf: PChar; AFilename: String);  // [1]
    PROCEDURE ProcessDTD(ABuf: PChar; AFilename: String);  // ([29])
  END;

VAR
    isEntity2Space:BOOLEAN=FALSE;





PROCEDURE TXMLReaderDocument.SetDocType(ADocType: TDOMDocumentType);
BEGIN
  FDocType := ADocType;
END;


PROCEDURE TXMLReader.RaiseExc(descr: String);
VAR
  apos: PChar;
  x, y: INTEGER;
BEGIN
  // find out the line IN which the error occured
  apos := BufStart;
  x := 1;
  y := 1;
  WHILE apos < buf DO BEGIN
    IF apos[0] = #10 THEN BEGIN
      Inc(y);
      x := 1;
    END ELSE
      Inc(x);
    Inc(apos);
  END;

  raise EXMLReadError.Create('In ' + Filename + ' (line ' + IntToStr(y) + ' pos ' +
    IntToStr(x) + '): ' + descr);
END;

FUNCTION TXMLReader.SkipWhitespace: BOOLEAN;
BEGIN
  Result := FALSE;
  WHILE buf[0] IN WhitespaceChars DO
  BEGIN
    Inc(buf);
    Result := True;
  END;
END;

PROCEDURE TXMLReader.ExpectWhitespace;
BEGIN
  IF NOT SkipWhitespace THEN
    RaiseExc('Expected whitespace');
END;

PROCEDURE TXMLReader.ExpectString(s: String);
VAR
  i: INTEGER;
  s2: PChar;
  s3: String;
BEGIN
  FOR i := 1 TO Length(s) DO
    IF buf[i - 1] <> s[i] THEN BEGIN
      GetMem(s2, Length(s) + 1);
      StrLCopy(s2, buf, Length(s));
      s3 := StrPas(s2);
      FreeMem(s2, Length(s) + 1);
      RaiseExc('Expected "' + s + '", found "' + s3 + '"');
    END;
  Inc(buf, Length(s));
END;

FUNCTION TXMLReader.CheckFor(s: PChar): BOOLEAN;
BEGIN
  IF buf[0] = #0 THEN BEGIN
    Result := FALSE;
    EXIT;
  END;
  IF StrLComp(buf, s, StrLen(s)) = 0 THEN BEGIN
    Inc(buf, StrLen(s));
    Result := True;
  END ELSE
    Result := FALSE;
END;

FUNCTION TXMLReader.GetString(ValidChars: TSetOfChar): String;
BEGIN
  SetLength(Result, 0);
  WHILE buf[0] IN ValidChars DO BEGIN
    Result := Result + buf[0];
    Inc(buf);
  END;
END;

PROCEDURE TXMLReader.ProcessXML(ABuf: PChar; AFilename: String);    // [1]
VAR
  LastNodeBeforeDoc: TDOMNode;
BEGIN
  buf := ABuf;
  BufStart := ABuf;
  Filename := AFilename;

  doc := TXMLReaderDocument.Create;
  ExpectProlog;
  LastNodeBeforeDoc := doc.LastChild;
  ExpectElement(doc);
  ParseMisc(doc);

  IF buf[0] <> #0 THEN
    RaiseExc('Text after end of document element found');

  {
  if buf[0] <> #0 then begin
    WriteLn('=== Unparsed: ===');
    //WriteLn(buf);
    WriteLn(StrLen(buf), ' chars');
  end;
  }
END;


FUNCTION TXMLReader.GetName(VAR s: String): BOOLEAN;    // [5]
BEGIN
  SetLength(s, 0);
  IF NOT (buf[0] IN (Letter + ['_', ':'])) THEN BEGIN
    Result := FALSE;
    EXIT;
  END;

  s := buf[0];
  Inc(buf);
  s := s + GetString(Letter + ['0'..'9', '.', '-', '_', ':']);
  Result := True;
END;

FUNCTION TXMLReader.ExpectName: String;    // [5]
BEGIN
  IF NOT (buf[0] IN (Letter + ['_', ':'])) THEN
    RaiseExc('Expected letter, "_" or ":" for name, found "' + buf[0] + '"');

  Result := buf[0];
  Inc(buf);
  Result := Result + GetString(Letter + ['0'..'9', '.', '-', '_', ':']);
END;

PROCEDURE TXMLReader.ExpectAttValue(attr: TDOMAttr);    // [10]
VAR
  s: String;

  PROCEDURE FlushStringBuffer;
  BEGIN
    IF Length(s) > 0 THEN
    BEGIN
      attr.AppendChild(doc.CreateTextNode(s));
      SetLength(s, 0);
    END;
  END;

VAR
  StrDel: ARRAY[0..1] OF CHAR;  // String delimiter
BEGIN
  IF (buf[0] <> '''') AND (buf[0] <> '"') THEN
    RaiseExc('Expected quotation marks');
  StrDel[0] := buf[0];
  StrDel[1] := #0;
  Inc(buf);
  SetLength(s, 0);
  WHILE NOT CheckFor(StrDel) DO
    IF buf[0] = '&' THEN
    BEGIN
      FlushStringBuffer;
      ParseReference(attr);
    END ELSE
    BEGIN
      s := s + buf[0];
      Inc(buf);
    END;
  FlushStringBuffer;
  ResolveEntities(Attr);
END;

FUNCTION TXMLReader.ExpectPubidLiteral: String;
BEGIN
  SetLength(Result, 0);
  IF CheckFor('''') THEN BEGIN
    result:=GetString(PubidChars - ['''']);
    ExpectString('''');
  END ELSE IF CheckFor('"') THEN BEGIN
    result:=GetString(PubidChars - ['"']);
    ExpectString('"');
  END ELSE
    RaiseExc('Expected quotation marks');
END;

FUNCTION TXMLReader.ParseComment(AOwner: TDOMNode): BOOLEAN;    // [15]
VAR
  comment: String;
BEGIN
  IF CheckFor('<!--') THEN BEGIN
    SetLength(comment, 0);
    WHILE (buf[0] <> #0) AND (buf[1] <> #0) AND
      ((buf[0] <> '-') OR (buf[1] <> '-')) DO BEGIN
      comment := comment + buf[0];
      Inc(buf);
    END;
    AOwner.AppendChild(doc.CreateComment(comment));
    ExpectString('-->');
    Result := True;
  END ELSE
    Result := FALSE;
END;

FUNCTION TXMLReader.ParsePI: BOOLEAN;    // [16]
VAR
  checkbuf: ARRAY[0..3] OF CHAR;
BEGIN
  IF CheckFor('<?') THEN BEGIN
    StrLCopy(checkbuf, buf, 3);
    IF UpperCase(StrPas(@checkbuf)) = 'XML' THEN
      RaiseExc('"<?xml" processing instruction not allowed here');
    ExpectName;
    IF SkipWhitespace THEN
      WHILE (buf[0] <> #0) AND (buf[1] <> #0) AND NOT
        ((buf[0] = '?') AND (buf[1] = '>')) DO Inc(buf);
    ExpectString('?>');
    Result := True;
  END ELSE
    Result := FALSE;
END;

PROCEDURE TXMLReader.ExpectProlog;    // [22]

  PROCEDURE ParseVersionNum;
  BEGIN
    doc.XMLVersion :=
      GetString(['a'..'z', 'A'..'Z', '0'..'9', '_', '.', ':', '-']);
  END;

  PROCEDURE ParseDoctypeDecls;
  BEGIN
    REPEAT
      SkipWhitespace;
    UNTIL NOT (ParseMarkupDecl OR ParsePEReference);
    ExpectString(']');
  END;


VAR
  DocType: TXMLReaderDocumentType;

BEGIN
  IF CheckFor('<?xml') THEN
  BEGIN
    // '<?xml' VersionInfo EncodingDecl? SDDecl? S? '?>'

    // VersionInfo: S 'version' Eq (' VersionNum ' | " VersionNum ")
    SkipWhitespace;
    ExpectString('version');
    ParseEq;
    IF buf[0] = '''' THEN
    BEGIN
      Inc(buf);
      ParseVersionNum;
      ExpectString('''');
    END ELSE IF buf[0] = '"' THEN
    BEGIN
      Inc(buf);
      ParseVersionNum;
      ExpectString('"');
    END ELSE
      RaiseExc('Expected single or double quotation mark');

    // EncodingDecl?
    ParseEncodingDecl;

    // SDDecl?
    SkipWhitespace;
    IF CheckFor('standalone') THEN
    BEGIN
      ExpectEq;
      IF buf[0] = '''' THEN
      BEGIN
        Inc(buf);
        IF NOT (CheckFor('yes''') OR CheckFor('no''')) THEN
          RaiseExc('Expected ''yes'' or ''no''');
      END ELSE IF buf[0] = '''' THEN
      BEGIN
        Inc(buf);
        IF NOT (CheckFor('yes"') OR CheckFor('no"')) THEN
          RaiseExc('Expected "yes" or "no"');
      END;
      SkipWhitespace;
    END;

    ExpectString('?>');
  END;

  // Check FOR "Misc*"
  ParseMisc(doc);

  // Check FOR "(doctypedecl Misc*)?"    [28]
  IF CheckFor('<!DOCTYPE') THEN
  BEGIN
    DocType := TXMLReaderDocumentType.Create(doc);
    doc.SetDocType(DocType);
    doc.AppendChild(DocType);
    SkipWhitespace;
    DocType.Name := ExpectName;
    SkipWhitespace;
    IF CheckFor('[') THEN
    BEGIN
      ParseDoctypeDecls;
      SkipWhitespace;
      ExpectString('>');
    END ELSE IF NOT CheckFor('>') THEN
    BEGIN
      ParseExternalID;
      SkipWhitespace;
      IF CheckFor('[') THEN
      BEGIN
        ParseDoctypeDecls;
        SkipWhitespace;
      END;
      ExpectString('>');
    END;
    ParseMisc(doc);
  END;
END;

FUNCTION TXMLReader.ParseEq: BOOLEAN;    // [25]
VAR
  savedbuf: PChar;
BEGIN
  savedbuf := buf;
  SkipWhitespace;
  IF buf[0] = '=' THEN BEGIN
    Inc(buf);
    SkipWhitespace;
    Result := True;
  END ELSE BEGIN
    buf := savedbuf;
    Result := FALSE;
  END;
END;

PROCEDURE TXMLReader.ExpectEq;
BEGIN
  IF NOT ParseEq THEN
    RaiseExc('Expected "="');
END;


// Parse "Misc*":
//   Misc ::= Comment | PI | S

PROCEDURE TXMLReader.ParseMisc(AOwner: TDOMNode);    // [27]
BEGIN
  REPEAT
    SkipWhitespace;
  UNTIL NOT (ParseComment(AOwner) OR ParsePI);
END;

FUNCTION TXMLReader.ParseMarkupDecl: BOOLEAN;    // [29]

  FUNCTION ParseElementDecl: BOOLEAN;    // [45]

    PROCEDURE ExpectChoiceOrSeq;    // [49], [50]

      PROCEDURE ExpectCP;    // [48]
      BEGIN
        IF CheckFor('(') THEN
          ExpectChoiceOrSeq
        ELSE
          ExpectName;
        IF CheckFor('?') THEN
        ELSE IF CheckFor('*') THEN
        ELSE IF CheckFor('+') THEN;
      END;

    VAR
      delimiter: CHAR;
    BEGIN
      SkipWhitespace;
      ExpectCP;
      SkipWhitespace;
      delimiter := #0;
      WHILE NOT CheckFor(')') DO BEGIN
        IF delimiter = #0 THEN BEGIN
          IF (buf[0] = '|') OR (buf[0] = ',') THEN
            delimiter := buf[0]
          ELSE
            RaiseExc('Expected "|" or ","');
          Inc(buf);
        END ELSE
          ExpectString(delimiter);
        SkipWhitespace;
        ExpectCP;
      END;
    END;

  BEGIN
    IF CheckFor('<!ELEMENT') THEN BEGIN
      ExpectWhitespace;
      ExpectName;
      ExpectWhitespace;

      // Get contentspec [46]

      IF CheckFor('EMPTY') THEN
      ELSE IF CheckFor('ANY') THEN
      ELSE IF CheckFor('(') THEN BEGIN
        SkipWhitespace;
        IF CheckFor('#PCDATA') THEN BEGIN
          // Parse Mixed section [51]
          SkipWhitespace;
          IF NOT CheckFor(')') THEN
            REPEAT
              ExpectString('|');
              SkipWhitespace;
              ExpectName;
            UNTIL CheckFor(')*');
        END ELSE BEGIN
          // Parse Children section [47]

          ExpectChoiceOrSeq;

          IF CheckFor('?') THEN
          ELSE IF CheckFor('*') THEN
          ELSE IF CheckFor('+') THEN;
        END;
      END ELSE
        RaiseExc('Invalid content specification');

      SkipWhitespace;
      ExpectString('>');
      Result := True;
    END ELSE
      Result := FALSE;
  END;

  FUNCTION ParseAttlistDecl: BOOLEAN;    // [52]
  VAR
    attr: TDOMAttr;
  BEGIN
    IF CheckFor('<!ATTLIST') THEN BEGIN
      ExpectWhitespace;
      ExpectName;
      SkipWhitespace;
      WHILE NOT CheckFor('>') DO BEGIN
        ExpectName;
        ExpectWhitespace;

        // Get AttType [54], [55], [56]
        IF CheckFor('CDATA') THEN
        ELSE IF CheckFor('ID') THEN
        ELSE IF CheckFor('IDREF') THEN
        ELSE IF CheckFor('IDREFS') THEN
        ELSE IF CheckFor('ENTITTY') THEN
        ELSE IF CheckFor('ENTITIES') THEN
        ELSE IF CheckFor('NMTOKEN') THEN
        ELSE IF CheckFor('NMTOKENS') THEN
        ELSE IF CheckFor('NOTATION') THEN BEGIN   // [57], [58]
          ExpectWhitespace;
          ExpectString('(');
          SkipWhitespace;
          ExpectName;
          SkipWhitespace;
          WHILE NOT CheckFor(')') DO BEGIN
            ExpectString('|');
            SkipWhitespace;
            ExpectName;
            SkipWhitespace;
          END;
        END ELSE IF CheckFor('(') THEN BEGIN    // [59]
          SkipWhitespace;
          GetString(Nmtoken);
          SkipWhitespace;
          WHILE NOT CheckFor(')') DO BEGIN
            ExpectString('|');
            SkipWhitespace;
            GetString(Nmtoken);
            SkipWhitespace;
          END;
        END ELSE
          RaiseExc('Invalid tokenized type');

        ExpectWhitespace;

        // Get DefaultDecl [60]
        IF CheckFor('#REQUIRED') THEN
        ELSE IF CheckFor('#IMPLIED') THEN
        ELSE BEGIN
          IF CheckFor('#FIXED') THEN
            SkipWhitespace;
          attr := doc.CreateAttribute('');
          ExpectAttValue(attr);
        END;

        SkipWhitespace;
      END;
      Result := True;
    END ELSE
      Result := FALSE;
  END;

  FUNCTION ParseEntityDecl: BOOLEAN;    // [70]
  VAR
    NewEntity: TDOMEntity;

    FUNCTION ParseEntityValue: BOOLEAN;    // [9]
    VAR
      strdel: ARRAY[0..1] OF CHAR;
    BEGIN
      IF (buf[0] <> '''') AND (buf[0] <> '"') THEN BEGIN
        Result := FALSE;
        EXIT;
      END;
      strdel[0] := buf[0];
      strdel[1] := #0;
      Inc(buf);
      WHILE NOT CheckFor(strdel) DO
        IF ParsePEReference THEN
        ELSE IF ParseReference(NewEntity) THEN
        ELSE BEGIN
          Inc(buf);             // Normal haracter
        END;
      Result := True;
    END;

  BEGIN
    IF CheckFor('<!ENTITY') THEN BEGIN
      ExpectWhitespace;
      IF CheckFor('%') THEN BEGIN    // [72]
        ExpectWhitespace;
        NewEntity := doc.CreateEntity(ExpectName);
        ExpectWhitespace;
        // Get PEDef [74]
        IF ParseEntityValue THEN
        ELSE IF ParseExternalID THEN
        ELSE
          RaiseExc('Expected entity value or external ID');
      END ELSE BEGIN    // [71]
        NewEntity := doc.CreateEntity(ExpectName);
        ExpectWhitespace;
        // Get EntityDef [73]
        IF ParseEntityValue THEN
        ELSE BEGIN
          ExpectExternalID;
          // Get NDataDecl [76]
          ExpectWhitespace;
          ExpectString('NDATA');
          ExpectWhitespace;
          ExpectName;
        END;
      END;
      SkipWhitespace;
      ExpectString('>');
      Result := True;
    END ELSE
      Result := FALSE;
  END;

  FUNCTION ParseNotationDecl: BOOLEAN;    // [82]
  BEGIN
    IF CheckFor('<!NOTATION') THEN BEGIN
      ExpectWhitespace;
      ExpectName;
      ExpectWhitespace;
      IF ParseExternalID THEN
      ELSE IF CheckFor('PUBLIC') THEN BEGIN    // [83]
        ExpectWhitespace;
        ExpectPubidLiteral;
      END ELSE
        RaiseExc('Expected external or public ID');
      SkipWhitespace;
      ExpectString('>');
      Result := True;
    END ELSE
      Result := FALSE;
  END;

BEGIN
  Result := FALSE;
  WHILE ParseElementDecl OR ParseAttlistDecl OR ParseEntityDecl OR
    ParseNotationDecl OR ParsePI OR ParseComment(doc) OR SkipWhitespace DO
    Result := True;
END;

PROCEDURE TXMLReader.ProcessDTD(ABuf: PChar; AFilename: String);
BEGIN
  buf := ABuf;
  BufStart := ABuf;
  Filename := AFilename;

  doc := TXMLReaderDocument.Create;
  ParseMarkupDecl;

  {
  if buf[0] <> #0 then begin
    WriteLn('=== Unparsed: ===');
    //WriteLn(buf);
    WriteLn(StrLen(buf), ' chars');
  end;
  }
END;

FUNCTION TXMLReader.ParseElement(AOwner: TDOMNode): BOOLEAN;    // [39] [40] [44]
VAR
  NewElem: TDOMElement;

  FUNCTION ParseCharData: BOOLEAN;    // [14]
  VAR
    s: String;
    i: INTEGER;
  BEGIN
    SetLength(s, 0);
    WHILE NOT (buf[0] IN [#0, '<', '&']) DO
    BEGIN
      s := s + buf[0];
      Inc(buf);
    END;
    IF Length(s) > 0 THEN
    BEGIN
      // Check IF s has non-whitespace content
      i := Length(s);
      WHILE (i > 0) AND (s[i] IN WhitespaceChars) DO
        Dec(i);
      IF i > 0 THEN
    NewElem.AppendChild(doc.CreateTextNode(s));
      Result := True;
    END ELSE
      Result := FALSE;
  END;


  FUNCTION ParseCDSect: BOOLEAN;    // [18]
  VAR
    cdata: String;
  BEGIN
    IF CheckFor('<![CDATA[') THEN
    BEGIN
      SetLength(cdata, 0);
      WHILE NOT CheckFor(']]>') DO
      BEGIN
        cdata := cdata + buf[0];
        Inc(buf);
      END;
      NewElem.AppendChild(doc.CreateCDATASection(cdata));
      Result := True;
    END ELSE
      Result := FALSE;
  END;



VAR
  IsEmpty: BOOLEAN;
  name: String;
  oldpos: PChar;

  attr: TDOMAttr;
BEGIN
  oldpos := buf;
  IF CheckFor('<') THEN
  BEGIN
    IF NOT GetName(name) THEN
    BEGIN
      buf := oldpos;
      Result := FALSE;
      EXIT;
    END;

    NewElem := doc.CreateElement(name);
    AOwner.AppendChild(NewElem);

    SkipWhitespace;
    IsEmpty := FALSE;
    WHILE True DO
    BEGIN
      IF CheckFor('/>') THEN
      BEGIN
        IsEmpty := True;
        break;
      END;
      IF CheckFor('>') THEN
        break;

      // Get Attribute [41]
      attr := doc.CreateAttribute(ExpectName);
      NewElem.Attributes.SetNamedItem(attr);
      ExpectEq;
      ExpectAttValue(attr);

      SkipWhitespace;
    END;

    IF NOT IsEmpty THEN
    BEGIN
      // Get content

///////***********************************BEGIN PATCH!

      IF isEntity2Space = FALSE THEN SkipWhitespace;
/////////**************************************************** END PATCH

      WHILE ParseCharData OR
            ParseCDSect OR
            ParsePI OR
            ParseComment(NewElem) OR
            ParseElement(NewElem) OR
            ParseReference(NewElem) DO;

      // Get ETag [42]
      ExpectString('</');
      IF ExpectName <> name THEN
        RaiseExc('Unmatching element end tag');
      SkipWhitespace;
      ExpectString('>');
    END;

    ResolveEntities(NewElem);



    Result := True;
  END ELSE
    Result := FALSE;
END;

PROCEDURE TXMLReader.ExpectElement(AOwner: TDOMNode);
BEGIN
  IF NOT ParseElement(AOwner) THEN
    RaiseExc('Expected element');
END;

FUNCTION TXMLReader.ParsePEReference: BOOLEAN;    // [69]
BEGIN
  IF CheckFor('%') THEN BEGIN
    ExpectName;
    ExpectString(';');
    Result := True;
  END ELSE
    Result := FALSE;
END;

FUNCTION TXMLReader.ParseReference(AOwner: TDOMNode): BOOLEAN;    // [67] [68]
BEGIN
  IF NOT CheckFor('&') THEN BEGIN
    Result := FALSE;
    EXIT;
  END;
  IF CheckFor('#') THEN BEGIN    // Test FOR CharRef [66]
    IF CheckFor('x') THEN BEGIN
      // !!!: there must be at least one digit
      WHILE buf[0] IN ['0'..'9', 'a'..'f', 'A'..'F'] DO Inc(buf);
    END ELSE
      // !!!: there must be at least one digit
      WHILE buf[0] IN ['0'..'9'] DO Inc(buf);
  END ELSE
    AOwner.AppendChild(doc.CreateEntityReference(ExpectName));
  ExpectString(';');
  Result := True;
END;

PROCEDURE TXMLReader.ExpectReference(AOwner: TDOMNode);
BEGIN
  IF NOT ParseReference(AOwner) THEN
    RaiseExc('Expected reference ("&Name;" or "%Name;")');
END;


FUNCTION TXMLReader.ParseExternalID: BOOLEAN;    // [75]

  FUNCTION GetSystemLiteral: String;
  BEGIN
    SetLength(Result, 0);
    IF buf[0] = '''' THEN BEGIN
      Inc(buf);
      WHILE (buf[0] <> '''') AND (buf[0] <> #0) DO BEGIN
        Result := Result + buf[0];
        Inc(buf);
      END;
      ExpectString('''');
    END ELSE IF buf[0] = '"' THEN BEGIN
      Inc(buf);
      WHILE (buf[0] <> '"') AND (buf[0] <> #0) DO BEGIN
        Result := Result + buf[0];
        Inc(buf);
      END;
      ExpectString('"');
    END;
  END;
  VAR
    PubSt,SysSt:DOMString;

BEGIN
  IF CheckFor('SYSTEM') THEN BEGIN
    ExpectWhitespace;
    GetSystemLiteral;
    Result := True;
  END ELSE IF CheckFor('PUBLIC') THEN BEGIN
    ExpectWhitespace;
    PubSt:=ExpectPubidLiteral;
    ExpectWhitespace;
    SysSt:=GetSystemLiteral;
    Result := True;
  END ELSE
    Result := FALSE;
  IF Assigned(doc.DocType) THEN BEGIN
    IF doc.DocType.NodeName='html' THEN
        SetXHTMLDocType(doc,'html',PubSt,SysSt);
  END;
END;

PROCEDURE TXMLReader.ExpectExternalID;
BEGIN
  IF NOT ParseExternalID THEN
    RaiseExc('Expected external ID');
END;

FUNCTION TXMLReader.ParseEncodingDecl: String;    // [80]

  FUNCTION ParseEncName: String;
  BEGIN
    IF NOT (buf[0] IN ['A'..'Z', 'a'..'z']) THEN
      RaiseExc('Expected character (A-Z, a-z)');
    Result := buf[0];
    Inc(buf);
    Result := Result + GetString(['A'..'Z', 'a'..'z', '0'..'9', '.', '_', '-']);
  END;

BEGIN
  SetLength(Result, 0);
  SkipWhitespace;
  IF CheckFor('encoding') THEN BEGIN
    ExpectEq;
    IF buf[0] = '''' THEN BEGIN
      Inc(buf);
      Result := ParseEncName;
      ExpectString('''');
    END ELSE IF buf[0] = '"' THEN BEGIN
      Inc(buf);
      Result := ParseEncName;
      ExpectString('"');
    END;
  END;
END;


{ Currently, this method will only resolve the entities which are
  predefined in XML: }

PROCEDURE TXMLReader.ResolveEntities(RootNode: TDOMNode);

  PROCEDURE ReplaceEntityRef(EntityNode: TDOMNode; CONST Replacement: String);
  VAR
    PrevSibling, NextSibling: TDOMNode;
  BEGIN
    PrevSibling := EntityNode.PreviousSibling;
    NextSibling := EntityNode.NextSibling;
    IF Assigned(PrevSibling) AND (PrevSibling.NodeType = TEXT_NODE) THEN
    BEGIN
      TDOMCharacterData(PrevSibling).AppendData(Replacement);
      RootNode.RemoveChild(EntityNode);
      IF Assigned(NextSibling) AND (NextSibling.NodeType = TEXT_NODE) THEN
      BEGIN
        TDOMCharacterData(PrevSibling).AppendData(
      TDOMCharacterData(NextSibling).Data);
    RootNode.RemoveChild(NextSibling);
      END
    END ELSE
      IF Assigned(NextSibling) AND (NextSibling.NodeType = TEXT_NODE) THEN
      BEGIN
        TDOMCharacterData(NextSibling).InsertData(0, Replacement);
    RootNode.RemoveChild(EntityNode);
      END ELSE
        RootNode.ReplaceChild(Doc.CreateTextNode(Replacement), EntityNode);
  END;

VAR
  Node, NextSibling: TDOMNode;
BEGIN
  Node := RootNode.FirstChild;
  WHILE Assigned(Node) DO
  BEGIN
    NextSibling := Node.NextSibling;
    IF Node.NodeType = ENTITY_REFERENCE_NODE THEN
      IF Node.NodeName = 'amp' THEN
        ReplaceEntityRef(Node, '&')
      ELSE IF Node.NodeName = 'apos' THEN
        ReplaceEntityRef(Node, '''')
      ELSE IF Node.NodeName = 'gt' THEN
        ReplaceEntityRef(Node, '>')
      ELSE IF Node.NodeName = 'lt' THEN
        ReplaceEntityRef(Node, '<')
      ELSE IF Node.NodeName = 'quot' THEN
        ReplaceEntityRef(Node, '"');
    Node := NextSibling;
  END;
END;

PROCEDURE ReadXMLFile(VAR ADoc: TXMLDocument; VAR f: File);
VAR
  reader: TXMLReader;
  buf: PChar;
  BufSize: LONGINT;
BEGIN
  ADoc := NIL;
  BufSize := FileSize(f) + 1;
  IF BufSize <= 1 THEN EXIT;

  GetMem(buf, BufSize);
  BlockRead(f, buf^, BufSize - 1);
  buf[BufSize - 1] := #0;
  reader := TXMLReader.Create;
  reader.ProcessXML(buf, Filerec(f).name);
  FreeMem(buf, BufSize);
  ADoc := reader.doc;
  reader.Free;
END;

PROCEDURE ReadXMLFileStreamName(VAR ADoc: TXMLDocument; VAR f: TStream;
  CONST AFilename: String);
VAR
  reader: TXMLReader;
  buf: PChar;
BEGIN
  ADoc := NIL;
  IF f.Size = 0 THEN EXIT;

  GetMem(buf, f.Size + 1);
  f.READ(buf^, f.Size);
  buf[f.Size] := #0;
  reader := TXMLReader.Create;
  reader.ProcessXML(buf, AFilename);
  FreeMem(buf, f.Size + 1);
  ADoc := reader.doc;
  reader.Free;
END;

PROCEDURE ReadXMLFileStream(VAR ADoc: TXMLDocument; VAR f: TStream);
BEGIN
  ReadXMLFileStreamName(ADoc, f, '<Stream>');
END;

PROCEDURE ReadXMLFileName(VAR ADoc: TXMLDocument; CONST AFilename: String);
VAR
  stream: TStream;
BEGIN
  ADoc := NIL;
  stream := TFileStream.Create(AFilename, fmOpenRead);
  try
    ReadXMLFileStreamName(ADoc, stream, AFilename);
  finally
    stream.Free;
  END;
END;


PROCEDURE ReadDTDFile(VAR ADoc: TXMLDocument; VAR f: File);
VAR
  reader: TXMLReader;
  buf: PChar;
  BufSize: LONGINT;
BEGIN
  ADoc := NIL;
  BufSize := FileSize(f) + 1;
  IF BufSize <= 1 THEN EXIT;

  GetMem(buf, BufSize + 1);
  BlockRead(f, buf^, BufSize - 1);
  buf[BufSize - 1] := #0;
  reader := TXMLReader.Create;
  reader.ProcessDTD(buf, Filerec(f).name);
  FreeMem(buf, BufSize);
  ADoc := reader.doc;
  reader.Free;
END;

PROCEDURE ReadDTDFileStreamName(VAR ADoc: TXMLDocument; VAR f: TStream;
  CONST AFilename: String);
VAR
  reader: TXMLReader;
  buf: PChar;
BEGIN
  ADoc := NIL;
  IF f.Size = 0 THEN EXIT;

  GetMem(buf, f.Size + 1);
  f.READ(buf^, f.Size);
  buf[f.Size] := #0;
  reader := TXMLReader.Create;
  reader.ProcessDTD(buf, AFilename);
  FreeMem(buf, f.Size + 1);
  ADoc := reader.doc;
  reader.Free;
END;

PROCEDURE ReadDTDFileStream(VAR ADoc: TXMLDocument; VAR f: TStream);
BEGIN
  ReadDTDFileStreamName(ADoc, f, '<Stream>');
END;

PROCEDURE ReadDTDFileName(VAR ADoc: TXMLDocument; CONST AFilename: String);
VAR
  stream: TStream;
BEGIN
  ADoc := NIL;
  stream := TFileStream.Create(AFilename, fmOpenRead);
  try
    ReadDTDFileStreamName(ADoc, stream, AFilename);
  finally
    stream.Free;
  END;
END;

PROCEDURE SetReaderEntity2Space;
BEGIN
    isEntity2Space:=TRUE;
END;
PROCEDURE SetReaderNoEntity2Space;
BEGIN
    isEntity2Space:=FALSE;
END;
BEGIN
END.


{
  $Log: XMLREAD.PAS $
  Revision 1.5  2006/11/22 16:17:24  Average
  xhtmlサポートの導入

  Revision 1.3  2006/11/19 14:16:18  Average
  xmlwrite.pasを書替え
  一応DOCTYPEwo
  書くように

  Revision 1.1  2003/12/01 14:02:21  Average
  Initial revision

  Revision 1.1.2.1  2000/07/29 14:20:54  sg
  * Modified the copyright notice to remove ambiguities

  Revision 1.1  2000/07/13 06:33:50  michael
  + Initial import

  Revision 1.19  2000/07/09 14:23:42  sg
  * Tabs are now considered as whitespace, too, when the reader determines if
    a text node would be empty or not

  Revision 1.18  2000/07/09 13:56:09  sg
  * Added support for predefined entities for attribute values

  Revision 1.17  2000/07/09 11:39:15  sg
  * Added support for predefined entities
  * Improved whitespace handling

  Revision 1.16  2000/04/20 14:15:45  sg
  * Minor bugfixes
  * Started support for DOM level 2

  Revision 1.15  2000/02/13 10:03:31  sg
  * Hopefully final fix for TDOMDocument.DocumentElement:
    - Reading this property always delivers the first element in the document
    - Removed SetDocumentElement. Use "AppendChild" or one of the other
      generic methods for TDOMNode instead.

  Revision 1.14  2000/01/30 22:19:13  sg
  * Made some optimizations and cosmetic changes
}
