{
    $Id: DOM.PAS 1.5 2006/11/22 16:17:24 Average Exp $
    This file is part of the Free Component Library

    Implementation of DOM interfaces
    Copyright (c) 1999-2000 by Sebastian Guenther, sg@freepascal.org

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}

{
  This unit provides classes which implement the interfaces defined in the
  DOM (Document Object Model) specification.
  The current state is:
  DOM Level 1  -  Almost completely implemented
  DOM Level 2  -  Partially implemented


  Specification used for this implementation:

  "Document Object Model (DOM) Level 2 Specification Version 1.0
   W3C Candidate Recommendation 07 March, 2000"
  http://www.w3.org/TR/2000/CR-DOM-Level-2-20000307
}


UNIT DOM;

{$H+}

INTERFACE

USES SysUtils, Classes;

CONST

  // DOM Level 1 exception codes:

  INDEX_SIZE_ERR              = 1;
  // index OR size is negative, OR greater than the allowed value

  DOMSTRING_SIZE_ERR          = 2;
  // Specified range OF text does NOT fit into a DOMString

  HIERARCHY_REQUEST_ERR       = 3;
  // node is inserted somewhere it does NOT belong

  WRONG_DOCUMENT_ERR          = 4;
  // node is used IN a different document than the one that created it
  // (that does NOT support it)

  INVALID_CHARACTER_ERR       = 5;
  // invalid OR illegal character is specified, such as IN a name

  NO_DATA_ALLOWED_ERR         = 6;
  // data is specified FOR a node which does NOT support data

  NO_MODIFICATION_ALLOWED_ERR = 7;
  // an attempt is made TO modify an OBJECT where modifications are NOT allowed

  NOT_FOUND_ERR               = 8;
  // an attempt is made TO reference a node IN a context where
  //it does NOT exist

  NOT_SUPPORTED_ERR           = 9;
  // IMPLEMENTATION does NOT support the TYPE OF OBJECT requested

  INUSE_ATTRIBUTE_ERR         = 10;
  // an attempt is made TO add an attribute that is already IN use elsewhere

  // DOM Level 2 exception codes:

  INVALID_STATE_ERR       = 11;
  // an attempt is made TO use an OBJECT that is NOT, OR is no longer, usable

  SYNTAX_ERR              = 12;
  // invalid OR illegal string specified

  INVALID_MODIFICATION_ERR    = 13;
  // an attempt is made TO modify the TYPE OF the underlying OBJECT

  NAMESPACE_ERR               = 14;
  // an attempt is made TO create OR change an OBJECT
  //IN a way which is incorrect WITH regard TO namespaces

  INVALID_ACCESS_ERR          = 15;
  // parameter OR operation is NOT supported by the underlying OBJECT

// -------------------------------------------------------
//   Node
// -------------------------------------------------------

CONST

  ELEMENT_NODE = 1;
  ATTRIBUTE_NODE = 2;
  TEXT_NODE = 3;
  CDATA_SECTION_NODE = 4;
  ENTITY_REFERENCE_NODE = 5;
  ENTITY_NODE = 6;
  PROCESSING_INSTRUCTION_NODE = 7;
  COMMENT_NODE = 8;
  DOCUMENT_NODE = 9;
  DOCUMENT_TYPE_NODE = 10;
  DOCUMENT_FRAGMENT_NODE = 11;
  NOTATION_NODE = 12;


TYPE
  LongWord=LONGINT;

  TDOMImplementation = CLASS;
  TDOMDocumentFragment = CLASS;
  TDOMDocument = CLASS;
  TDOMNode = CLASS;
  TDOMNodeList = CLASS;
  TDOMNamedNodeMap = CLASS;
  TDOMCharacterData = CLASS;
  TDOMAttr = CLASS;
  TDOMElement = CLASS;
  TDOMText = CLASS;
  TDOMComment = CLASS;
  TDOMCDATASection = CLASS;
  TDOMDocumentType = CLASS;
  TDOMNotation = CLASS;
  TDOMEntity = CLASS;
  TDOMEntityReference = CLASS;
  TDOMProcessingInstruction = CLASS;


// -------------------------------------------------------
//   DOMString
// -------------------------------------------------------

  DOMString = String;  // !!!: should be WideString as soon as this is supported by the compiler


