head	7.0;
access;
symbols;
locks;
comment	@ * @;


7.0
date	2008.06.08.03.33.19;	author Average;	state Exp;
branches;
next	6.3;

6.3
date	2007.07.22.12.09.38;	author Average;	state Exp;
branches;
next	6.2;

6.2
date	2007.07.22.12.00.04;	author Average;	state Exp;
branches;
next	6.1;

6.1
date	2007.07.21.18.25.24;	author Average;	state Exp;
branches;
next	5.2;

5.2
date	2007.07.07.13.51.26;	author Average;	state Exp;
branches;
next	5.1;

5.1
date	2007.07.04.12.44.23;	author Average;	state Exp;
branches;
next	4.6;

4.6
date	2007.07.01.12.59.41;	author Average;	state Exp;
branches;
next	4.5;

4.5
date	2007.06.27.14.32.59;	author Average;	state Exp;
branches;
next	4.4;

4.4
date	2007.06.26.14.45.58;	author Average;	state Exp;
branches;
next	4.3;

4.3
date	2007.06.26.14.03.08;	author Average;	state Exp;
branches;
next	4.2;

4.2
date	2007.06.25.15.49.58;	author Average;	state Exp;
branches;
next	4.1;

4.1
date	2007.06.25.12.37.11;	author Average;	state Exp;
branches;
next	3.2;

3.2
date	2007.06.21.15.23.37;	author Average;	state Exp;
branches;
next	3.1;

3.1
date	2007.06.17.12.40.01;	author Average;	state Exp;
branches;
next	2.0;

2.0
date	2007.06.13.16.06.57;	author Average;	state Exp;
branches;
next	1.1;

1.1
date	2007.06.06.15.39.17;	author Average;	state Exp;
branches;
next	;


desc
@@


7.0
log
@画像ファ@イルが見えなくなる問題を修正する版。これが初め
@
text
@UNIT GSVUnit;
INTERFACE
USES
    os2def,os2base,os2pmapi,NuCell,MkBMP,VPUtils,Classes,SysUtils;
CONST
    MaxScaleIndex=2;
    MinScaleIndex=-3;
    ScaleArray:ARRAY[MinScaleIndex..MaxScaleIndex] OF INTEGER=(33,50,75,100,200,400);
    AlbumName:String='Album';
    AlbumThumPath:string='thum';
TYPE
    GraphDataClass=CLASS(MingViewClass)
        isSort:BOOLEAN;
        IsSubDir:LongBool;
        NameIndex:LONGINT;
        isFitWindow:BOOLEAN;
        isRun:BOOLEAN;
        Scale:LONGINT;(**div 100**)

        SaveGraphAttr:GraphicAttr;
        JpegQuality:INTEGER;

        constructor Create;OverRide;
        PROCEDURE SetFirst;
        PROCEDURE SetNext;
        PROCEDURE SetPrev;
        FUNCTION isLast:BOOLEAN;
        FUNCTION GetCount:INTEGER;
        PROCEDURE FlushList;
        PROCEDURE LoadFile;virtual;
        PROCEDURE EvalArg(CONST nst:string);
        PROCEDURE FitWindow(rect:RectL);
        PROCEDURE UpScale;
        PROCEDURE DownScale;
        PROCEDURE JustScale;
        FUNCTION GetDrawRect:RectL;
        PROCEDURE DrawBitmap(rect:RectL;ps:hps);
        FUNCTION FileCount:INTEGER;
        PROCEDURE SaveFile;
        PROCEDURE MakeWebPage(ImageColumn:INTEGER);
    PROTECTED
        FileList:TList;
        htmlText:Text;
        FUNCTION GetCurFileName:String;
        FUNCTION GetFileName(i:INTEGER):string;
        FUNCTION GetFileGraphName(i:INTEGER):string;
        FUNCTION GetSaveFileName(i:INTEGER):string;
        PROCEDURE SetupFileName(DirName:string);
        FUNCTION isBMP(INFO:TSearchRec):BOOLEAN;
        FUNCTION isPING(INFO:TSearchRec):BOOLEAN;
        FUNCTION isJPEG(INFO:TSearchRec):BOOLEAN;
        FUNCTION IsDirectory(INFO:TSearchRec):BOOLEAN;
        FUNCTION isFileType:GraphicAttr;
        FUNCTION GetBgColorText:string;virtual;
        FUNCTION GetCurPathName:string;
        FUNCTION GetCurSaveFileName:String;
    END;
