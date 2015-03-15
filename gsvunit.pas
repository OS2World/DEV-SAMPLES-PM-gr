UNIT GSVUnit;
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
    rc:=WinDrawBitmap(PS,Hbm,@RectSrc,@Rect,1, 0,DBM_STRETCH);
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
