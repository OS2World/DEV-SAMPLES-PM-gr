{
    $Id: HTMLDOC.PAS 1.1 2006/11/19 13:18:22 Average Exp $
    This file is part of the Free Component Library
    Copyright (c) 1999-2000 by Michael Van Canneyt

    Implementation of a HTMLdocument class,
    following the W3 recommendation.

    See the file COPYING.FPC, included in this distribution,
    for details about the copyright.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 **********************************************************************}
UNIT htmldoc;

INTERFACE

USES Sysutils,   // Uppercase
     Classes,    // TList AND the like
     DOM;        // Naturally...

{ ---------------------------------------------------------------------
    Forward Class definitions
  ---------------------------------------------------------------------}
TYPE

THTMLCollection = CLASS;
THTMLDocument = CLASS;
THTMLElement = CLASS;
THTMLHtmlElement = CLASS;
THTMLHeadElement = CLASS;
THTMLLinkElement = CLASS;
THTMLTitleElement = CLASS;
THTMLMetaElement = CLASS;
THTMLBaseElement = CLASS;
THTMLIsIndexElement = CLASS;
THTMLStyleElement = CLASS;
THTMLBodyElement = CLASS;
THTMLFormElement = CLASS;
THTMLTableSectionElement = CLASS;

{ ---------------------------------------------------------------------
    Miscellaneous objects
  ---------------------------------------------------------------------}

// HTMLCollection
THTMLCollection = CLASS
  PRIVATE
    Flist : TList;
    FUNCTION GetLength : longword;
  PUBLIC
    Constructor Create;
    Destructor Destroy; Override;
    FUNCTION Item(Index : longword) : TDOMNode;
    FUNCTION NamedItem(Name : DomString) : TDOMNode;
    Property Length : LongWord READ GetLength;
  END;

{ ---------------------------------------------------------------------
    THTMLDocument class
  ---------------------------------------------------------------------}

THTMLDocument = CLASS(TDOMDocument)
  PRIVATE
    FTitle,
    FReferrer,
    FDomain,
    FCookie,
    FURL : DOMString;
    FBody : THTMLElement;
    FImages,
    FApplets,
    FLinks,
    FForms,
    Fanchors : THTMLCollection;
  PUBLIC
    Constructor Create; Override;
    Destructor Destroy; Override;

    PROCEDURE Open;
    PROCEDURE Close;
    PROCEDURE WRITE (TheText : DOMString);
    PROCEDURE WRITELN (TheText : DOMString);
    FUNCTION GetElementById (Id :longword) : TDOMElement;
    FUNCTION GetElementByName (Name : DOMString) : TDOMNodeList;

    Property Title : DOMString READ FTitle WRITE FTitle;
    Property Referrer : DOMString READ FReferrer;
    Property Domain : DOMString READ FDomain;
    Property URL : DOMString READ FURL;
    Property Body : THTMLElement READ FBody;
    Property Images : THTMLCollection READ Fimages;
    Property Applets : THTMLCollection READ FApplets;
    Property Links : THTMLCollection READ FLinks;
    Property Forms : THTMLCollection READ FForms;
    Property Anchors : THTMLCollection READ Fanchors;
    Property Cookie : DOMString READ FCookie;
  END;

{ ---------------------------------------------------------------------
    THTMLElement class
  ---------------------------------------------------------------------}

THTMLElement = CLASS(TDOMElement)
  PRIVATE
    FID,
    FTitle,
    FLang,
    FDir,
    FHTMLClassname : DOMString;
  PUBLIC
    Property ID : DOMString READ FID WRITE FID;
    Property Title : DOMString READ FTitle WRITE FTitle;
    Property Lang : DOMString READ FLang WRITE FLang;
    Property Dir : DOMString READ FDir WRITE FDir;
    Property HTMLClassName : DOMString READ FHTMLClassName WRITE FHTMLClassName;
  END;

{ ---------------------------------------------------------------------
    THTMLElement descendent classes
  ---------------------------------------------------------------------}

THTMLHtmlElement = CLASS(THTMLElement)
 PRIVATE
   FVersion : DOMString;
 PUBLIC
   Property Version : DOMString READ FVersion WRITE FVersion;
 END;

THTMLHeadElement = CLASS(THTMLElement)
  PRIVATE
    FProfile : DOMString;
  PUBLIC
    Property Profile : DOMString READ FProfile WRITE FProfile;
  END;

THTMLLinkElement = CLASS(THTMLElement)
  PRIVATE
    FDisabled : BOOLEAN;
    FCharset,
    FHREF,
    FHREFLang,
    FMedia,
    FRel,
    FREV,
    FTarget,
    FHTMLType : DOMString;
  PUBLIC
    Property Disabled : BOOLEAN READ FDisabled WRITE FDisabled;
    Property Charset : DOMString READ FCharset WRITE FCharset;
    Property HREF : DOMString READ FHREF WRITE FHREF;
    Property HREFLang : DOMString READ FHREFLang WRITE FHREFLang;
    Property Media : DOMString READ FMEdia WRITE FMedia;
    Property Rel : DOMString READ FRel WRITE FRel;
    Property Target : DOMString READ FTarget WRITE FTarget;
    Property HTMLType : DOMString READ FHTMLType WRITE FHTMLtype;
  END;

THTMLTitleElement = CLASS(THTMLElement)
  PRIVATE
    FHTMLtext : DOMString;
  PUBLIC
    Property HTMLText : DOMString READ FHTMLText WRITE FHTMLtext;
  END;

