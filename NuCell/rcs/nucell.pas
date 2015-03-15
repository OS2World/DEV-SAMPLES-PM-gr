head	4.2;
access;
symbols;
locks;
comment	@ * @;


4.2
date	2007.11.27.14.21.11;	author Average;	state Exp;
branches;
next	4.1;

4.1
date	2007.05.21.14.11.45;	author Average;	state Exp;
branches;
next	4.0;

4.0
date	2007.05.18.13.37.03;	author Average;	state Exp;
branches;
next	3.8;

3.8
date	2007.05.13.07.07.24;	author Average;	state Exp;
branches;
next	3.7;

3.7
date	2007.05.13.04.00.45;	author Average;	state Exp;
branches;
next	3.6;

3.6
date	2007.05.12.14.10.45;	author Average;	state Exp;
branches;
next	3.5;

3.5
date	2007.05.12.14.05.43;	author Average;	state Exp;
branches;
next	3.4;

3.4
date	2007.05.12.14.04.35;	author Average;	state Exp;
branches;
next	3.3;

3.3
date	2007.05.12.14.00.12;	author Average;	state Exp;
branches;
next	3.2;

3.2
date	2007.05.12.12.05.03;	author Average;	state Exp;
branches;
next	3.1;

3.1
date	2007.05.11.14.45.54;	author Average;	state Exp;
branches;
next	3.0;

3.0
date	2007.05.11.13.27.41;	author Average;	state Exp;
branches;
next	2.12;

2.12
date	2006.11.09.14.52.31;	author Average;	state Exp;
branches;
next	2.11;

2.11
date	2006.10.22.11.55.55;	author Average;	state Exp;
branches;
next	2.10;

2.10
date	2006.10.20.15.48.43;	author Average;	state Exp;
branches;
next	2.9;

2.9
date	2006.10.20.15.45.29;	author Average;	state Exp;
branches;
next	2.8;

2.8
date	2006.10.20.15.32.12;	author Average;	state Exp;
branches;
next	2.7;

2.7
date	2006.10.19.15.14.18;	author Average;	state Exp;
branches;
next	2.6;

2.6
date	2006.10.19.14.45.54;	author Average;	state Exp;
branches;
next	2.5;

2.5
date	2006.10.18.14.27.18;	author Average;	state Exp;
branches;
next	2.4;

2.4
date	2006.10.12.15.13.56;	author Average;	state Exp;
branches;
next	2.3;

2.3
date	2006.10.10.13.44.47;	author Average;	state Exp;
branches;
next	2.2;

2.2
date	2006.10.10.12.29.39;	author Average;	state Exp;
branches;
next	2.1;

2.1
date	2006.10.09.15.54.03;	author Average;	state Exp;
branches;
next	2.0;

2.0
date	2006.10.09.08.47.31;	author Average;	state Exp;
branches;
next	1.9;

1.9
date	2006.10.05.14.55.40;	author Average;	state Exp;
branches;
next	1.8;

1.8
date	2006.10.04.16.14.34;	author Average;	state Exp;
branches;
next	1.7;

1.7
date	2006.10.03.15.01.45;	author Average;	state Exp;
branches;
next	1.6;

1.6
date	2006.10.01.17.02.23;	author Average;	state Exp;
branches;
next	1.5;

1.5
date	2006.10.01.16.54.13;	author Average;	state Exp;
branches;
next	1.4;

1.4
date	2006.10.01.16.09.34;	author Average;	state Exp;
branches;
next	1.3;

1.3
date	2006.10.01.16.00.19;	author Average;	state Exp;
branches;
next	1.2;

1.2
date	2006.10.01.15.57.37;	author Average;	state Exp;
branches;
next	1.1;

1.1
date	2006.10.01.15.35.31;	author Average;	state Exp;
branches;
next	;


desc
@@


4.2
log
@ちょっと変更あり?
@
text
@(*
** Module   :CELL
** Abstract :Cell Toolkit
**
** Copyright (C) Sergey I. Yevtushenko
** Log: Sun  08/02/98   Created
**      Wed  25/10/2000 Updated to version 0.7b
*)
UNIT NuCell;
INTERFACE
{$Z-,P-,S-,R-,B-}
USES os2def, os2pmapi,SysUtils,Classes;

(* Constants *)
CONST
    ButtonDepth=1;
    NuCellTimerID=256;
    cTextSize=32;