TYPE
    TNameElement=CLASS
        constructor Create(pah:string;InF:TSearchRec;gAttr:GraphicAttr);
        FUNCTION GetName:String;
        FUNCTION GetFileName:String;
        FUNCTION GetPath:string;
    PROTECTED
        path:string;    //END \ CHAR have
        info:TSearchRec;
        Attr:GraphicAttr;
    END;

    ColorRecord=RECORD
        R,G,B:BYTE;
    END;

FUNCTION UColorToRGB(uCol:ULong):ColorRecord;

FUNCTION RGBtoUColor(rc:ColorRecord):ULong;

FUNCTION isRGBSame(rc1,rc2:ColorRecord):BOOLEAN;

IMPLEMENTATION

FUNCTION UColorToRGB(uCol:ULong):ColorRecord;
BEGIN
    result.R:=((uCol div 256) div 256)mod 256;
    result.G:=(uCol div 256) mod 256;
    result.B:=uCol mod 256;
END;

FUNCTION RGBtoUColor(rc:ColorRecord):ULong;
BEGIN
    result:=rc.R*256*256+rc.G*256+rc.B;
END;

FUNCTION isRGBSame(rc1,rc2:ColorRecord):BOOLEAN;
BEGIN
    result:=FALSE;
    IF (rc1.R=rc2.R) AND (rc1.G=rc2.G) AND (rc1.B=rc2.B) THEN
        result:=TRUE;
END;

FUNCTION NameElementCompare(Item1, Item2: POINTER): INTEGER;
BEGIN
    IF TNameElement(Item1).GetName<TNameElement(Item2).GetName THEN
        result:=-1
    ELSE IF TNameElement(Item1).GetName=TNameElement(Item2).GetName THEN
        Result:=0
    ELSE
        result:=1;
END;

constructor TNameElement.Create(pah:string;InF:TSearchRec;gAttr:GraphicAttr);
BEGIN
    path:=pah;
    Info:=inf;
    Attr:=GAttr;
END;

FUNCTION TNameElement.GetName:string;
BEGIN
    GetName:=path+Info.name;
END;

FUNCTION TNameElement.GetFileName:String;
BEGIN
    GetFileName:=Info.Name;
END;

FUNCTION TNameElement.GetPath:string;
BEGIN
    GetPath:=Path;
END;

constructor GraphDataClass.Create;
BEGIN
    inherited Create;
    FileList:=TList.Create;
    IsSubDir:=FALSE;
    isSort:=FALSE;
    NameIndex:=0;
    isFitWindow:=TRUE;
    isRun:=FALSE;
    Scale:=100;
END;


FUNCTION GraphDataClass.GetFileName(i:INTEGER):string;
BEGIN
    result:=TNameElement(FileList[i]).GetName;
END;

FUNCTION GraphDataClass.GetFileGraphName(i:INTEGER):string;
BEGIN
    result:=TNameElement(FileList[i]).GetFileName;
END;

FUNCTION GraphDataClass.GetSaveFileName(i:INTEGER):string;
VAR
    st:string;
    extSt:string;
BEGIN
    st:=TNameElement(FileList[i]).GetFileName;
    ExtSt:=ExtractFileExt(st);
    Delete(St,length(st)-Length(ExtSt)+1,Length(ExtSt));
    IF SaveGraphAttr=jpg THEN
        st:=st+'.jpg'
    ELSE
        st:=st+'.png';
    result:=st;
END;