THTMLMetaElement = CLASS(THTMLElement)
  PRIVATE
    FContent,
    FhttpEquiv,
    FName,
    FScheme : DOMString;
  PUBLIC
    Property Content : DOMString READ FContent WRITE FContent;
    Property HttpEquiv  : DOMString READ FHTTPEquiv WRITE FHTTPEquiv;
    Property Name : DOMString READ FName WRITE FName;
    Property Scheme : DOMString READ FScheme WRITE FScheme;
  END;

THTMLBaseElement = CLASS(TDOMElement)
  PRIVATE
    FHref,
    FTarget : DOMString;
  PUBLIC
    Property HRef : DOMString READ FHref WRITE FHRef;
    Property Target : DOMstring READ FTarget WRITE FTarget;
  END;

THTMLIsIndexElement = CLASS(THTMLElement)
  PRIVATE
    FForm : THTMLFormElement;
    FPrompt : DomString;
  PUBLIC
    Property Form : THTMLFormElement READ FForm;
    Property Prompt : DOMString READ FPrompt WRITE FPrompt;
  END;


THTMLStyleElement = CLASS(THTMLElement)
  PRIVATE
    FDisabled : BOOLEAN;
    FMEdia,
    FHTMLtype : DOMString;
  PUBLIC
    Property Disabled : BOOLEAN READ FDisabled WRITE FDisabled;
    Property HTMLtype : DOMString READ FHTMLType WRITE FHTMLtype;
  END;

