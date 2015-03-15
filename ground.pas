(**$Revision: 7.0 $**)
PROGRAM GSV;
USES
    os2def,os2base,os2pmapi,
    NuCell,GSVUnit,MkBmp,
    uGetOpt,
    xmlcfg,
    VPUtils,Classes,SysUtils;
{$PMTYPE PM}

{$R ground.res}

CONST
    WM_ENDTHREAD=WM_USER+1;
    WM_SAVESTART=WM_USER+2;
    WM_InitChangeSpin=WM_USER+3;

    MainTimerID:ULong=TID_USERMAX-1;
CONST
    idGraphShow  =  11000;
    ID_Pane      =  11001;
    ID_DRAWPANE  =  11002;
    ID_TOOLBAR   =  11003;

    IDB_LEFT     =  12001;
    IDB_RIGHT    =  12002;
    IDB_UP       =  12003;
    IDB_DOWN     =  12004;
    IDB_FIT      =  12005;
    IDB_EXIT     =  12008;
    IDB_SETTING  =  12012;
    IDB_SHOWDLG  =  12013;

    DLGPanel        =10000;
    IDColorButton   =10001;
    IDDropSpin      =10002;
    IDRoundCheck    =10003;
    IDRoundSpin     =10004;
    IDDropOptSpin   =10005;
//    IDChangeSizeXSpin   =10010;
    IDChangeSizeYSpin   =10011;
    IDChangeSizeCheck   =10012;
    IDRender        =10100;
    IDUndo          =10101;
    IDSaveRender    =10102;

    OptionDialog    =13000;
    IDPNGRadio      =13001;
    IDJPEGRadio     =13002;
    IDJPEGSpin      =13003;
    IDAlbumSpin     =13004;

(* Local procedures *)

FUNCTION MainClientProc(Window: HWnd; Msg: ULong; Mp1,Mp2: MParam): MResult;
                                                              cdecl; forward;
FUNCTION DrawPaneClientProc(Window:HWnd;Msg:ULong;Mp1,Mp2:MParam):MResult;
                                                              cdecl;forward;
FUNCTION PaneClientProc(Window:HWnd;Msg:ULong;Mp1,Mp2:MParam):MResult;
                                                              cdecl;forward;

(* Static Variables *)

CONST
    DrawPane    :CellDef =(lType:CELL_WINDOW;
                         pszClass:'BitmapPane';
                         pszName:'';
                         ulStyle:WS_VISIBLE;
                         ulID:ID_DRAWPANE;
                         pPanel1:NIL;
                         pPanel2:NIL;
                         pClassProc:NIL;
                         pClientClassProc:DrawPaneClientProc
                         );

    pane        :CellDef=(lType:CELL_HSPLIT ;
                         pszClass:NIL;
                         pszName:'pane';
                         ulStyle:WS_VISIBLE OR
                                 FCF_vertscroll OR fcf_HorzScroll;
                         ulID:ID_PANE;
                         pPanel1:@DrawPane;
                         pPanel2:NIL;
                         pClassProc:NIL;
                         pClientClassProc:PaneClientProc
                         );

    mainClient :CellDef=(lType:CELL_HSPLIT ;
                         pszClass:NIL;
                         pszName:'Round Rect ';
                         ulStyle:FCF_TITLEBAR OR FCF_SYSMENU OR
                                 FCF_MINMAX OR FCF_ICON OR FCF_ACCELTABLE OR
                                 FCF_TASKLIST OR FCF_SIZEBORDER ;
                         ulID:idGraphShow;
                         pPanel1:@Pane;
                         pPanel2:NIL;
                         pClassProc:NIL;          // Frame subclass proc
                         pClientClassProc:MainClientProc
                            );

      mainItems:ARRAY [0..8] OF TBItemData=(
            (NuID:IDB_FIT       ;cText:' Fit Window'),
            (NuID:IDB_UP        ;cText:' Scale Up'),
            (NuID:IDB_DOWN      ;cText:' Scale Down'),
            (NuID:TB_SEPARATOR),
            (NuID:IDB_EXIT      ;cText:' Exit Application '),
            (NuID:TB_SEPARATOR),
            (NuID:IDB_SETTING   ;cText:' Save File Option Dialog'),
            (NuID:IDB_SHOWDLG   ;cText:' Show Setting Dialog'),
            (NuID:0)
      );

    mainTb:TbDef = (lType:TB_VERTICAL OR TB_ATTACHED_BT OR TB_BUBBLE ;
                    ulID:ID_TOOLBAR;
                    tbItems:@mainItems);


    achDirection : ARRAY[1..3] OF pChar = ( 'Right',   'Left', 'Center');

TYPE
    RoundParamRecord=RECORD
        isMakeRound:BOOLEAN;
        DropBkCol,BkCol:ColorRecord;
        RoundRadian,DropLength:INTEGER;
        isChangeSize:BOOLEAN;
        ChangeSizeWidth,ChangeSizeHeight:INTEGER;
        XYRatio:LONGINT;
    END;

    GraphRounderClass=CLASS(GraphDataClass)
        FrameWindow:hwnd;
        hwndPane:HWnd;
        hwndVScrol,hwndHScrol:hwnd;
        hwndDlg:hwnd;
        cx,cy:INTEGER;
        xEdge,yEdge:INTEGER;
        pOrgBitmap:pBitmapRecord;
        pChangeSizeBMP:pBitmapRecord;

        DlgParam:RoundParamRecord;

        isAuto:BOOLEAN;//Auto Effect Mode
        isSave:BOOLEAN;
        ThreadID:TID;
        TimerSec:INTEGER;
        AlbumColum:integer;

        constructor Create;
        PROCEDURE SetPaneSize(x,y:INTEGER);
        PROCEDURE CalcFitScale;
        PROCEDURE CreateScroll(window:hwnd);
        PROCEDURE SetScroll;
        FUNCTION CalcEdge:RectL;
        PROCEDURE RedrawMsg;
        FUNCTION isArgEmpty:BOOLEAN;
        FUNCTION GetStatusStr:string;
        PROCEDURE DrawScreen(window:hwnd);
        PROCEDURE CopyToOrg;
        PROCEDURE MakePaneLarge(enLargeSize:INTEGER);
        PROCEDURE CopyFromOrg;
        PROCEDURE MakeRender(DropL,RoundR:INTEGER);
        PROCEDURE LoadFile;OverRide;
        PROCEDURE PushParamList;
        FUNCTION GetAnotherParamIndex:INTEGER;
        FUNCTION isPrevParam:BOOLEAN;
        FUNCTION GetPrevParam:RoundParamRecord;
        FUNCTION GetOrgWidth:INTEGER;
        FUNCTION GetOrgHeight:INTEGER;
        PROCEDURE SetChangeSizeHeader(x,y:INTEGER);
        PROCEDURE CopyFromChangeSize(x,y,r:INTEGER);
    PROTECTED
        ParamList:TList;
        FUNCTION GetBgColorText:string;OverRide;
    END;

CONST
    XMLConfName:string='grcfg.xml';
    isColorDefine='GraphRounder/BkColor/isDefine';
    ColorValue='GraphRounder/BkColor/Value';
    ShadowValue='GraphRounder/Shadow/Value';
    TimerValue='GraphRounder/Timer/msec';
    DropLengthValue='GraphRounder/Shadow/Length';
    isChangeSizeDefine='GraphRounder/ChangeSize/isChangeSize';
    ChangeSizeWidthValue='GraphRounder/ChangeSize/Width';
    ChangeSizeHeightValue='GraphRounder/ChangeSize/Height';
    RoundValue='GraphRounder/Round/Radian';
    xPosPath='GraphRounder/window/x';
    yPosPath='GraphRounder/window/y';
    xWidthPath='GraphRounder/window/width';
    yHeightPath='GraphRounder/window/height';
    AlbumColumPath='GraphRounder/Album/Colum';

VAR
    cfg: TXMLConfig;
    xWidth,yHeight,xPos,yPos:INTEGER;

    GSVClass:GraphRounderClass;
    hwndFrame,hwndTB:HWND;

PROCEDURE LoadCfg;
VAR
    St:string;
    aSWP:swp;
    CfgPath:string;