// -------------------------------------------------------
//   DOMException
// -------------------------------------------------------


  EDOMError = CLASS(Exception)
  PROTECTED
    constructor Create(ACode: INTEGER; CONST ASituation: String);
  PUBLIC
    Code: INTEGER;
  END;

  EDOMIndexSize = CLASS(EDOMError)
  PUBLIC
    constructor Create(CONST ASituation: String);
  END;

  EDOMHierarchyRequest = CLASS(EDOMError)
  PUBLIC
    constructor Create(CONST ASituation: String);
  END;

  EDOMWrongDocument = CLASS(EDOMError)
  PUBLIC
    constructor Create(CONST ASituation: String);
  END;

  EDOMNotFound = CLASS(EDOMError)
  PUBLIC
    constructor Create(CONST ASituation: String);
  END;

  EDOMNotSupported = CLASS(EDOMError)
  PUBLIC
    constructor Create(CONST ASituation: String);
  END;

  EDOMInUseAttribute = CLASS(EDOMError)
  PUBLIC
    constructor Create(CONST ASituation: String);
  END;

  EDOMInvalidState = CLASS(EDOMError)
  PUBLIC
    constructor Create(CONST ASituation: String);
  END;

  EDOMSyntax = CLASS(EDOMError)
  PUBLIC
    constructor Create(CONST ASituation: String);
  END;

  EDOMInvalidModification = CLASS(EDOMError)
  PUBLIC
    constructor Create(CONST ASituation: String);
  END;

  EDOMNamespace = CLASS(EDOMError)
  PUBLIC
    constructor Create(CONST ASituation: String);
  END;

  EDOMInvalidAccess = CLASS(EDOMError)
  PUBLIC
    constructor Create(CONST ASituation: String);
  END;


  TRefClass = CLASS
  PROTECTED
    RefCounter: LONGINT;
  PUBLIC
    constructor Create;
    FUNCTION AddRef: LONGINT; virtual;
    FUNCTION Release: LONGINT; virtual;
  END;

  TDOMNode = CLASS
  PROTECTED
    FNodeName, FNodeValue: DOMString;
    FNodeType: INTEGER;
    FParentNode: TDOMNode;
    FPreviousSibling, FNextSibling: TDOMNode;
    FOwnerDocument: TDOMDocument;

    FUNCTION  GetNodeValue: DOMString; virtual;
    PROCEDURE SetNodeValue(AValue: DOMString); virtual;
    FUNCTION  GetFirstChild: TDOMNode; virtual;
    FUNCTION  GetLastChild: TDOMNode; virtual;
    FUNCTION  GetAttributes: TDOMNamedNodeMap; virtual;

    constructor Create(AOwner: TDOMDocument);
  PUBLIC
    // Free NodeList WITH TDOMNodeList.Release!
    FUNCTION GetChildNodes: TDOMNodeList; virtual;

    property NodeName: DOMString READ FNodeName;
    property NodeValue: DOMString READ GetNodeValue WRITE SetNodeValue;
    property NodeType: INTEGER READ FNodeType;
    property ParentNode: TDOMNode READ FParentNode;
    property FirstChild: TDOMNode READ GetFirstChild;
    property LastChild: TDOMNode READ GetLastChild;
    property ChildNodes: TDOMNodeList READ GetChildNodes;
    property PreviousSibling: TDOMNode READ FPreviousSibling;
    property NextSibling: TDOMNode READ FNextSibling;
    property Attributes: TDOMNamedNodeMap READ GetAttributes;
    property OwnerDocument: TDOMDocument READ FOwnerDocument;

    FUNCTION InsertBefore(NewChild, RefChild: TDOMNode): TDOMNode; virtual;
    FUNCTION ReplaceChild(NewChild, OldChild: TDOMNode): TDOMNode; virtual;
    FUNCTION RemoveChild(OldChild: TDOMNode): TDOMNode; virtual;
    FUNCTION AppendChild(NewChild: TDOMNode): TDOMNode; virtual;
    FUNCTION HasChildNodes: BOOLEAN; virtual;
    FUNCTION CloneNode(deep: BOOLEAN): TDOMNode;virtual;

    // Extensions TO DOM INTERFACE:
    FUNCTION CloneNodeOwner(deep: BOOLEAN; ACloneOwner: TDOMDocument): TDOMNode; virtual;
    FUNCTION FindNode(CONST ANodeName: DOMString): TDOMNode;
  END;


  { The following class is an implementation specific extension, it is just an
    extended implementation of TDOMNode, the generic DOM::Node interface
    implementation. (Its main purpose is to save memory in a big node tree) }

  TDOMNode_WithChildren = CLASS(TDOMNode)
  PROTECTED
    FFirstChild, FLastChild: TDOMNode;
    FUNCTION GetFirstChild: TDOMNode; override;
    FUNCTION GetLastChild: TDOMNode; override;
    PROCEDURE CloneChildren(ACopy: TDOMNode; ACloneOwner: TDOMDocument);
  PUBLIC
    destructor Destroy; override;
    FUNCTION InsertBefore(NewChild, RefChild: TDOMNode): TDOMNode; override;
    FUNCTION ReplaceChild(NewChild, OldChild: TDOMNode): TDOMNode; override;
    FUNCTION RemoveChild(OldChild: TDOMNode): TDOMNode; override;
    FUNCTION AppendChild(NewChild: TDOMNode): TDOMNode; override;
    FUNCTION HasChildNodes: BOOLEAN; override;
  END;


// -------------------------------------------------------
//   NodeList
// -------------------------------------------------------

  TDOMNodeList = CLASS(TRefClass)
  PROTECTED
    node: TDOMNode;
    filter: DOMString;
    UseFilter: BOOLEAN;
    constructor Create(ANode: TDOMNode; AFilter: DOMString);
    FUNCTION GetCount: LONGINT;
    FUNCTION GetItem(index: LongWord): TDOMNode;
  PUBLIC
    property Item[index: LongWord]: TDOMNode READ GetItem;
    property Count: LONGINT READ GetCount;
  END;


// -------------------------------------------------------
//   NamedNodeMap
// -------------------------------------------------------

  TDOMNamedNodeMap = CLASS(TList)
  PROTECTED
    OwnerDocument: TDOMDocument;
    FUNCTION GetItem(index: LongWord): TDOMNode;
    PROCEDURE SetItem(index: LongWord; AItem: TDOMNode);
    FUNCTION GetLength: LONGINT;

    constructor Create(AOwner: TDOMDocument);
  PUBLIC
    FUNCTION GetNamedItem(CONST name: DOMString): TDOMNode;
    FUNCTION SetNamedItem(arg: TDOMNode): TDOMNode;
    FUNCTION RemoveNamedItem(CONST name: DOMString): TDOMNode;
    property Item[index: LongWord]: TDOMNode READ GetItem WRITE SetItem;
    property Length: LONGINT READ GetLength;
  END;


// -------------------------------------------------------
//   CharacterData
// -------------------------------------------------------

  TDOMCharacterData = CLASS(TDOMNode)
  PROTECTED
    FUNCTION  GetLength: LONGINT;
  PUBLIC
    property Data: DOMString READ FNodeValue;
    property Length: LONGINT READ GetLength;
    FUNCTION SubstringData(offset, count: LongWord): DOMString;
    PROCEDURE AppendData(CONST arg: DOMString);
    PROCEDURE InsertData(offset: LongWord; CONST arg: DOMString);
    PROCEDURE DeleteData(offset, count: LongWord);
    PROCEDURE ReplaceData(offset, count: LongWord; CONST arg: DOMString);
  END;


// -------------------------------------------------------
//   DOMImplementation
// -------------------------------------------------------

  TDOMImplementation = CLASS
  PUBLIC
    FUNCTION HasFeature(CONST feature, version: DOMString): BOOLEAN;

    // Introduced IN DOM Level 2:

    FUNCTION CreateDocumentType(CONST QualifiedName, PublicID,
      SystemID: DOMString): TDOMDocumentType;
    FUNCTION CreateDocument(CONST NamespaceURI, QualifiedName: DOMString;
      doctype: TDOMDocumentType): TDOMDocument;
  END;


// -------------------------------------------------------
//   DocumentFragment
// -------------------------------------------------------

  TDOMDocumentFragment = CLASS(TDOMNode_WithChildren)
  PROTECTED
    constructor Create(AOwner: TDOMDocument);
  END;