THTMLBodyElement = CLASS(THTMLElement)
  PRIVATE
    Falink,
    Fbackground,
    Fbgcolor,
    flink,
    fhtmltext,
    fvlink : DOMString;
  PUBLIC
    Property alink : DOMString READ falink WRITE falink;
    Property background  : DOMString READ Fbackground WRITE FBackground;
    Property bgcolor : DOMString  READ fbgcolor WRITE fbgcolor;
    Property link : DOMString  READ Flink WRITE flink;
    Property htmltext : DOMString READ fhtmltext WRITE fhtmltext;
    Property vlink : DOMString READ fvLink WRITE fvLink ;
  END;


  THTMLAnchorElement = CLASS(THTMLElement)
    PRIVATE
      FaccessKey : DOMString;
      Fcharset : DOMString;
      Fcoords : DOMString;
      Fhref : DOMString;
      Fhreflang : DOMString;
      Fname : DOMString;
      Frel : DOMString;
      Frev : DOMString;
      Fshape : DOMString;
      FtabIndex : LONGINT;
      Ftarget : DOMString;
      Ftype : DOMString;
    PUBLIC
      PROCEDURE blur;
      PROCEDURE focus;
      Property accessKey : DOMString READ FaccessKey WRITE FaccessKey;
      Property charset : DOMString READ Fcharset WRITE Fcharset;
      Property coords : DOMString READ Fcoords WRITE Fcoords;
      Property href : DOMString READ Fhref WRITE Fhref;
      Property hreflang : DOMString READ Fhreflang WRITE Fhreflang;
      Property name : DOMString READ Fname WRITE Fname;
      Property rel : DOMString READ Frel WRITE Frel;
      Property rev : DOMString READ Frev WRITE Frev;
      Property shape : DOMString READ Fshape WRITE Fshape;
      Property tabIndex : LONGINT READ FtabIndex WRITE FtabIndex;
      Property target : DOMString READ Ftarget WRITE Ftarget;
      Property htmltype : DOMString READ Ftype WRITE Ftype;
  END;

  THTMLAppletElement = CLASS(THTMLElement)
    PRIVATE
      Falign : DOMString;
      Falt : DOMString;
      Farchive : DOMString;
      Fcode : DOMString;
      FcodeBase : DOMString;
      Fheight : DOMString;
      Fhspace : DOMString;
      Fname : DOMString;
      Fobject : DOMString;
      Fvspace : DOMString;
      Fwidth : DOMString;
    PUBLIC
      Property align : DOMString READ Falign WRITE Falign;
      Property alt : DOMString READ Falt WRITE Falt;
      Property archive : DOMString READ Farchive WRITE Farchive;
      Property code : DOMString READ Fcode WRITE Fcode;
      Property codeBase : DOMString READ FcodeBase WRITE FcodeBase;
      Property height : DOMString READ Fheight WRITE Fheight;
      Property hspace : DOMString READ Fhspace WRITE Fhspace;
      Property name : DOMString READ Fname WRITE Fname;
      Property htmlobject : DOMString READ Fobject WRITE Fobject;
      Property vspace : DOMString READ Fvspace WRITE Fvspace;
      Property width : DOMString READ Fwidth WRITE Fwidth;
  END;

  THTMLAreaElement = CLASS(THTMLElement)
    PRIVATE
      FaccessKey : DOMString;
      Falt : DOMString;
      Fcoords : DOMString;
      Fhref : DOMString;
      FnoHref : BOOLEAN;
      Fshape : DOMString;
      FtabIndex : LONGINT;
      Ftarget : DOMString;
    PUBLIC
      Property accessKey : DOMString READ FaccessKey WRITE FaccessKey;
      Property alt : DOMString READ Falt WRITE Falt;
      Property coords : DOMString READ Fcoords WRITE Fcoords;
      Property href : DOMString READ Fhref WRITE Fhref;
      Property noHref : BOOLEAN READ FnoHref WRITE FnoHref;
      Property shape : DOMString READ Fshape WRITE Fshape;
      Property tabIndex : LONGINT READ FtabIndex WRITE FtabIndex;
      Property target : DOMString READ Ftarget WRITE Ftarget;
  END;

  THTMLBaseFontElement = CLASS(THTMLElement)
    PRIVATE
      Fcolor : DOMString;
      Fface : DOMString;
      Fsize : DOMString;
    PUBLIC
      Property color : DOMString READ Fcolor WRITE Fcolor;
      Property face : DOMString READ Fface WRITE Fface;
      Property size : DOMString READ Fsize WRITE Fsize;
  END;

  THTMLBlockquoteElement = CLASS(THTMLElement)
    PRIVATE
      Fcite : DOMString;
    PUBLIC
      Property cite : DOMString READ Fcite WRITE Fcite;
  END;

  THTMLBRElement = CLASS(THTMLElement)
    PRIVATE
      Fclear : DOMString;
    PUBLIC
      Property clear : DOMString READ Fclear WRITE Fclear;
  END;

  THTMLButtonElement = CLASS(THTMLElement)
    PRIVATE
      Fform : THTMLFormElement;
      FaccessKey : DOMString;
      Fdisabled : BOOLEAN;
      Fname : DOMString;
      FtabIndex : LONGINT;
      Ftype : DOMString;
      Fvalue : DOMString;
    PUBLIC
      Property form : THTMLFormElement READ Fform;
      Property accessKey : DOMString READ FaccessKey WRITE FaccessKey;
      Property disabled : BOOLEAN READ Fdisabled WRITE Fdisabled;
      Property name : DOMString READ Fname WRITE Fname;
      Property tabIndex : LONGINT READ FtabIndex WRITE FtabIndex;
      Property htmltype : DOMString READ Ftype;
      Property value : DOMString READ Fvalue WRITE Fvalue;
  END;

  THTMLDirectoryElement = CLASS(THTMLElement)
    PRIVATE
      Fcompact : BOOLEAN;
    PUBLIC
      Property compact : BOOLEAN READ Fcompact WRITE Fcompact;
  END;

  THTMLDivElement = CLASS(THTMLElement)
    PRIVATE
      Falign : DOMString;
    PUBLIC
      Property align : DOMString READ Falign WRITE Falign;
  END;

  THTMLDListElement = CLASS(THTMLElement)
    PRIVATE
      Fcompact : BOOLEAN;
    PUBLIC
      Property compact : BOOLEAN READ Fcompact WRITE Fcompact;
  END;

  THTMLFieldSetElement = CLASS(THTMLElement)
    PRIVATE
      Fform : THTMLFormElement;
    PUBLIC
      Property form : THTMLFormElement READ Fform;
  END;

  THTMLFontElement = CLASS(THTMLElement)
    PRIVATE
      Fcolor : DOMString;
      Fface : DOMString;
      Fsize : DOMString;
    PUBLIC
      Property color : DOMString READ Fcolor WRITE Fcolor;
      Property face : DOMString READ Fface WRITE Fface;
      Property size : DOMString READ Fsize WRITE Fsize;
  END;

  THTMLFormElement = CLASS(THTMLElement)
    PRIVATE
      Felements : THTMLCollection;
      Flength : LONGINT;
      Fname : DOMString;
      FacceptCharset : DOMString;
      Faction : DOMString;
      Fenctype : DOMString;
      Fmethod : DOMString;
      Ftarget : DOMString;
    PUBLIC
      Constructor Create(AOwner : TDOMDocument);override;
      Destructor Destroy;override;
      PROCEDURE submit;
      PROCEDURE reset;
      Property elements : THTMLCollection READ Felements;
      Property length : LONGINT READ Flength;
      Property name : DOMString READ Fname WRITE Fname;
      Property acceptCharset : DOMString READ FacceptCharset WRITE FacceptCharset;
      Property action : DOMString READ Faction WRITE Faction;
      Property enctype : DOMString READ Fenctype WRITE Fenctype;
      Property method : DOMString READ Fmethod WRITE Fmethod;
      Property target : DOMString READ Ftarget WRITE Ftarget;
  END;

  THTMLFrameElement = CLASS(THTMLElement)
    PRIVATE
      FframeBorder : DOMString;
      FlongDesc : DOMString;
      FmarginHeight : DOMString;
      FmarginWidth : DOMString;
      Fname : DOMString;
      FnoResize : BOOLEAN;
      Fscrolling : DOMString;
      Fsrc : DOMString;
    PUBLIC
      Property frameBorder : DOMString READ FframeBorder WRITE FframeBorder;
      Property longDesc : DOMString READ FlongDesc WRITE FlongDesc;
      Property marginHeight : DOMString READ FmarginHeight WRITE FmarginHeight;
      Property marginWidth : DOMString READ FmarginWidth WRITE FmarginWidth;
      Property name : DOMString READ Fname WRITE Fname;
      Property noResize : BOOLEAN READ FnoResize WRITE FnoResize;
      Property scrolling : DOMString READ Fscrolling WRITE Fscrolling;
      Property src : DOMString READ Fsrc WRITE Fsrc;
  END;

  THTMLFrameSetElement = CLASS(THTMLElement)
    PRIVATE
      Fcols : DOMString;
      Frows : DOMString;
    PUBLIC
      Property cols : DOMString READ Fcols WRITE Fcols;
      Property rows : DOMString READ Frows WRITE Frows;
  END;


  THTMLHeadingElement = CLASS(THTMLElement)
    PRIVATE
      Falign : DOMString;
    PUBLIC
      Property align : DOMString READ Falign WRITE Falign;
  END;

  THTMLHRElement = CLASS(THTMLElement)
    PRIVATE
      Falign : DOMString;
      FnoShade : BOOLEAN;
      Fsize : DOMString;
      Fwidth : DOMString;
    PUBLIC
      Property align : DOMString READ Falign WRITE Falign;
      Property noShade : BOOLEAN READ FnoShade WRITE FnoShade;
      Property size : DOMString READ Fsize WRITE Fsize;
      Property width : DOMString READ Fwidth WRITE Fwidth;
  END;


  THTMLIFrameElement = CLASS(THTMLElement)
    PRIVATE
      Falign : DOMString;
      FframeBorder : DOMString;
      Fheight : DOMString;
      FlongDesc : DOMString;
      FmarginHeight : DOMString;
      FmarginWidth : DOMString;
      Fname : DOMString;
      Fscrolling : DOMString;
      Fsrc : DOMString;
      Fwidth : DOMString;
    PUBLIC
      Property align : DOMString READ Falign WRITE Falign;
      Property frameBorder : DOMString READ FframeBorder WRITE FframeBorder;
      Property height : DOMString READ Fheight WRITE Fheight;
      Property longDesc : DOMString READ FlongDesc WRITE FlongDesc;
      Property marginHeight : DOMString READ FmarginHeight WRITE FmarginHeight;
      Property marginWidth : DOMString READ FmarginWidth WRITE FmarginWidth;
      Property name : DOMString READ Fname WRITE Fname;
      Property scrolling : DOMString READ Fscrolling WRITE Fscrolling;
      Property src : DOMString READ Fsrc WRITE Fsrc;
      Property width : DOMString READ Fwidth WRITE Fwidth;
  END;

  THTMLImageElement = CLASS(THTMLElement)
    PRIVATE
      FlowSrc : DOMString;
      Fname : DOMString;
      Falign : DOMString;
      Falt : DOMString;
      Fborder : DOMString;
      Fheight : DOMString;
      Fhspace : DOMString;
      FisMap : BOOLEAN;
      FlongDesc : DOMString;
      Fsrc : DOMString;
      FuseMap : DOMString;
      Fvspace : DOMString;
      Fwidth : DOMString;
    PUBLIC
      Property lowSrc : DOMString READ FlowSrc WRITE FlowSrc;
      Property name : DOMString READ Fname WRITE Fname;
      Property align : DOMString READ Falign WRITE Falign;
      Property alt : DOMString READ Falt WRITE Falt;
      Property border : DOMString READ Fborder WRITE Fborder;
      Property height : DOMString READ Fheight WRITE Fheight;
      Property hspace : DOMString READ Fhspace WRITE Fhspace;
      Property isMap : BOOLEAN READ FisMap WRITE FisMap;
      Property longDesc : DOMString READ FlongDesc WRITE FlongDesc;
      Property src : DOMString READ Fsrc WRITE Fsrc;
      Property useMap : DOMString READ FuseMap WRITE FuseMap;
      Property vspace : DOMString READ Fvspace WRITE Fvspace;
      Property width : DOMString READ Fwidth WRITE Fwidth;
  END;

  THTMLInputElement = CLASS(THTMLElement)
    PRIVATE
      FdefaultValue : DOMString;
      FdefaultChecked : BOOLEAN;
      Fform : THTMLFormElement;
      Faccept : DOMString;
      FaccessKey : DOMString;
      Falign : DOMString;
      Falt : DOMString;
      Fchecked : BOOLEAN;
      Fdisabled : BOOLEAN;
      FmaxLength : LONGINT;
      Fname : DOMString;
      FreadOnly : BOOLEAN;
      Fsize : DOMString;
      Fsrc : DOMString;
      FtabIndex : LONGINT;
      Ftype : DOMString;
      FuseMap : DOMString;
      Fvalue : DOMString;
    PUBLIC
      PROCEDURE blur;
      PROCEDURE focus;
      PROCEDURE select;
      PROCEDURE click;
      Property defaultValue : DOMString READ FdefaultValue WRITE FdefaultValue;
      Property defaultChecked : BOOLEAN READ FdefaultChecked WRITE FdefaultChecked;
      Property form : THTMLFormElement READ Fform;
      Property accept : DOMString READ Faccept WRITE Faccept;
      Property accessKey : DOMString READ FaccessKey WRITE FaccessKey;
      Property align : DOMString READ Falign WRITE Falign;
      Property alt : DOMString READ Falt WRITE Falt;
      Property checked : BOOLEAN READ Fchecked WRITE Fchecked;
      Property disabled : BOOLEAN READ Fdisabled WRITE Fdisabled;
      Property maxLength : LONGINT READ FmaxLength WRITE FmaxLength;
      Property name : DOMString READ Fname WRITE Fname;
      Property readOnly : BOOLEAN READ FreadOnly WRITE FreadOnly;
      Property size : DOMString READ Fsize WRITE Fsize;
      Property src : DOMString READ Fsrc WRITE Fsrc;
      Property tabIndex : LONGINT READ FtabIndex WRITE FtabIndex;
      Property htmltype : DOMString READ Ftype;
      Property useMap : DOMString READ FuseMap WRITE FuseMap;
      Property value : DOMString READ Fvalue WRITE Fvalue;
  END;

  THTMLLabelElement = CLASS(THTMLElement)
    PRIVATE
      Fform : THTMLFormElement;
      FaccessKey : DOMString;
      FhtmlFor : DOMString;
    PUBLIC
      Property form : THTMLFormElement READ Fform;
      Property accessKey : DOMString READ FaccessKey WRITE FaccessKey;
      Property htmlFor : DOMString READ FhtmlFor WRITE FhtmlFor;
  END;

  THTMLLegendElement = CLASS(THTMLElement)
    PRIVATE
      Fform : THTMLFormElement;
      FaccessKey : DOMString;
      Falign : DOMString;
    PUBLIC
      Property form : THTMLFormElement READ Fform;
      Property accessKey : DOMString READ FaccessKey WRITE FaccessKey;
      Property align : DOMString READ Falign WRITE Falign;
  END;

  THTMLLIElement = CLASS(THTMLElement)
    PRIVATE
      Ftype : DOMString;
      Fvalue : LONGINT;
    PUBLIC
      Property htmltype : DOMString READ Ftype WRITE Ftype;
      Property value : LONGINT READ Fvalue WRITE Fvalue;
  END;

  THTMLMapElement = CLASS(THTMLElement)
    PRIVATE
      Fareas : THTMLCollection;
      Fname : DOMString;
    PUBLIC
      Property areas : THTMLCollection READ Fareas;
      Property name : DOMString READ Fname WRITE Fname;
  END;

  THTMLMenuElement = CLASS(THTMLElement)
    PRIVATE
      Fcompact : BOOLEAN;
    PUBLIC
      Property compact : BOOLEAN READ Fcompact WRITE Fcompact;
  END;


  THTMLModElement = CLASS(THTMLElement)
    PRIVATE
      Fcite : DOMString;
      FdateTime : DOMString;
    PUBLIC
      Property cite : DOMString READ Fcite WRITE Fcite;
      Property dateTime : DOMString READ FdateTime WRITE FdateTime;
  END;

  THTMLObjectElement = CLASS(THTMLElement)
    PRIVATE
      Fform : THTMLFormElement;
      Fcode : DOMString;
      Falign : DOMString;
      Farchive : DOMString;
      Fborder : DOMString;
      FcodeBase : DOMString;
      FcodeType : DOMString;
      Fdata : DOMString;
      Fdeclare : BOOLEAN;
      Fheight : DOMString;
      Fhspace : DOMString;
      Fname : DOMString;
      Fstandby : DOMString;
      FtabIndex : LONGINT;
      Ftype : DOMString;
      FuseMap : DOMString;
      Fvspace : DOMString;
      Fwidth : DOMString;
    PUBLIC
      Property form : THTMLFormElement READ Fform;
      Property code : DOMString READ Fcode WRITE Fcode;
      Property align : DOMString READ Falign WRITE Falign;
      Property archive : DOMString READ Farchive WRITE Farchive;
      Property border : DOMString READ Fborder WRITE Fborder;
      Property codeBase : DOMString READ FcodeBase WRITE FcodeBase;
      Property codeType : DOMString READ FcodeType WRITE FcodeType;
      Property data : DOMString READ Fdata WRITE Fdata;
      Property declare : BOOLEAN READ Fdeclare WRITE Fdeclare;
      Property height : DOMString READ Fheight WRITE Fheight;
      Property hspace : DOMString READ Fhspace WRITE Fhspace;
      Property name : DOMString READ Fname WRITE Fname;
      Property standby : DOMString READ Fstandby WRITE Fstandby;
      Property tabIndex : LONGINT READ FtabIndex WRITE FtabIndex;
      Property htmltype : DOMString READ Ftype WRITE Ftype;
      Property useMap : DOMString READ FuseMap WRITE FuseMap;
      Property vspace : DOMString READ Fvspace WRITE Fvspace;
      Property width : DOMString READ Fwidth WRITE Fwidth;
  END;

  THTMLOListElement = CLASS(THTMLElement)
    PRIVATE
      Fcompact : BOOLEAN;
      Fstart : LONGINT;
      Ftype : DOMString;
    PUBLIC
      Property compact : BOOLEAN READ Fcompact WRITE Fcompact;
      Property start : LONGINT READ Fstart WRITE Fstart;
      Property htmltype : DOMString READ Ftype WRITE Ftype;
  END;

  THTMLOptGroupElement = CLASS(THTMLElement)
    PRIVATE
      Fdisabled : BOOLEAN;
      Flabel : DOMString;
    PUBLIC
      Property disabled : BOOLEAN READ Fdisabled WRITE Fdisabled;
      Property htmllabel : DOMString READ Flabel WRITE Flabel;
  END;

  THTMLOptionElement = CLASS(THTMLElement)
    PRIVATE
      Fform : THTMLFormElement;
      FdefaultSelected : BOOLEAN;
      Ftext : DOMString;
      Findex : LONGINT;
      Fdisabled : BOOLEAN;
      Flabel : DOMString;
      Fselected : BOOLEAN;
      Fvalue : DOMString;
    PUBLIC
      Property form : THTMLFormElement READ Fform;
      Property defaultSelected : BOOLEAN READ FdefaultSelected WRITE FdefaultSelected;
      Property htmltext : DOMString READ Ftext;
      Property index : LONGINT READ Findex WRITE Findex;
      Property disabled : BOOLEAN READ Fdisabled WRITE Fdisabled;
      Property htmllabel : DOMString READ Flabel WRITE Flabel;
      Property selected : BOOLEAN READ Fselected;
      Property value : DOMString READ Fvalue WRITE Fvalue;
  END;

  THTMLParagraphElement = CLASS(THTMLElement)
    PRIVATE
      Falign : DOMString;
    PUBLIC
      Property align : DOMString READ Falign WRITE Falign;
  END;

  THTMLParamElement = CLASS(THTMLElement)
    PRIVATE
      Fname : DOMString;
      Ftype : DOMString;
      Fvalue : DOMString;
      FvalueType : DOMString;
    PUBLIC
      Property name : DOMString READ Fname WRITE Fname;
      Property htmltype : DOMString READ Ftype WRITE Ftype;
      Property value : DOMString READ Fvalue WRITE Fvalue;
      Property valueType : DOMString READ FvalueType WRITE FvalueType;
  END;

  THTMLPreElement = CLASS(THTMLElement)
    PRIVATE
      Fwidth : LONGINT;
    PUBLIC
      Property width : LONGINT READ Fwidth WRITE Fwidth;
  END;

  THTMLQuoteElement = CLASS(THTMLElement)
    PRIVATE
      Fcite : DOMString;
    PUBLIC
      Property cite : DOMString READ Fcite WRITE Fcite;
  END;

  THTMLScriptElement = CLASS(THTMLElement)
    PRIVATE
      Ftext : DOMString;
      FhtmlFor : DOMString;
      Fevent : DOMString;
      Fcharset : DOMString;
      Fdefer : BOOLEAN;
      Fsrc : DOMString;
      Ftype : DOMString;
    PUBLIC
      Property htmltext : DOMString READ Ftext WRITE Ftext;
      Property htmlFor : DOMString READ FhtmlFor WRITE FhtmlFor;
      Property event : DOMString READ Fevent WRITE Fevent;
      Property charset : DOMString READ Fcharset WRITE Fcharset;
      Property defer : BOOLEAN READ Fdefer WRITE Fdefer;
      Property src : DOMString READ Fsrc WRITE Fsrc;
      Property htmltype : DOMString READ Ftype WRITE Ftype;
  END;

  THTMLSelectElement = CLASS(THTMLElement)
    PRIVATE
      Ftype : DOMString;
      FselectedIndex : LONGINT;
      Fvalue : DOMString;
      Flength : LONGINT;
      Fform : THTMLFormElement;
      Foptions : THTMLCollection;
      Fdisabled : BOOLEAN;
      Fmultiple : BOOLEAN;
      Fname : DOMString;
      Fsize : LONGINT;
      FtabIndex : LONGINT;
    PUBLIC
      PROCEDURE add;
      PROCEDURE remove;
      PROCEDURE blur;
      PROCEDURE focus;
      Property htmltype : DOMString READ Ftype;
      Property selectedIndex : LONGINT READ FselectedIndex WRITE FselectedIndex;
      Property value : DOMString READ Fvalue WRITE Fvalue;
      Property length : LONGINT READ Flength;
      Property form : THTMLFormElement READ Fform;
      Property options : THTMLCollection READ Foptions;
      Property disabled : BOOLEAN READ Fdisabled WRITE Fdisabled;
      Property multiple : BOOLEAN READ Fmultiple WRITE Fmultiple;
      Property name : DOMString READ Fname WRITE Fname;
      Property size : LONGINT READ Fsize WRITE Fsize;
      Property tabIndex : LONGINT READ FtabIndex WRITE FtabIndex;
  END;

  THTMLTableCaptionElement = CLASS(THTMLElement)
    PRIVATE
      Falign : DOMString;
    PUBLIC
      Property align : DOMString READ Falign WRITE Falign;
  END;

  THTMLTableCellElement = CLASS(THTMLElement)
    PRIVATE
      FcellIndex : LONGINT;
      Fabbr : DOMString;
      Falign : DOMString;
      Faxis : DOMString;
      FbgColor : DOMString;
      Fch : DOMString;
      FchOff : DOMString;
      FcolSpan : LONGINT;
      Fheaders : DOMString;
      Fheight : DOMString;
      FnoWrap : BOOLEAN;
      FrowSpan : LONGINT;
      Fscope : DOMString;
      FvAlign : DOMString;
      Fwidth : DOMString;
    PUBLIC
      Property cellIndex : LONGINT READ FcellIndex WRITE FcellIndex;
      Property abbr : DOMString READ Fabbr WRITE Fabbr;
      Property align : DOMString READ Falign WRITE Falign;
      Property axis : DOMString READ Faxis WRITE Faxis;
      Property bgColor : DOMString READ FbgColor WRITE FbgColor;
      Property ch : DOMString READ Fch WRITE Fch;
      Property chOff : DOMString READ FchOff WRITE FchOff;
      Property colSpan : LONGINT READ FcolSpan WRITE FcolSpan;
      Property headers : DOMString READ Fheaders WRITE Fheaders;
      Property height : DOMString READ Fheight WRITE Fheight;
      Property noWrap : BOOLEAN READ FnoWrap WRITE FnoWrap;
      Property rowSpan : LONGINT READ FrowSpan WRITE FrowSpan;
      Property scope : DOMString READ Fscope WRITE Fscope;
      Property vAlign : DOMString READ FvAlign WRITE FvAlign;
      Property width : DOMString READ Fwidth WRITE Fwidth;
  END;

  THTMLTableColElement = CLASS(THTMLElement)
    PRIVATE
      Falign : DOMString;
      Fch : DOMString;
      FchOff : DOMString;
      Fspan : LONGINT;
      FvAlign : DOMString;
      Fwidth : DOMString;
    PUBLIC
      Property align : DOMString READ Falign WRITE Falign;
      Property ch : DOMString READ Fch WRITE Fch;
      Property chOff : DOMString READ FchOff WRITE FchOff;
      Property span : LONGINT READ Fspan WRITE Fspan;
      Property vAlign : DOMString READ FvAlign WRITE FvAlign;
      Property width : DOMString READ Fwidth WRITE Fwidth;
  END;

  THTMLTableElement = CLASS(THTMLElement)
    PRIVATE
      Fcaption : THTMLTableCaptionElement;
      FtHead : THTMLTableSectionElement;
      FtFoot : THTMLTableSectionElement;
      Frows : THTMLCollection;
      FtBodies : THTMLCollection;
      Falign : DOMString;
      FbgColor : DOMString;
      Fborder : DOMString;
      FcellPadding : DOMString;
      FcellSpacing : DOMString;
      Fframe : DOMString;
      Frules : DOMString;
      Fsummary : DOMString;
      Fwidth : DOMString;
    PUBLIC
      FUNCTION createTHead : THTMLElement;
      PROCEDURE deleteTHead;
      FUNCTION createTFoot : THTMLElement;
      PROCEDURE deleteTFoot;
      FUNCTION createCaption : THTMLElement;
      PROCEDURE deleteCaption;
      FUNCTION insertRow : THTMLElement;
      PROCEDURE deleteRow;
      Property caption : THTMLTableCaptionElement READ Fcaption WRITE Fcaption;
      Property tHead : THTMLTableSectionElement READ FtHead WRITE FtHead;
      Property tFoot : THTMLTableSectionElement READ FtFoot WRITE FtFoot;
      Property rows : THTMLCollection READ Frows;
      Property tBodies : THTMLCollection READ FtBodies;
      Property align : DOMString READ Falign WRITE Falign;
      Property bgColor : DOMString READ FbgColor WRITE FbgColor;
      Property border : DOMString READ Fborder WRITE Fborder;
      Property cellPadding : DOMString READ FcellPadding WRITE FcellPadding;
      Property cellSpacing : DOMString READ FcellSpacing WRITE FcellSpacing;
      Property frame : DOMString READ Fframe WRITE Fframe;
      Property rules : DOMString READ Frules WRITE Frules;
      Property summary : DOMString READ Fsummary WRITE Fsummary;
      Property width : DOMString READ Fwidth WRITE Fwidth;
  END;

  THTMLTableRowElement = CLASS(THTMLElement)
    PRIVATE
      FrowIndex : LONGINT;
      FsectionRowIndex : LONGINT;
      Fcells : THTMLCollection;
      Falign : DOMString;
      FbgColor : DOMString;
      Fch : DOMString;
      FchOff : DOMString;
      FvAlign : DOMString;
    PUBLIC
      FUNCTION insertCell : THTMLElement;
      PROCEDURE deleteCell;
      Property rowIndex : LONGINT READ FrowIndex WRITE FrowIndex;
      Property sectionRowIndex : LONGINT READ FsectionRowIndex WRITE FsectionRowIndex;
      Property cells : THTMLCollection READ Fcells WRITE Fcells;
      Property align : DOMString READ Falign WRITE Falign;
      Property bgColor : DOMString READ FbgColor WRITE FbgColor;
      Property ch : DOMString READ Fch WRITE Fch;
      Property chOff : DOMString READ FchOff WRITE FchOff;
      Property vAlign : DOMString READ FvAlign WRITE FvAlign;
  END;

  THTMLTableSectionElement = CLASS(THTMLElement)
    PRIVATE
      Falign : DOMString;
      Fch : DOMString;
      FchOff : DOMString;
      FvAlign : DOMString;
      Frows : THTMLCollection;
    PUBLIC
      FUNCTION insertRow : THTMLElement;
      PROCEDURE deleteRow;
      Property align : DOMString READ Falign WRITE Falign;
      Property ch : DOMString READ Fch WRITE Fch;
      Property chOff : DOMString READ FchOff WRITE FchOff;
      Property vAlign : DOMString READ FvAlign WRITE FvAlign;
      Property rows : THTMLCollection READ Frows;
  END;

  THTMLTextAreaElement = CLASS(THTMLElement)
    PRIVATE
      FdefaultValue : DOMString;
      Fform : THTMLFormElement;
      FaccessKey : DOMString;
      Fcols : LONGINT;
      Fdisabled : BOOLEAN;
      Fname : DOMString;
      FreadOnly : BOOLEAN;
      Frows : LONGINT;
      FtabIndex : LONGINT;
      Ftype : DOMString;
      Fvalue : DOMString;
    PUBLIC
      PROCEDURE blur;
      PROCEDURE focus;
      PROCEDURE select;
      Property defaultValue : DOMString READ FdefaultValue WRITE FdefaultValue;
      Property form : THTMLFormElement READ Fform;
      Property accessKey : DOMString READ FaccessKey WRITE FaccessKey;
      Property cols : LONGINT READ Fcols WRITE Fcols;
      Property disabled : BOOLEAN READ Fdisabled WRITE Fdisabled;
      Property name : DOMString READ Fname WRITE Fname;
      Property readOnly : BOOLEAN READ FreadOnly WRITE FreadOnly;
      Property rows : LONGINT READ Frows WRITE Frows;
      Property tabIndex : LONGINT READ FtabIndex WRITE FtabIndex;
      Property htmltype : DOMString READ Ftype;
      Property value : DOMString READ Fvalue WRITE Fvalue;
  END;

  THTMLUListElement = CLASS(THTMLElement)
    PRIVATE
      Fcompact : BOOLEAN;
      Ftype : DOMString;
    PUBLIC
      Property compact : BOOLEAN READ Fcompact WRITE Fcompact;
      Property htmltype : DOMString READ Ftype WRITE Ftype;
  END;