BEGIN
    WinQueryWindowPos(HWND_DESKTOP, aSWP);

    xWidth:=(aSWP.cx div 2) +1;
    yHeight:=(aSWP.cy div 2) ;
    xPos:=(aSWP.x) ;
    yPos:=(aSWP.y+aSWP.cy -yHeight) ;


    cfgPath:=ExtractFilePath(ParamStr(0))+XMLConfName;
    cfg:=TXMLConfig.Create(cfgPath);
    St:=cfg.GetValue(ColorValue,IntToStr($FFFFFF));
    TRY
        GSVClass.DlgParam.BkCol:=UColorToRGB(StrToInt(St));
    EXCEPT
        GSVClass.DlgParam.BkCol:=UColorToRGB($FFFFFF);
    END;
    xPos:=cfg.GetValueInteger(xPosPath,xPos);
    yPos:=cfg.GetValueInteger(yPosPath,yPos);
    xWidth:=cfg.GetValueInteger(xWidthPath,xWidth);
    yHeight:=cfg.GetValueInteger(yHeightPath,yHeight);
    GSVClass.DlgParam.DropBkCol:=
        UColorToRGB(cfg.GetValueInteger(ShadowValue,$808080));
    GSVClass.DlgParam.RoundRadian:=cfg.GetValueInteger(RoundValue,20);
    GSVClass.DlgParam.DropLength:=cfg.GetValueInteger(DropLengthValue,20);
    GSVClass.DlgParam.isChangeSize:=cfg.GetValueBool(isChangeSizeDefine,FALSE);
    GSVClass.DlgParam.ChangeSizeWidth:=
        cfg.GetValueInteger(ChangeSizeWidthValue,120);
    GSVClass.TimerSec:=cfg.GetValueInteger(TimerValue,500);
    GSVClass.AlbumColum:=cfg.GetValueInteger(AlbumColumPath,4);
    cfg.Free;
END;

PROCEDURE SaveCfg;
VAR
    swap:Swp;
    cfgPath:string;
BEGIN
    IF GSVClass.isAuto THEN BEGIN
        GSVClass.MakeWebPage(GSVClass.AlbumColum)
    END;

    cfgPath:=ExtractFilePath(ParamStr(0))+XMLConfName;
    WinQueryWindowPos(hwndFrame,swap);
    xPos:=swap.x;
    yPos:=swap.y;
    xWidth:=swap.cx;
    yHeight:=swap.cy;

    cfg:=TXMLConfig.Create(cfgPath);
    cfg.SetValue(ColorValue,
                 '$'+IntToHex(RGBToUColor(GSVClass.DlgParam.BkCol),8) );
    cfg.SetValue(ShadowValue,
                 '$'+IntToHex(RGBToUColor(GSVClass.DlgParam.DropBkCol),8));
    cfg.SetValueInteger(RoundValue,GSVClass.DlgParam.RoundRadian);
    cfg.SetValueInteger(DropLengthValue,GSVClass.DlgParam.DropLength);
    cfg.SetValueInteger(xPosPath,xPos);
    cfg.SetValueInteger(yPosPath,yPos);
    cfg.SetValueInteger(xWidthPath,xWidth);
    cfg.SetValueInteger(yHeightPath,yHeight);
    cfg.SetValueBool(isChangeSizeDefine,GSVClass.DlgParam.isChangeSize);
    cfg.SetValueInteger(ChangeSizeWidthValue,
                        GSVClass.DlgParam.ChangeSizeWidth);
    cfg.SetValueInteger(TimerValue,GSVClass.TimerSec);
    cfg.SetValueInteger(AlbumColumPath,GSVClass.AlbumColum);
    cfg.Free;
END;


FUNCTION  LoadToDraw(GsvCls:POINTER ):LONGINT;
VAR
    GSVClass:GraphRounderClass;
    rc:bool;
BEGIN
    GSVClass:=GraphRounderClass(GsvCls);
    GSVClass.LoadFile;
    GSVClass.MakeRender(GSVClass.DlgParam.DropLength,
                        GSVClass.DlgParam.RoundRadian);
    GSVClass.SaveFile;
    rc:=WinPostMsg(GSVClass.hwndPane,WM_EndThread,0,0);
END;

constructor GraphRounderClass.Create;
BEGIN
    inherited Create;
    xEdge:=0;yEdge:=0;
    hwndPane:=NullHandle;
    DlgParam.isMakeRound:=TRUE;
    isAuto:=FALSE;
    isSave:=FALSE;
    ParamList:=TList.Create;
    DlgParam.isChangeSize:=FALSE;
    pChangeSizeBMP:=NIL;
END;

FUNCTION GraphRounderClass.GetBgColorText:string;
BEGIN
    result:='#'+IntToHex(RGBToUColor(DlgParam.BkCol),6);
END;

PROCEDURE GraphRounderClass.SetPaneSize(x,y:INTEGER);
BEGIN
    cx:=x;
    cy:=y;
END;

PROCEDURE GraphRounderClass.CalcFitScale;
VAR
    rect:RectL;
BEGIN
    IF isFitWindow=FALSE THEN
        EXIT;
    IF hwndPane=NullHandle THEN BEGIN
        rect.xLeft:=0;rect.yTop:=480;
        rect.xRight:=640;rect.yBottom:=0;
    END
    ELSE
        WinQueryWindowRect(hwndPane,rect);
    xEdge:=0;
    yEdge:=0;
    FitWindow(rect);
END;

PROCEDURE GraphRounderClass.CreateScroll(window:hwnd);
BEGIN
    HwndVScrol:=WinWindowFromID(WinQueryWindow(Window,QW_PARENT),
                                FID_VERTSCROLL);
    HwndHScrol:=WinWindowFromID(WinQueryWindow(Window, QW_PARENT),
                                FID_HORZSCROLL);
END;

PROCEDURE GraphRounderClass.SetScroll;
BEGIN
    IF pBMPBody^.sCy<=Cy THEN BEGIN
        WinEnableWindow( hwndVScrol, FALSE );
        yEdge:=0;
    END
    ELSE BEGIN
        WinEnableWindow( hwndVScrol, TRUE);
        WinSendMsg( hwndVScrol,
                    SBM_SETSCROLLBAR,
                    MPFROM2SHORT(0, 0),
                    MPFROM2SHORT(0, pBMPBody^.sCy-Cy) );
        WinSendMsg( hwndVScrol,
                    SBM_SETTHUMBSIZE,
                    MPFROM2SHORT(Cy,pBMPBody^.sCy),
                    MPFROM2SHORT(0, 0) );
        WinSendMsg( hwndVScrol,
                    SBM_SETPOS,
                    MPFROMSHORT((pBMPBody^.sCy-Cy) div 2 +yEdge),
                    0);
    END;
    IF pBMPBody^.sCx<=Cx THEN BEGIN
        WinEnableWindow( hwndHScrol, FALSE );
        xEdge:=0;
    END
    ELSE BEGIN
        WinEnableWindow( hwndHScrol, true);
        WinSendMsg( hwndHScrol,
                    SBM_SETSCROLLBAR,
                    MPFROM2SHORT(0, 0),
                    MPFROM2SHORT(0, pBMPBody^.sCx-Cx) );
        WinSendMsg( hwndHScrol,
                    SBM_SETTHUMBSIZE,
                    MPFROM2SHORT(Cx,pBMPBody^.sCx),
                    MPFROM2SHORT(0, 0) );
        WinSendMsg( hwndHScrol,
                    SBM_SETPOS,
                    MPFROMSHORT((pBMPBody^.sCx-Cx) div 2+xEdge),
                    0);
    END;
END;

FUNCTION GraphRounderClass.CalcEdge:RectL;
VAR
    xDif,yDif:INTEGER;
    DrawRect:RectL;
BEGIN
    DrawRect:=GetDrawRect;
    xDif:=(Cx-DrawRect.xRight) div 2+xEdge;
    Inc(DrawRect.xRight,xDif);
    inc(DrawRect.xLeft,xDif);
    yDif:=(Cy-DrawRect.yTop) div 2+yEdge;
    Inc(DrawRect.yTop,yDif);
    Inc(DrawRect.yBottom,yDif);
    CalcEdge:=DrawRect;
END;

PROCEDURE GraphRounderClass.RedrawMsg;
BEGIN
    WinInvalidateRect(hwndPane,NIL,FALSE);
END;

FUNCTION GraphRounderClass.isArgEmpty:BOOLEAN;
BEGIN
    IF GetCount>0 THEN isArgEmpty:=FALSE ELSE isArgEmpty:=TRUE
END;

FUNCTION GraphRounderClass.GetStatusStr:string;
BEGIN
    GetStatusStr:='GSV:'+FileName+'   '+
                  IntToStr(NameIndex+1)+'/'+IntToStr(GetCount)+
                  ' scale('+IntToStr(Scale)+'%)'+#0;
END;

PROCEDURE GraphRounderClass.CopyToOrg;
VAR
    TargSize:INTEGER;
BEGIN
    TargSize:=GetBMPSize(pBMPBody^.bmpCx,pBMPBody^.bmpCy);
    GetMem(pOrgBitmap,TargSize);
    Move(pBMPBody^,pOrgBitmap^,TargSize);
END;

FUNCTION GraphRounderClass.GetOrgWidth:INTEGER;
BEGIN
    IF DlgParam.isChangeSize THEN
        result:=DlgParam.ChangeSizeWidth
    ELSE
        result:=OrgWidth;