// -------------------------------------------------------
//   Document
// -------------------------------------------------------

  TDOMDocument = CLASS(TDOMNode_WithChildren)
  PROTECTED
    FDocType: TDOMDocumentType;
    FImplementation: TDOMImplementation;
    FUNCTION GetDocumentElement: TDOMElement;
  PUBLIC
    property DocType: TDOMDocumentType READ FDocType;
    property Impl: TDOMImplementation READ FImplementation;
    property DocumentElement: TDOMElement READ GetDocumentElement;

    FUNCTION CreateElement(CONST tagName: DOMString): TDOMElement; virtual;
    FUNCTION CreateDocumentFragment: TDOMDocumentFragment;
    FUNCTION CreateTextNode(CONST data: DOMString): TDOMText;
    FUNCTION CreateComment(CONST data: DOMString): TDOMComment;
    FUNCTION CreateCDATASection(CONST data: DOMString): TDOMCDATASection;
      virtual;
    FUNCTION CreateProcessingInstruction(CONST target, data: DOMString):
      TDOMProcessingInstruction; virtual;
    FUNCTION CreateAttribute(CONST name: DOMString): TDOMAttr; virtual;
    FUNCTION CreateEntityReference(CONST name: DOMString): TDOMEntityReference;
      virtual;
    // Free NodeList WITH TDOMNodeList.Release!
    FUNCTION GetElementsByTagName(CONST tagname: DOMString): TDOMNodeList;

    // Extensions TO DOM INTERFACE:
    constructor Create; virtual;
    FUNCTION CreateEntity(CONST data: DOMString): TDOMEntity;
  END;

  TXMLDocument = CLASS(TDOMDocument)
  PUBLIC
    // Extensions TO DOM INTERFACE:
    XMLVersion, Encoding: String;
    FUNCTION CreateCDATASection(CONST data: DOMString): TDOMCDATASection; override;
    FUNCTION CreateProcessingInstruction(CONST target, data: DOMString):
      TDOMProcessingInstruction; override;
    FUNCTION CreateEntityReference(CONST name: DOMString): TDOMEntityReference; override;

  END;


// -------------------------------------------------------
//   Attr
// -------------------------------------------------------

  TDOMAttr = CLASS(TDOMNode_WithChildren)
  PROTECTED
    FSpecified: BOOLEAN;
    AttrOwner: TDOMNamedNodeMap;
    FUNCTION  GetNodeValue: DOMString; override;
    PROCEDURE SetNodeValue(AValue: DOMString); override;

    constructor Create(AOwner: TDOMDocument);
  PUBLIC
    FUNCTION CloneNodeOwner(deep: BOOLEAN; ACloneOwner: TDOMDocument): TDOMNode; override;
    property Name: DOMString READ FNodeName;
    property Specified: BOOLEAN READ FSpecified;
    property Value: DOMString READ FNodeValue WRITE SetNodeValue;
  END;


// -------------------------------------------------------
//   Element
// -------------------------------------------------------

  TDOMElement = CLASS(TDOMNode_WithChildren)
  PROTECTED
    FAttributes: TDOMNamedNodeMap;
    FUNCTION GetAttributes: TDOMNamedNodeMap; override;

    constructor Create(AOwner: TDOMDocument); virtual;
  PUBLIC
    destructor Destroy; override;
    FUNCTION  CloneNodeOwner(deep: BOOLEAN; ACloneOwner: TDOMDocument): TDOMNode; OverRide;
    property  TagName: DOMString READ FNodeName;
    FUNCTION  GetAttribute(CONST name: DOMString): DOMString;
    PROCEDURE SetAttribute(CONST name, value: DOMString);
    PROCEDURE RemoveAttribute(CONST name: DOMString);
    FUNCTION  GetAttributeNode(CONST name: DOMString): TDOMAttr;
    PROCEDURE SetAttributeNode(NewAttr: TDOMAttr);
    FUNCTION  RemoveAttributeNode(OldAttr: TDOMAttr): TDOMAttr;
    // Free NodeList WITH TDOMNodeList.Release!
    FUNCTION  GetElementsByTagName(CONST name: DOMString): TDOMNodeList;
    PROCEDURE Normalize;

    property AttribStrings[CONST Name: DOMString]: DOMString
      READ GetAttribute WRITE SetAttribute; default;
  END;


// -------------------------------------------------------
//   Text
// -------------------------------------------------------

  TDOMText = CLASS(TDOMCharacterData)
  PROTECTED
    constructor Create(AOwner: TDOMDocument);
  PUBLIC
    FUNCTION  CloneNodeOwner(deep: BOOLEAN; ACloneOwner: TDOMDocument): TDOMNode; OverRide;
    FUNCTION SplitText(offset: LongWord): TDOMText;
  END;


// -------------------------------------------------------
//   Comment
// -------------------------------------------------------

  TDOMComment = CLASS(TDOMCharacterData)
  PROTECTED
    constructor Create(AOwner: TDOMDocument);
  PUBLIC
    FUNCTION CloneNodeOwner(deep: BOOLEAN; ACloneOwner: TDOMDocument): TDOMNode; OverRide;
  END;


// -------------------------------------------------------
//   CDATASection
// -------------------------------------------------------

  TDOMCDATASection = CLASS(TDOMText)
  PROTECTED
    constructor Create(AOwner: TDOMDocument);
  PUBLIC
    FUNCTION CloneNodeOwner(deep: BOOLEAN; ACloneOwner: TDOMDocument): TDOMNode; override;
  END;


// -------------------------------------------------------
//   DocumentType
// -------------------------------------------------------

  TDOMDocumentType = CLASS(TDOMNode)
  PROTECTED
    FEntities, FNotations: TDOMNamedNodeMap;

    constructor Create(AOwner: TDOMDocument);
  PUBLIC
    FUNCTION CloneNodeOwner(deep: BOOLEAN; ACloneOwner: TDOMDocument): TDOMNode; OverRide;
    property Name: DOMString READ FNodeName;
    property Entities: TDOMNamedNodeMap READ FEntities;
    property Notations: TDOMNamedNodeMap READ FEntities;
  END;


// -------------------------------------------------------
//   Notation
// -------------------------------------------------------

  TDOMNotation = CLASS(TDOMNode)
  PROTECTED
    FPublicID, FSystemID: DOMString;

    constructor Create(AOwner: TDOMDocument);
  PUBLIC
    FUNCTION CloneNodeOwner(deep: BOOLEAN; ACloneOwner: TDOMDocument): TDOMNode; OverRide;
    property PublicID: DOMString READ FPublicID;
    property SystemID: DOMString READ FSystemID;
  END;


// -------------------------------------------------------
//   Entity
// -------------------------------------------------------

  TDOMEntity = CLASS(TDOMNode_WithChildren)
  PROTECTED
    FPublicID, FSystemID, FNotationName: DOMString;

    constructor Create(AOwner: TDOMDocument);
  PUBLIC
    property PublicID: DOMString READ FPublicID;
    property SystemID: DOMString READ FSystemID;
    property NotationName: DOMString READ FNotationName;
  END;


// -------------------------------------------------------
//   EntityReference
// -------------------------------------------------------

  TDOMEntityReference = CLASS(TDOMNode_WithChildren)
  PROTECTED
    constructor Create(AOwner: TDOMDocument);
  END;