FUNCTION GraphDataClass.GetCurFileName:string;
BEGIN
    IF FileList.Count>0 THEN BEGIN
        GetCurFileName:=TNameElement(FileList[NameIndex]).GetName;
    END
    ELSE BEGIN
       GetCurFileName:='';
       NameIndex:=0;
    END;
END;

FUNCTION GraphDataClass.GetCurSaveFileName:String;
BEGIN
    result:=GetSaveFileName(NameIndex);
END;

PROCEDURE GraphDataClass.SetFirst;
BEGIN
    IF FileList.Count>0 THEN BEGIN
        FileName:=TNameElement(FileList[0]).GetName;
        NameIndex:=0;
    END
    ELSE BEGIN
       FileName:='';
       NameIndex:=0;
    END;
END;

PROCEDURE GraphDataClass.SetNext;
BEGIN
    Inc(NameIndex);
    IF FileList.Count<=NameIndex THEN NameIndex:=0;
    FileName:=GetCurFileName;
END;

PROCEDURE GraphDataClass.SetPrev;
BEGIN
    Dec(NameIndex);
    IF NameIndex<0 THEN NameIndex:=FileList.Count-1;
    FileName:=GetCurFileName;
END;

FUNCTION GraphDataClass.isLast:BOOLEAN;
BEGIN
    IF NameIndex=FileList.Count-1 THEN
        isLast:=TRUE
    ELSE
        isLast:=FALSE;
END;

PROCEDURE GraphDataClass.UpScale;
VAR
    i:INTEGER;
BEGIN
    i:=MinScaleIndex;
    WHILE (ScaleArray[i]<=Scale) AND (i<MaxScaleIndex) DO
        inc(i);
    Scale:=ScaleArray[i];
    pBMPBody^.sCx:=pBMPBody^.bmpcx*Scale div 100;
    pBMPBody^.sCy:=pBMPBody^.bmpcy*Scale div 100;
END;

PROCEDURE GraphDataClass.DownScale;
VAR
    i:INTEGER;
BEGIN
    i:=MaxScaleIndex;
    WHILE (ScaleArray[i]>=Scale) AND (i>MinScaleIndex) DO dec(i);
    Scale:=ScaleArray[i];
    pBMPBody^.sCx:=pBMPBody^.bmpcx*Scale div 100;
    pBMPBody^.sCy:=pBMPBody^.bmpcy*Scale div 100;
END;

PROCEDURE GraphDataClass.JustScale;
BEGIN
    Scale:=100;
    pBMPBody^.sCx:=pBMPBody^.bmpcx*Scale div 100;
    pBMPBody^.sCy:=pBMPBody^.bmpcy*Scale div 100;
END;

FUNCTION GraphDataClass.GetDrawRect:RectL;
VAR
    cx,cy :LONGINT;(**bitmap size**)
    rect  :RectL;
BEGIN
    cx:=pBMPBody^.bmpCx * Scale div 100;
    cy:=pBMPBody^.bmpCy * Scale div 100;
    rect.xLeft:=0;Rect.xRight:=cx;
    rect.yTop:=cy;rect.yBottom:=0;
//    rect.xRight:=(Rect.xRight div 8)*8;
    GetDrawRect:=Rect;
END;

PROCEDURE GraphDataClass.FitWindow(rect:RectL);
VAR
    dCx,dCy :LONGINT;(**Screen Size**)
    cx,cy   :LONGINT;(**bitmap size**)
BEGIN
    dCx:=rect.xRight-Rect.xLeft;
    dCy:=Rect.yTop-Rect.yBottom;
    cx:=pBMPBody^.bmpCx;
    cy:=pBMPBody^.bmpCy;

    IF (100*dCx div Cx)<(100*dCy div Cy) THEN BEGIN
        Scale:=dCx*100 div Cx;
    END
    ELSE BEGIN
        Scale:=dCy*100 div Cy;
    END;
    pBMPBody^.sCx:=cx*Scale div 100;
    pBMPBody^.sCy:=cy*Scale div 100;
END;