END;

FUNCTION GraphRounderClass.GetOrgHeight:INTEGER;
BEGIN
    IF DlgParam.isChangeSize THEN
        result:=DlgParam.ChangeSizeHeight
    ELSE
        result:=pOrgBitmap^.bmpCy;
END;

PROCEDURE GraphRounderClass.SetChangeSizeHeader(x,y:INTEGER);
VAR
    TargetSize:INTEGER;
BEGIN
    DlgParam.ChangeSizeWidth:=((DlgParam.ChangeSizeWidth+3)div 4)*4;
    DlgParam.ChangeSizeHeight:=((DlgParam.ChangeSizeHeight+3)div 4)*4;
    TargetSize:=GetBMPSize(x,y);

    IF pChangeSizeBMP=NIL THEN
        GetMem(pChangeSizeBMP,TargetSize)
    ELSE
        ReAllocMem(pChangeSizeBMP,TargetSize);
    FillChar(pChangeSizeBMP^,TargetSize,0);
    WITH pChangeSizeBMP^.InfoHeader2 DO BEGIN
        cbFix:=sizeof( BITMAPINFOHEADER2 );
        cx:=x;
        cy:=y;
        cPlanes:=1;
        cBitCount:=24;
        cbImage:=(x*y)*3;
        cclrused:=0;
        cclrImportant:=0;
    END;
    pChangeSizeBMP^.bmpCx:=x;
    pChangeSizeBMP^.bmpCy:=y;
    pChangeSizeBMP.cbSize:=TargetSize;
END;

PROCEDURE GraphRounderClass.CopyFromChangeSize(x,y,r:INTEGER);
VAR
    xScale,yScale:INTEGER;
    cx,cy,cc,d:INTEGER;
    RY,RX:INTEGER;
    OY,OX:INTEGER;
    OrgWidth,OrgHeight,CurWidth,CurHeight:INTEGER;
    FUNCTION GetRoundX(R,Y:INTEGER):INTEGER;
    BEGIN
        result:=TRUNC(SQRT(R*R-Y*Y));
    END;
BEGIN
    OrgWidth:=pOrgBitmap^.bmpCx;
    OrgHeight:=pOrgBitmap^.bmpCy;

    CurWidth:=pBMPBody^.bmpCx;
    CurHeight:=pBMPBody^.bmpCy;

    xScale:=(OrgWidth  *10) div DlgParam.ChangeSizeWidth;
    yScale:=(OrgHeight *10) div DlgParam.ChangeSizeHeight;

    FOR cy:=0 TO r-1 DO BEGIN
        RY:=(cy+y)*CurWidth*3;
        OY:=(cy*yScale div 10 )*OrgWidth*3;
        d:=R-GetRoundX(R,R-cy);
        FOR cx:=d TO DlgParam.ChangeSizeWidth-1-d DO BEGIN
            OX:=(cx*xScale div 10)*3;
            FOR cc:=0 TO 2 DO BEGIN
                pBMPBody^.rg[RY+(cx+x)*3+cc]:=pOrgBitmap^.rg[OY+OX+cc];
            END;
        END;
    END;

    FOR cy:=r TO DlgParam.ChangeSizeHeight-r DO BEGIN
        RY:=(cy+y)*CurWidth*3;
        OY:=(cy*yScale div 10 )*OrgWidth*3;
        FOR cx:=0 TO DlgParam.ChangeSizeWidth -1  DO BEGIN
            OX:=(cx*xScale div 10)*3;
            FOR cc:=0 TO 2 DO BEGIN
                pBMPBody^.rg[RY+(cx+x)*3+cc]:=pOrgBitmap^.rg[OY+OX+cc];
            END;
        END;
    END;

    FOR cy:=DlgParam.ChangeSizeHeight-r+1 TO DlgParam.ChangeSizeHeight DO BEGIN
        RY:=(cy+y)*CurWidth*3;
        OY:=(cy*yScale div 10)*OrgWidth*3;
        d:=R-GetRoundX(R,cy-DlgParam.ChangeSizeHeight+r-1);
        FOR cx:=d TO DlgParam.ChangeSizeWidth-1-d DO BEGIN
            OX:=(cx*xScale div 10)*3;
            FOR cc:=0 TO 2 DO BEGIN
                pBMPBody^.rg[RY+(cx+x)*3+cc]:=pOrgBitmap^.rg[OY+OX+cc];
            END;
        END;
    END;

END;


PROCEDURE GraphRounderClass.MakePaneLarge(enLargeSize:INTEGER);
VAR
    cx,cy,ox,oy,px,py:INTEGER;
BEGIN
    enLargeSize:=((enLargeSize+3) div 4)*4;
    ox:=pBMPBody^.bmpCx;
    oy:=pBMPBody^.bmpCy;
    cx:=pBMPBody^.bmpCx+enLargeSize;
    cy:=pBMPBody^.bmpCy+enLargeSize;
    ReAlloc(cx,cy+1); //Defensive . too large but neccesary!
    pBMPBody^.bmpCx:=cx;
    pBMPBody^.bmpCy:=cy;
    pBMPBody^.InfoHeader2.cx:=cx;
    pBMPBody^.InfoHeader2.cy:=cy;

    FOR py:=0 TO cy*3 DO BEGIN
        FOR px:=0 TO cx-1 DO BEGIN
            pBMPBody^.rg[py*cx+px*3+0]:=DlgParam.BkCol.B;
            pBMPBody^.rg[py*cx+px*3+1]:=DlgParam.BkCol.G;
            pBMPBody^.rg[py*cx+px*3+2]:=DlgParam.BkCol.R;
        END;
   END;

END;

PROCEDURE GraphRounderClass.CopyFromOrg;
VAR
    TargSize:INTEGER;
BEGIN
    TargSize:=GetBMPSize(pOrgBitmap^.bmpCx,pOrgBitmap^.bmpCy);
    Move(pOrgBitmap^,pBMPBody^,TargSize);
END;