// -------------------------------------------------------
//   ProcessingInstruction
// -------------------------------------------------------

  TDOMProcessingInstruction = CLASS(TDOMNode)
  PROTECTED
    constructor Create(AOwner: TDOMDocument);
  PUBLIC
    property Target: DOMString READ FNodeName;
    property Data: DOMString READ FNodeValue;
  END;

PROCEDURE SetXHTMLDocType(doc:TDOMDocument;NName,PubSt,SysSt:DOMString);


// =======================================================
// =======================================================

IMPLEMENTATION


constructor TRefClass.Create;
BEGIN
  inherited Create;
  RefCounter := 1;
END;

FUNCTION TRefClass.AddRef: LONGINT;
BEGIN
  Inc(RefCounter);
  Result := RefCounter;
END;

FUNCTION TRefClass.Release: LONGINT;
BEGIN
  Dec(RefCounter);
  Result := RefCounter;
  IF RefCounter <= 0 THEN Free;
END;


// -------------------------------------------------------
//   DOM Exception
// -------------------------------------------------------

constructor EDOMError.Create(ACode: INTEGER; CONST ASituation: String);
BEGIN
  Code := ACode;
  inherited Create(Self.ClassName + ' in ' + ASituation);
END;

constructor EDOMIndexSize.Create(CONST ASituation: String);    // 1
BEGIN
  inherited Create(INDEX_SIZE_ERR, ASituation);
END;

constructor EDOMHierarchyRequest.Create(CONST ASituation: String);    // 3
BEGIN
  inherited Create(HIERARCHY_REQUEST_ERR, ASituation);
END;

constructor EDOMWrongDocument.Create(CONST ASituation: String);    // 4
BEGIN
  inherited Create(WRONG_DOCUMENT_ERR, ASituation);
END;

constructor EDOMNotFound.Create(CONST ASituation: String);    // 8
BEGIN
  inherited Create(NOT_FOUND_ERR, ASituation);
END;

constructor EDOMNotSupported.Create(CONST ASituation: String);    // 9
BEGIN
  inherited Create(NOT_SUPPORTED_ERR, ASituation);
END;

constructor EDOMInUseAttribute.Create(CONST ASituation: String);    // 10
BEGIN
  inherited Create(INUSE_ATTRIBUTE_ERR, ASituation);
END;

constructor EDOMInvalidState.Create(CONST ASituation: String);    // 11
BEGIN
  inherited Create(INVALID_STATE_ERR, ASituation);
END;

constructor EDOMSyntax.Create(CONST ASituation: String);    // 12
BEGIN
  inherited Create(SYNTAX_ERR, ASituation);
END;

constructor EDOMInvalidModification.Create(CONST ASituation: String);    // 13
BEGIN
  inherited Create(INVALID_MODIFICATION_ERR, ASituation);
END;

constructor EDOMNamespace.Create(CONST ASituation: String);    // 14
BEGIN
  inherited Create(NAMESPACE_ERR, ASituation);
END;

constructor EDOMInvalidAccess.Create(CONST ASituation: String);    // 15
BEGIN
  inherited Create(INVALID_ACCESS_ERR, ASituation);
END;


// -------------------------------------------------------
//   Node
// -------------------------------------------------------

constructor TDOMNode.Create(AOwner: TDOMDocument);
BEGIN
  FOwnerDocument := AOwner;
  inherited Create;
END;

FUNCTION TDOMNode.GetNodeValue: DOMString;
BEGIN
  Result := FNodeValue;
END;

PROCEDURE TDOMNode.SetNodeValue(AValue: DOMString);
BEGIN
  FNodeValue := AValue;
END;

FUNCTION TDOMNode.GetChildNodes: TDOMNodeList;
BEGIN
  Result := TDOMNodeList.Create(Self, '*');
END;

FUNCTION TDOMNode.GetFirstChild: TDOMNode; BEGIN Result := NIL END;
FUNCTION TDOMNode.GetLastChild: TDOMNode; BEGIN Result := NIL END;
FUNCTION TDOMNode.GetAttributes: TDOMNamedNodeMap; BEGIN Result := NIL END;

FUNCTION TDOMNode.InsertBefore(NewChild, RefChild: TDOMNode): TDOMNode;
BEGIN
  raise EDOMHierarchyRequest.Create('Node.InsertBefore');
END;

FUNCTION TDOMNode.ReplaceChild(NewChild, OldChild: TDOMNode): TDOMNode;
BEGIN
  raise EDOMHierarchyRequest.Create('Node.ReplaceChild');
END;

FUNCTION TDOMNode.RemoveChild(OldChild: TDOMNode): TDOMNode;
BEGIN
  raise EDOMHierarchyRequest.Create('Node.RemoveChild');
END;

FUNCTION TDOMNode.AppendChild(NewChild: TDOMNode): TDOMNode;
BEGIN
  raise EDOMHierarchyRequest.Create('Node.AppendChild');
END;

FUNCTION TDOMNode.HasChildNodes: BOOLEAN;
BEGIN
  Result := FALSE;
END;

FUNCTION TDOMNode.CloneNode(deep: BOOLEAN): TDOMNode;
BEGIN
  CloneNode:=CloneNodeOwner(deep, FOwnerDocument);
END;

FUNCTION TDOMNode.CloneNodeOwner(deep: BOOLEAN; ACloneOwner: TDOMDocument): TDOMNode;
BEGIN
  raise EDOMNotSupported.Create('CloneNode not implemented for ' + ClassName);
END;

FUNCTION TDOMNode.FindNode(CONST ANodeName: DOMString): TDOMNode;
VAR
  child: TDOMNode;
BEGIN
  child := FirstChild;
  WHILE Assigned(child) DO
  BEGIN
    IF child.NodeName = ANodeName THEN
    BEGIN
      Result := child;
      EXIT;
    END;
    child := child.NextSibling;
  END;
  Result := NIL;
END;


FUNCTION TDOMNode_WithChildren.GetFirstChild: TDOMNode;
BEGIN
  Result := FFirstChild;
END;

FUNCTION TDOMNode_WithChildren.GetLastChild: TDOMNode;
BEGIN
  Result := FLastChild;
END;

destructor TDOMNode_WithChildren.Destroy;
VAR
  child, next: TDOMNode;
BEGIN
  child := FirstChild;
  WHILE Assigned(child) DO
  BEGIN
    next := child.NextSibling;
    child.Free;
    child := next;
  END;
  inherited Destroy;
END;

FUNCTION TDOMNode_WithChildren.InsertBefore(NewChild, RefChild: TDOMNode):
  TDOMNode;
VAR
  i: INTEGER;