IMPLEMENTATION

{ ---------------------------------------------------------------------
    THTMLCollection
  ---------------------------------------------------------------------}

Constructor THTMLCollection.Create;

BEGIN
  FList := TList.Create;
END;

Destructor THTMLCollection.Destroy;

BEGIN
  FList.Free;
  Inherited Destroy;
END;

FUNCTION THTMLCollection.GetLength : LongWord;

BEGIN
  Result:=FList.Count;
END;

FUNCTION THTMLCollection.Item(Index : longword) : TDOMNode;

BEGIN
  IF (Index<0) OR (Index>Flist.Count-1) THEN
    Result:=NIL
  ELSE
    Result:=TDOMNode(Flist[Index]);
END;

FUNCTION THTMLCollection.NamedItem(Name : DomString) : TDOMNode;

VAR I : longword;

BEGIN
  Name:=UpperCase(Name);
  // linear search, since the list is NOT ordered.
  // W3 says nothing about ordering; maybe we can implement it ?
  FOR i:=0 TO FList.Count-1 DO
    IF UpperCase(TDomNode(FList[i]).NodeName)=Name THEN
      BEGIN
      Result:=TDomNode(Flist[I]);
      EXIT;
      END;
  Result:=NIL;
END;

{ ---------------------------------------------------------------------
    THTMLDocument class
  ---------------------------------------------------------------------}