PROCEDURE GraphRounderClass.MakeRender(DropL,RoundR:INTEGER);
VAR
    wRect:RectL;
    OrgHeight:INTEGER;
    Width,Height:INTEGER;
    ix,iy:INTEGER;
    ShCol:ColorRecord;
    Suffix:INTEGER;

    FUNCTION GetRoundX(R,Y:INTEGER):INTEGER;
    BEGIN
        result:=TRUNC(SQRT(R*R-Y*Y));
    END;
    PROCEDURE MoveFromOrg(xDif,yDif:INTEGER);
    VAR
        ow,cw:INTEGER;
        iy:INTEGER;
    BEGIN
        ow:=pOrgBitmap^.bmpCx;
        cw:=pBMPBody^.bmpCx;
        FOR iy:=0 TO OrgHeight-1 DO BEGIN
            Move(pOrgBitmap^.rg[iy*ow*3],
                 pBMPBody^.rg[((iy+yDif)*cw+xDif)*3],
                 ow*3);
        END;
    END;
    PROCEDURE RoundMoveFromOrg(xDif,yDif:INTEGER);
    VAR
        ow,cw:INTEGER;
        iy:INTEGER;
        r:INTEGER;
    BEGIN
        ow:=pOrgBitmap^.bmpCx;
        cw:=pBMPBody^.bmpCx;
        FOR iy:=0 TO RoundR-1 DO BEGIN
            r:=RoundR-GetRoundX(RoundR,RoundR-iy-1);
            move(pOrgBitmap^.rg[(iy*ow+r)*3],
                 pBMPBody^.rg[((iy+yDif)*cw+r+xDif)*3],
                 (ow-r*2)*3);
        END;
        FOR iy:=RoundR TO OrgHeight-RoundR-1 DO BEGIN
            Move(pOrgBitmap^.rg[iy*ow*3],
                 pBMPBody^.rg[((iy+yDif)*cw+xDif)*3],
                 ow*3);
        END;
        FOR iy:=0 TO RoundR-1 DO BEGIN
            r:=RoundR-GetRoundX(RoundR,iy);
            move(pOrgBitmap^.rg[((OrgHeight-RoundR+iy)*ow+r)*3],
                 pBMPBody^.rg[((OrgHeight-RoundR+iy+yDif)*cw+r+xDif)*3],
                 (ow-r*2)*3);
        END;
    END;
    PROCEDURE SetRGB(Suffix:INTEGER;ColRec:ColorRecord);
    BEGIN
        pBMPBody^.rg[Suffix*3  ]:=ColRec.B;
        pBMPBody^.rg[Suffix*3+1]:=ColRec.G;
        pBMPBOdy^.rg[Suffix*3+2]:=ColRec.R;
    END;

    FUNCTION GetGradient(FgColR,BkColR:ColorRecord;FgCoE:INTEGER):ColorRecord;
    VAR
        fc,bc:INTEGER;
    BEGIN
        IF RoundR>DropL THEN BEGIN
            IF FgCoE <(RoundR-DropL ) THEN BEGIN
                Fc:=RoundR;
                bc:=0;
            END
            ELSE BEGIN
                Fc:=RoundR*RoundR div DropL -(FgCoE*RoundR) div DropL;
                Bc:=RoundR-fc;
            END;
        END
        ELSE BEGIN
            Fc:=RoundR-FgCoE;
            Bc:=RoundR-fc;
        END;
        result.r:=(FgColR.R*Fc+BkColR.R*(bc)) div RoundR;
        result.G:=(FgColR.G*Fc+BkColR.G*(bc)) div RoundR;
        result.B:=(FgColR.B*Fc+BkColR.B*(bc)) div RoundR;
    END;

    PROCEDURE DrawShadow(CoreRect:RectL);
    VAR
        ix,iy:INTEGER;
        distance:INTEGER;
    BEGIN

        FOR iy:=CoreRect.yBottom TO CoreRect.yTop DO BEGIN
            Suffix:=Width*iy;
            FOR ix:=CoreRect.xLeft TO CoreRect.xRight DO BEGIN
                SetRGB((Suffix+ix),DlgParam.DropBkCol);
            END;
        END;

        FOR iy:=0 TO RoundR-1 DO BEGIN
            ShCol:=GetGradient(DlgParam.DropBkCol,DlgParam.BkCol,RoundR-iy-1);
            Suffix:=iy*Width;
            FOR ix:=CoreRect.xLeft TO CoreRect.xRight DO BEGIN
                SetRGB((Suffix+ix),ShCol);
            END;
            Suffix:=(OrgHeight-iy)*Width;
            FOR ix:=CoreRect.xLeft TO CoreRect.xRight DO BEGIN
                SetRGB((Suffix+ix),ShCol);
            END;
        END;
        FOR ix:=0 TO RoundR-1 DO BEGIN
            ShCol:=GetGradient(DlgParam.DropBkCol,DlgParam.BkCol,RoundR-ix-1);
            Suffix:=ix+CoreRect.xLeft-RoundR;
            FOR iy:=CoreRect.yBottom TO CoreRect.yTop DO BEGIN
                SetRGB((Suffix+iy*Width),ShCol);
            END;
            Suffix:=CoreRect.xRight+RoundR-ix;
            FOR iy:=RoundR TO OrgHeight-RoundR DO BEGIN
                SetRGB((Suffix+iy*Width),ShCol);
            END;
        END;

        FOR ix:=0 TO RoundR-1 DO BEGIN
            FOR iy:=0 TO RoundR-1 DO BEGIN
                distance:=Round(sqrt(ix*ix+iy*iy));
                IF distance+1>RoundR THEN
                    distance:=RoundR-1;
                ShCol:=GetGradient(DlgParam.DropBkCol,DlgParam.BkCol,distance);

                SetRGB(((iy+CoreRect.yTop+1)*Width+CoreRect.xRight+ix+1),ShCol);
                SetRGB(((iy+CoreRect.yTop+1)*Width+CoreRect.xLeft-ix-1),ShCol);
                SetRGB(((CoreRect.yBottom-iy-1)*Width+CoreRect.xLeft-ix-1),ShCol);
                SetRGB(((CoreRect.yBottom-iy-1)*Width+CoreRect.xRight+ix+1),ShCol);
            END;
        END;
    END;
BEGIN
    IF DlgParam.isChangeSize THEN BEGIN
        DlgParam.ChangeSizeHeight:=pOrgBitmap^.bmpCy*DlgParam.ChangeSizeWidth div pOrgBitmap^.bmpCx;
        SetChangeSizeHeader(0,0);
        pBMPBody^.bmpCx:=DlgParam.ChangeSizeWidth;
        pBMPBody^.bmpCy:=DlgParam.ChangeSizeHeight;
    END
    ELSE
        CopyFromOrg;

    IF pBMPBody^.bmpcy div 4<RoundR THEN RoundR:=pBMPBody^.bmpCy div 4;
    IF pBMPBody^.bmpcx div 4<RoundR THEN RoundR:=pBMPBody^.bmpCx div 4;

    MakePaneLarge(abs(DropL));

    Width:= pBMPBody^.bmpCx;
    Height:=pBMPBody^.bmpCy;
    OrgHeight:=GetOrgHeight;


    wRect.xLeft :=DropL+RoundR;
    wRect.xRight:=GetOrgWidth+DropL-RoundR;
    wRect.yTop  :=OrgHeight-RoundR;
    wRect.yBottom:=RoundR;

    FOR iy:=0 TO Height-1 DO BEGIN
        FOR ix:=0 TO Width-1 DO BEGIN
            SetRGB((iy*width+ix),DlgParam.BkCol);
        END;
    END;
    DrawShadow(wRect);


    IF DlgParam.isChangeSize THEN BEGIN
        CopyFromChangeSize(0,DropL,RoundR);
    END
    ELSE BEGIN
        IF DlgParam.isMakeRound THEN
            RoundMoveFromOrg(0,DropL)
        ELSE
            MoveFromOrg(0,DropL);
    END;

END;


PROCEDURE GraphRounderClass.LoadFile;
VAR
    w,h:INTEGER;
BEGIN
    inherited LoadFile;
    CopyToOrg;
    w:=pBMPBody^.bmpCx;
    h:=pBMPBody^.bmpCy;
    SetChangeSizeHeader(w,h);
    DlgParam.XYRatio:=w*1000 div h;
END;


PROCEDURE GraphRounderClass.PushParamList;
VAR
    ParamListCount:INTEGER;
    pRoundParam:^RoundParamRecord;
BEGIN
    NEW(pRoundParam);
    pRoundParam^:=DlgParam;

    ParamListCount:=ParamList.Count;
    IF ParamListCount<1 THEN BEGIN
        ParamList.Add(pRoundParam);
    END
    ELSE IF ParamListCount>=1 THEN BEGIN
        ParamList.Add(pRoundParam);
    END;
END;

FUNCTION GraphRounderClass.GetAnotherParamIndex:INTEGER;
VAR
    CurIndex:INTEGER;
    FUNCTION isParamSame(i:INTEGER):BOOLEAN;
    VAR
      pRoundParam:^RoundParamRecord;
    BEGIN
        pRoundParam:=ParamList[i];
        IF pRoundParam^.isMakeRound<>DlgParam.isMakeRound THEN BEGIN
            result:=FALSE;EXIT;
        END;
        IF isRGBSame(DlgParam.DropBkCol,pRoundParam^.DropBkCol)=FALSE THEN BEGIN
            result:=FALSE;
            EXIT;
        END;
        IF isRGBSame(DlgParam.BkCol,pRoundParam^.BkCol)=FALSE THEN BEGIN
            result:=FALSE;
            EXIT;
        END;
        IF DlgParam.DropLength<>pRoundParam^.DropLength THEN BEGIN
            result:=FALSE;
            EXIT;
        END;
        IF DlgParam.RoundRadian<>pRoundParam^.RoundRadian THEN BEGIN
            result:=FALSE;
            EXIT;
        END;
        IF DlgParam.isChangeSize<>pRoundParam^.isChangeSize THEN BEGIN
            result:=FALSE;
            EXIT;
        END;
        IF DlgParam.ChangeSizeWidth<>pRoundParam^.ChangeSizeWidth THEN BEGIN
            result:=FALSE;
            EXIT;
        END;

        result:=TRUE;
    END;
BEGIN
    CurIndex:=ParamList.Count-1;
    WHILE (CurIndex>=0)AND ( isParamSame(CurIndex)=FALSE) DO Dec(CurIndex);
    result:=CurIndex;
END;

FUNCTION GraphRounderClass.isPrevParam:BOOLEAN;
BEGIN
    IF ParamList.Count>0 THEN BEGIN
        isPrevParam:=TRUE
    END
    ELSE
        isPrevParam:=FALSE;
END;

FUNCTION GraphRounderClass.GetPrevParam:RoundParamRecord;
VAR
    pRoundParam:^RoundParamRecord;
BEGIN
    ParamList.Delete(ParamList.Count-1);
    IF ParamList.Count>0 THEN BEGIN
        pRoundParam:=ParamList[ParamList.Count-1];
        result:=pRoundParam^;
    END;
END;


PROCEDURE GraphRounderClass.DrawScreen(window:hwnd);
VAR
    ps :HPS;
    rect ,DrawRect,CurRect:RectL;
    rc:bool;
    st:string;