BEGIN
  Result := NewChild;

  IF NOT Assigned(RefChild) THEN
  BEGIN
    AppendChild(NewChild);
    EXIT;
  END;

  IF NewChild.FOwnerDocument <> FOwnerDocument THEN
    raise EDOMWrongDocument.Create('NodeWC.InsertBefore');

  IF RefChild.ParentNode <> Self THEN
    raise EDOMHierarchyRequest.Create('NodeWC.InsertBefore');

  IF NewChild.NodeType = DOCUMENT_FRAGMENT_NODE THEN
    raise EDOMNotSupported.Create('NodeWC.InsertBefore for DocumentFragment');

  NewChild.FNextSibling := RefChild;
  IF RefChild = FFirstChild THEN
    FFirstChild := NewChild
  ELSE BEGIN
//////////****************PATCH BEGIN
    RefChild.FPreviousSibling.FNextSibling := NewChild;
    NewChild.FPreviousSibling:=RefChild.FPreviousSibling;
////////*****************Patch END
  END;

  RefChild.FPreviousSibling := NewChild;
  NewChild.FParentNode := Self;
END;

FUNCTION TDOMNode_WithChildren.ReplaceChild( NewChild, OldChild:TDOMNode):
    TDOMNode;
BEGIN
  InsertBefore(NewChild, OldChild);
  IF Assigned(OldChild) THEN
    RemoveChild(OldChild);
  Result := NewChild;
END;

FUNCTION TDOMNode_WithChildren.RemoveChild(OldChild: TDOMNode):TDOMNode;
VAR
    tNode:TDOMNode;
BEGIN
  IF OldChild.ParentNode <> Self THEN
    raise EDOMHierarchyRequest.Create('NodeWC.RemoveChild');

  IF OldChild = FFirstChild THEN
    FFirstChild := FFirstChild.NextSibling
  ELSE BEGIN
    OldChild.FPreviousSibling.FNextSibling := OldChild.FNextSibling;
  END;
  IF OldChild = FLastChild THEN
    FLastChild := FLastChild.FPreviousSibling
  ELSE
    OldChild.FNextSibling.FPreviousSibling := OldChild.FPreviousSibling;

  OldChild.Free;
END;

FUNCTION TDOMNode_WithChildren.AppendChild(NewChild: TDOMNode): TDOMNode;
VAR
  Parent: TDOMNode;
BEGIN
  IF NewChild.FOwnerDocument <> FOwnerDocument THEN
    raise EDOMWrongDocument.Create('NodeWC.AppendChild');

  Parent := Self;
  WHILE Assigned(Parent) DO
  BEGIN
    IF Parent = NewChild THEN
      raise EDOMHierarchyRequest.Create('NodeWC.AppendChild (cycle in tree)');
    Parent := Parent.ParentNode;
  END;

  IF NewChild.FParentNode = Self THEN
    RemoveChild(NewChild);

  IF NewChild.NodeType = DOCUMENT_FRAGMENT_NODE THEN
    raise EDOMNotSupported.Create('NodeWC.AppendChild for DocumentFragments')
  ELSE BEGIN
    IF Assigned(FFirstChild) THEN
    BEGIN
      FLastChild.FNextSibling := NewChild;
      NewChild.FPreviousSibling := FLastChild;
    END ELSE
      FFirstChild := NewChild;
    FLastChild := NewChild;
    NewChild.FParentNode := Self;
  END;
  Result := NewChild;
END;

FUNCTION TDOMNode_WithChildren.HasChildNodes: BOOLEAN;
BEGIN
  Result := Assigned(FFirstChild);
END;

PROCEDURE TDOMNode_WithChildren.CloneChildren(ACopy: TDOMNode; ACloneOwner: TDOMDocument);
VAR
  node: TDOMNode;
BEGIN
  node := FirstChild;
  WHILE Assigned(node) DO
  BEGIN
    ACopy.AppendChild(node.CloneNodeOwner(True, ACloneOwner));
    node := node.NextSibling;
  END;
END;


// -------------------------------------------------------
//   NodeList
// -------------------------------------------------------

constructor TDOMNodeList.Create(ANode: TDOMNode; AFilter: DOMString);
BEGIN
  inherited Create;
  node := ANode;
  filter := AFilter;
  UseFilter := filter <> '*';
END;

FUNCTION TDOMNodeList.GetCount: LONGINT;
VAR
  child: TDOMNode;
BEGIN
  Result := 0;
  child := node.FirstChild;
  WHILE Assigned(child) DO
  BEGIN
    IF (NOT UseFilter) OR (child.NodeName = filter) THEN
      Inc(Result);
    child := child.NextSibling;
  END;
END;

FUNCTION TDOMNodeList.GetItem(index: LongWord): TDOMNode;
VAR
  child: TDOMNode;
BEGIN
  Result := NIL;
  IF index < 0 THEN
    EXIT;
  child := node.FirstChild;
  WHILE Assigned(child) DO
  BEGIN
    IF index = 0 THEN
    BEGIN
      Result := child;
      break;
    END;
    IF (NOT UseFilter) OR (child.NodeName = filter) THEN
      Dec(index);
    child := child.NextSibling;
  END;
END;


// -------------------------------------------------------
//   NamedNodeMap
// -------------------------------------------------------

constructor TDOMNamedNodeMap.Create(AOwner: TDOMDocument);
BEGIN
  inherited Create;
  OwnerDocument := AOwner;
END;

FUNCTION TDOMNamedNodeMap.GetItem(index: LongWord): TDOMNode;
BEGIN
  Result := TDOMNode(Items[index]);
END;

PROCEDURE TDOMNamedNodeMap.SetItem(index: LongWord; AItem: TDOMNode);
BEGIN
  Items[index] := AItem;
END;

FUNCTION TDOMNamedNodeMap.GetLength: LONGINT;
BEGIN
  Result := Count;
END;

FUNCTION TDOMNamedNodeMap.GetNamedItem(CONST name: DOMString): TDOMNode;
VAR
  i: INTEGER;
BEGIN
  FOR i := 0 TO Count - 1 DO
    IF Item[i].NodeName = name THEN BEGIN
      result:=Item[i];
      EXIT;
    END;
  Result := NIL;
END;

FUNCTION TDOMNamedNodeMap.SetNamedItem(arg: TDOMNode): TDOMNode;
VAR
  i: INTEGER;
BEGIN
  IF arg.FOwnerDocument <> OwnerDocument THEN
    raise EDOMWrongDocument.Create('NamedNodeMap.SetNamedItem');

  IF arg.NodeType = ATTRIBUTE_NODE THEN
  BEGIN
    IF Assigned(TDOMAttr(arg).AttrOwner) THEN
      raise EDOMInUseAttribute.Create('NamedNodeMap.SetNamedItem');
    TDOMAttr(arg).AttrOwner := Self;
  END;

  FOR i := 0 TO Count - 1 DO
    IF Item[i].NodeName = arg.NodeName THEN
    BEGIN
      Result := Item[i];
      Item[i] := arg;
      EXIT;
    END;
  Add(arg);
  Result := NIL;