PROCEDURE GraphDataClass.DrawBitmap(rect:RectL;ps:hps);
VAR
    RectSrc,RectDest:RectL;
    hbm:HBITMAP;
    rc:bool;
BEGIN
    hbm:=GpiCreateBitmap(ps,
                        pBMPBody^.InfoHeader2,
                        CBM_INIT,
                        pBMPBody^.RG,
                        pBMPBody^.Info2);
    RectSrc.yTop:=pBMPBody^.bmpcy;
    RectSrc.yBottom:=0;
    RectSrc.xLeft:=0;
    RectSrc.xRight:=pBMPBody^.bmpCx;
    RectDest:=rect;
    rc:=WinDrawBitmap(PS,Hbm,@@RectSrc,@@Rect,1, 0,DBM_STRETCH);
    IF rc=FALSE THEN BEGIN
        HALT;
    END;
    GpiDeleteBitmap(HBM);
END;

FUNCTION GraphDataClass.FileCount:INTEGER;
BEGIN
    result:=FileList.Count;
END;

FUNCTION GraphDataClass.isFileType:GraphicAttr;
BEGIN
    isFileType:=TNameElement(FileList[NameIndex]).Attr;
END;

TYPE
    CHtype=(ctCTRL,ctAlNum,ctKanji1st,ctKana,ctIlleg);