BEGIN
    WinQueryWindowRect(Window, rect);
    CurRect:=rect;
    ps:= WinBeginPaint(Window,0,@rect);
    GpiCreateLogColorTable(ps,
                           lCol_Reset,
                           lColF_RGB,
                           0,
                           0,
                           NIL);
    IF isArgEmpty=FALSE THEN BEGIN
        st:=GetStatusStr;
        WinSetWindowText(hwndFrame,@st[1]);
        DrawRect:=CalcEdge;
        DrawBitmap(DrawRect,ps);
    END
    ELSE BEGIN
        DrawRect.xLeft:=(CurRect.xRight-CurRect.xLeft) div 8;
        DrawRect.xRight:=DrawRect.xLeft*7;
        DrawRect.yBottom:=(CurRect.yTop-CurRect.yBottom) div 2 ;
        DrawRect.yTop:=DrawRect.yBottom+20;
        WinDrawText(ps,
                    -1,
                    'Drop Picture File or Foloder',
                    DrawRect,
                    CLR_RED,
                    CLR_WHITE,
                    DT_CENTER OR DT_VCenter OR DT_ERASERECT)
    END;
    CurRect:=rect;
    CurRect.yBottom:=DrawRect.yTop-1;
    rc:=WinFillRect(ps, CurRect, RGBToUColor(DlgParam.BkCol));

    CurRect:=rect;
    CurRect.yTop:=DrawRect.yBottom+1;
    rc:=WinFillRect(ps, CurRect, RGBToUColor(DlgParam.BkCol));

    CurRect:=rect;
    CurRect.xLeft:=DrawRect.xRight-1;
    rc:=WinFillRect(ps, CurRect, RGBToUColor(DlgParam.BkCol));

    CurRect:=rect;
    CurRect.xRight:=DrawRect.xLeft+1;
    rc:=WinFillRect(ps, CurRect, RGBToUColor(DlgParam.BkCol));
    WinEndPaint(ps);
END;



VAR
    OldColorProc:FNWP;
FUNCTION DropColorProc( hwndAny : HWnd;
                          ulMsg     : ULong;
                          mp1: MParam;
                          mp2: MParam ) : mResult; cdecl;
VAR
    AttrFound:ULong;
    DropBkCol:ULong;
BEGIN
    IF ulMsg=WM_PRESPARAMCHANGED THEN BEGIN
        result:=OldColorProc(hwndAny,ulMsg,mp1,mp2);
        IF mp1=PP_BackGroundColor THEN BEGIN
            WinQueryPresParam(hwndAny,
                              PP_BackGroundColor,
                              0,
                              @AttrFound,
                              SizeOf(ULong),
                              @DropBkCol,
                              qpf_NoInherit);

            GSVClass.DlgParam.DropBkCol:=uColorToRGB(DropBkCol);
        END;
    END
    ELSE
        result:=OldColorProc(hwndAny,ulMsg,mp1,mp2);
END;

FUNCTION SettingDlgProc( hwndDlg: HWND ;
                            ulMsg  : ULONG;
                            mp1    : MPARAM;
                            mp2    : MPARAM ) : mResult; cdecl;
VAR
    BtBkCol:ULong;
    i:LONGINT;
    UndoParam:RoundParamRecord;
    pCh:ARRAY[0..255] OF CHAR;
    usID          : UShort;
    usNotifyCode  : UShort;
    PROCEDURE GetDlgStatus;
    BEGIN
        GSVClass.DlgParam.isChangeSize:=
            BOOLEAN(WinSendDlgItemMsg(hwndDlg,
                                      IDChangeSizeCheck,
                                      BM_QUERYCHECK,
                                      0,
                                      0));
        GSVClass.DlgParam.isMakeRound:=
            BOOLEAN(WinSendDlgItemMsg(hwndDlg,
                                      IDRoundCheck,
                                      BM_QUERYCHECK,
                                      0,
                                      0));
        WinSendDlgItemMsg(hwndDlg,
                          IDRoundSpin,
                           SPBM_QUERYVALUE,
                           MParam(@i),
                           MPFROM2SHORT(0,SPBQ_DONOTUPDATE));
        GSVClass.DlgParam.RoundRadian:=i;

        WinSendDlgItemMsg(hwndDlg,
                          IDDropSpin,
                          SPBM_QUERYVALUE,
                          MParam(@i),
                          MPFROM2SHORT(0,SPBQ_DONOTUPDATE));
        GSVClass.DlgParam.DropLength:=i;

        WinSendDlgItemMsg(hwndDlg,
                          IDChangeSizeYSpin,
                          SPBM_QUERYVALUE,
                          MParam(@i),
                          MPFROM2SHORT(0,SPBQ_DONOTUPDATE));
        GSVClass.DlgParam.ChangeSizeWidth:=i;

        WITH GSVClass.DlgParam DO
            ChangeSizeHeight:=ChangeSizeWidth*1000 div XYRatio;

        GSVClass.MakeRender(GSVClass.DlgParam.DropLength,
                            GSVClass.DlgParam.RoundRadian);
        IF GSVClass.DlgParam.isChangeSize THEN BEGIN
            GSVClass.isFitWindow:=FALSE;
            GSVClass.JustScale;
        END;
    END;
    PROCEDURE SetDlgStatus;
    BEGIN
        WinSendDlgItemMsg(hwndDlg,
                          IDDropSpin,
                          SPBM_SETCURRENTVALUE,
                          MParam(GSVClass.DlgParam.DropLength),
                          MParam(0) );
        WinSendDlgItemMsg(hwndDlg,
                          IDRoundSpin,
                          SPBM_SETCURRENTVALUE,
                          MParam(GSVClass.DlgParam.RoundRadian),
                          MParam(0) );
        WinSendDlgItemMsg(hwndDlg,
                          IDChangeSizeCheck,
                          BM_SETCHECK,
                          Ord(GSVClass.DlgParam.isChangeSize),
                          0);
        WinSendDlgItemMsg(hwndDlg,
                          IDRoundCheck,
                          BM_SETCHECK,
                          Ord(GSVClass.DlgParam.isMakeRound),
                          0);
        BtBkCol:=RGBToUColor(GSVClass.DlgParam.DropBkCol);
        WinSetPresParam(WinWindowFromID(hwndDlg,IDColorButton),
                        PP_BACKGROUNDCOLOR,
                        4,
                        @BtBkCol);
    END;
BEGIN
    result:=0;
    CASE(ulMsg) OF
        WM_InitDlg:BEGIN
            IF GSVClass.FileList.Count>0 THEN BEGIN
                WinPostMsg(hwndDlg,WM_InitChangeSpin,0,0);
            END;
            @OldColorProc:=WinSubClassWindow(
                                WinWindowFromID(hwndDlg,IDColorButton),
                                DropColorProc);

            WinSendDlgItemMsg( hwndDlg,IDRoundSpin,SPBM_SETLIMITS,120,0);
            WinSendDlgItemMsg( hwndDlg,IDDropSpin,SPBM_SETLIMITS,120,0);
            SetDlgStatus;
            WinEnableControl(hwndDlg,IDUndo,FALSE);
        END;
        WM_COMMAND:BEGIN
            CASE Short1FromMP( mp1) OF
                IDRender:BEGIN
                    IF GSVClass.FileList.Count<1 THEN EXIT;
                    GetDlgStatus;
                    GSVClass.CalcFitScale;
                    GSVClass.RedrawMsg;
                    GSVCLass.PushParamList;
                    IF GSVClass.isPrevParam THEN BEGIN
                        WinEnableControl(hwndDlg,IDUndo,true);
                    END;

                END;
                IDSaveRender:BEGIN
                    GetDlgStatus;
                    GSVClass.isSave:=TRUE;
                    WinSendMsg(GSVClass.hwndPane,WM_SAVESTART,0,0);
                END;
                IDUndo:BEGIN
                    IF GSVClass.isPrevParam =FALSE THEN BEGIN
                        EXIT;
                    END;
                    UndoParam:=GSVClass.GetPrevParam;

                    IF GSVClass.isPrevParam=FALSE THEN BEGIN
                        GSVClass.CopyFromOrg;
                    END
                    ELSE BEGIN
                        GSVClass.DlgParam:=UndoParam;

                        SetDlgStatus;
                        GSVClass.MakeRender(GSVClass.DlgParam.DropLength,
                                            GSVClass.DlgParam.RoundRadian);
                    END;
                    IF GSVClass.DlgParam.isChangeSize THEN BEGIN
                        GSVClass.isFitWindow:=FALSE;
                        GSVClass.JustScale;
                    END;
                    GSVClass.CalcFitScale;
                    GSVClass.RedrawMsg;
                    IF GSVClass.isPrevParam =FALSE THEN
                        WinEnableControl(hwndDlg,IDUndo,FALSE);
                END;
            END;
        END;(**WM_COMMNAD**)
        wm_InitChangeSpin:BEGIN

            WinSendDlgItemMsg(hwndDlg,
                              IDChangeSizeYSpin,
                              SPBM_SETLIMITS,
                              GSVClass.pOrgBitmap^.bmpCy,
                              1);
            WITH GSVCLass DO BEGIN
                i:=pOrgBitmap^.bmpCy*
                        DlgParam.ChangeSizeWidth div pOrgBitmap^.bmpCx;
                DlgParam.ChangeSizeHeight:=i;
            END;
            WinSendDlgItemMsg(hwndDlg,
                              IDChangeSizeYSpin,
                              SPBM_SETCURRENTVALUE,
                              MParam(GSVClass.DlgParam.ChangeSizeWidth),
                              MParam(0) );
        END;
        ELSE BEGIN
           result:=WinDefDlgProc(hwndDlg,ulMsg,mp1,mp2);
        END;
    END;(**case**)