Constructor THTMLDocument.Create;

BEGIN
  Inherited Create;
END;


Destructor THTMLDocument.Destroy;

BEGIN
  Inherited Destroy;
END;


PROCEDURE THTMLDocument.Open;

BEGIN
END;


PROCEDURE THTMLDocument.Close;

BEGIN
END;


PROCEDURE THTMLDocument.WRITE (TheText : DOMString);

BEGIN
END;


PROCEDURE THTMLDocument.WRITELN (TheText : DOMString);

BEGIN
END;


FUNCTION THTMLDocument.GetElementById (Id :longword) : TDOMElement;

BEGIN
END;


FUNCTION THTMLDocument.GetElementByName (Name : DOMString) : TDOMNodeList;

BEGIN
END;


Constructor THTMLFormElement.Create(AOwner : TDOMDocument);

BEGIN
  Inherited Create(AOWner);
  FElements:=THTMLCollection.Create;
END;


Destructor THTMLFormElement.Destroy;

BEGIN
  FElements.Free;
  Inherited Destroy;
END;

PROCEDURE THTMLFormElement.Submit;

BEGIN
END;

PROCEDURE THTMLFormElement.Reset;

BEGIN
END;

// Created From file htmlanchorelement.xml
PROCEDURE THTMLAnchorElement.blur;