END;

FUNCTION TDOMNamedNodeMap.RemoveNamedItem(CONST name: DOMString): TDOMNode;
VAR
  i: INTEGER;
BEGIN
  FOR i := 0 TO Count - 1 DO
    IF Item[i].NodeName = name THEN
    BEGIN
      Result := Item[i];
      Result.FParentNode := NIL;
      EXIT;
    END;
  raise EDOMNotFound.Create('NamedNodeMap.RemoveNamedItem');
END;


// -------------------------------------------------------
//   CharacterData
// -------------------------------------------------------

FUNCTION TDOMCharacterData.GetLength: LONGINT;
BEGIN
  Result := system.Length(FNodeValue);
END;

FUNCTION TDOMCharacterData.SubstringData(offset, count: LongWord): DOMString;
BEGIN
  IF (offset < 0) OR (offset > Length) OR (count < 0) THEN
    raise EDOMIndexSize.Create('CharacterData.SubstringData');
  Result := Copy(FNodeValue, offset + 1, count);
END;

PROCEDURE TDOMCharacterData.AppendData(CONST arg: DOMString);
BEGIN
  FNodeValue := FNodeValue + arg;
END;

PROCEDURE TDOMCharacterData.InsertData(offset: LongWord; CONST arg: DOMString);
BEGIN
  IF (offset < 0) OR (offset > Length) THEN
    raise EDOMIndexSize.Create('CharacterData.InsertData');

  FNodeValue := Copy(FNodeValue, 1, offset) + arg +
    Copy(FNodeValue, offset + 1, Length);
END;

PROCEDURE TDOMCharacterData.DeleteData(offset, count: LongWord);
BEGIN
  IF (offset < 0) OR (offset > Length) OR (count < 0) THEN
    raise EDOMIndexSize.Create('CharacterData.DeleteData');

  FNodeValue := Copy(FNodeValue, 1, offset) +
    Copy(FNodeValue, offset + count + 1, Length);
END;

PROCEDURE TDOMCharacterData.ReplaceData(offset, count: LongWord; CONST arg: DOMString);
BEGIN
  DeleteData(offset, count);
  InsertData(offset, arg);
END;


// -------------------------------------------------------
//   DocumentFragmet
// -------------------------------------------------------

constructor TDOMDocumentFragment.Create(AOwner: TDOMDocument);
BEGIN
  FNodeType := DOCUMENT_FRAGMENT_NODE;
  FNodeName := '#document-fragment';
  inherited Create(AOwner);
END;


// -------------------------------------------------------
//   DOMImplementation
// -------------------------------------------------------

FUNCTION TDOMImplementation.HasFeature(CONST feature, version: DOMString):
  BOOLEAN;
BEGIN
  Result := FALSE;
END;

FUNCTION TDOMImplementation.CreateDocumentType(CONST QualifiedName, PublicID,
  SystemID: DOMString): TDOMDocumentType;
BEGIN
  // !!!: Implement this method (easy TO DO)
  raise EDOMNotSupported.Create('DOMImplementation.CreateDocumentType');
END;

FUNCTION TDOMImplementation.CreateDocument(CONST NamespaceURI,
  QualifiedName: DOMString; doctype: TDOMDocumentType): TDOMDocument;
BEGIN
  // !!!: Implement this method (easy TO DO)
  raise EDOMNotSupported.Create('DOMImplementation.CreateDocument');
END;


// -------------------------------------------------------
//   Document
// -------------------------------------------------------

constructor TDOMDocument.Create;
BEGIN
  FNodeType := DOCUMENT_NODE;
  FNodeName := '#document';
  inherited Create(NIL);
  FOwnerDocument := Self;
END;

FUNCTION TDOMDocument.GetDocumentElement: TDOMElement;
VAR
  node: TDOMNode;
BEGIN
  node := FFirstChild;
  WHILE Assigned(node) DO
  BEGIN
    IF node.FNodeType = ELEMENT_NODE THEN
    BEGIN
      Result := TDOMElement(node);
      EXIT;
    END;
    node := node.NextSibling;
  END;
  Result := NIL;
END;

FUNCTION TDOMDocument.CreateElement(CONST tagName: DOMString): TDOMElement;
BEGIN
  Result := TDOMElement.Create(Self);
  Result.FNodeName := tagName;
END;

FUNCTION TDOMDocument.CreateDocumentFragment: TDOMDocumentFragment;
BEGIN
  Result := TDOMDocumentFragment.Create(Self);
END;

FUNCTION TDOMDocument.CreateTextNode(CONST data: DOMString): TDOMText;
BEGIN
  Result := TDOMText.Create(Self);
  Result.FNodeValue := data;
END;

FUNCTION TDOMDocument.CreateComment(CONST data: DOMString): TDOMComment;
BEGIN
  Result := TDOMComment.Create(Self);
  Result.FNodeValue := data;
END;

FUNCTION TDOMDocument.CreateCDATASection(CONST data: DOMString):
  TDOMCDATASection;
BEGIN
  raise EDOMNotSupported.Create('DOMDocument.CreateCDATASection');
END;

FUNCTION TDOMDocument.CreateProcessingInstruction(CONST target,
  data: DOMString): TDOMProcessingInstruction;
BEGIN
  raise EDOMNotSupported.Create('DOMDocument.CreateProcessingInstruction');
END;

FUNCTION TDOMDocument.CreateAttribute(CONST name: DOMString): TDOMAttr;
BEGIN
  Result := TDOMAttr.Create(Self);
  Result.FNodeName := name;
END;

FUNCTION TDOMDocument.CreateEntityReference(CONST name: DOMString):
  TDOMEntityReference;
BEGIN
  raise EDOMNotSupported.Create('DOMDocument.CreateEntityReference');
END;

FUNCTION TDOMDocument.CreateEntity(CONST data: DOMString): TDOMEntity;
BEGIN
  Result := TDOMEntity.Create(Self);
  Result.FNodeName := data;
END;

FUNCTION TDOMDocument.GetElementsByTagName(CONST tagname: DOMString): TDOMNodeList;
BEGIN
  Result := TDOMNodeList.Create(Self, tagname);
END;


FUNCTION TXMLDocument.CreateCDATASection(CONST data: DOMString):
  TDOMCDATASection;
BEGIN
  Result := TDOMCDATASection.Create(Self);
  Result.FNodeValue := data;
END;

FUNCTION TXMLDocument.CreateProcessingInstruction(CONST target,
  data: DOMString): TDOMProcessingInstruction;
BEGIN
  Result := TDOMProcessingInstruction.Create(Self);
  Result.FNodeName := target;
  Result.FNodeValue := data;