END;

FUNCTION OptionDlgProc( hwndDlg: HWND ;
                            ulMsg  : ULONG;
                            mp1    : MPARAM;
                            mp2    : MPARAM ) : mResult; cdecl;
var
    rc:ulong;
BEGIN
    result:=0;
    CASE(ulMsg) OF
        WM_InitDlg:BEGIN
            IF GSVClass.SaveGraphAttr=png THEN BEGIN
                WinSendDlgItemMsg(hwndDlg,IDPNGRadio,BM_SETCHECK,Ord(true),0);
                WinEnableControl(hwndDlg,IDJPEGSpin,FALSE);
            END
            ELSE BEGIN
                WinSendDlgItemMsg(hwndDlg,IDJPEGRadio,BM_SETCHECK,Ord(true),0);
                WinEnableControl(hwndDlg,IDJPEGSpin,TRUE);
            END;

            rc:=WinSendDlgItemMsg(hwndDlg,IDJPEGSpin,SPBM_SETLIMITS,95,5);
            WinSendDlgItemMsg(hwndDlg,
                              IDJPEGSpin,
                              SPBM_SETCURRENTVALUE,
                              MParam(GSVClass.JpegQuality),
                              0);
            WinSendDlgItemMsg(hwndDlg,IDAlbumSpin,SPBM_SETLIMITS,16,1);
            WinSendDlgItemMsg(hwndDlg,
                              IDAlbumSpin,
                              SPBM_SETCURRENTVALUE,
                              MParam(GSVClass.AlbumColum),
                              0);
        END;
        WM_COMMAND:BEGIN
            CASE Short1FromMP( mp1) OF
                DID_OK:BEGIN
                    IF WinSendDlgItemMsg(hwndDlg,
                                        IDPNGRadio,
                                        BM_QUERYCHECK,
                                        0,
                                        0)=Ord(True) THEN
                    BEGIN
                        GSVClass.SaveGraphAttr:=png
                    END
                    ELSE BEGIN
                        GSVClass.SaveGraphAttr:=jpg
                    END;
                    WinSendDlgItemMsg(hwndDlg,
                                      IDJPEGSpin,
                                      SPBM_QUERYVALUE,
                                      MParam(@GSVClass.JpegQuality),
                                      0);
                    WinSendDlgItemMsg(hwndDlg,
                                      IDAlbumSpin,
                                      SPBM_QUERYVALUE,
                                      MParam(@GSVClass.AlbumColum),
                                      0);
                    WinDismissDlg(hwndDlg,Ord(TRUE));
                END;
                DID_CANCEL:BEGIN
                    WinDismissDlg(hwndDlg,Ord(FALSE));
                END;
            END;
        END;(**WM_COMMNAD**)
        WM_CONTROL:BEGIN
            CASE SHORT1FROMMP(mp1) OF
                IDPNGRadio,IDJPEGRadio:BEGIN
                    IF SHORT2FROMMP(mp1) =BN_CLICKED THEN BEGIN
                        IF SHORT1FROMMP(mp1)=IDPNGRadio THEN BEGIN
                            WinEnableControl(hwndDlg,IDJPEGSpin,FALSE);
                        END
                        ELSE BEGIN
                            WinEnableControl(hwndDlg,IDJPEGSpin,TRUE);
                        END;
                    END;
                END;
            END;
        END;
        ELSE BEGIN
           result:=WinDefDlgProc(hwndDlg,ulMsg,mp1,mp2);
        END;
    END;(**case**)
END;

FUNCTION MainClientProc(Window: HWnd; Msg: ULong; Mp1,Mp2: MParam): MResult;
VAR
    St:String;
BEGIN
    result   :=0;
    CASE msg OF
        WM_COMMAND:BEGIN
            CASE SHORT1FROMMP(mp1) OF
                IDB_FIT:BEGIN
                    IF GSVClass.isArgEmpty THEN EXIT;
                    GSVClass.isFitWindow:=TRUE;
                    GSVClass.CalcFitScale;
                    GSVClass.RedrawMsg;
                END;
                IDB_UP:BEGIN
                    IF GSVClass.isArgEmpty THEN
                        EXIT;
                    GSVClass.isFitWindow:=FALSE;
                    GSVClass.UpScale;
                    GSVClass.RedrawMsg;
                    st:=GSVClass.GetStatusStr;
                    WinSetWindowText(hwndFrame,@st[1]);
                END;
                IDB_DOWN:BEGIN
                    IF GSVClass.isArgEmpty THEN EXIT;
                    GSVClass.isFitWindow:=FALSE;
                    GSVClass.DownScale;
                    GSVClass.RedrawMsg;
                    st:=GSVClass.GetStatusStr;
                    WinSetWindowText(hwndFrame,@st[1]);
                END;
                IDB_EXIT:BEGIN
                    SaveCfg;
                    WinPostMsg(Window, WM_QUIT, 0, 0);
                END;
                IDB_SETTING:BEGIN
                    IF WinDlgBox(HWND_DESKTOP,
                                 Window,
                                 OptionDlgProc,
                                 NullHandle,
                                 OptionDialog,
                                 NIL) =Ord(TRUE) THEN BEGIN

                    END;
                END;
                IDB_SHOWDLG  :BEGIN
                    WinSetActiveWindow(HWND_DESKTOP,GSVClass.hwndDlg);
                END;
            END;
        END;
        WM_CLOSE:BEGIN
            SaveCfg;
            WinPostMsg(GSVClass.FrameWindow, WM_QUIT, 0, 0);
        END;
        ELSE BEGIN
            result:=WinDefWindowProc(Window, msg, mp1, mp2);
        END;
    END;
END;


FUNCTION PaneClientProc(Window: HWnd; Msg: ULong; Mp1,Mp2: MParam): MResult;
VAR
    xScroll,yScroll:INTEGER;
BEGIN
    result   :=0;
    CASE msg OF
        wm_vscroll:BEGIN
            IF (GSVClass.pBMPBody^.sCy-GSVCLass.Cy) <=0 THEN
                EXIT;
            CASE SHORT2FROMMP(mp2) OF
                SB_LINEUP:BEGIN
                    Dec(GSVClass.yEdge,5);
                    yScroll:=(GSVClass.pBMPBody^.sCy-GSVCLass.Cy) div 2
                            + GSVClass.yEdge;
                END;
                SB_LINEDOWN:BEGIN
                    Inc(GSVClass.yEdge,5);
                    yScroll:=(GSVClass.pBMPBody^.sCy-GSVCLass.Cy) div 2
                            + GSVClass.yEdge;
                END;
                SB_PAGEUP:BEGIN
                    Dec(GSVClass.yEdge,GSVClass.Cy);
                    yScroll:=(GSVClass.pBMPBody^.sCy-GSVCLass.Cy) div 2
                            + GSVClass.yEdge;

                END;
                SB_PAGEDOWN:BEGIN
                    inc(GSVClass.yEdge,GSVClass.Cy);
                    yScroll:=(GSVClass.pBMPBody^.sCy-GSVCLass.Cy) div 2
                            + GSVClass.yEdge;
                END;
                SB_SLIDERTRACK,SB_SLIDERPOSITION:BEGIN
                    yScroll:=SHORT1FROMMP(mp2);
                    GSVClass.yEdge:=yScroll-
                                    (GSVClass.pBMPBody^.sCy-GSVCLass.Cy) div 2;
                END;
            END;
            IF yScroll<0 THEN BEGIN
                yScroll:=0;
                GSVClass.yEdge:=-(GSVClass.pBMPBody^.sCy-GSVCLass.Cy) div 2;
            END;
            IF yScroll>GSVClass.pBMPBody^.sCy-GSVClass.Cy THEN BEGIN
                yScroll:=(GSVClass.pBMPBody^.sCy-GSVCLass.Cy);
                GSVClass.yEdge:=(GSVClass.pBMPBody^.sCy-GSVCLass.Cy) div 2;
            END;

            WinSendMsg( GSVClass.HwndVScrol,
                        SBM_SETPOS,
                        MPFROMSHORT(yScroll),
                        0);
            GSVClass.RedrawMsg;
        END;
        wm_hscroll:BEGIN
            IF (GSVClass.pBMPBody^.sCx-GSVCLass.cy) <0 THEN
                EXIT;
            CASE SHORT2FROMMP(mp2) OF
                SB_LINELEFT:BEGIN
                    Dec(GSVClass.xEdge,5);
                END;
                SB_LINERIGHT:BEGIN
                    Inc(GSVClass.xEdge,5);
                END;
                SB_PAGELEFT:BEGIN
                    Dec(GSVClass.xEdge,GSVClass.cy);
                END;
                SB_PAGERIGHT:BEGIN
                    Inc(GSVClass.xEdge,GSVClass.Cx);
                END;
                SB_SLIDERTRACK,SB_SLIDERPOSITION:BEGIN
                    xScroll:=SHORT1FROMMP(mp2);
                    GSVClass.xEdge:=xScroll-
                                    (GSVClass.pBMPBody^.sCx-GSVCLass.Cx) div 2;
                END;
            END;
            xScroll:=(GSVClass.pBMPBody^.sCx-GSVCLass.Cx) div 2 + GSVClass.xEdge;
            IF xScroll<0 THEN BEGIN
                xScroll:=0;
                GSVClass.xEdge:=-(GSVClass.pBMPBody^.sCx-GSVCLass.Cx) div 2;
            END;
            IF xScroll>GSVClass.pBMPBody^.sCx-GSVClass.Cx THEN BEGIN
                xScroll:=(GSVClass.pBMPBody^.sCx-GSVCLass.Cx);
                GSVClass.xEdge:=(GSVClass.pBMPBody^.sCx-GSVCLass.Cx) div 2;
            END;

            WinSendMsg( GSVClass.HwndHScrol,
                        SBM_SETPOS,
                        MPFROMSHORT(xScroll),
                        0);
            GSVClass.RedrawMsg;
        END;
        ELSE
            result:=WinDefWindowProc(Window, msg, mp1, mp2);

    END;