FUNCTION ChkChType(ch:CHAR):Chtype;
        {    #$00..#$1F, #$7F : ctCtrl;         }
        {    #$20..#$7E       : ctAlNum;        }
        {    #$81..#$9F, #$E0..#$FC : ctKanji1; }
        {    #$A0..#$DF       : ctKana          }
VAR
    ch2int:INTEGER;
BEGIN
    ch2int:=Ord(ch);
    IF (ch2int<=$1F) OR (ch2int=$7f) THEN
        ChkChType:=ctCtrl
    ELSE IF ch2int<$7E THEN
        ChkChType:=ctAlNum
    ELSE IF ( (ch2int>=$81) AND (ch2int<=$9F) ) OR
            ( (ch2int>=$E0) AND (ch2int<=$FC) ) THEN
        ChkChType:=ctKanji1st
    ELSE IF (ch2int>=$A0) AND (ch2int<=$DF) THEN
        ChkChtype:=ctKana
    ELSE
        ChkChType:= ctIlleg;
END;

FUNCTION isKanji2nd(EL:String;Index:INTEGER):BOOLEAN;
VAR
    i:INTEGER;
    ChTy:ChType;
BEGIN
    IF (Length(EL)<Index) OR (Index<=0) THEN BEGIN
        isKanji2nd:=FALSE;
        EXIT;
    END;
    i:=1;
    WHILE i<Index DO BEGIN
        ChTy:=ChkChType(EL[i]);
        CASE ChTy OF
            ctKanji1st:i:=i+2;
            ELSE i:=i+1;
        END;
    END;
    IF i>Index THEN
        IsKanji2nd:=True
    ELSE
        IsKanji2nd:=FALSE;
END;


PROCEDURE GraphDataClass.SetupFileName(DirName:string);
VAR
    Info:TSearchRec;
    RC:INTEGER;
    d:string;
    i:INTEGER;

    PROCEDURE PushElement(DirName:string;Info:TSearchRec);
    VAR
        NameElement:TNameElement;
    BEGIN
        IF isJPEG(Info) THEN BEGIN
            NameElement:=TNameElement.Create(DirName+'\',info,JPG);
            FileList.Add(NameElement);
        END
        ELSE IF isPING(Info) THEN BEGIN
            NameElement:=TNameElement.Create(DirName+'\',info,PNG);
            FileList.Add(NameElement);
        END
        ELSE IF isBMP(info) THEN BEGIN
            NameElement:=TNameElement.Create(DirName+'\',info,BMP);
            FileList.Add(NameElement);
        END;
    END;

    PROCEDURE ListupName(DirName:string);
    VAR
        SubInfo:TSearchRec;
    BEGIN
        RC:=FindFirst(DirName+'\*.*',faAnyFile,SubInfo);
        WHILE (RC=0)  DO BEGIN
            IF (isDirectory(SubInfo) ) THEN BEGIN
                IF isSubDir THEN BEGIN
                    ListupName(DirName+'\'+SubInfo.Name);
                END;
            END
            ELSE BEGIN
                IF (SubInfo.name<>'.') AND (SubInfo.Name<>'..') THEN
                    PushElement(DirName,SubInfo);
            END;
            RC:=FindNext(Subinfo);
        END;
        FindClose(SubInfo);
    END;
    FUNCTION isRoot(st:string):BOOLEAN;
    BEGIN
        result:=((Length(DirName)<=3) AND (pos(':',DirName)>0));
        Info.Attr:=faDirectory;
    END;

BEGIN
    RC:=FindFirst(DirName,faAnyFile,Info);
    IF (RC=0) OR isRoot(DirName) THEN BEGIN
        IF (Info.Attr AND faDirectory )=0 THEN BEGIN
            DirName:=ExpandFileName(DirName);
            i:=Length(DirName);
            WHILE (i>0) AND
                NOT(DirName[i] IN ['/','\',':']) AND
                NOT(isKanji2nd(DirName,i))
            DO
                Dec(i);
            IF DirName[i] IN ['/','\'] THEN
                d:=Copy(DirName,1,i-1)
            ELSE
                d:=Copy(DirName,1,i);
            PushElement(d,Info);
        END
        ELSE BEGIN
            ListupName(DirName);
        END;
    END;
    FindClose(Info);
    IF isSort THEN FileList.Sort(NameElementCompare);
END;

FUNCTION GraphDataClass.isPING(INFO:TSearchRec):BOOLEAN;
BEGIN
    IF POS('.PNG',UpperCase(INFO.NAME) )>0 THEN
        isPING:=TRUE
    ELSE
        isPING:=FALSE;
END;

FUNCTION GraphDataClass.isJPEG(INFO:TSearchRec):BOOLEAN;
BEGIN
    IF POS('.JPG',UpperCase(INFO.NAME) )>0 THEN
        isJPEG:=TRUE
    ELSE IF POS('.JPEG',UpperCase(Info.Name)) >0 THEN
        isJpeg:=TRUE
    ELSE
        isJPEG:=FALSE;
END;

FUNCTION GraphDataClass.isBMP(INFO:TSearchRec):BOOLEAN;
BEGIN
    IF POS('.BMP',UpperCase(INFO.NAME) )>0 THEN
        isBMP:=TRUE
    ELSE
        isBMP:=FALSE;
END;


FUNCTION GraphDataClass.IsDirectory(INFO:TSearchRec):BOOLEAN;
BEGIN
    IsDirectory:=FALSE;
    IF (INFO.Attr AND faDirectory)>0 THEN BEGIN
        IF (Info.name<>'.') AND (Info.Name<>'..') THEN
            IsDirectory:=TRUE;
    END;
END;

FUNCTION GraphDataClass.GetCount:INTEGER;
BEGIN
    result:=FileList.Count;
END;

PROCEDURE GraphDataClass.FlushList;
BEGIN
    FileList.Clear;
END;

PROCEDURE GraphDataClass.LoadFile;
BEGIN
    CASE isFileType OF
        JPG:JpegFileLoad;
        PNG:MingFileLoad;
    END;
END;

PROCEDURE GraphDataClass.EvalArg(CONST nst:string);
VAR
    st:string;
BEGIN
    st:=nSt;
    IF (St[length(St)]='\') OR (St[length(St)]='/') THEN BEGIN
        System.Delete(St,length(St),1);
    END;
    SetupFileName(St);
END;

FUNCTION GraphDataClass.GetCurPathName:string;
VAR
    st:string;
BEGIN
    st:=TNameElement(FileList[NameIndex]).Path;
    IF st='' THEN BEGIN
        result:='';
        EXIT;
    END;
    GetCurPathName:=St;
END;

FUNCTION GraphDataClass.GetBgColorText:string;
BEGIN
    result:='#FFFFFF"';
END;

PROCEDURE GraphDataClass.SaveFile;
VAR
    SaveSt:string;
BEGIN

    SaveSt:=GetCurPathName+AlbumThumPath+'\'+GetCurSaveFileName;
    CASE SaveGraphAttr OF
        jpg:BEGIN
            JpegFileSave(SaveSt,JpegQuality);
        END;
        png:BEGIN
            PingFileSave(SaveSt);
        END;
    END;
END;

PROCEDURE GraphDataClass.MakeWebPage(ImageColumn:INTEGER);
    PROCEDURE MakeTable(ImageColumn:INTEGER);
    VAR
        i:INTEGER;
        ImgSt:AnsiString;
        ImgCount:INTEGER;
        ImgMax:INTEGER;
        FUNCTION ImgTD(ix:INTEGER):AnsiString;
        VAR
            CurSt:AnsiString;
        BEGIN
            IF FileList.Count-1<ImgCount+Ix THEN BEGIN
                result:='';
                EXIT;
            END;
            CurSt:='<a href="./'+GetFileGraphName(ImgCount+ix)+'">'+
                   '<img src="'+
                   AlbumThumPath+GetSaveFileName(ImgCount+ix)+'"'+
                   ' border="0" > </a> <br> '+
                   GetFileGraphName(ImgCount+ix)+' ';
            result:='    <td>'+CurSt+'</td>';
            WRITELN(htmlText,'    <td>'+CurSt+'</td>');
        END;
        FUNCTION ImgTR:AnsiString;
        VAR
            CurSt:AnsiString;
            j:INTEGER;
        BEGIN
            CurSt:='';
            WRITELN(htmlText,'<tr>');
            FOR j:=0 TO ImageColumn-1 DO
                ImgTD(j);
            WRITELN(htmlText,'</tr>');
        END;
    BEGIN
        // Never thumPath=''!!
        IF (AlbumThumPath[length(AlbumThumPath)]<>'/') THEN BEGIN
            AlbumThumPath:=AlbumThumPath+'/';
        END;
        ImgCount:=0;
        WRITELN(htmlText,'<table >');
        WRITELN(htmlText,'<caption>');
        WRITELN(htmlText,'<title>'+GetCurPathName+':ImageFile'+'</title>');
        WRITELN(htmlText,'</caption>');
        ImgCount:=0;
        ImgMax:=FileList.Count-1;
        WHILE ImgCount<=ImgMax DO BEGIN
            ImgTR;
            Inc(ImgCount,imageColumn);
        END;

        WRITELN(htmlText,'</table>');
    END;
BEGIN
    Assign(htmlText,GetCurPathName+'\'+AlbumName+'.htm');
    rewrite(htmlText);
    WRITELN(htmlText,'<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"');
    WRITELN(htmlText,'"http://www.w3.org/TR/html4/loose.dtd">');
    WRITELN(htmlText,'<html>');
    WRITELN(htmlText,'<head>');
    WRITELN(htmlText,'<title>'+GetCurPathName+':ImageFile'+'</title>');
    WRITELN(htmlText,'</head>');
    WRITELN(htmlText,'<body bgcolor='+ GetBgColorText+' >');
    MakeTable(ImageColumn);

    WRITELN(htmlText,'</body>');

    WRITELN(htmlText,'</html>');

    close(htmlText);

END;


BEGIN
END.

ExtractFileName
TStringList
@


6.3
log
@セーブファ@イル形式を変更
@
text
@d19 1
a19 1
        
d22 1
@


6.2
log
@リファ@クタ第一段。
アルバムファ@イルがjpegサポート
@
text
@d18 2
d21 1
a21 1
        Scale:LONGINT;(**div 100**)
d38 1
a38 2
        FUNCTION GetCurPathName:string;
        FUNCTION GetCurSaveFileName:String;
d54 2
d521 16
@


6.1
log
@セーブオプションダイアログを導入
@
text
@d10 1
a10 1
    PNGThumPath:string='thum';
d18 1
d37 1
a37 1
        FUNCTION GetCurPNGFileName:string;
d45 1
a45 1
        FUNCTION GetPNGFileName(i:INTEGER):string;
d152 1
a152 1
FUNCTION GraphDataClass.GetPNGFileName(i:INTEGER):string;
d160 4
a163 1
    st:=st+'.png';
d179 1
a179 1
FUNCTION GraphDataClass.GetCurPNGFileName:string;
d181 1
a181 1
    result:=GetPNGFileName(NameIndex);
d536 2
a537 1
                   '<img src="'+PNGthumPath+GetPNGFileName(ImgCount+ix)+'"'+
d556 2
a557 2
        IF (PNGthumPath[length(PNGthumPath)]<>'/') THEN BEGIN
            PNGThumPath:=PNGThumPath+'/';
@


5.2
log
@ちょこっとリファ@クタ
@
text
@@


5.1
log
@周辺ぼかしをアルゴリズムじゃなくてぼかしで
@
text
@d65 3
d69 5
d76 19
@


4.6
log
@ダイアログの形を変えた
@
text
@@


4.5
log
@ ばばんとWebページ作成へ
@
text
@d51 1
d484 5
d550 1
a550 1
    WRITELN(htmlText,'<body>');
@


4.4
log
@縦横比の正確さを求める
@
text
@d499 5
a503 3
                   '<img src="'+PNGthumPath+GetPNGFileName(ImgCount+ix)+
                   '"> </a>';
            result:='<td>'+CurSt+'</td>';
d511 4
a514 26
            FOR j:=0 TO ImageColumn-1 DO BEGIN
                CurSt:=CurSt+ImgTD(j);
            END;
            result:='<tr>'+CurSt+'</tr>';
        END;
        FUNCTION TextTD(ix:INTEGER):AnsiString;
        VAR
            CurSt:AnsiString;
        BEGIN
            IF FileList.Count-1<ImgCount+Ix THEN BEGIN
                result:='';
                EXIT;
            END;
            CurSt:='<p>'+GetFileGraphName(ImgCount+ix)+'</p>';
            result:='<td>'+CurSt+'</td>';
        END;
        FUNCTION TextTR:AnsiString;
        VAR
            CurSt:AnsiString;
            j:INTEGER;
        BEGIN
            CurSt:='';
            FOR j:=0 TO ImageColumn-1 DO BEGIN
                CurSt:=CurSt+TextTD(j);
            END;
            result:='<tr>'+CurSt+'</tr>';
d529 2
a530 3
            WRITELN(htmlText,ImgTR);
            WRITELN(htmlText,TextTr);
            Inc(ImgCount,ImageColumn);
@


4.3
log
@ 一応Webページが表示できるように
@
text
@@


4.2
log
@とりあえずmakeroudしながらの閲覧は大丈夫になりました。
これからWebページの構築へ
@
text
@d6 5
a10 3
 MaxScaleIndex=2;
 MinScaleIndex=-3;
 ScaleArray:ARRAY[MinScaleIndex..MaxScaleIndex] OF INTEGER=(33,50,75,100,200,400);
d35 3
a37 2
        PROCEDURE MakeWebPage(ImageCx,ImageColumn:INTEGER;
                              WebName,thumName:string);
a40 2
        FolderPath:String;
        thumPath:String;
d43 2
a50 1
        PROCEDURE MakeTable(ImageColumn:INTEGER);
d54 6
a59 1
        path:string;
a61 2
        constructor Create(pah:string;InF:TSearchRec;gAttr:GraphicAttr);
        FUNCTION GetName:String;
d90 10
a109 1
    FolderPath:='';
d118 18
d146 6
d470 2
a471 1
PROCEDURE GraphDataClass.MakeTable(ImageColumn:INTEGER);
d473 12
a484 5
    i:INTEGER;
    ImgSt:string;
    ImgCount:INTEGER;
    ImgMax:INTEGER;
    FUNCTION ImgTD(ix:INTEGER):string;
d486 38
a523 5
        CurSt:string;
    BEGIN
        IF FileList.Count-1<ImgCount+Ix THEN BEGIN
            result:='';
            EXIT;
d525 10
a534 12
        CurSt:='<a href="./'+GetFileName(ImgCount+ix)+'">'+
               '<img src="'+GetFileName(ImgCount+ix)+'">';
        result:='<td>'+CurSt+'</td>';
    END;
    FUNCTION ImgTR:string;
    VAR
        CurSt:string;
        j:INTEGER;
    BEGIN
        CurSt:='';
        FOR j:=0 TO ImageColumn-1 DO BEGIN
            CurSt:=CurSt+ImgTD(j);
a535 5
        result:='<tr>'+CurSt+'</tr>';
    END;
    FUNCTION TextTD(ix:INTEGER):string;
    VAR
        CurSt:string;
d537 3
a539 3
        IF FileList.Count-1<ImgCount+Ix THEN BEGIN
            result:='';
            EXIT;
d541 11
a551 11
        CurSt:='<p>'+GetFileName(ImgCount+ix)+'</p>';
        result:='<td>'+CurSt+'</td>';
    END;
    FUNCTION TextTR:string;
    VAR
        CurSt:string;
        j:INTEGER;
    BEGIN
        CurSt:='';
        FOR j:=0 TO ImageColumn-1 DO BEGIN
            CurSt:=CurSt+TextTD(j);
d553 2
a554 1
        result:='<tr>'+CurSt+'</tr>';
d557 1
a557 23
    ImgCount:=0;
    WRITELN(htmlText,'<table>');
    WRITELN(htmlText,'<caption>');
    WRITELN(htmlText,'<title>'+FolderPath+':ImageFile'+'</title>');
    WRITELN(htmlText,'</caption>');
    ImgCount:=0;
    ImgMax:=FileList.Count-1;
    WHILE ImgCount<=ImgMax DO BEGIN
        WRITELN(htmlText,ImgTR);
        WRITELN(htmlText,TextTr);
        Inc(ImgCount,3);
    END;

    WRITELN(htmlText,'</table>');
END;


PROCEDURE GraphDataClass.MakeWebPage(ImageCx,ImageColumn:INTEGER;
                                     WebName,thumName:String);
BEGIN
    FolderPath:=ExtractFilePath(WebName);
    ThumPath:=thumName;
    Assign(htmlText,FolderPath+'\'+ExtractFileName(WebName)+'.html');
d563 1
a563 1
    WRITELN(htmlText,'<title>'+FolderPath+':ImageFile'+'</title>');
@


4.1
log
@ Webアルバム化
@
text
@d21 1
d38 2
a39 1
        folderName:String;
d95 1
a95 1
    FolderName:=' Test Page';
d140 8
d487 1
a487 1
    WRITELN(htmlText,'<title>'+FolderName+':ImageFile'+'</title>');
d504 3
a506 4
    FolderName:=WebName;
    ThumsName:=thunName;
    ImageColumn:=3;
    Assign(htmlText,FolderName+'\'+ExtractFileName(FolderName)+'.html');
d512 1
a512 1
    WRITELN(htmlText,'<title>'+FolderName+':ImageFile'+'</title>');
@


3.2
log
@とりあえず縮小が上手く動くように
@
text
@d32 2
d36 2
d39 1
d46 1
d93 1
d97 5
d422 95
@


3.1
log
@影の方向を色々に変更出来るように
試行錯誤バージョン(変更はじめ)
@
text
@d28 1
d145 7
@


2.0
log
@BMP読み込みルーチンを削除
@
text
@@


1.1
log
@Initial revision
@
text
@d10 1
a10 1
    GraphDataClass=CLASS(BitmapViewClass)
a388 1
        BMP:BMPFileLoad;
@