END;

FUNCTION TXMLDocument.CreateEntityReference(CONST name: DOMString):
  TDOMEntityReference;
BEGIN
  Result := TDOMEntityReference.Create(Self);
  Result.FNodeName := name;
END;


// -------------------------------------------------------
//   Attr
// -------------------------------------------------------

constructor TDOMAttr.Create(AOwner: TDOMDocument);
BEGIN
  FNodeType := ATTRIBUTE_NODE;
  inherited Create(AOwner);
END;

FUNCTION TDOMAttr.CloneNodeOwner(deep: BOOLEAN; ACloneOwner: TDOMDocument): TDOMNode;
BEGIN
  Result := TDOMAttr.Create(ACloneOwner);
  Result.FNodeName := FNodeName;
  TDOMAttr(Result).FSpecified := FSpecified;
  IF deep THEN
    CloneChildren(Result, ACloneOwner);
END;

FUNCTION TDOMAttr.GetNodeValue: DOMString;
VAR
  child: TDOMNode;
BEGIN
  SetLength(Result, 0);
  IF Assigned(FFirstChild) THEN
  BEGIN
    child := FFirstChild;
    WHILE Assigned(child) DO
    BEGIN
      IF child.NodeType = ENTITY_REFERENCE_NODE THEN
        Result := Result + '&' + child.NodeName + ';'
      ELSE
        Result := Result + child.NodeValue;
      child := child.NextSibling;
    END;
  END;
END;

PROCEDURE TDOMAttr.SetNodeValue(AValue: DOMString);
VAR
  tn: TDOMText;
BEGIN
  FSpecified := True;
  tn := TDOMText.Create(FOwnerDocument);
  tn.FNodeValue := AValue;
  IF Assigned(FFirstChild) THEN
    ReplaceChild(tn, FFirstChild)
  ELSE
    AppendChild(tn);
END;


// -------------------------------------------------------
//   Element
// -------------------------------------------------------

constructor TDOMElement.Create(AOwner: TDOMDocument);
BEGIN
  FNodeType := ELEMENT_NODE;
  inherited Create(AOwner);
  FAttributes := TDOMNamedNodeMap.Create(AOwner);
END;

destructor TDOMElement.Destroy;
VAR
  i: INTEGER;
BEGIN
  {As the attributes are _not_ childs of the element node, we have to free
   them manually here:}
  FOR i := 0 TO FAttributes.Count - 1 DO
      TDOMNamedNodeMap(FAttributes[i]).Free;
  FAttributes.Free;
  inherited Destroy;
END;

FUNCTION TDOMElement.CloneNodeOwner(deep: BOOLEAN; ACloneOwner: TDOMDocument): TDOMNode;
VAR
  i: INTEGER;
  temp:TDOMNode;
BEGIN
  Result := TDOMElement.Create(ACloneOwner);
  Result.FNodeName := FNodeName;
  FOR i := 0 TO FAttributes.Count - 1 DO BEGIN
    temp:=TDOMNode(FAttributes[i]);
    TDOMElement(Result).FAttributes.Add(temp.CloneNodeOwner(True, ACloneOwner));
  END;
  IF deep THEN
    CloneChildren(Result, ACloneOwner);
END;

FUNCTION TDOMElement.GetAttributes: TDOMNamedNodeMap;
BEGIN
  Result := FAttributes;
END;

FUNCTION TDOMElement.GetAttribute(CONST name: DOMString): DOMString;
VAR
  i: INTEGER;
BEGIN
  FOR i := 0 TO FAttributes.Count - 1 DO
    IF TDOMNode(FAttributes[i]).NodeName = name THEN
    BEGIN
      Result := TDOMNode(FAttributes[i]).NodeValue;
      EXIT;
    END;
  SetLength(Result, 0);
END;

PROCEDURE TDOMElement.SetAttribute(CONST name, value: DOMString);
VAR
  i: INTEGER;
  attr: TDOMAttr;
BEGIN
  FOR i := 0 TO FAttributes.Count - 1 DO
    IF TDOMNode(FAttributes[i]).NodeName = name THEN
    BEGIN
      TDOMNode(FAttributes[i]).NodeValue := value;
      EXIT;
    END;
  attr := TDOMAttr.Create(FOwnerDocument);
  attr.FNodeName := name;
  attr.NodeValue := value;
  FAttributes.Add(attr);
END;

PROCEDURE TDOMElement.RemoveAttribute(CONST name: DOMString);
VAR
  i: INTEGER;
BEGIN
  FOR i := 0 TO FAttributes.Count - 1 DO
    IF TDOMNode(FAttributes[i]).NodeName = name THEN
    BEGIN
      TDOMNode(FAttributes[i]).Free;
      FAttributes.Delete(i);
      EXIT;
    END;
END;

FUNCTION TDOMElement.GetAttributeNode(CONST name: DOMString): TDOMAttr;
VAR
  i: INTEGER;
BEGIN
  FOR i := 0 TO FAttributes.Count - 1 DO
    IF TDOMNode(FAttributes[i]).NodeName = name THEN
    BEGIN
      Result := TDOMAttr(TDOMNode(FAttributes[i]));
      EXIT;
    END;
  Result := NIL;
END;

PROCEDURE TDOMElement.SetAttributeNode(NewAttr: TDOMAttr);
VAR
  i: INTEGER;
BEGIN
  FOR i := 0 TO FAttributes.Count - 1 DO
    IF TDOMAttr(FAttributes[i]).NodeName = NewAttr.NodeName THEN
    BEGIN
      TDOMAttr(FAttributes[i]).Free;
      FAttributes[i] := NewAttr;
      EXIT;
    END;
END;

FUNCTION TDOMElement.RemoveAttributeNode(OldAttr: TDOMAttr): TDOMAttr;
VAR
  i: INTEGER;
  node: TDOMNode;
BEGIN
  FOR i := 0 TO FAttributes.Count - 1 DO
  BEGIN
    node := TDOMNode(FAttributes[i]);
    IF node = OldAttr THEN
    BEGIN
      FAttributes.Delete(i);
      Result := TDOMAttr(node);
      EXIT;
    END;
  END;
END;

FUNCTION TDOMElement.GetElementsByTagName(CONST name: DOMString): TDOMNodeList;
BEGIN
  Result := TDOMNodeList.Create(Self, name);
END;

PROCEDURE TDOMElement.Normalize;
BEGIN
  // !!!: NOT implemented
END;


// -------------------------------------------------------
//   Text
// -------------------------------------------------------

constructor TDOMText.Create(AOwner: TDOMDocument);
BEGIN
  FNodeType := TEXT_NODE;
  FNodeName := '#text';
  inherited Create(AOwner);