END;


FUNCTION DropToString(mp1,mp2:MParam):string;
VAR
    pChFile,achFile,achPath : ARRAY[0..CCHMAXPATH-1] OF CHAR;
    pdiDrag : PDRAGINFO;
    pdiItem : PDRAGITEM;
BEGIN
    pdiDrag := PVOIDFROMMP(mp1);
    DrgAccessDraginfo( pdiDrag^ );

    pdiItem := DrgQueryDragitemPtr(pdiDrag^, 0);
    DrgQueryStrName(pdiItem^.hstrContainerName,sizeof(achPath),achPath);
    DosQueryPathInfo(achPath,FIL_QUERYFULLNAME,achPath,sizeof(achPath));

    IF (achPath[strlen(achPath)-1] <> '\') THEN strcat(achPath, '\');
    DrgQueryStrName(pdiItem^.hstrSourceName,sizeof(achFile),achFile);
    strcopy( pchFile, achPath );
    strcat( pchFile, achFile );
    result:=StrPas(PchFile);
    WinSendMsg( pdiDrag^.hwndSource,
            DM_ENDCONVERSATION,
            MPFROMLONG(pdiItem^.ulItemID),
            MPFROMLONG(DMFL_TARGETSUCCESSFUL) );

    DrgFreeDraginfo(pdiDrag^);
END;

FUNCTION DrawPaneClientProc(Window:HWnd;Msg:ULong;Mp1,Mp2:MParam):MResult;
VAR
    i:INTEGER;
    st:string;
    AttrFound:ULong;
    ps:hps;
    BkCol:ULong;
    ColTable:ARRAY[0..15]OF ULong;
    PROCEDURE FirstPNGAction;
    BEGIN
        GSVClass.isFitWindow:=FALSE;
        GSVClass.Scale:=100;
        GSVClass.DrawScreen(window);
        GSVClass.MakeRender(GSVClass.DlgParam.DropLength,
                            GSVClass.DlgParam.RoundRadian);
        CreateDir(GSVClass.GetCurPathName+AlbumThumPath);
        GSVClass.SaveFile;
      END;
BEGIN
    result:=0;
    CASE msg OF
        WM_CREATE:BEGIN
            GSVClass.SaveGraphAttr:=png;
            GSVClass.JpegQuality:=75;
            IF GSVClass.isArgEmpty=FALSE THEN BEGIN
                GSVClass.SetFirst;
                GSVClass.LoadFile;
                GSVClass.CalcFitScale;
                IF GSVClass.isAuto THEN BEGIN
                    FirstPNGAction;
                END;
            END;
            GSVClass.CreateScroll(window);
            GSVClass.DrawScreen(window);
            IF GSVClass.isAuto THEN
                WinSendMsg(Window,WM_ENDTHREAD,0,0);
        END;
        WM_PAINT:BEGIN
            GSVClass.DrawScreen(window);
            GSVClass.SetScroll;
        END;
        WM_SIZE:BEGIN
            GSVClass.SetPaneSize(SHORT1FROMMP(mp2),SHORT2FROMMP(mp2));
            IF GSVClass.isArgEmpty=FALSE THEN BEGIN
                GSVClass.CalcFitScale;
                GSVClass.SetScroll;
            END;
        END;
        DM_DRAGOVER:BEGIN
            result:=MRFROM2SHORT(DOR_DROP, DO_MOVE);
        END;
        DM_DROP:BEGIN
            IF GSVClass.isArgEmpty=FALSE THEN BEGIN
                GSVClass.FlushList;
            END;
            St:=DropToString(mp1,mp2);

            GSVClass.EvalArg(St);
            IF GSVClass.isArgEmpty=FALSE THEN BEGIN
                GSVClass.xEdge:=0;
                GSVClass.yEdge:=0;
                GSVClass.SetFirst;
                GSVClass.LoadFile;
                WinSendMsg(GSVClass.hwndDlg,WM_InitChangeSpin,0,0);
                GSVClass.CalcFitScale;
                GSVClass.SetScroll;
            END;
            GSVClass.RedrawMsg;
        END;
        WM_TIMER:BEGIN
            WinStopTimer(GetAnchor,Window,MainTimerID);
            IF GSVClass.isLast=TRUE THEN BEGIN
                SaveCfg;
                IF GSVClass.isSave=FALSE THEN
                    WinSendMsg(GSVClass.FrameWindow,WM_CLOSE,0,0)
                ELSE BEGIN
                    GSVClass.isSave:=FALSE;
                    GSVClass.isAuto:=FALSE;
                END;
            END
            ELSE BEGIN
                GSVClass.SetNext;
                GSVClass.ThreadID:=VPBeginThread(LoadToDraw,20480000,GSVClass);
            END;
        END;
        WM_ENDTHREAD:BEGIN
            DosKillThread(GSVClass.ThreadID);
            IF GSVClass.isFitWindow THEN
                GSVClass.CalcFitScale;
            GSVClass.RedrawMsg;

            IF GSVClass.isAuto THEN BEGIN
                WinStartTimer(GetAnchor,
                              Window,
                              MainTimerID,
                              GSVClass.TimerSec);
            END;
        END;
        WM_SAVESTART:BEGIN
              GSVClass.SetFirst;
              GSVClass.isAuto:=TRUE;
              FirstPNGAction;
              WinSendMsg(Window,WM_ENDTHREAD,0,0);
        END;
        WM_PRESPARAMCHANGED:BEGIN
            IF mp1=PP_BackGroundColor THEN BEGIN
                WinQueryPresParam(Window,
                                  PP_BackGroundColor,
                                  0,
                                  @AttrFound,
                                  SizeOf(ULong),
                                  @BkCol,
                                  qpf_NoInherit);
                GSVClass.DlgParam.BkCol:=uColorToRGB(BkCol);
            END;
            GSVClass.RedrawMsg;
        END;
        ELSE
            result:=WinDefWindowProc(Window, msg, mp1, mp2);
    END;
END;

VAR
    mq       :HMQ;
    msg      :QMSG;
    swp      :os2pmapi.SWP;
    St:string;
    Anchor:HAB;
    GetOpt:GetOptClass;

BEGIN
//HALT;
    Anchor:=WinInitialize(0);
    IF Anchor=0 THEN HALT(-1);

    mq:=WinCreateMsgQueue(Anchor, 0);

    IF mq=0 THEN BEGIN
        WinTerminate(Anchor);
        HALT(-2);
    END;

    ToolkitInit(Anchor);

    WinRegisterClass(Anchor,
                     'BitmapPane',
                     DrawPaneClientProc,
                     CS_SIZEREDRAW,
                     sizeof(ULONG));

    WinQueryWindowPos(HWND_DESKTOP, swp);

    GSVClass:=GraphRounderClass.Create;
    LoadCfg;
    GetOpt:=GetOptClass.Create('ac','');
    WHILE GetOpt.isOptEnd=FALSE DO BEGIN
        CASE GetOpt.GetOptCh OF
            'c':BEGIN
                IF GetOpt.isEnd=FALSE THEN BEGIN
                    St:=GetOpt.GetNextArg;
                    TRY
                        GSVClass.AlbumColum:=StrToInt(St);
                    EXCEPT
                        GSVClass.AlbumColum:=5;
                    END;
                END;
            END;
            'a':BEGIN
                IF GetOpt.isEnd =FALSE THEN BEGIN
                    GSVClass.isAuto:=TRUE;
                    GSVClass.EvalArg(GetOpt.GetNextArg);
                END;
            END;
        END;
    END;
    WHILE GetOpt.isEnd=FALSE DO BEGIN
        GSVClass.EvalArg(GetOpt.GetNextArg);
    END;

    hwndFrame:=CreateCell(mainClient, HWND_DESKTOP, 0);
    GSVClass.FrameWindow:=hwndFrame;
    IF hwndFrame<>0 THEN BEGIN
        WinSetWindowPos(hwndFrame,
                        NULLHANDLE,
                        swp.x ,
                        swp.y + swp.cy div 2,
                        (swp.cx div 2),
                        (swp.cy div 2),
                        SWP_ACTIVATE OR SWP_MOVE OR SWP_SIZE OR SWP_SHOW);

        hwndTB:=CreateToolbar(hwndFrame,mainTb);

        GSVClass.hwndPane:=CellWindowFromID(hwndFrame, ID_DRAWPANE);
        WinSetWindowPos(hwndFrame,
                        NULLHANDLE,
                        xPos,yPos,xWidth,yHeight,
                        SWP_ACTIVATE OR SWP_MOVE OR SWP_SIZE OR SWP_SHOW);
        GSVClass.hwndDlg:=WinLoadDlg( hWND_DESKTOP,
                                      HWND_OBJECT,
                                      SettingDlgProc,
                                      0,
                                      DLGPanel,
                                      NIL);

        // -------------------------------
        WHILE WinGetMsg(Anchor,msg,0,0,0) DO WinDispatchMsg(Anchor,msg);
        // -------------------------------
        WinDestroyWindow(hwndFrame);
    END;

    WinDestroyMsgQueue(mq);
    WinTerminate(Anchor);
END.


VM

{
$Log: ground.pas $
Revision 7.0  2008/06/08 03:33:19  Average
画像ファイルが見えなくなる問題を修正する版。これが初め

Revision 6.8  2007/07/22 13:13:40  Average
一応Radioボタンに連動してJPEGのQualityスピンボタンが活性させる

Revision 6.7  2007/07/22 12:33:36  Average
結局コントロールのオンオフは挫折

Revision 6.6  2007/07/22 12:09:38  Average
セーブファイル形式を変更

Revision 6.5  2007/07/22 12:00:04  Average
リファクタ第一段。
アルバムファイルがjpegサポート

Revision 6.4  2007/07/22 11:36:01  Average
 ファイルセーブを全部手続きに

Revision 6.3  2007/07/22 08:24:39  Average
設定ダイアログの動作確認

Revision 6.2  2007/07/22 04:56:58  Average
ダイアログに数値を表示可能に

Revision 6.1  2007/07/21 18:25:24  Average
セーブオプションダイアログを導入

Revision 5.13  2007/07/15 11:32:08  Average
 とりあえずレンダリングの影のバグを修正

Revision 5.12  2007/07/14 16:22:47  Average
グラディエーションを変化。

Revision 5.11  2007/07/11 15:18:49  Average
 一部リファクタ化

Revision 5.10  2007/07/07 15:55:15  Average
とりあえずちょっと修正

Revision 5.9  2007/07/07 15:20:21  Average
BMPのサイズを求める関数を追加

Revision 5.8  2007/07/07 15:14:36  Average
Undoのバグ取り
これで上手くいっているのか???

Revision 5.7  2007/07/07 14:46:15  Average
Undoのバグを修正

Revision 5.6  2007/07/07 14:42:18  Average
前に戻した

Revision 5.4  2007/07/05 14:07:46  Average
 リファクタ第一号

Revision 5.3  2007/07/04 16:12:06  Average
パラメータのセーブ/ロードを入れ込みはじめた

Revision 5.2  2007/07/04 16:02:43  Average
とりあえず、Render&Saveが動くように

Revision 5.1  2007/07/04 12:44:23  Average
周辺ぼかしをアルゴリズムじゃなくてぼかしで

Revision 4.8  2007/07/02 15:50:33  Average
設定ファイル読み書きの修正。

Revision 4.7  2007/07/01 13:16:23  Average
ダイアログのデザインを改訂

Revision 4.6  2007/07/01 12:59:41  Average
ダイアログの形を変えた

Revision 4.5  2007/06/27 14:32:59  Average
 ばばんとWebページ作成へ

Revision 4.4  2007/06/26 14:45:58  Average
縦横比の正確さを求める

Revision 4.3  2007/06/26 14:03:08  Average
 一応Webページが表示できるように

Revision 4.2  2007/06/25 15:49:58  Average
とりあえずmakeroudしながらの閲覧は大丈夫になりました。
これからWebページの構築へ

Revision 4.1  2007/06/25 12:37:11  Average
 Webアルバム化

Revision 3.16  2007/06/23 14:30:59  Average
ドロップした時の挙動をマシに

Revision 3.15  2007/06/21 15:23:37  Average
とりあえず縮小が上手く動くように

Revision 3.13  2007/06/20 14:11:33  Average
とりあえずリサイズの部分を導入

Revision 3.12  2007/06/20 13:41:21  Average
リサイズ直前リファクタ版

Revision 3.11  2007/06/19 16:12:12  Average
とりあえずUndoをより自然に?

Revision 3.10  2007/06/19 16:07:42  Average
ちょこっとダイアログを増やしました

Revision 3.9  2007/06/19 14:23:47  Average
PNGファイルの書き込みを可能に

Revision 3.8  2007/06/18 14:08:54  Average
ちょっとだけ手直し

Revision 3.7  2007/06/18 13:59:33  Average
Undoをちょっと正確に

Revision 3.6  2007/06/17 14:35:06  Average
ファイルが無い時にレンダーしない様に

Revision 3.5  2007/06/17 14:33:38  Average
Undoをインプリメント。だけど中途半端難だよなぁ。

Revision 3.4  2007/06/17 14:19:41  Average
ちょっとリファクタ

Revision 3.3  2007/06/17 14:10:09  Average
ダイアログデザイン、及びUndoを活性化
(活性化はそれまで)

Revision 3.2  2007/06/17 13:12:39  Average
とりあえずリファクタリング

Revision 3.1  2007/06/17 12:40:01  Average
影の方向を色々に変更出来るように
試行錯誤バージョン(変更はじめ)

Revision 2.9  2007/06/16 14:36:41  Average
Undoボタンを非活性化

Revision 2.8  2007/06/16 14:29:41  Average
影落としのバグ修正

Revision 2.7  2007/06/16 13:09:05  Average
ちょこっとリファクタ

Revision 2.6  2007/06/16 13:01:52  Average
MakeRound改良が出来るようになりました

Revision 2.5  2007/06/15 15:42:10  Average
識別子をちょっといじる

Revision 2.4  2007/06/15 15:38:49  Average
まずは影の完全描画

Revision 2.3  2007/06/14 13:33:13  Average
Undoのガラだけ付けました。

Revision 2.2  2007/06/14 12:38:49  Average
とりあえず影を矛盾なく落とせるように

Revision 2.1  2007/06/14 12:29:35  Average
作業途中

Revision 2.0  2007/06/13 16:06:57  Average
BMP読み込みルーチンを削除

Revision 1.11  2007/06/13 15:28:36  Average
色を保存できるように

Revision 1.10  2007/06/13 15:05:31  Average
カラーパレットから影の色をコントロールできるように

Revision 1.9  2007/06/12 15:44:57  Average
レンダーダイアログの登場。

Revision 1.8  2007/06/12 15:22:03  Average
とりあえずダイアログを出した。

Revision 1.7  2007/06/09 19:01:04  Average
とりあえずbmpが4の倍数でない時の処理を追加

Revision 1.6  2007/06/09 15:32:20  Average
四隅をグレイに

Revision 1.5  2007/06/09 15:00:58  Average
グラデーションを円弧以外実装

Revision 1.4  2007/06/09 13:36:04  Average
ラウンド処理を影付に

Revision 1.3  2007/06/09 05:06:59  Average
ファイルに書き込めるように

Revision 1.2  2007/06/07 15:56:48  Average
角を丸める

Revision 1.1  2007/06/06 15:39:17  Average
Initial revision

HWND_OBJECT