BEGIN
END;


PROCEDURE THTMLAnchorElement.focus;

BEGIN
END;



PROCEDURE THTMLInputElement.blur;

BEGIN
END;


PROCEDURE THTMLInputElement.focus;

BEGIN
END;


PROCEDURE THTMLInputElement.select;

BEGIN
END;


PROCEDURE THTMLInputElement.click;

BEGIN
END;


PROCEDURE THTMLSelectElement.add;

BEGIN
END;


PROCEDURE THTMLSelectElement.remove;

BEGIN
END;


PROCEDURE THTMLSelectElement.blur;

BEGIN
END;


PROCEDURE THTMLSelectElement.focus;

BEGIN
END;


FUNCTION THTMLTableElement.createTHead : THTMLElement;

BEGIN
END;


PROCEDURE THTMLTableElement.deleteTHead;

BEGIN
END;


FUNCTION THTMLTableElement.createTFoot : THTMLElement;

BEGIN
END;


PROCEDURE THTMLTableElement.deleteTFoot;

BEGIN
END;


FUNCTION THTMLTableElement.createCaption : THTMLElement;

BEGIN
END;


PROCEDURE THTMLTableElement.deleteCaption;

BEGIN
END;


FUNCTION THTMLTableElement.insertRow : THTMLElement;

BEGIN
END;


PROCEDURE THTMLTableElement.deleteRow;

BEGIN
END;


// Created From file htmltablerowelement.xml
FUNCTION THTMLTableRowElement.insertCell : THTMLElement;

BEGIN
END;


PROCEDURE THTMLTableRowElement.deleteCell;

BEGIN
END;


// Created From file htmltablesectionelement.xml
FUNCTION THTMLTableSectionElement.insertRow : THTMLElement;

BEGIN
END;


PROCEDURE THTMLTableSectionElement.deleteRow;

BEGIN
END;


// Created From file htmltextareaelement.xml
PROCEDURE THTMLTextAreaElement.blur;

BEGIN
END;


PROCEDURE THTMLTextAreaElement.focus;

BEGIN
END;


PROCEDURE THTMLTextAreaElement.select;

BEGIN
END;


END.