END;

FUNCTION TDOMText.CloneNodeOwner(deep: BOOLEAN; ACloneOwner: TDOMDocument): TDOMNode;
BEGIN
  Result := TDOMText.Create(ACloneOwner);
  Result.FNodeValue := FNodeValue;
END;

FUNCTION TDOMText.SplitText(offset: LongWord): TDOMText;
VAR
  nt: TDOMText;
BEGIN
  IF offset > Length THEN
    raise EDOMIndexSize.Create('Text.SplitText');

  nt := TDOMText.Create(FOwnerDocument);
  nt.FNodeValue := Copy(FNodeValue, offset + 1, Length);
  FNodeValue := Copy(FNodeValue, 1, offset);
  FParentNode.InsertBefore(nt, FNextSibling);
END;


// -------------------------------------------------------
//   Comment
// -------------------------------------------------------

constructor TDOMComment.Create(AOwner: TDOMDocument);
BEGIN
  FNodeType := COMMENT_NODE;
  FNodeName := '#comment';
  inherited Create(AOwner);
END;

FUNCTION TDOMComment.CloneNodeOwner(deep: BOOLEAN; ACloneOwner: TDOMDocument): TDOMNode;
BEGIN
  Result := TDOMComment.Create(ACloneOwner);
  Result.FNodeValue := FNodeValue;
END;


// -------------------------------------------------------
//   CDATASection
// -------------------------------------------------------

constructor TDOMCDATASection.Create(AOwner: TDOMDocument);
BEGIN
  inherited Create(AOwner);
  FNodeType := CDATA_SECTION_NODE;
  FNodeName := '#cdata-section';
END;

FUNCTION TDOMCDATASection.CloneNodeOwner(deep: BOOLEAN; ACloneOwner: TDOMDocument): TDOMNode;
BEGIN
  Result := TDOMCDATASection.Create(ACloneOwner);
  Result.FNodeValue := FNodeValue;
END;


// -------------------------------------------------------
//   DocumentType
// -------------------------------------------------------

constructor TDOMDocumentType.Create(AOwner: TDOMDocument);
BEGIN
  FNodeType := DOCUMENT_TYPE_NODE;
  inherited Create(AOwner);
END;

FUNCTION TDOMDocumentType.CloneNodeOwner(deep: BOOLEAN; ACloneOwner: TDOMDocument): TDOMNode;
BEGIN
  Result := TDOMDocumentType.Create(ACloneOwner);
  Result.FNodeName := FNodeName;
END;


// -------------------------------------------------------
//   Notation
// -------------------------------------------------------

constructor TDOMNotation.Create(AOwner: TDOMDocument);
BEGIN
  FNodeType := NOTATION_NODE;
  inherited Create(AOwner);
END;

FUNCTION TDOMNotation.CloneNodeOwner(deep: BOOLEAN; ACloneOwner: TDOMDocument): TDOMNode;
BEGIN
  Result := TDOMNotation.Create(ACloneOwner);
  Result.FNodeName := FNodeName;
END;


// -------------------------------------------------------
//   Entity
// -------------------------------------------------------

constructor TDOMEntity.Create(AOwner: TDOMDocument);
BEGIN
  FNodeType := ENTITY_NODE;
  inherited Create(AOwner);
END;


// -------------------------------------------------------
//   EntityReference
// -------------------------------------------------------

constructor TDOMEntityReference.Create(AOwner: TDOMDocument);
BEGIN
  FNodeType := ENTITY_REFERENCE_NODE;
  inherited Create(AOwner);
END;


// -------------------------------------------------------
//   ProcessingInstruction
// -------------------------------------------------------

constructor TDOMProcessingInstruction.Create(AOwner: TDOMDocument);
BEGIN
  FNodeType := PROCESSING_INSTRUCTION_NODE;
  inherited Create(AOwner);
END;

PROCEDURE SetXHTMLDocType(doc:TDOMDocument;NName,PubSt,SysSt:DOMString);
VAR
    XHTMLEntity:TDOMEntity;
BEGIN
    IF Assigned(doc.DocType) THEN BEGIN
        XHTMLEntity:=doc.CreateEntity('xhtml');
        XHTMLEntity.FPublicID:=PubSt;
        XHTMLEntity.FSystemID:=SysSt;
        doc.DocType.FEntities:= TDOMNamedNodeMap.Create(doc);
        doc.DocType.Entities.Add(XHTMLEntity);
        doc.DocType.FNodeName:=NName;
    END;
END;

BEGIN
END.


{
  $Log: DOM.PAS $
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

  Revision 1.1  2000/07/13 06:33:49  michael
  + Initial import

  Revision 1.16  2000/07/09 11:38:33  sg
  * Fixed TDOMNode_WithChildren.RemoveNode for the case when the node to be
    removed is the first child node.

  Revision 1.15  2000/06/29 08:45:05  sg
  * RemoveAttributeNode bugfix

  Revision 1.14  2000/05/04 18:24:22  sg
  * Bugfixes: In some cases the DOM node tree was invalid
  * Simplifications
  * Minor optical improvements

  Revision 1.13  2000/04/20 14:15:45  sg
  * Minor bugfixes
  * Started support for DOM level 2

  Revision 1.12  2000/02/13 10:03:31  sg
  * Hopefully final fix for TDOMDocument.DocumentElement:
    - Reading this property always delivers the first element in the document
    - Removed SetDocumentElement. Use "AppendChild" or one of the other
      generic methods for TDOMNode instead.

  Revision 1.11  2000/01/30 22:18:16  sg
  * Fixed memory leaks, all nodes are now freed by their parent
  * Many cosmetic changes

  Revision 1.10  2000/01/07 01:24:34  peter
    * updated copyright to 2000

  Revision 1.9  2000/01/06 23:55:22  peter
    * childnodes property as that is used instead of getchildnodes
      in the apps

  Revision 1.8  2000/01/06 01:20:36  peter
    * moved out of packages/ back to topdir

  Revision 1.1  2000/01/03 19:33:11  peter
    * moved to packages dir

  Revision 1.6  1999/12/05 22:00:10  sg
  * Bug workaround for problem with "exit(<some string type>)"

  Revision 1.5  1999/07/12 12:19:49  michael
  + More fixes from Sebastian Guenther

  Revision 1.4  1999/07/11 20:20:11  michael
  + Fixes from Sebastian Guenther

  Revision 1.3  1999/07/10 21:48:26  michael
  + Made domelement constructor virtual, needs overriding in thtmlelement

  Revision 1.2  1999/07/09 21:05:49  michael
  + fixes from Guenther Sebastian

  Revision 1.1  1999/07/09 08:35:09  michael
  + Initial implementation by Sebastian Guenther

}