CONST
    TK_VERSION      ='$Revision: 4.1 $';  (* Toolkit version *)
    CELL_WINDOW     = $0000;  (* Cell is window *)
    CELL_VSPLIT     = $0001;  (* Cell is vertically splitted view *)
    CELL_HSPLIT     = $0002;  (* Cell is horizontally splitted view *)
    CELL_SPLITBAR   = $0004;  (* Call has a splitbar *)
    CELL_FIXED      = $0008;  (* Views can't be sized *)
    CELL_SIZE1      = $0010;  (* *)
    CELL_SIZE2      = $0020;
    CELL_HIDE_1     = $0040;  (* Cell 1 is hidden *)
    CELL_HIDE_2     = $0080;  (* Cell 2 is hidden *)
    CELL_HIDE       = $00C0;  (* Cell 1 or cell 2 is hidden *)
    CELL_SPLIT_MASK = $003F;
    CELL_SWAP       = $1000;  (* Cells are swapped *)
    CELL_SPLIT10x90 = $0100;  (* Sizes of panels related as 10% and 90% *)
    CELL_SPLIT20x80 = $0200;  (* Sizes of panels related as 20% and 80% *)
    CELL_SPLIT30x70 = $0300;  (* Sizes of panels related as 30% and 70% *)
    CELL_SPLIT40x60 = $0400;  (* Sizes of panels related as 40% and 60% *)
    CELL_SPLIT50x50 = $0500;  (* Sizes of panels related as 50% and 50% *)
    CELL_SPLIT60x40 = $0600;  (* Sizes of panels related as 60% and 40% *)
    CELL_SPLIT70x30 = $0700;  (* Sizes of panels related as 70% and 30% *)
    CELL_SPLIT80x20 = $0800;  (* Sizes of panels related as 80% and 20% *)
    CELL_SPLIT90x10 = $0900;  (* Sizes of panels related as 90% and 10% *)
    CELL_SPLIT_REL  = $0F00;

    TB_BUBBLE       = $0001; (* Toolbar has bubble help *)
    TB_VERTICAL     = $0002; (* Default toolbar view is vertical *)
    TB_FLOATING     = $0004; (* Toolbar not attached *)
    TB_ATTACHED_LT  = $0010; (* Toolbar attached to left side  *)
    TB_ATTACHED_TP  = $0020; (* Toolbar attached to right side *)
    TB_ATTACHED_RT  = $0040; (* Toolbar attached to top side   *)
    TB_ATTACHED_BT  = $0080; (* Toolbar attached to bottom     *)
    TB_ALLOWED      = $00FF; (* *)

    TB_SEPARATOR    = $7001; (* Separator Item ID *)
    TB_BUBBLEID     = $7002; (* Bubble help window ID *)
    TB_ENTRYFIELD   = $7003;

(* Limits *)

    SPLITBAR_WIDTH   =    2; (* wodth of split bar between cells *)
    HAND_SIZE        =    8; (* toolbar drag 'hand' *)
    TB_SEP_SIZE      =    7; (* width of toolbar separator item *)
    TB_BUBBLE_SIZE   =   32; (* bubble help item size *)
    CELL_TOP_LIMIT   =   98; (* maximal space occupied by one cell (%%) *)
    CELL_BOTTOM_LIMIT=    2; (* minimal space occupied by one cell (%%) *)
    TBSepSize      :INTEGER=TB_SEP_SIZE;
    TBSepLong       :INTEGER=TB_SEP_SIZE;

(* Window classes *)

TYPE
    PCellDef = ^CellDef;
    CellDef  = RECORD
        lType    :LONGINT; // Cell TYPE flags
        pszClass :pchar;   // IF flag CELL_WINDOW is set,
                           //  this is a Window CLASS
        pszName  :pchar;   // Caption
        ulStyle  :LONGINT; // IF flag CELL_WINDOW is NOT set,
                           // this a Frame creation flags
        ulID     :LONGINT; // Cell window ID
        pPanel1  :PCellDef;
        pPanel2  :PCellDef;
        pClassProc:FnWp;
        pClientClassProc:FnWp;
        lSize    :LONGINT; // Meaningful only
                           //IF both CELL_SIZE(1|2) AND CELL_FIXED is set
    END;

    (* Toolbar data *)

    TbItemData  = RECORD
        NuID:ULong;
        cText   :String[cTextSize];
    END;
    PTbItemData = ^TbItemData;


    TbDef    = RECORD
        lType    :LONGINT; // Toolbar flags
        ulID     :LONGINT; // Toolbar window ID
        tbItems  :pTBItemData;
    END;

(*
** Internal cell data, used by ordinary windows.
** May be useful for user-defined windows
*)
    PWindowCellCtlData = ^WindowCellCtlData;
    WindowCellCtlData  = RECORD
        pOldProc :FnWp;
    END;

(* Prototypes *)

PROCEDURE ToolkitInit(appAnchor:HAB);

FUNCTION  CreateCell(VAR pCell:CellDef; hWndParent,hWndOwner:HWND):HWND;
FUNCTION  CellWindowFromID(hwndCell:HWND; ulID:LONGINT):HWND;
FUNCTION  CellParentWindowFromID(hwndCell:HWND; ulID:LONGINT):HWND;
FUNCTION CreateToolbar(hwndCell:HWND; VAR pTb:TbDef):HWND;

(* Some useful additions *)
TYPE
    NuTBClass=CLASS
        NuID:ULong;
        NuWnd:hwnd;
        cText   :String[32];
        isHilight,isCapture,isStartTimer:LongBool;
        pOldProc:FNWP;
        FUNCTION CreateButton(tb:TBItemData;hwndTB,hwndOwner:hwnd):hwnd;
                                                                    virtual;
        PROCEDURE DrawFrame(isPop:BOOLEAN;rect:RectL;ps:HPS);virtual;
        FUNCTION ButtonHandler(window:hwnd;Msg:ULong;Mp1,Mp2:MParam):MResult;
                                                                     virtual;
        FUNCTION GetUpBitmap(window:hwnd):HBitmap;virtual;
    END;
    NuTBListClass=CLASS
        TBList:TList;
        constructor Create;
        FUNCTION GetTBClass(NuID:ULong):NuTBClass;
        PROCEDURE SetTB(NuID:ULong;NuTB:NuTBClass);
    END;
VAR
    NuTBList:NuTBListClass;

FUNCTION  GetSplit(Window:HWND; lID:LONGINT):LONGINT;
FUNCTION  SetSplit(Window:HWND; lID,lNewSplit:LONGINT):LONGINT;
PROCEDURE SetSplitType(Window:HWND; lID,lNewSplit:LONGINT);
FUNCTION  GetSplitType(Window:HWND; lID:LONGINT):LONGINT;
PROCEDURE ShowCell(Window:HWND; lID:LONGINT; Action:BOOLEAN);
PROCEDURE SetToolBarState(Window:HWND; lState:ULong);
FUNCTION GetID(window:hwnd):INTEGER;
FUNCTION GetAnchor:HAB;


IMPLEMENTATION
USES
    strings;
VAR
    Anchor:HAB;
FUNCTION GetAnchor:HAB;
begin
    GetAnchor:=Anchor;
end;

CONST
    TKM_SEARCH_ID       =WM_USER+$1000;
    TKM_QUERY_FLAGS     =WM_USER+$1001;
    TKM_SEARCH_PARENT   =WM_USER+$1002;

    TB_ATTACHED         =$00F8;

(*****************************************************************************
** Static data
*)
    CELL_CLIENT:pchar   ='Uni.Cell.Client';
    TB_CLIENT  :pchar   ='Uni.Tb.Client';
    TB_SEPCLASS:pchar   ='Uni.Tb.Separator';
    ppFont     :pchar   ='9.WarpSans';

(* Color tables *)

TYPE
    ClTableArray  = ARRAY [0..SPLITBAR_WIDTH-1] OF LONGINT;
    PClTableArray = ^ClTableArray;

CONST
    lColor  :ClTableArray=(
                CLR_BLACK,// CLR_PALEGRAY, { if (SPLITBAR_WIDTH>2) }
                CLR_WHITE
            );
    lColor2 :ClTableArray=(
                CLR_WHITE,// CLR_PALEGRAY, { if (SPLITBAR_WIDTH>2) }
                CLR_BLACK
            );

(*****************************************************************************
** Internal prototypes
*)
FUNCTION  CellProc(Window: HWnd; Msg: ULong; Mp1,Mp2: MParam): MResult;
                                                                cdecl; forward;
FUNCTION  CellClientProc(Window: HWnd; Msg: ULong; Mp1,Mp2: MParam): MResult;
                                                                cdecl; forward;
FUNCTION  TbProc(Window: HWnd; Msg: ULong; Mp1,Mp2: MParam): MResult;
                                                                cdecl; forward;
FUNCTION  TbClientProc(Window: HWnd; Msg: ULong; Mp1,Mp2: MParam): MResult;
                                                                cdecl; forward;
FUNCTION  TbSeparatorProc(Window: HWnd; Msg: ULong; Mp1,Mp2: MParam): MResult;
                                                                cdecl; forward;
FUNCTION  BtProc(Window: HWnd; Msg: ULong; Mp1,Mp2: MParam): MResult;
                                                                cdecl; forward;

FUNCTION  CreateTb(pTb:TbDef; hWndParent, hWndOwner:HWND):HWND; forward;
PROCEDURE RecalcTbDimensions(Window:HWND; pSize:PPOINTL); forward;
FUNCTION  TrackRectangle(hwndBase:HWND;
                         VAR rclTrack:RECTL;
                         rclBounds:PRECTL):LONG; forward;

(*****************************************************************************
** Internal data types
*)

    (* Cell data, used by subclass proc of splitted window. *)

TYPE
    PCellTb = ^CellTb;
    CellTb  = RECORD
        Window:HWND;
        pNext :PCellTb;
    END;

    PCellCtlData = ^CellCtlData;
    CellCtlData  = RECORD
        pOldProc:FNWP;
        rclBnd  :RECTL;
        lType   :LONGINT;
        lSplit  :LONGINT;
        lSize   :LONGINT;
        hwndSplitbar :HWND;
        hwndPanel1   :HWND;
        hwndPanel2   :HWND;
        CellTbD      :PCellTb;
    END;

    TbCtlData  = RECORD
        pOldProc  :FNWP;
        hwndParent:HWND;
        lState    :LONGINT;
        lCount    :LONGINT;

        bBubble   :longbool;
        hwndBubble:HWND;
        BubbleClient:hWnd;
        hwndEntry:hwnd;
        hItems    :ARRAY [0..0] OF HWND;
    END;
    PTbCtlData = ^TbCtlData;


(* Function: ToolkitInit
** Abstract: Registers classes needed for toolkit
*)

PROCEDURE ToolkitInit(appAnchor:HAB);
BEGIN
  Anchor:=appAnchor;
  WinRegisterClass(Anchor,
                   CELL_CLIENT,
                   CellClientProc,
                   CS_SIZEREDRAW,
                   sizeof(ULONG));
  WinRegisterClass(Anchor,
                   TB_CLIENT,
                   TbClientProc,
                   CS_SIZEREDRAW,
                   sizeof(ULONG));
  WinRegisterClass(Anchor,
                   TB_SEPCLASS,
                   TbSeparatorProc,
                   CS_SIZEREDRAW,
                   sizeof(ULONG));
END;

(*
******************************************************************************
** Cell (Splitted view) implementation
******************************************************************************
*)

PROCEDURE ShowCell(Window:HWND; lID:LONGINT; Action:BOOLEAN);
VAR
    hwndMain:HWND;
    pCtlData:PCellCtlData;
    lCell   :LONGINT;
BEGIN
    hwndMain:=Window;
    pCtlData:=NIL;
    lCell   :=0;

    Window:=CellParentWindowFromID(Window,lID);
    IF Window=0 THEN EXIT;

    pCtlData:=PCellCtlData(WinQueryWindowULong(Window,QWL_USER));
    IF pCtlData=NIL THEN EXIT;

    IF WinQueryWindowUShort(pCtlData^.hwndPanel1,QWS_ID)=lID THEN
        lCell:=CELL_HIDE_1;
    IF WinQueryWindowUShort(pCtlData^.hwndPanel2,QWS_ID)=lID THEN
        lCell:=CELL_HIDE_2;

    CASE lCell OF
        CELL_HIDE_1:
            IF Action THEN
                pCtlData^.lType:=pCtlData^.lType AND NOT CELL_HIDE_1
            ELSE
                pCtlData^.lType:=pCtlData^.lType OR CELL_HIDE_1;
        CELL_HIDE_2:
            IF Action THEN
                pCtlData^.lType:=pCtlData^.lType AND NOT CELL_HIDE_2
            ELSE
                pCtlData^.lType:=pCtlData^.lType OR CELL_HIDE_2;
    END;

    IF lCell<>0 THEN WinSendMsg(Window,WM_UPDATEFRAME,0,0);
END;

FUNCTION GetSplit(Window:HWND; lID:LONGINT):LONGINT;
VAR
    pCtlData:PCellCtlData;
BEGIN
    pCtlData:=NIL;
    result:=0;

    Window:=CellWindowFromID(Window,lID);
    IF Window=0 THEN EXIT;

    pCtlData:=PCellCtlData(WinQueryWindowULong(Window,QWL_USER));
    IF pCtlData=NIL THEN EXIT;

    result:=pCtlData^.lSplit;
END;

FUNCTION SetSplit(Window:HWND; lID,lNewSplit:LONGINT):LONGINT;
VAR
    pCtlData:PCellCtlData;
BEGIN
    pCtlData:=NIL;
    result:=0;

    Window:=CellWindowFromID(Window,lID);
    IF Window=0 THEN EXIT;

    pCtlData:=PCellCtlData(WinQueryWindowULong(Window,QWL_USER));
    IF pCtlData=NIL THEN EXIT;

    IF pCtlData^.lType AND CELL_FIXED=0 THEN BEGIN
        pCtlData^.lSplit:=lNewSplit;
        IF pCtlData^.lSplit>CELL_TOP_LIMIT THEN
            pCtlData^.lSplit:=CELL_TOP_LIMIT;
        IF pCtlData^.lSplit<CELL_BOTTOM_LIMIT THEN
            pCtlData^.lSplit:=CELL_BOTTOM_LIMIT;

        WinSendMsg(Window,WM_UPDATEFRAME,0,0);
    END;
    result:=pCtlData^.lSplit;
END;

FUNCTION  GetSplitType(Window:HWND; lID:LONGINT):LONGINT;
VAR
    pCtlData:PCellCtlData;
BEGIN
    pCtlData:=NIL;
    result:=0;

    Window:=CellWindowFromID(Window,lID);
    IF Window=0 THEN EXIT;

    pCtlData:=PCellCtlData(WinQueryWindowULong(Window,QWL_USER));
    IF pCtlData=NIL THEN EXIT;

    result:=pCtlData^.lType AND (CELL_VSPLIT OR CELL_HSPLIT OR CELL_SWAP);
END;

PROCEDURE SetSplitType(Window:HWND; lID,lNewSplit:LONGINT);
VAR
    pCtlData:PCellCtlData;
    hwndTmp :HWND;
BEGIN
    pCtlData:=NIL;

    Window:=CellWindowFromID(Window,lID);
    IF Window=0 THEN EXIT;

    pCtlData:=PCellCtlData(WinQueryWindowULong(Window,QWL_USER));
    IF pCtlData=NIL THEN EXIT;

    pCtlData^.lType:=pCtlData^.lType AND NOT (CELL_VSPLIT OR CELL_HSPLIT);
    pCtlData^.lType:=pCtlData^.lType OR lNewSplit
                        AND (CELL_VSPLIT OR CELL_HSPLIT);

    IF lNewSplit AND CELL_SWAP<>0 THEN //Swap required?
    BEGIN
        IF pCtlData^.lType AND CELL_SWAP =0 THEN //NOT swapped yet
        BEGIN
            //Swap subwindows
            hwndTmp:=pCtlData^.hwndPanel1;
            pCtlData^.hwndPanel1:=pCtlData^.hwndPanel2;
            pCtlData^.hwndPanel2:=hwndTmp;
        END;
        pCtlData^.lType:=pCtlData^.lType OR CELL_SWAP;
    END ELSE
    BEGIN
        IF pCtlData^.lType AND CELL_SWAP<>0 THEN //Already swapped
        BEGIN
            // Restore original state
            hwndTmp:=pCtlData^.hwndPanel1;
            pCtlData^.hwndPanel1:=pCtlData^.hwndPanel2;
            pCtlData^.hwndPanel2:=hwndTmp;
        END;
        pCtlData^.lType:=pCtlData^.lType AND NOT CELL_SWAP;
    END;
END;

(* Function: CountControls
** Abstract: calculates number of additional controls in cell window
*)

FUNCTION CountControls(pCtlData:PCellCtlData):smallword;
VAR
    itemCount:smallword;
    CellTbD  :PCellTb;
    lFlags   :LONGINT;
BEGIN
    itemCount:=0;
    CellTbD  :=NIL;

    IF (pCtlData^.hwndPanel1<>0) AND (pCtlData^.lType AND CELL_HIDE_1=0) THEN
        inc(itemCount);
    IF (pCtlData^.hwndPanel2<>0) AND (pCtlData^.lType AND CELL_HIDE_2=0) THEN
        inc(itemCount);

    CellTbD:=pCtlData^.CellTbD;

    WHILE CellTbD<>NIL DO BEGIN
        lFlags:=WinSendMsg(CellTbD^.Window,TKM_QUERY_FLAGS,0,0);
        IF lFlags AND TB_ATTACHED<>0 THEN inc(itemCount);
        CellTbD:=CellTbD^.pNext;
    END;
    result:=itemCount;
END;

(* Function: CreateCell
** Abstract: Creates a subwindows tree for a given CellDef
** Note: If hWndOwner == NULLHANDLE, and first CellDef is frame,
**       all subwindows will have this frame window as Owner.
*)

FUNCTION CreateCell(VAR pCell:CellDef; hWndParent,hWndOwner:HWND):HWND;
VAR
    hwndFrame:HWND;
    pCtlData :PCellCtlData;
    pWCtlData:PWindowCellCtlData;
    WStyle:ULong;
    ResID:ULong;
BEGIN
    hwndFrame:=NULLHANDLE;
    pCtlData :=NIL;
    pWCtlData:=NIL;
    result   :=NULLHANDLE;

    CASE pCell.lType AND (CELL_VSPLIT OR CELL_HSPLIT OR CELL_WINDOW) OF
        CELL_WINDOW:BEGIN
            hwndFrame:=WinCreateWindow(hWndParent,
                                       pCell.pszClass,
                                       pCell.pszName,
                                       pCell.ulStyle,
                                       0,
                                       0,
                                       0,
                                       0,
                                       hWndOwner,
                                       HWND_TOP,
                                       pCell.ulID,
                                       NIL,
                                       NIL);

            IF (@@pCell.pClassProc<>NIL) AND (hwndFrame<>0) THEN BEGIN
                NEW(pWCtlData);
                IF pWCtlData=NIL THEN BEGIN
                    result:=hwndFrame;
                    EXIT
                END;

                fillchar(pWCtlData^,sizeof(WindowCellCtlData),#0);

                @@pWCtlData^.pOldProc:=WinSubclassWindow(hwndFrame,
                                                        pCell.pClassProc);
                WinSetWindowULong(hwndFrame,QWL_USER,ULONG(pWCtlData));
            END;
        END;
        CELL_HSPLIT, CELL_VSPLIT:BEGIN
            NEW(pCtlData);
            IF pCtlData=NIL THEN BEGIN
                result:=hwndFrame;
                EXIT
            END;

            fillchar(pCtlData^,sizeof(CellCtlData),#0);

            pCtlData^.lType:=pCell.lType AND (CELL_SPLIT_MASK OR CELL_HIDE);
            IF pCell.lType AND (CELL_SIZE1 OR CELL_SIZE2 OR CELL_FIXED)<>0 THEN
                pCtlData^.lSize:=pCell.lSize;
            pCtlData^.lSplit:=50;

            CASE pCell.lType AND CELL_SPLIT_REL OF
                CELL_SPLIT10x90: pCtlData^.lSplit:=10;
                CELL_SPLIT20x80: pCtlData^.lSplit:=20;
                CELL_SPLIT30x70: pCtlData^.lSplit:=30;
                CELL_SPLIT40x60: pCtlData^.lSplit:=40;
                CELL_SPLIT50x50: pCtlData^.lSplit:=50;
                CELL_SPLIT60x40: pCtlData^.lSplit:=60;
                CELL_SPLIT70x30: pCtlData^.lSplit:=70;
                CELL_SPLIT80x20: pCtlData^.lSplit:=80;
                CELL_SPLIT90x10: pCtlData^.lSplit:=90;
            END;

            WStyle:=WS_VISIBLE;
            IF (pCell.ulStyle AND FCF_MINMAX) <>0 THEN BEGIN
                WStyle:=WStyle OR WS_ANIMATE;
            END;

            hwndFrame:=WinCreateStdWindow(hWndParent,
                                          WStyle,
                                          pCell.ulStyle,
                                          CELL_CLIENT,
                                          pCell.pszName,
                                          0,
                                          0,
                                          pCell.ulID,
                                          @@pCtlData^.hwndSplitbar);

            WinSetOwner(hwndFrame,hWndOwner);

            IF @@pCell.pClassProc<>NIL THEN
                @@pCtlData^.pOldProc:=WinSubclassWindow(hwndFrame,
                                                       pCell.pClassProc)
            ELSE
                @@pCtlData^.pOldProc:=WinSubclassWindow(hwndFrame,CellProc);

            IF @@pCell.pClientClassProc<>NIL THEN BEGIN
                NEW(pWCtlData);
                IF pWCtlData=NIL THEN BEGIN
                    result:=hwndFrame;
                    EXIT
                END;

                fillchar(pWCtlData^,sizeof(WindowCellCtlData),#0);

                @@pWCtlData^.pOldProc:=WinSubclassWindow(pCtlData^.hwndSplitbar,
                                                       pCell.pClientClassProc);

                WinSetWindowULong(pCtlData^.hwndSplitbar,
                                  QWL_USER,ULONG(pWCtlData));
            END;

            IF hWndOwner=0 THEN
                hWndOwner:=hwndFrame
            ELSE
                WinSetOwner(pCtlData^.hwndSplitbar,hWndOwner);

            IF pCell.pPanel1<>NIL THEN
                pCtlData^.hwndPanel1:=CreateCell(pCell.pPanel1^,
                                                 hwndFrame,
                                                 hWndOwner);
            IF pCell.pPanel2<>NIL THEN
                pCtlData^.hwndPanel2:=CreateCell(pCell.pPanel2^,
                                                 hwndFrame,
                                                 hWndOwner);

            WinSetWindowULong(hwndFrame, QWL_USER, ULONG(pCtlData));
        END;(**cell split**)
    END;(**case**)
    result:=hwndFrame;
END;

(* Function: CellProc
** Abstract: Subclass procedure for frame window
*)

FUNCTION CellProc(Window: HWnd; Msg: ULong; Mp1,Mp2: MParam): MResult;
VAR pCtlData  :PCellCtlData;
    CellTbD   :PCellTb;
    itemCount :LONGINT;
    lFlags    :LONGINT;
    hwndBehind:HWND;
    hwndRC    :HWND;
    Swp,tSwp  :PSWP;
    cSwp      :PSWP;
    usClient  :smallword;
    itemCount2:smallword;
    hClient   :HWND;
    ptlSize   :POINTL;
    usPanel1,
    usPanel2  :PSWP;
    usWidth1,
    usWidth2  :smallword;
BEGIN
    pCtlData :=NIL;
    CellTbD  :=NIL;
    itemCount:=0;
    result   :=0;

    pCtlData:=PCellCtlData(WinQueryWindowULong(Window,QWL_USER));
    IF pCtlData=NIL THEN EXIT;

    CASE Msg OF
        WM_ADJUSTWINDOWPOS:BEGIN
            CellTbD:=pCtlData^.CellTbD;
            Swp    :=PSWP(mp1);

            IF (Swp^.fl AND SWP_ZORDER<>0) AND (CellTbD<>NIL) THEN BEGIN
                hwndBehind:=Swp^.hwndInsertBehind;
                WHILE CellTbD<>NIL DO BEGIN
                    lFlags:=WinSendMsg(CellTbD^.Window,TKM_QUERY_FLAGS,0,0);
                    IF lFlags AND TB_ATTACHED=0 THEN BEGIN
                        WinSetWindowPos(CellTbD^.Window,
                                        hwndBehind,
                                        0,
                                        0,
                                        0,
                                        0,
                                        SWP_ZORDER);
                        hwndBehind:=CellTbD^.Window;
                    END;
                    CellTbD:=CellTbD^.pNext;
                END;
                Swp^.hwndInsertBehind:=hwndBehind;
            END;
        END;(**WM_ADJUSTWINDOWPOS**)
        TKM_SEARCH_PARENT:BEGIN
            IF WinQueryWindowUShort(Window,QWS_ID)=mp1 THEN EXIT;

            IF WinQueryWindowUShort(pCtlData^.hwndPanel1,QWS_ID)=mp1 THEN BEGIN
                result:=MPARAM(Window);
                EXIT
            END;
            hwndRC:=HWND(WinSendMsg(pCtlData^.hwndPanel1,
                                    TKM_SEARCH_PARENT,
                                    mp1,
                                    0));
            IF hwndRC<>0 THEN BEGIN
                result:=MPARAM(hwndRC);
                EXIT
            END;

            IF WinQueryWindowUShort(pCtlData^.hwndPanel2,QWS_ID)=mp1 THEN BEGIN
                result:=MPARAM(Window);
                EXIT
            END;
            hwndRC:=HWND(WinSendMsg(pCtlData^.hwndPanel2,
                                    TKM_SEARCH_PARENT,
                                    mp1,
                                    0));
            IF hwndRC<>0 THEN BEGIN
                result:=MPARAM(hwndRC);
                EXIT
            END;

            EXIT;
        END;(**TKM_SEARCH_PARENT**)
        TKM_SEARCH_ID:BEGIN
            CellTbD:=pCtlData^.CellTbD;

            WHILE CellTbD<>NIL DO BEGIN
                IF WinQueryWindowUShort(CellTbD^.Window,QWS_ID)=mp1 THEN BEGIN
                    result:=MPARAM(CellTbD^.Window); EXIT
                END;

                hwndRC:=HWND(WinSendMsg(CellTbD^.Window,TKM_SEARCH_ID,mp1,0));
                IF hwndRC<>0 THEN BEGIN
                    result:=MPARAM(hwndRC);
                    EXIT
                END;

                CellTbD:=CellTbD^.pNext;
            END;

            IF WinQueryWindowUShort(Window,QWS_ID)=mp1 THEN BEGIN
                result:=MPARAM(Window);
                EXIT
            END;

            IF WinQueryWindowUShort(pCtlData^.hwndPanel1,QWS_ID)=mp1 THEN BEGIN
                result:=MPARAM(pCtlData^.hwndPanel1);
                EXIT ;
            END;
            hwndRC:=HWND(WinSendMsg(pCtlData^.hwndPanel1,TKM_SEARCH_ID,mp1,0));
            IF hwndRC<>0 THEN BEGIN
                result:=MPARAM(hwndRC);
                EXIT
            END;

            IF WinQueryWindowUShort(pCtlData^.hwndPanel2,QWS_ID)=mp1 THEN BEGIN
                result:=MPARAM(pCtlData^.hwndPanel2);
                EXIT ;
            END;
            hwndRC:=HWND(WinSendMsg(pCtlData^.hwndPanel2,TKM_SEARCH_ID,mp1,0));
            IF hwndRC<>0 THEN BEGIN
                result:=MPARAM(hwndRC);
                EXIT ;
            END;

            EXIT;
        END;(**TKM_SEARCH_ID**)
        WM_QUERYFRAMECTLCOUNT:BEGIN
            itemCount:=pCtlData^.pOldProc(Window,msg,mp1,mp2);
            inc(itemCount,CountControls(pCtlData));
            result:=itemCount;
            EXIT;
        END;(**WM_QUERYFRAMECTLCOUNT**)
        WM_FORMATFRAME:BEGIN
          Swp     :=NIL;
          usClient:=0;
          hClient :=HWND_TOP;

          itemCount :=pCtlData^.pOldProc(Window,msg,mp1,mp2);
          itemCount2:=CountControls(pCtlData);

          IF (itemCount2=0) OR (itemCount<1) THEN
          BEGIN
            result:=itemCount;
            EXIT;
          END;

          Swp :=PSWP(mp1);
          cSwp:=Swp;

          usClient:=itemCount-1;
          inc(cSwp,usClient);
          hClient :=cSwp^.wnd;

          (*
          ** Cutting client window.
          ** If there are any attached toolbars, cut client window
          ** regarding to attachment type
          *)

          (* Toolbars attached to top and bottom sides *)

          CellTbD:=pCtlData^.CellTbD;

          WHILE CellTbD<>NIL DO BEGIN
              lFlags:=WinSendMsg(CellTbD^.Window,TKM_QUERY_FLAGS,0,0);

              IF lFlags AND TB_ATTACHED=0 THEN BEGIN
                  CellTbD:=CellTbD^.pNext;
                  continue;
              END;

              RecalcTbDimensions(CellTbD^.Window,@@ptlSize);
              tSwp:=Swp;
              inc(tSwp,itemCount);

              CASE lFlags AND TB_ATTACHED OF
                  TB_ATTACHED_TP:BEGIN
                      tSwp^.x :=cSwp^.x;
                      tSwp^.y :=cSwp^.y+cSwp^.cy-ptlSize.y;
                      tSwp^.cx:=cSwp^.cx;
                      tSwp^.cy:=ptlSize.y;
                      tSwp^.fl:=SWP_SIZE OR SWP_MOVE OR SWP_SHOW;

                      tSwp^.wnd:=CellTbD^.Window;
                      tSwp^.hwndInsertBehind:=hClient;
                      hClient:=tSwp^.wnd;

                      dec(cSwp^.cy,ptlSize.y);
                      inc(itemCount);
                  END;
                  TB_ATTACHED_BT:BEGIN
                      tSwp^.x :=cSwp^.x;
                      tSwp^.y :=cSwp^.y;
                      tSwp^.cx:=cSwp^.cx;
                      tSwp^.cy:=ptlSize.y;
                      tSwp^.fl:=SWP_SIZE OR SWP_MOVE OR SWP_SHOW;

                      tSwp^.wnd:=CellTbD^.Window;
                      tSwp^.hwndInsertBehind:=hClient;
                      hClient:=tSwp^.wnd;

                      dec(cSwp^.cy,ptlSize.y);
                      inc(cSwp^.y ,ptlSize.y);
                      inc(itemCount);
                  END;
              END;(**calse lFlags**)
              CellTbD:=CellTbD^.pNext;
          END;(**while**)

          (*Toolbars attached to left and right sides*)

          CellTbD:=pCtlData^.CellTbD;

          WHILE CellTbD<>NIL DO BEGIN
              lFlags:=WinSendMsg(CellTbD^.Window,TKM_QUERY_FLAGS,0,0);

              IF lFlags AND TB_ATTACHED=0 THEN BEGIN
                  CellTbD:=CellTbD^.pNext;
                  continue;
              END;

              RecalcTbDimensions(CellTbD^.Window,@@ptlSize);
              tSwp:=Swp;
              inc(tSwp,itemCount);

              CASE lFlags AND TB_ATTACHED OF
                  TB_ATTACHED_LT:BEGIN
                      tSwp^.x :=cSwp^.x;
                      tSwp^.y :=cSwp^.y;
                      tSwp^.cx:=ptlSize.x;
                      tSwp^.cy:=cSwp^.cy;
                      tSwp^.fl:=SWP_SIZE OR SWP_MOVE OR SWP_SHOW;

                      tSwp^.wnd:=CellTbD^.Window;
                      tSwp^.hwndInsertBehind:=hClient;
                      hClient:=tSwp^.wnd;

                      dec(cSwp^.cx,ptlSize.x);
                      inc(cSwp^.x ,ptlSize.x);
                      inc(itemCount);
                  END;
                  TB_ATTACHED_RT:BEGIN
                      tSwp^.x :=cSwp^.x+cSwp^.cx-ptlSize.x;
                      tSwp^.y :=cSwp^.y;
                      tSwp^.cx:=ptlSize.x;
                      tSwp^.cy:=cSwp^.cy;
                      tSwp^.fl:=SWP_SIZE OR SWP_MOVE OR SWP_SHOW;

                      tSwp^.wnd:=CellTbD^.Window;
                      tSwp^.hwndInsertBehind:=hClient;
                      hClient:=tSwp^.wnd;

                      dec(cSwp^.cx,ptlSize.x);
                      inc(itemCount);
                  END;
              END;(**case lFlags**)
              CellTbD:=CellTbD^.pNext;
          END;

          (*
          ** Placing panels.
          ** Remember client rect for future use
          ** They will save time when we start moving splitbar
          *)

          pCtlData^.rclBnd.xLeft   := cSwp^.x;
          pCtlData^.rclBnd.xRight  := cSwp^.x+cSwp^.cx;
          pCtlData^.rclBnd.yTop    := cSwp^.y+cSwp^.cy;
          pCtlData^.rclBnd.yBottom := cSwp^.y;

          IF (pCtlData^.hwndPanel1=0) OR (pCtlData^.hwndPanel2=0) OR
            (pCtlData^.lType AND CELL_HIDE<>0) THEN
          BEGIN
              (*
              **single subwindow;
              **In this case we don't need a client window,
              **because of lack of splitbar.
              **Just copy all data from pSWP[usClient]
              **and replace some part of it
              *)

              tSwp:=Swp;
              inc(tSwp,itemCount);
              tSwp^:=cSwp^;
              tSwp^.fl:=tSwp^.fl OR SWP_MOVE OR SWP_SIZE;
              tSwp^.hwndInsertBehind:=HWND_TOP;
              cSwp^.cy:=0;

              tSwp^.wnd:=0;

              IF (pCtlData^.hwndPanel1<>0) AND (pCtlData^.lType AND CELL_HIDE_1=0) THEN
                tSwp^.wnd:=pCtlData^.hwndPanel1;
              IF (pCtlData^.hwndPanel2<>0) AND (pCtlData^.lType AND CELL_HIDE_2=0) THEN
                tSwp^.wnd:=pCtlData^.hwndPanel2;

              (* Increase number of controls *)

              IF tSwp^.wnd<>0 THEN BEGIN
                  tSwp^.hwndInsertBehind:=hClient;
                  hClient:=tSwp^.wnd;
                  inc(itemCount);
              END;
          END
          ELSE BEGIN
              usPanel1:=Swp; inc(usPanel1,itemCount);
              usPanel2:=Swp; inc(usPanel2,itemCount+1);
              usWidth1:=0;
              usWidth2:=0;

              (* Just like case of one panel *)
              usPanel1^:=cSwp^;
              usPanel2^:=cSwp^;

              usPanel1^.fl:=usPanel1^.fl OR SWP_MOVE OR SWP_SIZE;
              usPanel2^.fl:=usPanel2^.fl OR SWP_MOVE OR SWP_SIZE;

              usPanel1^.hwndInsertBehind:=hClient;
              usPanel2^.hwndInsertBehind:=pCtlData^.hwndPanel1;

              usPanel1^.wnd:=pCtlData^.hwndPanel1;
              usPanel2^.wnd:=pCtlData^.hwndPanel2;

              hClient:=pCtlData^.hwndPanel2;

              IF pCtlData^.lType AND CELL_VSPLIT<>0 THEN BEGIN
                  IF (pCtlData^.lType AND CELL_FIXED<>0) AND
                    (pCtlData^.lType AND (CELL_SIZE1 OR CELL_SIZE2)<>0) AND
                      (pCtlData^.lSize>0) THEN
                  BEGIN
                      (* Case of fixed panel with exact size *)

                      IF pCtlData^.lType AND CELL_SIZE1<>0 THEN BEGIN
                          usWidth1:=pCtlData^.lSize;
                          usWidth2:=cSwp^.cx-usWidth1;
                      END
                      ELSE BEGIN
                          usWidth2:=pCtlData^.lSize;
                          usWidth1:=cSwp^.cx-usWidth2;
                      END;
                  END
                  ELSE BEGIN
                      usWidth1:=(cSwp^.cx*pCtlData^.lSplit) div 100;
                      usWidth2:=cSwp^.cx-usWidth1;
                  END;

                  IF pCtlData^.lType AND CELL_SPLITBAR<>0 THEN BEGIN
                      IF pCtlData^.lType AND CELL_SIZE1=0 THEN
                          dec(usWidth2,SPLITBAR_WIDTH)
                      ELSE
                          dec(usWidth1,SPLITBAR_WIDTH);

                      cSwp^.cx:=SPLITBAR_WIDTH;
                      cSwp^.x :=cSwp^.x + usWidth1;
                  END
                  ELSE BEGIN
                      cSwp^.cx:=0;
                      cSwp^.cy:=0;
                  END;
                  usPanel1^.cx:=usWidth1;
                  inc(usPanel2^.x,usWidth1+cSwp^.cx);
                  usPanel2^.cx:=usWidth2;
              END
              ELSE BEGIN
                  IF (pCtlData^.lType AND CELL_FIXED<>0) AND
                    (pCtlData^.lType AND (CELL_SIZE1 OR CELL_SIZE2)<>0) AND
                      (pCtlData^.lSize>0) THEN
                  BEGIN
                      (* Case of fixed panel with exact size *)

                      IF pCtlData^.lType AND CELL_SIZE1<>0 THEN BEGIN
                          usWidth1:=pCtlData^.lSize;
                          usWidth2:=cSwp^.cy-usWidth1;
                      END
                      ELSE BEGIN
                          usWidth2:=pCtlData^.lSize;
                          usWidth1:=cSwp^.cy-usWidth2;
                      END;
                  END
                  ELSE BEGIN
                      usWidth1:=(cSwp^.cy*pCtlData^.lSplit) div 100;
                      usWidth2:=cSwp^.cy-usWidth1;
                  END;

                  IF pCtlData^.lType AND CELL_SPLITBAR<>0 THEN BEGIN
                      IF pCtlData^.lType AND CELL_SIZE1=0 THEN
                          dec(usWidth2,SPLITBAR_WIDTH)
                      ELSE
                          dec(usWidth1,SPLITBAR_WIDTH);

                      cSwp^.cy:=SPLITBAR_WIDTH;
                      cSwp^.y :=cSwp^.y + usWidth1;
                  END
                  ELSE BEGIN
                      cSwp^.cx:=0;
                      cSwp^.cy:=0;
                  END;
                  usPanel1^.cy:=usWidth1;
                  inc(usPanel2^.y,usWidth1+cSwp^.cy);
                  usPanel2^.cy:=usWidth2;
              END;
              inc(itemCount,2);
          END;
          result:=itemCount;
          EXIT
        END;(**WM_FORMATFRAME**)
    END;(**case**)
    result:=pCtlData^.pOldProc(Window,msg,mp1,mp2);
END;

(* Function: CellClientProc
** Abstract: Window procedure for Cell Client Window Class (splitbar)
*)

FUNCTION CellClientProc(Window: HWnd; Msg: ULong; Mp1,Mp2: MParam): MResult;
VAR hwndFrame:HWND;
    pCtlData :PCellCtlData;
    hpsPaint :HPS;
    rclPaint :RECTL;
    ptlStart :ARRAY [0..SPLITBAR_WIDTH-1] OF POINTL;
    ptlEnd   :ARRAY [0..SPLITBAR_WIDTH-1] OF POINTL;
    pClTable :PClTableArray;
    ii       :LONGINT;
    rclFrame :RECTL;
    rclBounds:RECTL;
    usNewRB,
    usSize   :smallword;
    lType    :LONGINT;
    hwndTemp :HWND;
BEGIN
  pCtlData:=NIL;
  result  :=0;

  hwndFrame:=WinQueryWindow(Window,QW_PARENT);

  IF hwndFrame<>0 THEN
    pCtlData:=PCellCtlData(WinQueryWindowULong(hwndFrame,QWL_USER));
  IF (hwndFrame=0) OR (pCtlData=NIL) THEN
  BEGIN
    result:=WinDefWindowProc(Window,msg,mp1,mp2);
    EXIT
  END;

  CASE msg OF
    WM_ACTIVATE,WM_SETFOCUS:EXIT;
    WM_PAINT:BEGIN
        hpsPaint:=WinBeginPaint(Window,0,NIL);
        WinQueryWindowRect(Window,rclPaint);

        IF pCtlData^.lType AND CELL_VSPLIT<>0 THEN BEGIN
          FOR ii:=0 TO SPLITBAR_WIDTH-1 DO
          BEGIN
            ptlStart[ii].x:=rclPaint.xLeft + ii;
            ptlStart[ii].y:=rclPaint.yTop;

            ptlEnd[ii].x:=rclPaint.xLeft + ii;
            ptlEnd[ii].y:=rclPaint.yBottom;
          END;
          IF pCtlData^.lType AND CELL_FIXED<>0 THEN
            pClTable:=@@lColor ELSE pClTable:=@@lColor2;
        END ELSE
        BEGIN
          FOR ii:=0 TO SPLITBAR_WIDTH-1 DO BEGIN
            ptlStart[ii].x:=rclPaint.xLeft;
            ptlStart[ii].y:=rclPaint.yBottom+ii;

            ptlEnd[ii].x:=rclPaint.xRight;
            ptlEnd[ii].y:=rclPaint.yBottom+ii;
          END;
          IF pCtlData^.lType AND CELL_FIXED<>0 THEN
            pClTable:=@@lColor2 ELSE pClTable:=@@lColor;
        END;
        FOR ii:=0 TO SPLITBAR_WIDTH-1 DO BEGIN
          GpiSetColor(hpsPaint,pClTable^[ii]);
          GpiMove(hpsPaint,ptlStart[ii]);
          GpiLine(hpsPaint,ptlEnd[ii]);
        END;
        WinEndPaint(hpsPaint);
        EXIT
      END;
    WM_MOUSEMOVE:IF pCtlData^.lType AND CELL_FIXED=0 THEN
      BEGIN
        IF pCtlData^.lType AND CELL_VSPLIT<>0 THEN
          WinSetPointer(HWND_DESKTOP,WinQuerySysPointer(HWND_DESKTOP,SPTR_SIZEWE,FALSE))
        ELSE
          WinSetPointer(HWND_DESKTOP,WinQuerySysPointer(HWND_DESKTOP,SPTR_SIZENS,FALSE));
        EXIT
      END;
    WM_BUTTON1DOWN:
      IF pCtlData^.lType AND CELL_FIXED=0 THEN
      BEGIN
        WinQueryWindowRect(Window,rclFrame);

        rclBounds:=pCtlData^.rclBnd;
        WinMapWindowPoints(hwndFrame,HWND_DESKTOP,PPOINTL(@@rclBounds)^,2);

        IF TrackRectangle(Window,rclFrame,@@rclBounds)=1 THEN
        BEGIN
          IF pCtlData^.lType AND CELL_VSPLIT<>0 THEN
          BEGIN
            usNewRB:=rclFrame.xLeft-rclBounds.xLeft;
            usSize :=rclBounds.xRight-rclBounds.xLeft;
          END ELSE
          BEGIN
            usNewRB:=rclFrame.yBottom-rclBounds.yBottom;
            usSize :=rclBounds.yTop-rclBounds.yBottom;
          END;
            pCtlData^.lSplit:=(usNewRB*100) div usSize;
            IF pCtlData^.lSplit>CELL_TOP_LIMIT THEN pCtlData^.lSplit:=CELL_TOP_LIMIT;
            IF pCtlData^.lSplit<CELL_BOTTOM_LIMIT THEN pCtlData^.lSplit:=CELL_BOTTOM_LIMIT;
            WinSendMsg(hwndFrame,WM_UPDATEFRAME,0,0);
        END;
        EXIT;
      END;
    WM_BUTTON2DOWN:IF pCtlData^.lType AND CELL_FIXED=0 THEN
      BEGIN
        lType:=pCtlData^.lType AND (CELL_VSPLIT OR CELL_HSPLIT);

        pCtlData^.lType:=pCtlData^.lType AND NOT (CELL_VSPLIT OR CELL_HSPLIT);
        IF lType AND CELL_VSPLIT<>0 THEN
          pCtlData^.lType:=pCtlData^.lType OR CELL_HSPLIT
        ELSE
          pCtlData^.lType:=pCtlData^.lType OR CELL_VSPLIT;

        (* Swap subwindows *)

        IF lType AND CELL_VSPLIT<>0 THEN
        BEGIN
          hwndTemp:=pCtlData^.hwndPanel1;
          pCtlData^.hwndPanel1:=pCtlData^.hwndPanel2;
          pCtlData^.hwndPanel2:=hwndTemp;
          pCtlData^.lType:=pCtlData^.lType xor CELL_SWAP;
        END;

        IF pCtlData^.lType AND CELL_HIDE_1<>0 THEN
        BEGIN
          pCtlData^.lType:=pCtlData^.lType AND NOT CELL_HIDE_1;
          pCtlData^.lType:=pCtlData^.lType OR CELL_HIDE_2;
        END ELSE
        IF pCtlData^.lType AND CELL_HIDE_2<>0 THEN
        BEGIN
          pCtlData^.lType:=pCtlData^.lType AND NOT CELL_HIDE_2;
          pCtlData^.lType:=pCtlData^.lType OR CELL_HIDE_1;
        END;

        IF pCtlData^.lType AND CELL_SIZE1<>0 THEN
        BEGIN
          pCtlData^.lType:=pCtlData^.lType AND NOT CELL_SIZE1;
          pCtlData^.lType:=pCtlData^.lType OR CELL_SIZE2;
        END ELSE
        IF pCtlData^.lType AND CELL_SIZE2<>0 THEN
        BEGIN
          pCtlData^.lType:=pCtlData^.lType AND NOT CELL_SIZE2;
          pCtlData^.lType:=pCtlData^.lType OR CELL_SIZE1;
        END;

        WinSendMsg(hwndFrame,WM_UPDATEFRAME,0,0);
        EXIT
      END;
  END;
  result:=WinDefWindowProc(Window,msg,mp1,mp2);
END;

(*****************************************************************************
** Toolbar implementation
*)

(* Function: CreateTb
** Abstract: Creates Toolbar for a gived TbDef
*)

PROCEDURE SetToolBarState(Window:HWND; lState:ULong);
VAR
    TbCtlD:PTbCtlData;
    hwndFrame:hwnd;
BEGIN
    TbCtlD   :=PTbCtlData(WinQueryWindowULong(Window,QWL_USER));
    TbCtlD^.lState:=lState;
    hwndFrame:=WinQueryWindow(Window,QW_PARENT);
    WinSendMsg(hwndFrame,WM_UPDATEFRAME,0,0);
END;

VAR
    PrevPoint:PointL;

FUNCTION NuTBClass.CreateButton(tb:TBItemData;hwndTb,hwndOwner:hwnd):hwnd;
VAR
    cButtText :string;
    window:hwnd;
BEGIN
    cButtText:='#'+IntToStr(tb.NuID)+#0;
    window:=WinCreateWindow(hwndTb,
                            WC_STATIC,
                            @@cButtText[1],
                            SS_BITMAP,
                            -1,
                            -1,
                            -1,
                            -1,
                            hWndOwner,
                            HWND_TOP,
                            tb.NuID,
                            NIL,
                            NIL);
    result:=Window;
    NuWnd:=Window;
    isStartTimer:=FALSE;
    isCapture:=FALSE;
    isHilight:=FALSE;
    NuID:=TB.NuID;
    cText:=TB.cText;
    @@pOldProc:=WinSubclassWindow(window,BtProc);
END;


FUNCTION CreateTb(pTb:TbDef; hWndParent, hWndOwner:HWND):HWND;
CONST
    ppFont:pChar='12.Helv';
VAR swp        :os2pmapi.swp;
    hwndClient :HWND;
    hwndTb     :HWND;
    lCount     :LONGINT;
    ptlSize,
    ptlFSize   :POINTL;
    flCreate   :LONGINT;
    TbCtlD     :PTbCtlData;
    TbItemD    :PTbItemData;
    tbItem     :pTBItemData;
    TbCtlLen,
    TbItemLen  :LONGINT;
    cButtText :ARRAY[BYTE] OF CHAR;
    uStyle:ULong;
    TBClass:NuTBClass;
    temp:ARRAY[1..32] OF CHAR;
    rc:ulong;
BEGIN
    hwndTb:=NULLHANDLE;
    result:=NULLHANDLE;

    lCount:=0;
    tbItem:=pTb.tbItems;
    WHILE tbItem^.NuID<>0 DO BEGIN
        tbItem^.cText:=tbItem^.cText+#0;
        IF TbItem^.cText[1]=#0 THEN BEGIN
            rc:=WinLoadString(Anchor,
                              0,
                              tbItem^.NuID,
                              cTextSize,
                              @@(temp[1] ) );
            IF rc=0 THEN
                TbItem^.cText:=#0
            ELSE
                TbItem^.cText:=StrPas(@@temp[1]);
        END;
        inc(lCount);
        inc(tbItem);
    END;

    TbCtlLen:=sizeof(TbCtlData)+sizeof(HWND)*lCount;
    getmem(TbCtlD,TbCtlLen);

    IF TbCtlD=NIL THEN EXIT;

    TbItemLen:=sizeof(TbItemData)*lCount;
    getmem(TbItemD,TbItemLen);

    IF TbItemD=NIL THEN BEGIN
        freemem(TbCtlD,TbCtlLen);
        EXIT;
    END;

    fillchar(TbCtlD^ ,TbCtlLen ,#0);
    fillchar(TbItemD^,TbItemLen,#0);

    TbCtlD^.lCount :=lCount;
    TbCtlD^.bBubble:=pTb.lType AND TB_BUBBLE<>0;
    TbCtlD^.hwndEntry:=NullHandle;


    pTb.lType:=pTb.lType AND TB_ALLOWED;

    (*
    **Some checks:
    ** if toolbar attached, they should be properly
    ** oriented. I.e. toolbar attached to top or
    ** bottom, can't be vertical.
    *)

    IF pTb.lType AND (TB_ATTACHED_TP OR TB_ATTACHED_BT)<>0 THEN
        pTb.lType:=pTb.lType AND NOT TB_VERTICAL;

    TbCtlD^.lState:=pTb.lType;
    TbCtlD^.hwndParent:=hWndParent;

    IF pTb.lType AND TB_ATTACHED=0 THEN hWndParent:=HWND_DESKTOP;

    IF pTb.lType AND TB_ATTACHED<>0 THEN
        flCreate:=FCF_BORDER OR FCF_NOBYTEALIGN
    ELSE
        flCreate:=FCF_DLGBORDER OR FCF_NOBYTEALIGN;

    uStyle:=WS_CLIPCHILDREN OR WS_CLIPSIBLINGS OR WS_PARENTCLIP;
    hwndTb:=WinCreateStdWindow(hWndParent,
                               uStyle,
                               flCreate,
                               TB_CLIENT,
                               '',
                               0,
                               0,
                               pTb.ulID,
                               @@hwndClient);

    IF hwndTb=0 THEN BEGIN
        freemem(TbItemD,TbItemLen);
        freemem(TbCtlD,TbCtlLen);
        EXIT;
    END;

    IF TbCtlD^.lState AND TB_VERTICAL<>0 THEN BEGIN
        ptlSize.x:=0;
        ptlSize.y:=HAND_SIZE
    END
    ELSE BEGIN
        ptlSize.x:=HAND_SIZE;
        ptlSize.y:=0
    END;

    FOR lCount:=0 TO TbCtlD^.lCount-1 DO BEGIN
        tbItem:=pTb.tbItems;
        inc(tbItem,lCount);
        IF tbItem^.NuID=TB_SEPARATOR THEN BEGIN
            TbCtlD^.hItems[lCount]:=WinCreateWindow(hwndTb,
                                                    TB_SEPCLASS,
                                                    '',
                                                    0,
                                                    0,
                                                    0,
                                                    TBSepSize,
                                                    TBSepLong,
                                                    hwndTb,
                                                    HWND_TOP,
                                                    tbItem^.NuID,
                                                    NIL,
                                                    NIL);
        END
        ELSE BEGIN
            TBClass:=NuTBClass.Create;

            TbCtlD^.hItems[lCount]:=TBClass.CreateButton(tbItem^,
                                                         hwndTB,
                                                         hWndOwner);
            WinSetWindowULong(TbCtlD^.hItems[lCount],QWL_USER,ULONG(TBClass));
            NuTBList.TBList.Add(TBClass);
        END;

        WinQueryWindowPos(TbCtlD^.hItems[lCount],swp);

        IF TbCtlD^.lState AND TB_VERTICAL<> 0 THEN BEGIN
            IF swp.cx>ptlSize.x THEN ptlSize.x:=swp.cx;
            inc(ptlSize.y,swp.cy);
            IF TbCtlD^.hItems[lCount]<TB_SEPARATOR THEN BEGIN
                TBSepSize:=TB_SEP_SIZE;
                TBSepLong:=swp.cx;
            END;
        END
        ELSE BEGIN
            IF swp.cy>ptlSize.y THEN ptlSize.y:=swp.cy;
            inc(ptlSize.x,swp.cx);
            IF TbCtlD^.hItems[lCount]<TB_SEPARATOR THEN BEGIN
                TBSepLong:=swp.cy;
                TBSepSize:=TB_SEP_SIZE;
            END;
        END;
    END;

    (*
    ** Now we have calculated client window size for toolbar
    ** Recalculate its proper size
    *)

    WinSendMsg(hwndTb,WM_QUERYBORDERSIZE,MPFROMP(@@ptlFSize),0);
    inc(ptlSize.x,ptlFSize.x*2);
    inc(ptlSize.y,ptlFSize.y*2);

    @@TbCtlD^.pOldProc:=WinSubclassWindow(hwndTb,TbProc);
    TbCtlD^.BubbleClient:=NULLHANDLE;

    PrevPoint.x:=0;PrevPoint.y:=0;
    WinSetWindowULong(hwndTb,QWL_USER,ULONG(TbCtlD));

    WinQueryWindowPos(hWndOwner,swp);

    WinSetWindowPos(hwndTb,
                    0,
                    swp.x+HAND_SIZE div 2,
                    swp.y+HAND_SIZE div 2,
                    ptlSize.x,
                    ptlSize.y,
                    SWP_MOVE OR SWP_SIZE OR SWP_SHOW);
    result:=hwndTb
END;

(* Function: BtProc
** Abstract: Subclass procedure for buttons
*)

PROCEDURE NuTBClass.DrawFrame(isPop:BOOLEAN;rect:RectL;ps:HPS);
VAR
    UpperFrameColor,DownFrameColor:ULong;
    wRect:RectL;
BEGIN
    IF isPop THEN BEGIN
        UpperFrameColor:=CLR_WHITE;
        DownFrameColor:=CLR_DARKGRAY;
    END
    ELSE BEGIN
        DownFrameColor:=CLR_WHITE;
        UpperFrameColor:=CLR_DARKGRAY;
    END;
    wRect:=Rect;
    rect.xRight:=rect.xLeft+ButtonDepth;
    WinFillRect(ps,rect,UpperFrameColor);

    Rect:=wRect;
    rect.yBottom:=rect.yTop-ButtonDepth;
    WinFillRect(ps,rect,UpperFrameColor);

    Rect:=wRect;
    rect.xLeft:=rect.xRight-ButtonDepth;
    WinFillRect(ps,rect,DownFrameColor);

    Rect:=wRect;
    rect.yTop:=rect.yBottom+ButtonDepth;
    WinFillRect(ps,rect,DownFrameColor);
END;

FUNCTION NuTBClass.GetUpBitmap(window:hwnd):HBitmap;

BEGIN
    result:=WinSendMsg(window,SM_QUERYHANDLE,0,0);
END;

FUNCTION NuTBClass.ButtonHandler(window:hwnd;Msg:ULong;Mp1,Mp2:MParam):MResult;
VAR
    hwndOwner  :HWND;
    hpsTemp    :HPS;
    rclButton:RECTL;
    TbCtlD:PTbCtlData;
    hwndFrame:hwnd;
    ulStyle    :ULong;
    hwndBubbleClient:HWND;
    ptlWork    :POINTL;
    ulColor    :LONGINT;
    txtPointl  :ARRAY [0..TXTBOX_COUNT-1] OF POINTL;
    lHight,
    lWidth     :LONGINT;
    UpBitmap:HBITMAP;


    FUNCTION isRectIn:BOOLEAN;
    VAR
        mCx,mCy:INTEGER;
    BEGIN
        mCx:=SHORT1FROMMP(mp1);
        mCy:=SHORT2FROMMP(mp1);
        IF (RclButton.yBottom<mCy) AND (rclButton.yTop>mCy) AND
           (rclButton.xLeft<mCx) AND (rclButton.xRight>mCx)
        THEN
            isRectIn:=TRUE
        ELSE
            isRectIn:=FALSE;
    END;
BEGIN
    result:=0;
    CASE msg OF
        WM_MOUSEMOVE:BEGIN
            hwndFrame:=WinQueryWindow(Window,QW_PARENT);
            TbCtlD   :=PTbCtlData(WinQueryWindowULong(hwndFrame,QWL_USER));
            WinQueryWindowRect(Window,rclButton);
            IF isRectIn THEN BEGIN
                IF isCapture = FALSE THEN BEGIN
                    WinSetCapture(HWND_DESKTOP,Window);
                    isCapture :=TRUE;
                END;
                IF isHilight=FALSE THEN BEGIN
                    isHilight:=TRUE;
                    HPSTemp:=WinGetPS(Window);
                    DrawFrame(true,rclButton,HPSTemp);
                    WinReleasePS(HPSTemp);
                END;
                IF (TbCtlD^.hwndBubble=0 ) AND
                   (isStartTimer=FALSE) AND
                   (TbCtlD^.BubbleClient<>Window) THEN
                BEGIN
                    WinStartTimer(Anchor,Window,NuCellTimerID+NuID,700);
                    isStartTimer:=TRUE;
                END;
            END
            ELSE BEGIN
                IF isStartTimer THEN
                    WinStopTimer(Anchor,Window,NuCellTimerID+NuID);
                isStartTimer:=FALSE;
                IF TbCtlD^.hwndBubble<>0 THEN BEGIN
                    WinDestroyWindow(TbCtlD^.hwndBubble);
                    TbCtlD^.hwndBubble:=0;
                    TbCtlD^.BubbleClient:=Window;
                    HPSTemp:=WinGetPS(Window);
                    DrawFrame(true,rclButton,HPSTemp);
                    WinReleasePS(HPSTemp);
                END;
                IF isCapture THEN BEGIN
                    WinSetCapture(HWND_DESKTOP,NULLHANDLE);
                    isCapture :=FALSE;
                END;
                IF isHilight THEN BEGIN
                    TbCtlD^.BubbleClient:=NULLHANDLE;
                    isHilight:=FALSE;
                    WinSendMsg(Window,
                               SM_SETHANDLE,
                               WinSendMsg(window,SM_QUERYHANDLE,0,0),
                               0);
                END;
            END;
        END;(**WM_MOUSEMOVE**)
        WM_TIMER:BEGIN
            hwndFrame:=WinQueryWindow(Window,QW_PARENT);
            TbCtlD   :=PTbCtlData(WinQueryWindowULong(hwndFrame,QWL_USER));
            IF isStartTimer THEN
                WinStopTimer(Anchor,Window,NuCellTimerID+NuID);
            isStartTimer:=FALSE;

            WinQueryWindowRect(Window,rclButton);
            ulStyle:=FCF_BORDER OR FCF_NOBYTEALIGN;
            hpsTemp:=0;
            ptlWork.x:=0;
            ptlWork.y:=0;
            ulColor:=CLR_PALEGRAY;
            WinQueryPointerPos(HWND_DESKTOP,PrevPoint);

            TbCtlD^.hwndBubble:=WinCreateStdWindow( HWND_DESKTOP,
                                                    0,
                                                    ulStyle,
                                                    WC_STATIC,
                                                    '',
                                                    SS_TEXT OR
                                                    DT_LEFT OR
                                                    DT_VCENTER,
                                                    NULLHANDLE,
                                                    TB_BUBBLEID,
                                                    @@hwndBubbleClient);

            WinSetPresParam(hwndBubbleClient,
                            PP_FONTNAMESIZE,
                            strlen(ppFont)+1,
                            ppFont);
            WinSetPresParam(hwndBubbleClient,
                            PP_BACKGROUNDCOLORINDEX,
                            sizeof(
                            ulColor),@@ulColor);

            WinSetWindowText(hwndBubbleClient, @@(cText[1]));

            WinMapWindowPoints(Window, HWND_DESKTOP, ptlWork, 1);

            hpsTemp:=WinGetPS(hwndBubbleClient);
            GpiQueryTextBox(hpsTemp,
                            Length(cText)-1,
                            @@cText[1],
                            TXTBOX_COUNT,PPOINTL(@@txtPointl[0])^);

            WinReleasePS(hpsTemp);

            lWidth:=txtPointl[TXTBOX_TOPRIGHT].x-
                    txtPointl[TXTBOX_TOPLEFT].x+
                    WinQuerySysValue(HWND_DESKTOP,SV_CYDLGFRAME)*2;

            lHight:=txtPointl[TXTBOX_TOPLEFT].y-
                    txtPointl[TXTBOX_BOTTOMLEFT].y+
                    WinQuerySysValue(HWND_DESKTOP,SV_CXDLGFRAME)*2;

            Dec(ptlWork.y,lHight);
            IF TbCtlD^.lState AND TB_VERTICAL <>0 THEN
                inc(ptlWork.x,(rclButton.xRight-rclButton.xLeft) );

            WinSetWindowPos(TbCtlD^.hwndBubble,
                            HWND_TOP,
                            ptlWork.x,
                            ptlWork.y,
                            lWidth,
                            lHight,
                            SWP_SIZE OR SWP_MOVE OR SWP_SHOW);

        END;
        WM_BUTTON1DOWN:BEGIN
            HPSTemp:=WinGetPS(Window);
            WinQueryWindowRect(Window,rclButton);
            DrawFrame(FALSE,rclButton,HPSTemp);
            WinReleasePS(HPSTemp);
        END;
        WM_BUTTON1UP:BEGIN
            UpBitmap:=GetUpBitmap(window);
            hwndOwner:=WinQueryWindow(Window,QW_OWNER);
            WinSendMsg(Window,SM_SETHANDLE,UpBitmap,0);
            WinPostMsg(hwndOwner,
                       WM_COMMAND,
                       NuID,
                       MPFROM2SHORT(NuID,CMDSRC_OTHER));
        END;
        ELSE
            result:=pOldProc(Window, msg, mp1, mp2);
    END;

END;

FUNCTION BtProc(Window: HWnd; Msg: ULong; Mp1,Mp2: MParam): MResult;
VAR
    TbItemD    :NuTBClass;

BEGIN
    TbItemD  :=NuTBClass(WinQueryWindowULong(Window,QWL_USER));
    result:=TBItemD.ButtonHandler(Window,msg,mp1,mp2);
END;

PROCEDURE SetSepSize(SepWnd:hwnd;cx,cy:INTEGER);
VAR
    swp:os2pmapi.swp;
BEGIN
     WinQueryWindowPos(SepWnd, swp);
     IF GetID(SepWnd)=TB_SEPARATOR THEN BEGIN
         WinSetWindowPos(SepWnd,
                         SWP.hwndInsertBehind ,
                         0,
                         0,
                         cx,
                         cy,
                         SWP_SIZE OR SWP_MOVE OR SWP_SHOW);
    END;
END;



(* Function: TbProc
** Abstract: Subclass procedure for toolbar window
*)

FUNCTION TbProc(Window: HWnd; Msg: ULong; Mp1,Mp2: MParam): MResult;
VAR TbCtlD    :PTbCtlData;
    itemCount :LONGINT;

    lOffset   :LONGINT;
    lCount    :LONGINT;
    cSwp      :PSWP;
    tSwp,iSwp :PSWP;
    swp:os2pmapi.swp;

    cx,cy:INTEGER;
BEGIN
  result:=0;
  TbCtlD:=PTbCtlData(WinQueryWindowULong(Window,QWL_USER));
  IF TbCtlD=NIL THEN EXIT;

  CASE msg OF
    (* Internal messages *)
    TKM_SEARCH_ID:BEGIN
        FOR itemCount:=0 TO TbCtlD^.lCount-1 DO
          IF GetID(TbCtlD^.hItems[itemCount])=ULONG(mp1) THEN BEGIN
            result:=TbCtlD^.hItems[itemCount];
          END;
    END;
    TKM_QUERY_FLAGS:BEGIN
        result:=TbCtlD^.lState;
    END;

    (* Standard messages *)

    WM_QUERYFRAMECTLCOUNT:BEGIN
        itemCount:=TbCtlD^.pOldProc(Window, msg, mp1, mp2);
        inc(itemCount,TbCtlD^.lCount);

        result:=itemCount;
    END;

    WM_FORMATFRAME:BEGIN
        lOffset :=0;

        itemCount:=TbCtlD^.pOldProc(Window, msg, mp1, mp2);

        cSwp:=PSWP(PVOIDFROMMP(mp1));
        tSwp:=cSwp;

        WHILE tSwp^.wnd<>WinWindowFromID(Window,FID_CLIENT) DO inc(tSwp);

        IF TbCtlD^.lState AND TB_VERTICAL<>0 THEN BEGIN
            lOffset:=tSwp^.cy-HAND_SIZE;
            cx:=TBSepLong;
            cy:=TBSepSize;
        END
        ELSE BEGIN
            lOffset:=HAND_SIZE+1;
            cx:=TBSepSize;
            cy:=TBSepLong;
        END;
        FOR lCount:=0 TO TbCtlD^.lCount-1 DO BEGIN
            SetSepSize(TbCtlD^.hItems[lCount],cx,cy);
        END;

        IF TbCtlD^.lState AND TB_VERTICAL<>0 THEN
          lOffset:=tSwp^.cy-HAND_SIZE
        ELSE
          lOffset:=HAND_SIZE+1;

        FOR lCount:=0 TO TbCtlD^.lCount-1 DO BEGIN
            WinQueryWindowPos(TbCtlD^.hItems[lCount],swp);

            iSwp:=cSwp;
            inc(iSwp,itemCount);

            IF TbCtlD^.lState AND TB_VERTICAL<>0 THEN
            BEGIN
              iSwp^.x:=tSwp^.x;
              iSwp^.y:=lOffset+tSwp^.y-swp.cy
            END ELSE
            BEGIN
              iSwp^.x:=tSwp^.x+lOffset;
              iSwp^.y:=tSwp^.y;
            END;

            iSwp^.cx := swp.cx;
            iSwp^.cy := swp.cy;
            iSwp^.fl := SWP_SIZE OR SWP_MOVE OR SWP_SHOW;
            iSwp^.wnd:= TbCtlD^.hItems[lCount];
            iSwp^.hwndInsertBehind:= HWND_TOP;

            IF TbCtlD^.lState AND TB_VERTICAL<>0 THEN dec(lOffset,swp.cy)
              ELSE inc(lOffset,swp.cx);

            inc(itemCount);
        END;

        IF TbCtlD^.lState AND TB_VERTICAL<>0 THEN BEGIN
            inc(tSwp^.y,tSwp^.cy-HAND_SIZE);
            tSwp^.cy:=HAND_SIZE;
        END
        ELSE
            tSwp^.cx:=HAND_SIZE;
        result:=itemCount;
    END;
    ELSE
        result:=TbCtlD^.pOldProc(Window, msg, mp1, mp2);
  END;
END;

(* Function: TbSeparatorProc
** Abstract: Window procedure for Toolbar Separator Window Class
*)

FUNCTION TbSeparatorProc(Window: HWnd; Msg: ULong; Mp1,Mp2: MParam): MResult;
VAR
    ps:HPS;
    rclPaint,rect:RECTL;
    BkWnd:hwnd;
    PROCEDURE DrawFrame;
    BEGIN
        Inc(rclPaint.xLeft,2);inc(rclPaint.yBottom,2);
        Dec(rclPaint.xRight,2);dec(rclPaint.yTop,2);
        Rect:=rclPaint;
        rect.xRight:=rect.xLeft+ButtonDepth;
        WinFillRect(ps,rect,clr_darkgray);

        Rect:=rclPaint;
        rect.yBottom:=rect.yTop-ButtonDepth;
        WinFillRect(ps,rect,clr_darkgray);

        Rect:=rclPaint;
        rect.xLeft:=rect.xRight-ButtonDepth;
        WinFillRect(ps,rect,clr_white);

        Rect:=rclPaint;
        rect.yTop:=rect.yBottom+ButtonDepth;
        WinFillRect(ps,rect,clr_white);
    END;

BEGIN
    result:=0;
    CASE msg OF
        WM_PAINT:BEGIN
            WinQueryWindowRect(Window, rclPaint);
            ps:=WinBeginPaint(Window, 0, NIL);
            WinFillRect(ps, rclPaint, CLR_PALEGRAY);
            DrawFrame;
            WinEndPaint(ps);
        END;
        ELSE
            result:=WinDefWindowProc(Window, msg, mp1, mp2);
    END;
END;

(* Function: RecalcTbDimensions
** Abstract: Recalculate Toolbar window dimensions
*)

PROCEDURE RecalcTbDimensions(Window:HWND; pSize:PPOINTL);
VAR
    lCount   :LONGINT;
    TbCtlD   :PTbCtlData;
    ptlSize  :POINTL;
    ptlFSize :POINTL;
    swp      :os2pmapi.swp;
    hwndBehind:hwnd;
    SepCx,SepCy:INTEGER;
BEGIN
    TbCtlD:=PTbCtlData(WinQueryWindowULong(Window, QWL_USER));
    IF TbCtlD^.lState AND TB_VERTICAL<>0 THEN BEGIN
        ptlSize.x:=0;
        ptlSize.y:=HAND_SIZE ;
            SepCy:=TBSepSize;
            SepCx:=TBSepLong;
    END
    ELSE BEGIN
        ptlSize.x:=HAND_SIZE;
        ptlSize.y:=0 ;
            SepCx:=TBSepSize;
            SepCy:=TBSepLong;
    END;

    FOR lCount:=0 TO TbCtlD^.lCount-1 DO BEGIN
        WinQueryWindowPos(TbCtlD^.hItems[lCount],swp);
        IF GetID(TbCtlD^.hItems[lCount])=TB_SEPARATOR THEN BEGIN
            swp.cx:=SepCx;
            swp.cy:=SepCy;
        END;
        IF TbCtlD^.lState AND TB_VERTICAL<>0 THEN BEGIN
            IF swp.cx>ptlSize.x THEN ptlSize.x:=swp.cx;
            inc(ptlSize.y,swp.cy)
        END
        ELSE BEGIN
            IF swp.cy>ptlSize.y THEN ptlSize.y:=swp.cy;
            inc(ptlSize.x,swp.cx)
        END;
    END;

    WinSendMsg(Window, WM_QUERYBORDERSIZE, MPFROMP(@@ptlFSize), 0);
    inc(ptlSize.x,ptlFSize.x*2);
    inc(ptlSize.y,ptlFSize.y*2);

    IF pSize<>NIL THEN
        pSize^:=ptlSize
    ELSE
        WinSetWindowPos(Window, 0, 0, 0, ptlSize.x, ptlSize.y, SWP_SIZE)
END;

(* Function: TrackRectangle
** Abstract: Tracks given rectangle.
**
** If rclBounds is NULL, then track rectangle on entire desktop.
** rclTrack is in window coorditates and will be mapped to
** desktop.
*)

FUNCTION TrackRectangle(hwndBase:HWND; VAR rclTrack:RECTL; rclBounds:PRECTL):LONG;
VAR track   :TRACKINFO;
    ptlSize :POINTL;
BEGIN
  result:=0;
  track.cxBorder:=1;
  track.cyBorder:=1;
  track.cxGrid  :=1;
  track.cyGrid  :=1;
  track.cxKeyboard:=1;
  track.cyKeyboard:=1;

  IF rclBounds<>NIL THEN track.rclBoundary:=rclBounds^ ELSE
  BEGIN
    track.rclBoundary.yTop   := 3000;
    track.rclBoundary.xRight := 3000;
    track.rclBoundary.yBottom:=-3000;
    track.rclBoundary.xLeft  :=-3000;
  END;

  track.rclTrack:=rclTrack;

  WinMapWindowPoints(hwndBase, HWND_DESKTOP, PPOINTL(@@track.rclTrack)^, 2);

  track.ptlMinTrackSize.x:= track.rclTrack.xRight - track.rclTrack.xLeft;
  track.ptlMinTrackSize.y:= track.rclTrack.yTop   - track.rclTrack.yBottom;
  track.ptlMaxTrackSize.x:= track.rclTrack.xRight - track.rclTrack.xLeft;
  track.ptlMaxTrackSize.y:= track.rclTrack.yTop   - track.rclTrack.yBottom;

  track.fs:= TF_MOVE OR TF_ALLINBOUNDARY OR TF_GRID;

  IF WinTrackRect(HWND_DESKTOP, 0, track) THEN result:=1;

  IF result=1 THEN
  BEGIN
    IF WinEqualRect(Anchor,rclTrack,track.rclTrack) THEN
      BEGIN result:=-1; EXIT END;
    rclTrack:=track.rclTrack
  END;
END;

(* Function: TbClientProc
** Abstract: Window procedure for Toolbar Client Window Class
*)

FUNCTION TbClientProc(Window: HWnd; Msg: ULong; Mp1,Mp2: MParam): MResult;
VAR
    hwndFrame :HWND;
    TbCtlD    :PTbCtlData;
    rclPaint  :RECTL;
    hpsPaint  :HPS;
    ptlWork   :POINTL;
    iShift    :LONGINT;
    ptlPoint  :POINTL;
    swp       :os2pmapi.swp;
    rclOwner  :RECTL;
    rclFrame  :RECTL;
    lState    :LONGINT;
    lBorderX  :LONGINT;
    lBorderY  :LONGINT;
    ptlSize   :POINTL;
BEGIN
  hwndFrame:=WinQueryWindow(Window,QW_PARENT);
  TbCtlD   :=PTbCtlData(WinQueryWindowULong(hwndFrame,QWL_USER));
  result   :=0;

  CASE msg OF
    WM_ERASEBACKGROUND:BEGIN
        WinFillRect(HPS(mp1),PRECTL(mp2)^,SYSCLR_BUTTONMIDDLE);
        EXIT;
      END;
    WM_PAINT:BEGIN
        hpsPaint:=WinBeginPaint(Window,0,NIL);
        WinQueryWindowRect(Window,rclPaint);

        WinFillRect(hpsPaint,rclPaint,CLR_PALEGRAY);

        GpiSetColor(hpsPaint,CLR_WHITE);

        ptlWork.x:= rclPaint.xLeft   + 2;
        ptlWork.y:= rclPaint.yBottom + 2;
        GpiMove(hpsPaint, ptlWork);
        ptlWork.y:= rclPaint.yTop    - 2;
        GpiLine(hpsPaint, ptlWork);
        ptlWork.x:= rclPaint.xRight  - 2;
        GpiLine(hpsPaint, ptlWork);

        GpiSetColor(hpsPaint,CLR_BLACK);

        ptlWork.y:= rclPaint.yBottom + 2;
        GpiLine(hpsPaint, ptlWork);
        ptlWork.x:= rclPaint.xLeft   + 2;
        GpiLine(hpsPaint, ptlWork);

        WinEndPaint(hpsPaint);
        EXIT;
      END;
    WM_MOUSEMOVE:BEGIN
        WinSetPointer(HWND_DESKTOP,
                      WinQuerySysPointer(HWND_DESKTOP, SPTR_MOVE, FALSE));
        EXIT;
      END;
    WM_BUTTON2DBLCLK: (* Switch bubble help on/off *)
        IF TbCtlD^.lState AND TB_BUBBLE<>0 THEN
            TbCtlD^.bBubble:=NOT TbCtlD^.bBubble;
    WM_BUTTON1DBLCLK: (* Flip horisontal/vertical *)
    BEGIN
        (* attached toolbar can't be flipped *)
        IF TbCtlD^.lState AND TB_ATTACHED<>0 THEN EXIT;

        TbCtlD^.lState:=TbCtlD^.lState xor TB_VERTICAL;
        WinShowWindow(hwndFrame, FALSE);
        RecalcTbDimensions(hwndFrame, NIL);

        (*
        ** Setup new position
        ** New positon should be aligned to mouse cursor
        *)

        WinQueryPointerPos(HWND_DESKTOP,ptlPoint);
        WinQueryWindowPos(hwndFrame, swp);

        IF TbCtlD^.lState AND TB_VERTICAL<>0 THEN
            WinSetWindowPos(hwndFrame,
                            0,
                            ptlPoint.x - swp.cx div 2,
                            ptlPoint.y - swp.cy + HAND_SIZE div 2,
                            0,
                            0,
                            SWP_MOVE)
        ELSE
            WinSetWindowPos(hwndFrame,
                            0,
                            ptlPoint.x - HAND_SIZE div 2,
                            ptlPoint.y - swp.cy div 2,
                            0,
                            0,
                            SWP_MOVE);
        WinShowWindow(hwndFrame, TRUE);
        EXIT
    END;
    WM_BUTTON1DOWN:BEGIN
        lState:=0;

        RecalcTbDimensions(hwndFrame, @@ptlSize);

        rclFrame.xLeft  := 0;
        rclFrame.yBottom:= 0;
        rclFrame.yTop   := ptlSize.y;
        rclFrame.xRight := ptlSize.x;

        IF (TbCtlD^.lState AND TB_ATTACHED<>0) AND
           (TbCtlD^.lState AND TB_VERTICAL<>0)
        THEN BEGIN
            WinQueryWindowRect(hwndFrame, rclOwner);

            iShift:=rclOwner.yTop-rclOwner.yBottom-ptlSize.y;
            inc(rclFrame.yBottom,iShift);
            inc(rclFrame.yTop,iShift);
        END;

        IF TrackRectangle(hwndFrame, rclFrame, NIL)=1 THEN BEGIN
          (*
          ** Check new position for the toolbar
          ** NOTE: order of checks is important
          *)
          WinQueryWindowRect(TbCtlD^.hwndParent,rclOwner);

          (* Map both points to the desktop *)
          WinMapWindowPoints(TbCtlD^.hwndParent,
                             HWND_DESKTOP,
                             PPOINTL(@@rclOwner)^,
                             2);

          (* Cut owner rect by titlebar and menu hight *)
          lBorderX:= WinQuerySysValue(HWND_DESKTOP, SV_CXDLGFRAME);
          lBorderY:= WinQuerySysValue(HWND_DESKTOP, SV_CYDLGFRAME);

          IF WinWindowFromID(TbCtlD^.hwndParent,FID_MENU)<>0 THEN
            dec(rclOwner.yTop,WinQuerySysValue(HWND_DESKTOP,SV_CYMENU));

          IF WinWindowFromID(TbCtlD^.hwndParent,FID_TITLEBAR)<>0 THEN
            dec(rclOwner.yTop,WinQuerySysValue(HWND_DESKTOP,SV_CYTITLEBAR));

          lState:=0;
          IF (rclFrame.xLeft>=rclOwner.xLeft-lBorderX*2) AND
            (rclFrame.xLeft<=rclOwner.xLeft+lBorderX*2)
          THEN
            lState:=TB_ATTACHED_LT;

          IF (rclFrame.yTop>=rclOwner.yTop-lBorderY*2) AND
            (rclFrame.yTop<=rclOwner.yTop+lBorderY*2)
          THEN
            lState:=TB_ATTACHED_TP;

          IF (rclFrame.xRight>=rclOwner.xRight-lBorderX*2) AND
            (rclFrame.xRight<=rclOwner.xRight+lBorderX*2)
          THEN
            lState:=TB_ATTACHED_RT;

          IF (rclFrame.yBottom>=rclOwner.yBottom-lBorderY*2) AND
            (rclFrame.yBottom<=rclOwner.yBottom+lBorderY*2)
          THEN
            lState:=TB_ATTACHED_BT;

          WinShowWindow(hwndFrame, FALSE);

          IF (TbCtlD^.lState AND TB_ATTACHED=0) AND (lState=0) THEN BEGIN
              (* Toolbar is not attached and will not be attached
                 this time. Just change its position.
               *)
              WinSetWindowPos(hwndFrame,
                              0,
                              rclFrame.xLeft,
                              rclFrame.yBottom,
                              0,
                              0,
                              SWP_MOVE);
          END;

          IF TbCtlD^.lState AND TB_ATTACHED<>0 THEN BEGIN
              WinSetWindowBits( hwndFrame, QWL_STYLE, 0, FS_BORDER);
              WinSetWindowBits( hwndFrame,
                                QWL_STYLE,
                                FS_DLGBORDER,
                                FS_DLGBORDER);
              WinSendMsg(hwndFrame, WM_UPDATEFRAME, FCF_SIZEBORDER, 0);

              TbCtlD^.lState:=TbCtlD^.lState AND NOT TB_ATTACHED;
              WinSetParent(hwndFrame, HWND_DESKTOP, FALSE);
              RecalcTbDimensions(hwndFrame, NIL);

              WinQueryPointerPos(HWND_DESKTOP,ptlPoint);
              WinQueryWindowPos(hwndFrame, swp);

              IF TbCtlD^.lState AND TB_VERTICAL<>0 THEN
                WinSetWindowPos(hwndFrame,
                                0,
                                ptlPoint.x - swp.cx div 2,
                                ptlPoint.y - swp.cy + HAND_SIZE div 2,
                                0,
                                0,
                                SWP_MOVE)
              ELSE
                WinSetWindowPos(hwndFrame,
                                0,
                                ptlPoint.x - HAND_SIZE div 2,
                                ptlPoint.y - swp.cy div 2,
                                0,
                                0,
                                SWP_MOVE)
          END;

          IF lState<>0 THEN
          BEGIN
            TbCtlD^.lState:=TbCtlD^.lState OR lState;

            WinSetWindowBits(hwndFrame, QWL_STYLE, 0, FS_DLGBORDER);
            WinSetWindowBits(hwndFrame, QWL_STYLE, FS_BORDER, FS_BORDER);
            WinSendMsg(hwndFrame, WM_UPDATEFRAME, FCF_SIZEBORDER, 0);

            WinSetFocus(HWND_DESKTOP, TbCtlD^.hwndParent);
            WinSetParent(hwndFrame, TbCtlD^.hwndParent, FALSE);

            IF (lState AND (TB_ATTACHED_LT OR TB_ATTACHED_RT)<>0) AND
              (TbCtlD^.lState AND TB_VERTICAL=0) THEN
            BEGIN
              (*
              ** toolbar is horisontal, but we need to
              ** attach them to vertical side
              *)
              TbCtlD^.lState:=TbCtlD^.lState xor TB_VERTICAL
            END;

            IF (lState AND (TB_ATTACHED_TP OR TB_ATTACHED_BT)<>0) AND
              (TbCtlD^.lState AND TB_VERTICAL<>0) THEN
            BEGIN
              (*
              **toolbar is vertical, but we need to
              **attach them to horizontal side
              *)
              TbCtlD^.lState:=TbCtlD^.lState xor TB_VERTICAL
            END;
            RecalcTbDimensions(hwndFrame, NIL);
          END;

          WinSendMsg(TbCtlD^.hwndParent, WM_UPDATEFRAME, 0, 0);
          WinShowWindow(hwndFrame, TRUE);
          WinSetWindowPos(hwndFrame, HWND_TOP, 0, 0, 0, 0, SWP_ZORDER);

          EXIT;
        END;
      END;
  END;
  result:=WinDefWindowProc(Window, msg, mp1, mp2);
END;

(* Function: CreateToolbar
** Abstract: Creates toolbar for cell frame window
*)

FUNCTION CreateToolbar(hwndCell:HWND; VAR pTb:TbDef):hwnd;
VAR
    CtlD  :PCellCtlData;
    CellD :PCellTb;
    hwndTb:HWND;
BEGIN
    result:=NullHandle;
    IF hwndCell=0 THEN EXIT;

    CtlD:=PCellCtlData(WinQueryWindowULong(hwndCell, QWL_USER));
    IF CtlD=NIL THEN EXIT;

    hwndTb:=CreateTb(pTb,hwndCell,hwndCell);
    IF hwndTb=0 THEN EXIT;

    NEW(CellD);
    IF CellD=NIL THEN EXIT;

    fillchar(CellD^,sizeof(CellTb),#0);

    CellD^.Window:= hwndTb;
    CellD^.pNext := CtlD^.CellTbD;
    CtlD^.CellTbD:= CellD;

    WinSendMsg(hwndCell, WM_UPDATEFRAME, 0, 0);
    result:=hwndTB;
END;

(* Function: CellWindowFromID
** Abstract: Locate control window with given ID
*)

FUNCTION CellWindowFromID(hwndCell:HWND; ulID:LONGINT):HWND;
BEGIN
    result:=WinSendMsg(hwndCell, TKM_SEARCH_ID, ulID, 0);
END;

(* Function: CellWindowFromID
** Abstract: Locate parent window for window with given ID
*)

FUNCTION CellParentWindowFromID(hwndCell:HWND; ulID:LONGINT):HWND;
BEGIN
    result:=WinSendMsg(hwndCell, TKM_SEARCH_PARENT, ulID, 0);
END;

FUNCTION GetID(window:hwnd):INTEGER;
BEGIN
    result:=WinQueryWindowUSHORT(window,QWS_ID);
END;

constructor NuTBListCLass.Create;
BEGIN
    TBList:=TList.Create;
END;
FUNCTION NuTBListCLass.GetTBClass(NuID:ULong):NuTBClass;
VAR
    i:INTEGER;
BEGIN
    result:=NIL;
    FOR i:=0 TO TBList.Count-1 DO BEGIN
        IF NuTBClass(TBList[i]).NuID=NuID THEN
            result:=NuTBClass(TBList[i]);
    END;
END;

PROCEDURE NuTBListCLass.SetTB(NuID:ULong;NuTB:NuTBClass);
VAR
    NuHWND:hwnd;
    OldTB:NuTBClass;
BEGIN
    OldTB:=GetTBClass(NuID);
    WITH NuTB DO BEGIN
        NuID:=OldTB.NuID;
        NuWnd:=OldTB.NuWnd;
        cText:=OldTB.cText;
        isHilight:=OldTB.isHilight;
        isCapture:=OldTB.isCapture;
        isStartTimer:=OldTB.isStartTimer;
        pOldProc:=OldTB.pOldProc;
    END;
    NuHWND:=OldTB.NuWnd;
    WinSetWindowULong(NuHWND,QWL_USER,ULONG(NuTB));
END;

BEGIN
    NuTBList:=NuTBListCLass.Create;
END.
@


4.1
log
@ちょっとソースを手直し
@
text
@d21 1
a21 1
    TK_VERSION      ='$Revision: 4.0 $';  (* Toolkit version *)
a122 8

FUNCTION  GetSplit(Window:HWND; lID:LONGINT):LONGINT;
FUNCTION  SetSplit(Window:HWND; lID,lNewSplit:LONGINT):LONGINT;
PROCEDURE SetSplitType(Window:HWND; lID,lNewSplit:LONGINT);
FUNCTION  GetSplitType(Window:HWND; lID:LONGINT):LONGINT;
PROCEDURE ShowCell(Window:HWND; lID:LONGINT; Action:BOOLEAN);
PROCEDURE SetToolBarState(Window:HWND; lState:ULong);
FUNCTION GetID(window:hwnd):INTEGER;
d146 10
d161 4
@


4.0
log
@ツールチップの出方を変更
@
text
@d21 1
a21 1
    TK_VERSION      ='$Revision: 3.8 $';  (* Toolkit version *)
a1478 14
{
                IF (TbCtlD^.hwndBubble<>0) THEN BEGIN
                    WinQueryPointerPos(HWND_DESKTOP,ptlWork);
                    IF (PrevPoint.x<>ptlWork.x) OR (PrevPoint.y<>ptlWork.y) THEN
                    BEGIN
                        WinDestroyWindow(TbCtlD^.hwndBubble);
                        TbCtlD^.hwndBubble:=0;
                        TbCtlD^.BubbleClient:=Window;
                        HPSTemp:=WinGetPS(Window);
                        DrawFrame(true,rclButton,HPSTemp);
                        WinReleasePS(HPSTemp);
                    END;
                END;
}
@


3.8
log
@定義がまちがってましたー
@
text
@d21 1
a21 1
    TK_VERSION      ='$Revision: 3.7 $';  (* Toolkit version *)
d143 1
a143 1
        function GetUpBitmap(window:hwnd):HBitmap;virtual;
d148 4
a151 4
        function GetTBClass(NuID:ULong):NuTBClass;
        procedure SetTB(NuID:ULong;NuTB:NuTBClass);
    end;
var
d1418 1
a1418 1
function NuTBClass.GetUpBitmap(window:hwnd):HBitmap;
d1420 1
a1420 1
begin
d1422 1
a1422 1
end;
d1476 1
a1476 3
                    IF isStartTimer=FALSE THEN BEGIN
                        WinStartTimer(Anchor,Window,NuCellTimerID+NuID,700);
                    END;
d1479 1
d1492 1
a1492 1

d1511 1
d2208 1
a2208 1
begin
d2210 7
a2216 7
end;
function NuTBListCLass.GetTBClass(NuID:ULong):NuTBClass;
var
    i:integer;
begin
    result:=Nil;
    for i:=0 to TBList.Count-1 do begin
d2219 2
a2220 2
    end;
end;
d2222 2
a2223 2
procedure NuTBListCLass.SetTB(NuID:ULong;NuTB:NuTBClass);
var
d2226 1
a2226 1
begin
d2228 1
a2228 1
    with NuTB do begin
d2239 1
a2239 1
end;
@


3.7
log
@ボタンの変化を後で付けられるようにした
@
text
@d21 1
a21 1
    TK_VERSION      ='$Revision: 3.6 $';  (* Toolkit version *)
a142 1
        function GetCurBitmap(window:hwnd):HBitmap;virtual;
a1417 5
function NuTBClass.GetCurBitmap(window:hwnd):HBitmap;
begin
   result:=WinSendMsg(window,SM_QUERYHANDLE,0,0);
end;

d1438 1
a1438 1
    HiLight,UpBitmap:HBITMAP;
d1513 4
a1516 2
                    HiLIght:=GetCurBitmap(window);
                    WinSendMsg(Window,SM_SETHANDLE,HiLight,0);
@


3.6
log
@クラス差し替えメソッドの導入
@
text
@d21 1
a21 1
    TK_VERSION      ='$Revision: 3.5 $';  (* Toolkit version *)
d143 2
d1419 11
d1444 2
a1445 1
    HiLight:HBITMAP;
d1519 1
a1519 2
                    HPSTemp:=WinGetPS(Window);
                    HiLight:=GpiLoadBitmap(HPSTemp,0,NuID,TBSepLong,TBSepLong);
a1520 1
                    WinReleasePS(HPSTemp);
d1594 4
a1597 4
           HPSTemp:=WinGetPS(Window);
           WinQueryWindowRect(Window,rclButton);
           DrawFrame(FALSE,rclButton,HPSTemp);
           WinReleasePS(HPSTemp);
d1600 7
a1606 9
           hwndOwner:=WinQueryWindow(Window,QW_OWNER);
           WinSendMsg(Window,
                      SM_SETHANDLE,
                      WinSendMsg(window,SM_QUERYHANDLE,0,0),
                      0);
           WinPostMsg(hwndOwner,
                      WM_COMMAND,
                      NuID,
                      MPFROM2SHORT(NuID,CMDSRC_OTHER));
@


3.5
log
@クラスのネーミングを変えた
@
text
@d21 1
a21 1
    TK_VERSION      ='$Revision: 3.4 $';  (* Toolkit version *)
d2219 1
d2221 11
a2231 1
    NuHWND:=GetTBClass(NuID).NuWnd;
a2232 1

@


3.4
log
@クラス化してみましたが・・・
@
text
@d21 1
a21 1
    TK_VERSION      ='$Revision: 3.3 $';  (* Toolkit version *)
d145 1
a145 1
        NuTBList:TList;
d1333 1
a1333 1
            NuTBList.NuTBList.Add(TBClass);
d2203 1
a2203 1
    NuTBList:=TList.Create;
d2210 3
a2212 3
    for i:=0 to NuTBList.Count-1 do begin
        IF NuTBClass(NuTBList[i]).NuID=NuID THEN
            result:=NuTBClass(NuTBList[i]);
@


3.3
log
@TBリストを作る。でもこれ一個だけだしナー。どうすべ。
@
text
@d21 1
a21 1
    TK_VERSION      ='$Revision: 3.2 $';  (* Toolkit version *)
d144 6
a149 2
function GetTBClass(NuID:ULong):NuTBClass;
procedure SetTB(NuID:ULong;NuTB:NuTBClass);
d151 1
a151 1
    NuTBList:TList;
d1333 1
a1333 1
            NuTBList.Add(TBClass);
d2201 5
a2205 1
function GetTBClass(NuID:ULong):NuTBClass;
d2216 1
a2216 1
procedure SetTB(NuID:ULong;NuTB:NuTBClass);
d2226 1
a2226 1
    NuTBList:=TList.Create;
@


3.2
log
@Anchorの可視性を変えた
@
text
@d12 1
a12 1
USES os2def, os2pmapi,SysUtils;
d21 1
a21 1
    TK_VERSION      ='$Revision: 3.1 $';  (* Toolkit version *)
d131 17
a233 13
    NuTBClass=CLASS
        NuID:ULong;
        NuWnd:hwnd;
        cText   :String[32];
        isHilight,isCapture,isStartTimer:LongBool;
        pOldProc:FNWP;
        FUNCTION CreateButton(tb:TBItemData;hwndTB,hwndOwner:hwnd):hwnd;
                                                                    virtual;
        PROCEDURE DrawFrame(isPop:BOOLEAN;rect:RectL;ps:HPS);virtual;
        FUNCTION ButtonHandler(window:hwnd;Msg:ULong;Mp1,Mp2:MParam):MResult;
                                                                     virtual;
    END;

d1329 1
d2197 20
d2218 1
@


3.1
log
@EntryFieldを消す
@
text
@d21 1
a21 1
    TK_VERSION      ='$Revision: 3.0 $';  (* Toolkit version *)
a112 3
VAR
    Anchor:HAB;

d135 2
@


3.0
log
@Bottonの拡張を行う版
@
text
@d21 1
a21 1
    TK_VERSION      ='$Revision: 2.12 $';  (* Toolkit version *)
a1200 1
    tmpItemD   :PTbItemData;
a1318 17
        ELSE IF tbItem^.NuID=TB_ENTRYFIELD THEN BEGIN
            TbCtlD^.hItems[lCount]:=WinCreateWindow(hwndTb,
                                                    WC_ENTRYFIELD,
                                                    'Fit Screen',
                                                    WS_VISIBLE,
                                                    0,
                                                    0,
                                                    64,
                                                    TBSepLong,
                                                    hwndTb,
                                                    HWND_TOP,
                                                    tbItem^.NuID,
                                                    NIL,
                                                    NIL);
            TbCtlD^.hwndEntry:=TbCtlD^.hItems[lCount];

        END
a1324 1
            tmpItemD:=TbItemD;
@


2.12
log
@ツールバーの出し入れ自由に
@
text
@d21 1
a21 1
    TK_VERSION      ='$Revision: 2.9 $';  (* Toolkit version *)
@


2.11
log
@entryfieldの修正
@
text
@d18 1
d21 1
a21 1
    TK_VERSION      ='$Revision: 2.10 $';  (* Toolkit version *)
d93 1
a93 1
        cText   :String[32];
d123 1
a123 1
PROCEDURE CreateToolbar(hwndCell:HWND; VAR pTb:TbDef);
d132 1
d230 1
d240 1
d1144 12
d1208 2
d1218 11
d1251 2
d1334 1
a1334 5
            WinSetPresParam(TbCtlD^.hItems[lCount],
                            PP_FONTNAMESIZE,
                            strlen(ppFont)+1,
                            ppFont);

d1378 1
d2161 1
a2161 1
PROCEDURE CreateToolbar(hwndCell:HWND; VAR pTb:TbDef);
d2167 1
d2186 1
@


2.10
log
@ちょこっと変えました
@
text
@d20 1
a20 1
    TK_VERSION      ='$Revision: 2.9 $';  (* Toolkit version *)
d1293 1
a1293 1
                                                    WS_VISIBLE OR ES_MARGIN,
d1297 1
a1297 1
                                                    32,
d1489 1
a1489 1
                    HiLight:=GpiLoadBitmap(HPSTemp,0,NuID,32,32);
@


2.9
log
@とりあえずポインタを動かすと消える仕様に
@
text
@d20 1
a20 1
    TK_VERSION      ='$Revision: 2.8 $';  (* Toolkit version *)
d1498 2
a1499 1
            WinStopTimer(Anchor,Window,NuCellTimerID+NuID);
@


2.8
log
@原点に戻りました
@
text
@d20 1
a20 1
    TK_VERSION      ='$Revision: 2.5 $';  (* Toolkit version *)
d1140 2
d1351 1
d1451 1
a1451 1
                    IF isStartTimer=FALSE THEN
d1453 1
d1456 13
d1507 1
@


2.7
log
@途中でバブルが消える
が、失敗しているなー
@
text
@d20 1
a20 1
    TK_VERSION      ='$Revision: 2.6 $';  (* Toolkit version *)
d220 1
a220 3
        isHilight,isCapture,
        isStartTimer,
        isWipeBubble:LongBool;
a1162 1
    isWipeBubble:=FALSE;
d1291 5
a1295 5
                                                    WS_VISIBLE,
                                                    -1,
                                                    -1,
                                                    48,
                                                    TbSepLong,
a1396 2
VAR
    PrevPoint:PointL;
d1446 4
a1449 2
                   (TbCtlD^.BubbleClient<>Window) THEN BEGIN
                    WinStartTimer(Anchor,Window,NuCellTimerID+NuID,700);
a1451 20
(**add**)

                IF (TbCtlD^.hwndBubble<>0) THEN BEGIN
                    WinQueryPointerPos(HWND_DESKTOP,ptlWork);
                    IF (PrevPoint.x<>ptlWork.x) OR
                       (PrevPoint.y<>ptlWork.y) THEN
                    BEGIN
                        IF isWipeBubble THEN BEGIN
                            WinStopTimer(ANchor,Window,NuCellTimerID+NuID);
                            isWipeBubble:=FALSE;
                        END;
                        WinDestroyWindow(TbCtlD^.hwndBubble);
                        TbCtlD^.hwndBubble:=0;
                        TbCtlD^.BubbleClient:=Window;
                        HPSTemp:=WinGetPS(Window);
                        DrawFrame(true,rclButton,HPSTemp);
                        WinReleasePS(HPSTemp);
                    END;
                END;
(** add end**)
a1456 4
                IF isWipeBubble THEN BEGIN
                    WinStopTimer(ANchor,Window,NuCellTimerID+NuID);
                    isWipeBubble:=FALSE;
                END;
d1472 1
a1472 1
                    HiLight:=GpiLoadBitmap(HPSTemp,0,NuID,0,0);
a1480 1
            WinQueryWindowRect(Window,rclButton);
a1481 10
            IF TbCtlD^.hwndBubble<>0 THEN BEGIN
                WinDestroyWindow(TbCtlD^.hwndBubble);
                TbCtlD^.hwndBubble:=0;
                TbCtlD^.BubbleClient:=Window;
                HPSTemp:=WinGetPS(Window);
                DrawFrame(true,rclButton,HPSTemp);
                WinReleasePS(HPSTemp);
                isWipeBubble:=TRUE;
                EXIT;
            END;
d1484 1
a1484 1
            WinQueryPointerPos(HWND_DESKTOP,PrevPoint);
a1513 1
{
a1514 1
}           ptlWork:=PrevPoint;
d1532 3
a1534 4
//            IF TbCtlD^.lState AND TB_VERTICAL=0 THEN
  //              (ptlWork.y,lHight);
//            IF TbCtlD^.lState AND TB_ATTACHED <>0 THEN
  //              inc(ptlWork.x,(rclButton.xRight-rclButton.xLeft) );
a1543 1
            WinStartTimer(Anchor,Window,NuCellTimerID+NuID,1500);
@


2.6
log
@バブル自然消滅
@
text
@d20 1
a20 1
    TK_VERSION      ='$Revision: 2.5 $';  (* Toolkit version *)
d1297 2
a1298 2
                                                    -1,
                                                    -1,
@


2.5
log
@ポップアップを改良
@
text
@d20 1
a20 1
    TK_VERSION      ='$Revision: 3.8 $';  (* Toolkit version *)
d220 3
a222 1
        isHilight,isCapture,isStartTimer:LongBool;
d1165 1
d1294 5
a1298 5
                                                    WS_VISIBLE OR ES_MARGIN,
                                                    0,
                                                    0,
                                                    64,
                                                    32,
d1456 1
d1462 4
d1480 4
d1499 1
a1499 1
                    HiLight:=GpiLoadBitmap(HPSTemp,0,NuID,32,32);
d1508 1
d1510 10
a1521 1
            WinQueryWindowRect(Window,rclButton);
d1585 1
@


2.4
log
@ Editorを入れ込めるよーに。
@
text
@d12 1
a12 1
USES os2def, os2pmapi;
d17 1
d20 1
a20 1
    TK_VERSION      ='$Revision: 2.3 $';  (* Toolkit version *)
a51 1
    TB_NuStyle      = $0100; (* Flat Style*)
d55 1
a55 1
    TB_EDITCTRL     = $7003;
d65 2
d91 1
a91 1
        NormalID:ULong;
d112 2
a122 1
PROCEDURE GenResIDStr(buff:pchar; ulID:LONGINT);
d131 1
d217 2
a218 1
        NormalID:ULong;
d220 1
a220 1
        isHilight,isCapture:BOOLEAN;
a224 2
        FUNCTION MouseOver(window:hwnd;Msg:ULong;Mp1,Mp2:MParam):MResult;
                                                                    virtual;
d236 1
a236 1
        hwndLast  :HWND;
a241 3
VAR
    Anchor:HAB;

d656 4
a659 4
            WHILE CellTbD<>NIL DO
            BEGIN
              IF WinQueryWindowUShort(CellTbD^.Window,QWS_ID)=mp1 THEN
                BEGIN result:=MPARAM(CellTbD^.Window); EXIT END;
d661 5
a665 3
              hwndRC:=HWND(WinSendMsg(CellTbD^.Window,TKM_SEARCH_ID,mp1,0));
              IF hwndRC<>0 THEN
                BEGIN result:=MPARAM(hwndRC); EXIT END;
d667 1
a667 1
              CellTbD:=CellTbD^.pNext;
d670 4
a673 2
            IF WinQueryWindowUShort(Window,QWS_ID)=mp1 THEN
              BEGIN result:=MPARAM(Window); EXIT END;
d675 4
a678 2
            IF WinQueryWindowUShort(pCtlData^.hwndPanel1,QWS_ID)=mp1 THEN
              BEGIN result:=MPARAM(pCtlData^.hwndPanel1); EXIT END;
d680 4
a683 2
            IF hwndRC<>0 THEN
              BEGIN result:=MPARAM(hwndRC); EXIT END;
d685 4
a688 2
            IF WinQueryWindowUShort(pCtlData^.hwndPanel2,QWS_ID)=mp1 THEN
              BEGIN result:=MPARAM(pCtlData^.hwndPanel2); EXIT END;
d690 4
a693 2
            IF hwndRC<>0 THEN
              BEGIN result:=MPARAM(hwndRC); EXIT END;
d1019 1
a1019 2
        IF pCtlData^.lType AND CELL_VSPLIT<>0 THEN
        BEGIN
d1032 1
a1032 2
          FOR ii:=0 TO SPLITBAR_WIDTH-1 DO
          BEGIN
d1042 1
a1042 2
        FOR ii:=0 TO SPLITBAR_WIDTH-1 DO
        BEGIN
d1143 1
a1143 1
    cButtText :ARRAY[BYTE] OF CHAR;
d1146 1
a1146 1
    GenResIDStr(cButtText,tb.NormalID);
d1149 1
a1149 1
                            cButtText,
d1157 1
a1157 1
                            tb.NormalID,
d1161 2
a1162 1
    @@pOldProc:=WinSubclassWindow(window,BtProc);
d1165 1
a1165 1
    NormalID:=TB.normalID;
d1167 1
a1169 199
PROCEDURE NuTBClass.DrawFrame(isPop:BOOLEAN;rect:RectL;ps:HPS);
VAR
    UpperFrameColor,DownFrameColor:ULong;
    wRect:RectL;
BEGIN
    IF isPop THEN BEGIN
        UpperFrameColor:=CLR_WHITE;
        DownFrameColor:=CLR_DARKGRAY;
    END
    ELSE BEGIN
        DownFrameColor:=CLR_WHITE;
        UpperFrameColor:=CLR_DARKGRAY;
    END;
    wRect:=Rect;
    rect.xRight:=rect.xLeft+ButtonDepth;
    WinFillRect(ps,rect,UpperFrameColor);

    Rect:=wRect;
    rect.yBottom:=rect.yTop-ButtonDepth;
    WinFillRect(ps,rect,UpperFrameColor);

    Rect:=wRect;
    rect.xLeft:=rect.xRight-ButtonDepth;
    WinFillRect(ps,rect,DownFrameColor);

    Rect:=wRect;
    rect.yTop:=rect.yBottom+ButtonDepth;
    WinFillRect(ps,rect,DownFrameColor);
END;

FUNCTION NuTBClass.MouseOver(window:hwnd;Msg:ULong;Mp1,Mp2:MParam):MResult;
VAR
    rclButton:RectL;
    hpsTemp:hps;
    HiLight:HBITMAP;
    TbCtlD:PTbCtlData;
    hwndFrame:hwnd;
    ulStyle    :LONGINT;
    hwndBubbleClient:HWND;
    ptlWork    :POINTL;
    ulColor    :LONGINT;
    txtPointl  :ARRAY [0..TXTBOX_COUNT-1] OF POINTL;
    lHight,
    lWidth     :LONGINT;
    FUNCTION isRectIn:BOOLEAN;
    VAR
        mCx,mCy:INTEGER;
    BEGIN
        mCx:=SHORT1FROMMP(mp1);
        mCy:=SHORT2FROMMP(mp1);
        IF (RclButton.yBottom<mCy) AND (rclButton.yTop>mCy) AND
           (rclButton.xLeft<mCx) AND (rclButton.xRight>mCx)
        THEN
            isRectIn:=TRUE
        ELSE
            isRectIn:=FALSE;
    END;
BEGIN
    hwndFrame:=WinQueryWindow(Window,QW_PARENT);
    TbCtlD   :=PTbCtlData(WinQueryWindowULong(hwndFrame,QWL_USER));
    WinQueryWindowRect(Window,rclButton);
    IF isRectIn THEN BEGIN
        IF isCapture = FALSE THEN BEGIN
            WinSetCapture(HWND_DESKTOP,Window);
            isCapture :=TRUE;
        END;
        IF isHilight=FALSE THEN BEGIN
            isHilight:=TRUE;
            HPSTemp:=WinGetPS(Window);
            DrawFrame(true,rclButton,HPSTemp);
            WinReleasePS(HPSTemp);
        END;
    END
    ELSE BEGIN
        IF isCapture THEN BEGIN
            WinSetCapture(HWND_DESKTOP,NULLHANDLE);
            isCapture :=FALSE;
        END;
        IF isHilight THEN BEGIN
            isHilight:=FALSE;
            HPSTemp:=WinGetPS(Window);
            HiLight:=GpiLoadBitmap(HPSTemp,0,NormalID,32,32);
            WinSendMsg(Window,SM_SETHANDLE,HiLight,0);
            WinReleasePS(HPSTemp);
        END;
        IF TbCtlD^.hwndBubble<>0 THEN
        BEGIN
            WinDestroyWindow(TbCtlD^.hwndBubble);
            TbCtlD^.hwndBubble:=0;
        END;
    END;
    IF (TbCtlD^.lState AND TB_BUBBLE<>0) AND
       TbCtlD^.bBubble AND
       ((WinQueryActiveWindow(HWND_DESKTOP)=hwndFrame) OR
          (WinQueryActiveWindow(HWND_DESKTOP)=TbCtlD^.hwndParent)) AND
       (TbCtlD^.hwndLast<>Window)
    THEN BEGIN
        IF TbCtlD^.hwndBubble<>0 THEN BEGIN
            WinDestroyWindow(TbCtlD^.hwndBubble);
            TbCtlD^.hwndBubble:=0;
        END;

        IF TbCtlD^.hwndBubble=0 THEN BEGIN
            ulStyle:=FCF_BORDER OR FCF_NOBYTEALIGN;
            hpsTemp:=0;
            ptlWork.x:=0;
            ptlWork.y:=0;
            ulColor:=CLR_PALEGRAY;

            TbCtlD^.hwndLast:=Window;
            TbCtlD^.hwndBubble:=WinCreateStdWindow( HWND_DESKTOP,
                                                    0,
                                                    ulStyle,
                                                    WC_STATIC,
                                                    '',
                                                    SS_TEXT OR
                                                    DT_LEFT OR
                                                    DT_VCENTER,
                                                    NULLHANDLE,
                                                    TB_BUBBLEID,
                                                    @@hwndBubbleClient);

            WinSetPresParam(hwndBubbleClient,
                            PP_FONTNAMESIZE,
                            strlen(ppFont)+1,
                            ppFont);
            WinSetPresParam(hwndBubbleClient,
                            PP_BACKGROUNDCOLORINDEX,
                            sizeof(
                            ulColor),@@ulColor);

            WinSetWindowText(hwndBubbleClient, @@(cText[1]));

            WinMapWindowPoints(Window, HWND_DESKTOP, ptlWork, 1);

            hpsTemp:=WinGetPS(hwndBubbleClient);
            GpiQueryTextBox(hpsTemp,
                            Length(cText)-1,
                            @@cText[1],
                            TXTBOX_COUNT,PPOINTL(@@txtPointl[0])^);

            WinReleasePS(hpsTemp);

            lWidth:=txtPointl[TXTBOX_TOPRIGHT].x-
                    txtPointl[TXTBOX_TOPLEFT].x+
                    WinQuerySysValue(HWND_DESKTOP,SV_CYDLGFRAME)*2;

            lHight:=txtPointl[TXTBOX_TOPLEFT].y-
                    txtPointl[TXTBOX_BOTTOMLEFT].y+
                    WinQuerySysValue(HWND_DESKTOP,SV_CXDLGFRAME)*2;

            IF TbCtlD^.lState AND TB_VERTICAL=0 THEN
                dec(ptlWork.y,lHight);
            IF TbCtlD^.lState AND TB_ATTACHED <>0 THEN
                inc(ptlWork.x,
                    (rclButton.xRight-rclButton.xLeft) div 2);

            WinSetWindowPos(TbCtlD^.hwndBubble,
                            HWND_TOP,
                            ptlWork.x,
                            ptlWork.y,
                            lWidth,
                            lHight,
                            SWP_SIZE OR SWP_MOVE OR SWP_SHOW);
        END;
    END;
END;

FUNCTION NuTBClass.ButtonHandler(window:hwnd;Msg:ULong;Mp1,Mp2:MParam):MResult;
VAR
    hwndOwner  :HWND;
    hpsTemp    :HPS;
    rclButton:RECTL;
BEGIN

    CASE msg OF
        WM_MOUSEMOVE:BEGIN
            MouseOver(Window,msg,mp1,mp2);
        END;(**WM_MOUSEMOVE**)
        WM_BUTTON1DOWN:BEGIN
           HPSTemp:=WinGetPS(Window);
           WinQueryWindowRect(Window,rclButton);
           DrawFrame(FALSE,rclButton,HPSTemp);
           WinReleasePS(HPSTemp);
        END;
        WM_BUTTON1UP:BEGIN
           hwndOwner:=WinQueryWindow(Window,QW_OWNER);
           WinSendMsg(Window,
                      SM_SETHANDLE,
                      WinSendMsg(window,SM_QUERYHANDLE,0,0),
                      0);
           WinPostMsg(hwndOwner,
                      WM_COMMAND,
                      NormalID,
                      MPFROM2SHORT(NormalID,CMDSRC_OTHER));
        END;
    END;
    result:=pOldProc(Window, msg, mp1, mp2);
END;
d1172 2
d1196 1
a1196 1
    WHILE tbItem^.normalID<>0 DO BEGIN
d1272 36
a1307 28
        IF tbItem^.NormalID=TB_SEPARATOR THEN
              TbCtlD^.hItems[lCount]:=WinCreateWindow(hwndTb,
                                                      TB_SEPCLASS,
                                                      '',
                                                      0,
                                                      0,
                                                      0,
                                                      TB_SEP_SIZE,
                                                      TB_SEP_SIZE,
                                                      hwndTb,
                                                      HWND_TOP,
                                                      tbItem^.NormalID,
                                                      NIL,
                                                      NIL)
        ELSE IF tbItem^.NormalID=TB_EDITCTRL THEN
              TbCtlD^.hItems[lCount]:=WinCreateWindow(hwndTb,
                                                      WC_ENTRYFIELD,
                                                      'EDITOR',
                                                      WS_VISIBLE,
                                                      0,
                                                      0,
                                                      64,
                                                      24,
                                                      hwndTb,
                                                      HWND_TOP,
                                                      tbItem^.NormalID,
                                                      NIL,
                                                      NIL)
d1311 3
a1313 1
            TbCtlD^.hItems[lCount]:=TBClass.CreateButton(tbItem^,hwndTB,hWndOwner);
d1322 7
a1328 3
            inc(ptlSize.y,swp.cy)
        END ELSE
        BEGIN
d1330 5
a1334 1
            inc(ptlSize.x,swp.cx)
d1348 1
d1367 220
d1596 18
d1626 3
a1628 1
    Swp       :os2pmapi.swp;
d1638 4
a1641 4
          IF WinQueryWindowUShort(TbCtlD^.hItems[itemCount],QWS_ID)=ULONG(mp1) THEN
            BEGIN result:=TbCtlD^.hItems[itemCount]; EXIT END;
        EXIT;
      END;
d1644 1
a1644 2
        EXIT
      END;
d1653 1
a1653 2
        EXIT;
      END;
d1665 13
d1684 2
a1685 3
        FOR lCount:=0 TO TbCtlD^.lCount-1 DO
        BEGIN
          WinQueryWindowPos(TbCtlD^.hItems[lCount],swp);
d1687 2
a1688 2
          iSwp:=cSwp;
          inc(iSwp,itemCount);
d1690 9
a1698 9
          IF TbCtlD^.lState AND TB_VERTICAL<>0 THEN
          BEGIN
            iSwp^.x:=tSwp^.x;
            iSwp^.y:=lOffset+tSwp^.y-swp.cy
          END ELSE
          BEGIN
            iSwp^.x:=tSwp^.x+lOffset;
            iSwp^.y:=tSwp^.y;
          END;
d1700 18
a1717 18
          iSwp^.cx := swp.cx;
          iSwp^.cy := swp.cy;
          iSwp^.fl := SWP_SIZE OR SWP_MOVE OR SWP_SHOW;
          iSwp^.wnd:= TbCtlD^.hItems[lCount];
          iSwp^.hwndInsertBehind:= HWND_TOP;

          IF TbCtlD^.lState AND TB_VERTICAL<>0 THEN dec(lOffset,swp.cy)
            ELSE inc(lOffset,swp.cx);

          inc(itemCount);
        END;

        IF TbCtlD^.lState AND TB_VERTICAL<>0 THEN
        BEGIN
          inc(tSwp^.y,tSwp^.cy-HAND_SIZE);
          tSwp^.cy:=HAND_SIZE;
        END ELSE
          tSwp^.cx:=HAND_SIZE;
d1719 3
a1721 2
        EXIT;
      END;
a1722 1
  result:=TbCtlD^.pOldProc(Window, msg, mp1, mp2);
d1730 25
a1754 2
VAR hpsPaint:HPS;
    rclPaint:RECTL;
d1756 12
a1767 11
  result:=0;
  CASE msg OF
    WM_PAINT:BEGIN
        hpsPaint:=WinBeginPaint(Window, 0, NIL);
        WinQueryWindowRect(Window, rclPaint);
        WinFillRect(hpsPaint, rclPaint, CLR_PALEGRAY);
        WinEndPaint(hpsPaint);
        EXIT;
      END;
  END;
  result:=WinDefWindowProc(Window, msg, mp1, mp2);
d1775 22
a1796 12
VAR  lCount   :LONGINT;
     TbCtlD   :PTbCtlData;
     ptlSize  :POINTL;
     ptlFSize :POINTL;
     swp      :os2pmapi.swp;
BEGIN
  TbCtlD:=PTbCtlData(WinQueryWindowULong(Window, QWL_USER));

  IF TbCtlD^.lState AND TB_VERTICAL<>0 THEN
    BEGIN ptlSize.x:=0; ptlSize.y:=HAND_SIZE END
  ELSE
    BEGIN ptlSize.x:=HAND_SIZE; ptlSize.y:=0 END;
d1798 14
a1811 11
  FOR lCount:=0 TO TbCtlD^.lCount-1 DO
  BEGIN
    WinQueryWindowPos(TbCtlD^.hItems[lCount],swp);
    IF TbCtlD^.lState AND TB_VERTICAL<>0 THEN
    BEGIN
      IF swp.cx>ptlSize.x THEN ptlSize.x:=swp.cx;
      inc(ptlSize.y,swp.cy)
    END ELSE
    BEGIN
      IF swp.cy>ptlSize.y THEN ptlSize.y:=swp.cy;
      inc(ptlSize.x,swp.cx)
a1812 1
  END;
d1814 3
a1816 3
  WinSendMsg(Window, WM_QUERYBORDERSIZE, MPFROMP(@@ptlFSize), 0);
  inc(ptlSize.x,ptlFSize.x*2);
  inc(ptlSize.y,ptlFSize.y*2);
d1818 4
a1821 2
  IF pSize<>NIL THEN pSize^:=ptlSize ELSE
    WinSetWindowPos(Window, 0, 0, 0, ptlSize.x, ptlSize.y, SWP_SIZE)
d1878 2
a1879 1
VAR hwndFrame :HWND;
d1930 2
a1931 1
        WinSetPointer(HWND_DESKTOP, WinQuerySysPointer(HWND_DESKTOP, SPTR_MOVE, FALSE));
d1935 2
a1936 1
      IF TbCtlD^.lState AND TB_BUBBLE<>0 THEN TbCtlD^.bBubble:=NOT TbCtlD^.bBubble;
d1938 1
a1938 1
      BEGIN
d1955 7
a1961 2
          WinSetWindowPos(hwndFrame, 0, ptlPoint.x - swp.cx div 2,
            ptlPoint.y - swp.cy + HAND_SIZE div 2, 0, 0, SWP_MOVE)
d1963 7
a1969 2
          WinSetWindowPos(hwndFrame, 0, ptlPoint.x - HAND_SIZE div 2,
            ptlPoint.y - swp.cy div 2, 0, 0, SWP_MOVE);
d1972 1
a1972 1
      END;
d1983 4
a1986 3
        IF (TbCtlD^.lState AND TB_ATTACHED<>0) AND (TbCtlD^.lState AND TB_VERTICAL<>0) THEN
        BEGIN
          WinQueryWindowRect(hwndFrame, rclOwner);
d1988 3
a1990 3
          iShift:=rclOwner.yTop-rclOwner.yBottom-ptlSize.y;
          inc(rclFrame.yBottom,iShift);
          inc(rclFrame.yTop,iShift);
d1993 1
a1993 2
        IF TrackRectangle(hwndFrame, rclFrame, NIL)=1 THEN
        BEGIN
d2001 4
a2004 1
          WinMapWindowPoints(TbCtlD^.hwndParent, HWND_DESKTOP, PPOINTL(@@rclOwner)^, 2);
d2018 3
a2020 1
            (rclFrame.xLeft<=rclOwner.xLeft+lBorderX*2) THEN lState:=TB_ATTACHED_LT;
d2023 3
a2025 1
            (rclFrame.yTop<=rclOwner.yTop+lBorderY*2) THEN lState:=TB_ATTACHED_TP;
d2028 3
a2030 1
            (rclFrame.xRight<=rclOwner.xRight+lBorderX*2) THEN lState:=TB_ATTACHED_RT;
d2033 3
a2035 1
            (rclFrame.yBottom<=rclOwner.yBottom+lBorderY*2) THEN lState:=TB_ATTACHED_BT;
d2039 11
a2049 6
          IF (TbCtlD^.lState AND TB_ATTACHED=0) AND (lState=0) THEN
          BEGIN
            (* Toolbar is not attached and will not be attached
               this time. Just change its position.
             *)
            WinSetWindowPos(hwndFrame,0,rclFrame.xLeft,rclFrame.yBottom,0,0,SWP_MOVE);
d2052 31
a2082 19
          IF TbCtlD^.lState AND TB_ATTACHED<>0 THEN
          BEGIN
            WinSetWindowBits(hwndFrame, QWL_STYLE, 0, FS_BORDER);
            WinSetWindowBits(hwndFrame, QWL_STYLE, FS_DLGBORDER, FS_DLGBORDER);
            WinSendMsg(hwndFrame, WM_UPDATEFRAME, FCF_SIZEBORDER, 0);

            TbCtlD^.lState:=TbCtlD^.lState AND NOT TB_ATTACHED;
            WinSetParent(hwndFrame, HWND_DESKTOP, FALSE);
            RecalcTbDimensions(hwndFrame, NIL);

            WinQueryPointerPos(HWND_DESKTOP,ptlPoint);
            WinQueryWindowPos(hwndFrame, swp);

            IF TbCtlD^.lState AND TB_VERTICAL<>0 THEN
              WinSetWindowPos(hwndFrame, 0, ptlPoint.x - swp.cx div 2,
                ptlPoint.y - swp.cy + HAND_SIZE div 2, 0, 0, SWP_MOVE)
            ELSE
              WinSetWindowPos(hwndFrame, 0, ptlPoint.x - HAND_SIZE div 2,
                ptlPoint.y - swp.cy div 2, 0, 0, SWP_MOVE)
d2134 2
a2135 1
VAR CtlD  :PCellCtlData;
d2139 1
a2139 1
  IF hwndCell=0 THEN EXIT;
d2141 2
a2142 2
  CtlD:=PCellCtlData(WinQueryWindowULong(hwndCell, QWL_USER));
  IF CtlD=NIL THEN EXIT;
d2144 2
a2145 2
  hwndTb:=CreateTb(pTb,hwndCell,hwndCell);
  IF hwndTb=0 THEN EXIT;
d2147 2
a2148 2
  NEW(CellD);
  IF CellD=NIL THEN EXIT;
d2150 1
a2150 1
  fillchar(CellD^,sizeof(CellTb),#0);
d2152 3
a2154 3
  CellD^.Window:= hwndTb;
  CellD^.pNext := CtlD^.CellTbD;
  CtlD^.CellTbD:= CellD;
d2156 1
a2156 1
  WinSendMsg(hwndCell, WM_UPDATEFRAME, 0, 0);
d2165 1
a2165 1
  result:=WinSendMsg(hwndCell, TKM_SEARCH_ID, ulID, 0);
d2174 1
a2174 1
  result:=WinSendMsg(hwndCell, TKM_SEARCH_PARENT, ulID, 0);
d2177 1
a2177 8
(* Function: GenResIDStr
** Abstract: Generate string '#nnnn' for a given ID for using with Button
**           controls
*)

PROCEDURE GenResIDStr(buff:pchar; ulID:LONGINT);
VAR  str :pchar;
     slen:LONGINT;
d2179 1
a2179 23
  slen:=0;
  buff^:='#';
  inc(buff);
  str:=buff;

  REPEAT
    str^:=CHR(ulID mod 10+ord('0'));
    inc(str);
    ulID:=ulID div 10;
    inc(slen);
  UNTIL ulID=0;

  str^:=#0;
  dec(str);

  WHILE str>buff DO
  BEGIN
    buff^:=CHAR(ord(buff^) xor ord(str^));
    str^ :=CHAR(ord(str^) xor ord(buff^));
    buff^:=CHAR(ord(buff^) xor ord(str^));
    dec(str);
    inc(buff);
  END;
d2182 1
@


2.3
log
@更にちっとクラス化
@
text
@d19 1
a19 1
    TK_VERSION      ='$Revision: 2.2 $';  (* Toolkit version *)
d55 1
d1467 14
@


2.2
log
@クラス化の端緒
@
text
@d19 1
a19 1
    TK_VERSION      ='$Revision: 2.1 $';  (* Toolkit version *)
a86 1
    PTbItemData = ^TbItemData;
d91 1
a92 12
    PTbCtlData = ^TbCtlData;
    TbCtlData  = RECORD
        pOldProc  :FNWP;
        hwndParent:HWND;
        lState    :LONGINT;
        lCount    :LONGINT;

        bBubble   :longbool;
        hwndBubble:HWND;
        hwndLast  :HWND;
        hItems    :ARRAY [0..0] OF HWND;
    END;
d179 1
a179 1
FUNCTION  CreateTb(VAR pTb:TbDef; hWndParent, hWndOwner:HWND):HWND; forward;
d224 12
d1358 1
a1358 1
FUNCTION CreateTb(VAR pTb:TbDef; hWndParent, hWndOwner:HWND):HWND;
@


2.1
log
@ ちょっと前進
@
text
@d19 1
a19 1
    TK_VERSION      ='$Revision: 2.0 $';  (* Toolkit version *)
d222 4
a225 5
    
    NuTBClass=Class
        function CreateButton(tb:TBItemData;hwndOwner:hwnd):hwnd;virtual;
        function ButtonHandler(window:hwnd;Msg:ULong;Mp1,Mp2:MParam):MResult;
                                                                     virtual;
d228 7
d1131 2
a1132 2
function NuTBClass.CreateButton(tb:TBItemData;hwndOwner:hwnd):hwnd;
var
d1135 1
a1135 1
begin
d1150 2
a1151 2

    pOldProc:=WinSubclassWindow(window,BtProc);
d1156 103
a1258 1
end;
d1260 97
a1356 3
function NuTBClass.ButtonHandler(window:hwnd;Msg:ULong;Mp1,Mp2:MParam):MResult;
begin
end;
d1473 2
a1474 2
            
            TbCtlD^.hItems[lCount]:=NuTBClass.CreateButton(tbItem^,hWndOwner);
d1520 1
a1520 1
VAR TbCtlD     :PTbCtlData;
a1521 24
    hwndFrame,hwndOwner  :HWND;
    hwndBubbleClient:HWND;
    ulStyle    :LONGINT;
    hpsTemp    :HPS;
    lHight,
    lWidth     :LONGINT;
    txtPointl  :ARRAY [0..TXTBOX_COUNT-1] OF POINTL;
    ptlWork    :POINTL;
    ulColor    :LONGINT;
    rclButton,Rect:RECTL;
    HiLight:HBITMAP;
    FUNCTION isRectIn:BOOLEAN;
    VAR
        mCx,mCy:INTEGER;
    BEGIN
        mCx:=SHORT1FROMMP(mp1);
        mCy:=SHORT2FROMMP(mp1);
        IF (RclButton.yBottom<mCy) AND (rclButton.yTop>mCy) AND
           (rclButton.xLeft<mCx) AND (rclButton.xRight>mCx)
        THEN
            isRectIn:=TRUE
        ELSE
            isRectIn:=FALSE;
    END;
a1523 2
    hwndFrame:=WinQueryWindow(Window,QW_PARENT);
    TbCtlD   :=PTbCtlData(WinQueryWindowULong(hwndFrame,QWL_USER));
d1525 1
a1525 160

    CASE msg OF
        WM_MOUSEMOVE:BEGIN
            WinQueryWindowRect(Window,rclButton);
            IF isRectIn THEN BEGIN
                IF tbItemD^.isCapture = FALSE THEN BEGIN
                    WinSetCapture(HWND_DESKTOP,Window);
                    tbItemD^.isCapture :=TRUE;
                END;
                IF tbItemD^.isHilight=FALSE THEN BEGIN
                    tbItemD^.isHilight:=TRUE;
                    HPSTemp:=WinGetPS(Window);

                    Rect:=rclButton;
                    rect.xRight:=rect.xLeft+ButtonDepth;
                    WinFillRect(HPSTemp,rect,CLR_WHITE);

                    Rect:=rclButton;
                    rect.yBottom:=rect.yTop-ButtonDepth;
                    WinFillRect(HPSTemp,rect,CLR_WHITE);

                    Rect:=rclButton;
                    rect.xLeft:=rect.xRight-ButtonDepth;
                    WinFillRect(HPSTemp,rect,CLR_DARKGRAY);

                    Rect:=rclButton;
                    rect.yTop:=rect.yBottom+ButtonDepth;
                    WinFillRect(HPSTemp,rect,CLR_DARKGRAY);

                    WinReleasePS(HPSTemp);
                END;
            END
            ELSE BEGIN
                IF tbItemD^.isCapture THEN BEGIN
                    WinSetCapture(HWND_DESKTOP,NULLHANDLE);
                    tbItemD^.isCapture :=FALSE;
                END;
                IF tbItemD^.isHilight THEN BEGIN
                    tbItemD^.isHilight:=FALSE;
                    HPSTemp:=WinGetPS(Window);
                    HiLight:=GpiLoadBitmap(HPSTemp,0,tbItemD^.NormalID,32,32);
                    WinSendMsg(Window,SM_SETHANDLE,HiLight,0);
                    WinReleasePS(HPSTemp);
                END;
                IF TbCtlD^.hwndBubble<>0 THEN
                BEGIN
                    WinDestroyWindow(TbCtlD^.hwndBubble);
                    TbCtlD^.hwndBubble:=0;
                END;
            END;
            IF (TbCtlD^.lState AND TB_BUBBLE<>0) AND
               TbCtlD^.bBubble AND
               ((WinQueryActiveWindow(HWND_DESKTOP)=hwndFrame) OR
                  (WinQueryActiveWindow(HWND_DESKTOP)=TbCtlD^.hwndParent)) AND
               (TbCtlD^.hwndLast<>Window)
            THEN BEGIN
                IF TbCtlD^.hwndBubble<>0 THEN BEGIN
                    WinDestroyWindow(TbCtlD^.hwndBubble);
                    TbCtlD^.hwndBubble:=0;
                END;

                IF TbCtlD^.hwndBubble=0 THEN BEGIN
                    ulStyle:=FCF_BORDER OR FCF_NOBYTEALIGN;
                    hpsTemp:=0;
                    ptlWork.x:=0;
                    ptlWork.y:=0;
                    ulColor:=CLR_PALEGRAY;

                    TbCtlD^.hwndLast:=Window;
                    TbCtlD^.hwndBubble:=WinCreateStdWindow( HWND_DESKTOP,
                                                            0,
                                                            ulStyle,
                                                            WC_STATIC,
                                                            '',
                                                            SS_TEXT OR
                                                            DT_LEFT OR
                                                            DT_VCENTER,
                                                            NULLHANDLE,
                                                            TB_BUBBLEID,
                                                            @@hwndBubbleClient);

                    WinSetPresParam(hwndBubbleClient,
                                    PP_FONTNAMESIZE,
                                    strlen(ppFont)+1,
                                    ppFont);
                    WinSetPresParam(hwndBubbleClient,
                                    PP_BACKGROUNDCOLORINDEX,
                                    sizeof(
                                    ulColor),@@ulColor);

                    WinSetWindowText(hwndBubbleClient, @@(TbItemD^.cText[1]));

                    WinMapWindowPoints(Window, HWND_DESKTOP, ptlWork, 1);

                    hpsTemp:=WinGetPS(hwndBubbleClient);
                    GpiQueryTextBox(hpsTemp,
                                    Length(TbItemD^.cText)-1,
                                    @@TbItemD^.cText[1],
                                    TXTBOX_COUNT,PPOINTL(@@txtPointl[0])^);

                    WinReleasePS(hpsTemp);

                    lWidth:=txtPointl[TXTBOX_TOPRIGHT].x-
                            txtPointl[TXTBOX_TOPLEFT].x+
                            WinQuerySysValue(HWND_DESKTOP,SV_CYDLGFRAME)*2;

                    lHight:=txtPointl[TXTBOX_TOPLEFT].y-
                            txtPointl[TXTBOX_BOTTOMLEFT].y+
                            WinQuerySysValue(HWND_DESKTOP,SV_CXDLGFRAME)*2;

                    IF TbCtlD^.lState AND TB_VERTICAL=0 THEN
                        dec(ptlWork.y,lHight);
                    IF TbCtlD^.lState AND TB_ATTACHED <>0 THEN
                        inc(ptlWork.x,
                            (rclButton.xRight-rclButton.xLeft) div 2);

                    WinSetWindowPos(TbCtlD^.hwndBubble,
                                    HWND_TOP,
                                    ptlWork.x,
                                    ptlWork.y,
                                    lWidth,
                                    lHight,
                                    SWP_SIZE OR SWP_MOVE OR SWP_SHOW);
                END;
            END;
        END;(**WM_MOUSEMOVE**)
        WM_BUTTON1DOWN:begin
           HPSTemp:=WinGetPS(Window);
           WinQueryWindowRect(Window,rclButton);
           Rect:=rclButton;
           rect.xRight:=rect.xLeft+ButtonDepth;
           WinFillRect(HPSTemp,rect,CLR_DARKGRAY);

           Rect:=rclButton;
           rect.yBottom:=rect.yTop-ButtonDepth;
           WinFillRect(HPSTemp,rect,CLR_DARKGRAY);

           Rect:=rclButton;
           rect.xLeft:=rect.xRight-ButtonDepth;
           WinFillRect(HPSTemp,rect,CLR_white);

           Rect:=rclButton;
           rect.yTop:=rect.yBottom+ButtonDepth;
           WinFillRect(HPSTemp,rect,CLR_white);

           WinReleasePS(HPSTemp);
        end;
        WM_BUTTON1UP:BEGIN
           hwndOwner:=WinQueryWindow(Window,QW_OWNER);
           WinSendMsg(Window,
                      SM_SETHANDLE,
                      WinSendMsg(window,SM_QUERYHANDLE,0,0),
                      0);
           WinPostMsg(hwndOwner,
                      WM_COMMAND,
                      tbItemD^.NormalID,
                      MPFROM2SHORT(tbItemD^.NormalID,CMDSRC_OTHER));
        END;
    END;
    result:=TbItemD^.pOldProc(Window, msg, mp1, mp2);
@


2.0
log
@ボタンクラス化への伏線
@
text
@d19 1
a19 1
    TK_VERSION      ='$Revision: 1.9 $';  (* Toolkit version *)
a90 2
        isHilight,isCapture:BOOLEAN;
        pOldProc:FNWP;
d222 8
a229 1

d1125 31
d1172 1
d1270 3
a1272 15
            GenResIDStr(cButtText,tbItem^.NormalID);
            TbCtlD^.hItems[lCount]:=WinCreateWindow(hwndTb,
                                                    WC_STATIC,
                                                    cButtText,
                                                    SS_BITMAP,
                                                    -1,
                                                    -1,
                                                    -1,
                                                    -1,
                                                    hWndOwner,
                                                    HWND_TOP,
                                                    tbItem^.NormalID,
                                                    NIL,
                                                    NIL);

d1274 1
a1274 7
            inc(tmpItemD,lCount);
            @@tmpItemD^.pOldProc:=WinSubclassWindow(TbCtlD^.hItems[lCount],BtProc);
            tmpItemD^.isCapture:=FALSE;
            tmpItemD^.isHilight:=FALSE;
            tmpItemD^.NormalID:=TBItem^.normalID;
            tmpItemD^.cText:=TBItem^.cText;
            WinSetWindowULong(TbCtlD^.hItems[lCount],QWL_USER,ULONG(tmpItemD))
d1319 1
a1319 1
    TbItemD    :PTbItemData;
d1348 1
a1348 1
    TbItemD  :=PTbItemData(WinQueryWindowULong(Window,QWL_USER));
@


1.9
log
@リソースをプログラム中に書くように変更
@
text
@d19 1
a19 1
    TK_VERSION      ='$Revision$';  (* Toolkit version *)
@


1.8
log
@ 定義を変えた
@
text
@d19 1
a19 1
    TK_VERSION      ='0.7b';  (* Toolkit version *)
d84 1
a84 1
    
d90 2
a91 1
        cText   :ARRAY [0..TB_BUBBLE_SIZE-1] OF CHAR;
a92 1
        isHilight,isCapture:BOOLEAN;
a107 1

d111 1
a111 1
        tbItems  :pTbItemData;
d1123 1
a1123 1
    hwndTb,hwndTemp:HWND;
d1129 1
a1129 1
    TBItemD    :PTbItemData;
d1131 1
a1131 1
    TBItem     :pTBItemData;
d1141 5
a1145 4
    TBItem:=pTb.tbItems;
    WHILE TBItem^.NormalID<>0 DO BEGIN 
        inc(lCount); 
        inc(TBItem,SizeOf(TBItemData)) ;
d1154 1
a1154 1
    getmem(TBItemD,TbItemLen);
d1156 1
a1156 1
    IF TBItemD=NIL THEN BEGIN
d1162 1
a1162 1
    fillchar(TBItemD^,TbItemLen,#0);
d1201 1
a1201 1
        freemem(TBItemD,TbItemLen);
d1216 3
a1218 3
        TBItem:=pTb.tbItems;
        inc(TBItem,lCount*SizeOf(TBItem) );
        IF TBItem^.NormalID=TB_SEPARATOR THEN
d1229 1
a1229 1
                                                      TBItem^.NormalID,
d1233 18
a1250 19
            GenResIDStr(cButtText,TBItem^.NormalID);
            hwndTemp:=WinCreateWindow(hwndTb,
                                      WC_STATIC,
                                      cButtText,
                                      SS_BITMAP,
                                      -1,
                                      -1,
                                      -1,
                                      -1,
                                      hWndOwner,
                                      HWND_TOP,
                                      TBItem^.NormalID,
                                      NIL,
                                      NIL);
            TbCtlD^.hItems[lCount]:=hwndTemp;
            tmpItemD:=TBItemD;
            inc(tmpItemD,lCount*SizeOf(TBItemData));
            @@tmpItemD^.pOldProc:=WinSubclassWindow(TbCtlD^.hItems[lCount],
                                                    BtProc);
d1253 2
d1300 1
a1300 1
    TBItemD    :PTbItemData;
d1329 1
a1329 1
    TBItemD  :=PTbItemData(WinQueryWindowULong(Window,QWL_USER));
d1335 1
a1335 1
                IF TBItemD^.isCapture = FALSE THEN BEGIN
d1337 1
a1337 1
                    TBItemD^.isCapture :=TRUE;
d1339 2
a1340 2
                IF TBItemD^.isHilight=FALSE THEN BEGIN
                    TBItemD^.isHilight:=TRUE;
d1363 1
a1363 1
                IF TBItemD^.isCapture THEN BEGIN
d1365 1
a1365 1
                    TBItemD^.isCapture :=FALSE;
d1367 2
a1368 2
                IF TBItemD^.isHilight THEN BEGIN
                    TBItemD^.isHilight:=FALSE;
d1370 1
a1370 1
                    HiLight:=GpiLoadBitmap(HPSTemp,0,TBItemD^.NormalID,32,32);
d1420 1
a1420 8
                    IF TBItemD^.cText[0]=#0 THEN
                        WinLoadString(Anchor,
                                      0,
                                      WinQueryWindowUShort(Window,QWS_ID),
                                      sizeof(TBItemD^.cText),
                                      TBItemD^.cText);

                    WinSetWindowText(hwndBubbleClient, TBItemD^.cText);
d1426 2
a1427 2
                                    strlen(TBItemD^.cText),
                                    TBItemD^.cText,
d1441 4
a1444 4
                        dec(ptlWork.y,lHight)
                    ELSE BEGIN
                        inc(ptlWork.x,rclButton.xRight-rclButton.xLeft);
                    END;
d1456 1
a1456 1
        WM_BUTTON1DOWN:BEGIN
d1476 1
a1476 1
        END;
d1485 2
a1486 2
                      TBItemD^.NormalID,
                      MPFROM2SHORT(TBItemD^.NormalID,CMDSRC_OTHER));
d1489 1
a1489 1
    result:=TBItemD^.pOldProc(Window, msg, mp1, mp2);
@


1.7
log
@ButtonUpのメッセージを追加
@
text
@d84 24
d112 1
a112 1
        tbItems  :plong;
a226 22
    (* Toolbar data *)

    PTbItemData = ^TbItemData;
    TbItemData  = RECORD
        pOldProc:FNWP;
        cText   :ARRAY [0..TB_BUBBLE_SIZE-1] OF CHAR;
        isHilight,isCapture:BOOLEAN;
        NormalID:ULong;
    END;

    PTbCtlData = ^TbCtlData;
    TbCtlData  = RECORD
        pOldProc  :FNWP;
        hwndParent:HWND;
        lState    :LONGINT;
        lCount    :LONGINT;

        bBubble   :longbool;
        hwndBubble:HWND;
        hwndLast  :HWND;
        hItems    :ARRAY [0..0] OF HWND;
    END;
d1124 1
a1124 1
    hwndTb     :HWND;
d1130 1
a1130 1
    TbItemD    :PTbItemData;
d1132 1
a1132 1
    tbItem     :plong;
d1142 5
a1146 2
    tbItem:=pTb.tbItems;
    WHILE tbItem^<>0 DO BEGIN inc(lCount); inc(tbItem) END;
d1154 1
a1154 1
    getmem(TbItemD,TbItemLen);
d1156 1
a1156 1
    IF TbItemD=NIL THEN BEGIN
d1162 1
a1162 1
    fillchar(TbItemD^,TbItemLen,#0);
d1201 1
a1201 1
        freemem(TbItemD,TbItemLen);
d1216 3
a1218 3
        tbItem:=pTb.tbItems;
        inc(tbItem,lCount);
        IF tbItem^=TB_SEPARATOR THEN
d1229 1
a1229 1
                                                      tbItem^,
d1233 19
a1251 18
            GenResIDStr(cButtText,tbItem^);
            TbCtlD^.hItems[lCount]:=WinCreateWindow(hwndTb,
                                                    WC_STATIC,
                                                    cButtText,
                                                    SS_BITMAP,
                                                    -1,
                                                    -1,
                                                    -1,
                                                    -1,
                                                    hWndOwner,
                                                    HWND_TOP,
                                                    tbItem^,
                                                    NIL,
                                                    NIL);

            tmpItemD:=TbItemD;
            inc(tmpItemD,lCount);
            @@tmpItemD^.pOldProc:=WinSubclassWindow(TbCtlD^.hItems[lCount],BtProc);
a1253 1
            tmpItemD^.NormalID:=tbItem^;
d1299 1
a1299 1
    TbItemD    :PTbItemData;
d1328 1
a1328 1
    TbItemD  :=PTbItemData(WinQueryWindowULong(Window,QWL_USER));
d1334 1
a1334 1
                IF tbItemD^.isCapture = FALSE THEN BEGIN
d1336 1
a1336 1
                    tbItemD^.isCapture :=TRUE;
d1338 2
a1339 2
                IF tbItemD^.isHilight=FALSE THEN BEGIN
                    tbItemD^.isHilight:=TRUE;
d1362 1
a1362 1
                IF tbItemD^.isCapture THEN BEGIN
d1364 1
a1364 1
                    tbItemD^.isCapture :=FALSE;
d1366 2
a1367 2
                IF tbItemD^.isHilight THEN BEGIN
                    tbItemD^.isHilight:=FALSE;
d1369 1
a1369 1
                    HiLight:=GpiLoadBitmap(HPSTemp,0,tbItemD^.NormalID,32,32);
d1419 1
a1419 1
                    IF TbItemD^.cText[0]=#0 THEN
d1423 2
a1424 2
                                      sizeof(TbItemD^.cText),
                                      TbItemD^.cText);
d1426 1
a1426 1
                    WinSetWindowText(hwndBubbleClient, TbItemD^.cText);
d1432 2
a1433 2
                                    strlen(TbItemD^.cText),
                                    TbItemD^.cText,
d1491 2
a1492 2
                      tbItemD^.NormalID,
                      MPFROM2SHORT(tbItemD^.NormalID,CMDSRC_OTHER));
d1495 1
a1495 1
    result:=TbItemD^.pOldProc(Window, msg, mp1, mp2);
@


1.6
log
@キーワードの正規かだけ
@
text
@d577 30
a606 23
  pCtlData :=NIL;
  CellTbD  :=NIL;
  itemCount:=0;
  result   :=0;

  pCtlData:=PCellCtlData(WinQueryWindowULong(Window,QWL_USER));
  IF pCtlData=NIL THEN EXIT;

  CASE Msg OF
    WM_ADJUSTWINDOWPOS:BEGIN
        CellTbD:=pCtlData^.CellTbD;
        Swp    :=PSWP(mp1);

        IF (Swp^.fl AND SWP_ZORDER<>0) AND (CellTbD<>NIL) THEN
        BEGIN
          hwndBehind:=Swp^.hwndInsertBehind;
          WHILE CellTbD<>NIL DO
          BEGIN
            lFlags:=WinSendMsg(CellTbD^.Window,TKM_QUERY_FLAGS,0,0);
            IF lFlags AND TB_ATTACHED=0 THEN
            BEGIN
              WinSetWindowPos(CellTbD^.Window,hwndBehind,0,0,0,0,SWP_ZORDER);
              hwndBehind:=CellTbD^.Window;
d608 7
a614 119
            CellTbD:=CellTbD^.pNext;
          END;
          Swp^.hwndInsertBehind:=hwndBehind;
        END;
      END;
    TKM_SEARCH_PARENT:BEGIN
        IF WinQueryWindowUShort(Window,QWS_ID)=mp1 THEN EXIT;

        IF WinQueryWindowUShort(pCtlData^.hwndPanel1,QWS_ID)=mp1 THEN
          BEGIN result:=MPARAM(Window); EXIT END;
        hwndRC:=HWND(WinSendMsg(pCtlData^.hwndPanel1,TKM_SEARCH_PARENT,mp1,0));
        IF hwndRC<>0 THEN
          BEGIN result:=MPARAM(hwndRC); EXIT END;

        IF WinQueryWindowUShort(pCtlData^.hwndPanel2,QWS_ID)=mp1 THEN
          BEGIN result:=MPARAM(Window); EXIT END;
        hwndRC:=HWND(WinSendMsg(pCtlData^.hwndPanel2,TKM_SEARCH_PARENT,mp1,0));
        IF hwndRC<>0 THEN
          BEGIN result:=MPARAM(hwndRC); EXIT END;

        EXIT;
      END;
    TKM_SEARCH_ID:BEGIN
        CellTbD:=pCtlData^.CellTbD;

        WHILE CellTbD<>NIL DO
        BEGIN
          IF WinQueryWindowUShort(CellTbD^.Window,QWS_ID)=mp1 THEN
            BEGIN result:=MPARAM(CellTbD^.Window); EXIT END;

          hwndRC:=HWND(WinSendMsg(CellTbD^.Window,TKM_SEARCH_ID,mp1,0));
          IF hwndRC<>0 THEN
            BEGIN result:=MPARAM(hwndRC); EXIT END;

          CellTbD:=CellTbD^.pNext;
        END;

        IF WinQueryWindowUShort(Window,QWS_ID)=mp1 THEN
          BEGIN result:=MPARAM(Window); EXIT END;

        IF WinQueryWindowUShort(pCtlData^.hwndPanel1,QWS_ID)=mp1 THEN
          BEGIN result:=MPARAM(pCtlData^.hwndPanel1); EXIT END;
        hwndRC:=HWND(WinSendMsg(pCtlData^.hwndPanel1,TKM_SEARCH_ID,mp1,0));
        IF hwndRC<>0 THEN
          BEGIN result:=MPARAM(hwndRC); EXIT END;

        IF WinQueryWindowUShort(pCtlData^.hwndPanel2,QWS_ID)=mp1 THEN
          BEGIN result:=MPARAM(pCtlData^.hwndPanel2); EXIT END;
        hwndRC:=HWND(WinSendMsg(pCtlData^.hwndPanel2,TKM_SEARCH_ID,mp1,0));
        IF hwndRC<>0 THEN
          BEGIN result:=MPARAM(hwndRC); EXIT END;

        EXIT;
      END;
    WM_QUERYFRAMECTLCOUNT:BEGIN
        itemCount:=pCtlData^.pOldProc(Window,msg,mp1,mp2);
        inc(itemCount,CountControls(pCtlData));
        result:=itemCount;
        EXIT;
      END;
    WM_FORMATFRAME:BEGIN
      Swp     :=NIL;
      usClient:=0;
      hClient :=HWND_TOP;

      itemCount :=pCtlData^.pOldProc(Window,msg,mp1,mp2);
      itemCount2:=CountControls(pCtlData);

      IF (itemCount2=0) OR (itemCount<1) THEN
      BEGIN
        result:=itemCount;
        EXIT;
      END;

      Swp :=PSWP(mp1);
      cSwp:=Swp;

      usClient:=itemCount-1;
      inc(cSwp,usClient);
      hClient :=cSwp^.wnd;

      (*
      ** Cutting client window.
      ** If there are any attached toolbars, cut client window
      ** regarding to attachment type
      *)

      (* Toolbars attached to top and bottom sides *)

      CellTbD:=pCtlData^.CellTbD;

      WHILE CellTbD<>NIL DO
      BEGIN
        lFlags:=WinSendMsg(CellTbD^.Window,TKM_QUERY_FLAGS,0,0);

        IF lFlags AND TB_ATTACHED=0 THEN
        BEGIN
          CellTbD:=CellTbD^.pNext;
          continue;
        END;

        RecalcTbDimensions(CellTbD^.Window,@@ptlSize);
        tSwp:=Swp;
        inc(tSwp,itemCount);

        CASE lFlags AND TB_ATTACHED OF
          TB_ATTACHED_TP:BEGIN
              tSwp^.x :=cSwp^.x;
              tSwp^.y :=cSwp^.y+cSwp^.cy-ptlSize.y;
              tSwp^.cx:=cSwp^.cx;
              tSwp^.cy:=ptlSize.y;
              tSwp^.fl:=SWP_SIZE OR SWP_MOVE OR SWP_SHOW;

              tSwp^.wnd:=CellTbD^.Window;
              tSwp^.hwndInsertBehind:=hClient;
              hClient:=tSwp^.wnd;

              dec(cSwp^.cy,ptlSize.y);
              inc(itemCount);
d616 7
a622 14
          TB_ATTACHED_BT:BEGIN
              tSwp^.x :=cSwp^.x;
              tSwp^.y :=cSwp^.y;
              tSwp^.cx:=cSwp^.cx;
              tSwp^.cy:=ptlSize.y;
              tSwp^.fl:=SWP_SIZE OR SWP_MOVE OR SWP_SHOW;

              tSwp^.wnd:=CellTbD^.Window;
              tSwp^.hwndInsertBehind:=hClient;
              hClient:=tSwp^.wnd;

              dec(cSwp^.cy,ptlSize.y);
              inc(cSwp^.y ,ptlSize.y);
              inc(itemCount);
a623 11
        END;
        CellTbD:=CellTbD^.pNext;
      END;

      (*Toolbars attached to left and right sides*)

      CellTbD:=pCtlData^.CellTbD;

      WHILE CellTbD<>NIL DO
      BEGIN
        lFlags:=WinSendMsg(CellTbD^.Window,TKM_QUERY_FLAGS,0,0);
d625 3
a627 25
        IF lFlags AND TB_ATTACHED=0 THEN
        BEGIN
          CellTbD:=CellTbD^.pNext;
          continue;
        END;

        RecalcTbDimensions(CellTbD^.Window,@@ptlSize);
        tSwp:=Swp;
        inc(tSwp,itemCount);

        CASE lFlags AND TB_ATTACHED OF
          TB_ATTACHED_LT:BEGIN
              tSwp^.x :=cSwp^.x;
              tSwp^.y :=cSwp^.y;
              tSwp^.cx:=ptlSize.x;
              tSwp^.cy:=cSwp^.cy;
              tSwp^.fl:=SWP_SIZE OR SWP_MOVE OR SWP_SHOW;

              tSwp^.wnd:=CellTbD^.Window;
              tSwp^.hwndInsertBehind:=hClient;
              hClient:=tSwp^.wnd;

              dec(cSwp^.cx,ptlSize.x);
              inc(cSwp^.x ,ptlSize.x);
              inc(itemCount);
d629 7
a635 13
          TB_ATTACHED_RT:BEGIN
              tSwp^.x :=cSwp^.x+cSwp^.cx-ptlSize.x;
              tSwp^.y :=cSwp^.y;
              tSwp^.cx:=ptlSize.x;
              tSwp^.cy:=cSwp^.cy;
              tSwp^.fl:=SWP_SIZE OR SWP_MOVE OR SWP_SHOW;

              tSwp^.wnd:=CellTbD^.Window;
              tSwp^.hwndInsertBehind:=hClient;
              hClient:=tSwp^.wnd;

              dec(cSwp^.cx,ptlSize.x);
              inc(itemCount);
a636 3
        END;
        CellTbD:=CellTbD^.pNext;
      END;
d638 4
a641 10
      (*
      ** Placing panels.
      ** Remember client rect for future use
      ** They will save time when we start moving splitbar
      *)

      pCtlData^.rclBnd.xLeft   := cSwp^.x;
      pCtlData^.rclBnd.xRight  := cSwp^.x+cSwp^.cx;
      pCtlData^.rclBnd.yTop    := cSwp^.y+cSwp^.cy;
      pCtlData^.rclBnd.yBottom := cSwp^.y;
d643 4
a646 24
      IF (pCtlData^.hwndPanel1=0) OR (pCtlData^.hwndPanel2=0) OR
        (pCtlData^.lType AND CELL_HIDE<>0) THEN
      BEGIN
        (*
        **single subwindow;
        **In this case we don't need a client window,
        **because of lack of splitbar.
        **Just copy all data from pSWP[usClient]
        **and replace some part of it
        *)

        tSwp:=Swp;
        inc(tSwp,itemCount);
        tSwp^:=cSwp^;
        tSwp^.fl:=tSwp^.fl OR SWP_MOVE OR SWP_SIZE;
        tSwp^.hwndInsertBehind:=HWND_TOP;
        cSwp^.cy:=0;

        tSwp^.wnd:=0;

        IF (pCtlData^.hwndPanel1<>0) AND (pCtlData^.lType AND CELL_HIDE_1=0) THEN
          tSwp^.wnd:=pCtlData^.hwndPanel1;
        IF (pCtlData^.hwndPanel2<>0) AND (pCtlData^.lType AND CELL_HIDE_2=0) THEN
          tSwp^.wnd:=pCtlData^.hwndPanel2;
d648 3
a650 1
        (* Increase number of controls *)
d652 2
a653 12
        IF tSwp^.wnd<>0 THEN
        BEGIN
          tSwp^.hwndInsertBehind:=hClient;
          hClient:=tSwp^.wnd;
          inc(itemCount);
        END;
      END ELSE
      BEGIN
        usPanel1:=Swp; inc(usPanel1,itemCount);
        usPanel2:=Swp; inc(usPanel2,itemCount+1);
        usWidth1:=0;
        usWidth2:=0;
d655 2
a656 3
        (* Just like case of one panel *)
        usPanel1^:=cSwp^;
        usPanel2^:=cSwp^;
d658 24
a681 2
        usPanel1^.fl:=usPanel1^.fl OR SWP_MOVE OR SWP_SIZE;
        usPanel2^.fl:=usPanel2^.fl OR SWP_MOVE OR SWP_SIZE;
d683 2
a684 2
        usPanel1^.hwndInsertBehind:=hClient;
        usPanel2^.hwndInsertBehind:=pCtlData^.hwndPanel1;
d686 1
a686 23
        usPanel1^.wnd:=pCtlData^.hwndPanel1;
        usPanel2^.wnd:=pCtlData^.hwndPanel2;

        hClient:=pCtlData^.hwndPanel2;

        IF pCtlData^.lType AND CELL_VSPLIT<>0 THEN
        BEGIN
          IF (pCtlData^.lType AND CELL_FIXED<>0) AND
            (pCtlData^.lType AND (CELL_SIZE1 OR CELL_SIZE2)<>0) AND
              (pCtlData^.lSize>0) THEN
          BEGIN
            (* Case of fixed panel with exact size *)

            IF pCtlData^.lType AND CELL_SIZE1<>0 THEN
            BEGIN
              usWidth1:=pCtlData^.lSize;
              usWidth2:=cSwp^.cx-usWidth1;
            END ELSE
            BEGIN
              usWidth2:=pCtlData^.lSize;
              usWidth1:=cSwp^.cx-usWidth2;
            END;
          END ELSE
d688 2
a689 2
            usWidth1:=(cSwp^.cx*pCtlData^.lSplit) div 100;
            usWidth2:=cSwp^.cx-usWidth1;
d692 2
a693 22
          IF pCtlData^.lType AND CELL_SPLITBAR<>0 THEN
          BEGIN
            IF pCtlData^.lType AND CELL_SIZE1=0 THEN dec(usWidth2,SPLITBAR_WIDTH)
              ELSE dec(usWidth1,SPLITBAR_WIDTH);

            cSwp^.cx:=SPLITBAR_WIDTH;
            cSwp^.x :=cSwp^.x + usWidth1;
          END ELSE
          BEGIN
            cSwp^.cx:=0;
            cSwp^.cy:=0;
          END;
          usPanel1^.cx:=usWidth1;
          inc(usPanel2^.x,usWidth1+cSwp^.cx);
          usPanel2^.cx:=usWidth2;
        END ELSE
        BEGIN
          IF (pCtlData^.lType AND CELL_FIXED<>0) AND
            (pCtlData^.lType AND (CELL_SIZE1 OR CELL_SIZE2)<>0) AND
              (pCtlData^.lSize>0) THEN
          BEGIN
            (* Case of fixed panel with exact size *)
d695 108
a802 13
            IF pCtlData^.lType AND CELL_SIZE1<>0 THEN
            BEGIN
              usWidth1:=pCtlData^.lSize;
              usWidth2:=cSwp^.cy-usWidth1;
            END ELSE
            BEGIN
              usWidth2:=pCtlData^.lSize;
              usWidth1:=cSwp^.cy-usWidth2;
            END;
          END ELSE
          BEGIN
            usWidth1:=(cSwp^.cy*pCtlData^.lSplit) div 100;
            usWidth2:=cSwp^.cy-usWidth1;
d805 142
a946 11
          IF pCtlData^.lType AND CELL_SPLITBAR<>0 THEN
          BEGIN
            IF pCtlData^.lType AND CELL_SIZE1=0 THEN dec(usWidth2,SPLITBAR_WIDTH)
              ELSE dec(usWidth1,SPLITBAR_WIDTH);

            cSwp^.cy:=SPLITBAR_WIDTH;
            cSwp^.y :=cSwp^.y + usWidth1;
          END ELSE
          BEGIN
            cSwp^.cx:=0;
            cSwp^.cy:=0;
d948 5
a952 11
          usPanel1^.cy:=usWidth1;
          inc(usPanel2^.y,usWidth1+cSwp^.cy);
          usPanel2^.cy:=usWidth2;
        END;
        inc(itemCount,2);
      END;
      result:=itemCount;
      EXIT
    END;
  END;
  result:=pCtlData^.pOldProc(Window,msg,mp1,mp2);
d1295 1
a1295 1
    hwndFrame  :HWND;
d1336 1
a1336 1
                    
d1340 1
a1340 1
                    
d1344 1
a1344 1
                    
d1348 1
a1348 1
                    
d1352 1
a1352 1
                    
d1456 32
@


1.5
log
@ハイライト処理はやめてボタンが飛び出すダケに
@
text
@d209 1
a209 1
        isHilight,isCapture:boolean;
d1122 1
a1122 1
    cButtText :array[byte] of char;
d1295 4
a1298 4
    function isRectIn:boolean;
    var
        mCx,mCy:integer;
    begin
d1301 2
a1302 2
        IF (RclButton.yBottom<mCy) and (rclButton.yTop>mCy) and
           (rclButton.xLeft<mCx) and (rclButton.xRight>mCx)
d1305 1
a1305 1
        else
d1307 1
a1307 1
    end;
@


1.4
log
@とりあえずボタン用の描画枠を描く
@
text
@d13 1
a13 1
{$I multibar.inc}
d15 2
a88 1
        HiLightID:ULong;
a209 1
        HiLightID:ULong;
a1236 1
            tmpItemD^.HiLightID:=IDB_HiLight;
d1293 1
a1293 1
    rclButton  :RECTL;
d1325 17
a1341 7
                    HiLight:=GpiLoadBitmap(HPSTemp,0,tbItemD^.HiLightID,32,32);
                    WinSendMsg(Window,SM_SETHANDLE,HiLight,0);
                    Inc(rclButton.yBottom,1);
                    Inc(rclButton.xLeft,1);
                    Dec(rclButton.yTop,1);
                    Dec(rclButton.xRight,1);
                    WinDrawBorder(HPSTemp,rclButton,1,1,CLR_BLACK,CLR_GREEN,DB_AREAATTRS);
@


1.3
log
@タイマー処理を削除
@
text
@d1328 5
@


1.2
log
@ハイライト復帰処理を動作するように
@
text
@a1315 8
        WM_TIMER:BEGIN
            IF TbCtlD^.hwndBubble<>0 THEN
            BEGIN
                WinDestroyWindow(TbCtlD^.hwndBubble);
                TbCtlD^.hwndBubble:=0;
                WinStopTimer(Anchor,Window,1);
            END;
        END;
d1343 5
a1357 1
                    WinStopTimer(Anchor,TbCtlD^.hwndLast,1);
a1428 2

                    WinStartTimer(Anchor, Window, 1, 1500);
@


1.1
log
@Initial revision
@
text
@d1122 1
a1122 2
    cButtText  :ARRAY [BYTE] OF CHAR;
    cName:pChar;
a1123 1
    isNuStyle:boolean;
a1124 2
    isNuStyle:=FALSE;
    IF (pTB.lType and TB_NuStyle)>0 THEN isNuStyle:=TRUE;
a1217 7
            flCreate:=BS_PUSHBUTTON OR BS_BITMAP OR
                      BS_AUTOSIZE OR BS_NOPOINTERFOCUS;
            cName:=WC_BUTTON;
            IF isNuStyle THEN BEGIN
                flCreate:=SS_BITMAP;
                cName:=WC_STATIC;
            END;
d1219 1
a1219 1
                                                    cName,
d1221 1
a1221 1
                                                    flCreate,
d1296 14
d1325 26
a1350 6
            IF tbItemD^.isHilight=FALSE THEN BEGIN
                tbItemD^.isHilight:=TRUE;
                HPSTemp:=WinGetPS(Window);
                HiLight:=GpiLoadBitmap(HPSTemp,0,tbItemD^.HiLightID,32,32);
                WinSendMsg(Window,SM_SETHANDLE,HiLight,0);
                WinReleasePS(HPSTemp);
a1422 1
                        WinQueryWindowRect(Window,rclButton);
@
