head	2.6;
access;
symbols;
locks;
comment	@ * @;


2.6
date	2007.05.13.07.07.24;	author Average;	state Exp;
branches;
next	2.5;

2.5
date	2007.05.12.12.05.03;	author Average;	state Exp;
branches;
next	2.4;

2.4
date	2006.11.09.14.52.31;	author Average;	state Exp;
branches;
next	2.3;

2.3
date	2006.10.18.14.27.18;	author Average;	state Exp;
branches;
next	2.2;

2.2
date	2006.10.12.15.13.56;	author Average;	state Exp;
branches;
next	2.1;

2.1
date	2006.10.10.12.29.39;	author Average;	state Exp;
branches;
next	2.0;

2.0
date	2006.10.09.08.47.31;	author Average;	state Exp;
branches;
next	1.5;

1.5
date	2006.10.05.14.55.40;	author Average;	state Exp;
branches;
next	1.4;

1.4
date	2006.10.04.16.14.34;	author Average;	state Exp;
branches;
next	1.3;

1.3
date	2006.10.03.15.01.45;	author Average;	state Exp;
branches;
next	1.2;

1.2
date	2006.10.01.17.02.23;	author Average;	state Exp;
branches;
next	1.1;

1.1
date	2006.10.01.15.35.31;	author Average;	state Exp;
branches;
next	;


desc
@@


2.6
log
@定義がまちがってましたー
@
text
@PROGRAM Base;
USES
os2def,os2pmapi,NuCell,strings;

{$PMTYPE PM}

{$I base.inc}

{$R base.res}

(* Local procedures *)

VAR
    hwndFrame:HWND;
    hwndTb   :HWND;

FUNCTION MainClientProc(Window: HWnd; Msg: ULong; Mp1,Mp2: MParam): MResult; cdecl; forward;

(* Static Variables *)

CONST
    cdLeftPane :CellDef=(lType:CELL_WINDOW;
                         pszClass:WC_LISTBOX;
                         pszName:'List';
                         ulStyle:LS_NOADJUSTPOS OR WS_VISIBLE;
                         ulID:ID_LIST);

    cdRightPane:CellDef=(lType:CELL_WINDOW;
                         pszClass:WC_MLE;
                         pszName:'Sample Text';
                         ulStyle:MLS_BORDER OR WS_VISIBLE;
                         ulID:ID_MLE);

    rPanel     :CellDef=(lType:CELL_VSPLIT OR CELL_SPLITBAR OR CELL_SPLIT30x70;
                         pszClass:NIL;
                         pszName:'Subwindow';
                         ulStyle:WS_VISIBLE;
                         ulID:ID_TOP;
                         pPanel1:@@cdLeftPane;
                         pPanel2:@@cdRightPane;
                         pClassProc:NIL;
                         pClientClassProc:NIL);

    Panel1    :CellDef =(lType:CELL_WINDOW;
                         pszClass:'StatusLine';
                         pszName:'';
                         ulStyle:WS_VISIBLE;
                         ulID:ID_STATUS);

    mainClient :CellDef=(lType:CELL_HSPLIT OR CELL_FIXED OR CELL_SIZE1;
                         pszClass:NIL;
                         pszName:'Status Line Sample';
                         ulStyle:FCF_TITLEBAR OR FCF_SYSMENU OR
                                 FCF_MENU OR FCF_MINMAX OR
                                 FCF_TASKLIST OR FCF_SIZEBORDER;
                         ulID:MAIN_FRAME;
                         pPanel1:@@Panel1; pPanel2:@@rPanel;
                         pClassProc:NIL;          // Frame subclass proc
                         pClientClassProc:MainClientProc;
                                                 // Client subclass proc
                         lSize:20                         // Status line hight
                            );

      mainItems:ARRAY [0..11] OF TBItemData=(
            (NuID:IDB_FILENEW ;cText:' Create new file '),
            (NuID:IDB_FILEOPEN;cText:' Open existing file '),
            (NuID:IDB_FILESAVE;cText:' Save file '),
            (NuID:IDB_FILSAVAS;cText:' Save file As New Name'),
            (NuID:TB_SEPARATOR;cText:''),
            (NuID:IDB_EXIT    ;cText:' Exit Application '),
            (NuID:TB_SEPARATOR;cText:''),
            (NuID:IDB_EDITCOPY;cText:' Copy Text '),
            (NuID:IDB_EDITCUT ;cText:' Cut Text'),
            (NuID:IDB_EDITFIND;cText:' Find Text'),
            (NuID:IDB_EDITFNNX;cText:' Find Next Text'),
            (NuID:0)
      );

      mainTb:TbDef = (lType:TB_VERTICAL OR TB_ATTACHED_TP OR
                            TB_BUBBLE ;
                      ulID:ID_TOOLBAR;
                      tbItems:@@mainItems);

CONST
    MLE_INDEX = 0;

CONST
    CVis:BOOLEAN=true;

FUNCTION MainClientProc(Window: HWnd; Msg: ULong; Mp1,Mp2: MParam): MResult;
VAR
    pWCtlData:PWindowCellCtlData;
BEGIN
    pWCtlData:=PWindowCellCtlData(WinQueryWindowULong(Window,QWL_USER));
    result   :=0;
    CASE msg OF
        WM_COMMAND:BEGIN
            CASE SHORT1FROMMP(mp1) OF
                IDB_EXIT:BEGIN
                    WinPostMsg(Window, WM_QUIT, 0, 0);
                END;
                IDB_FILENEW:BEGIN
                    IF hwndTB<>NullHandle THEN BEGIN
                        SetToolbarState(hwndTB,TB_FLOATING);
                        WinDestroyWindow(hwndTB);
                        hwndTB:=NullHandle;
                    END;
                END;
            END;
        END;
        WM_CLOSE:BEGIN
            WinPostMsg(Window, WM_QUIT, 0, 0);
        END
        ELSE BEGIN
            IF pWCtlData<>NIL THEN
                result:=pWCtlData^.pOldProc(Window, msg, mp1, mp2)
            ELSE
                result:=WinDefWindowProc(Window, msg, mp1, mp2);
        END;
    END;
END;

FUNCTION StatusLineProc(Window: HWnd; Msg: ULong; Mp1,Mp2: MParam): MResult; cdecl;
VAR hpsPaint :HPS;
    rclPaint :RECTL;
    ptlWork  :POINTL;
BEGIN
  result:=0;
  CASE msg OF
    WM_PAINT:BEGIN
        hpsPaint:= WinBeginPaint(Window, 0, NIL);
        WinQueryWindowRect(Window, rclPaint);

        WinFillRect(hpsPaint, rclPaint, CLR_PALEGRAY);

        GpiSetColor(hpsPaint, CLR_BLACK);

        ptlWork.x:= rclPaint.xLeft      ;
        ptlWork.y:= rclPaint.yBottom    ;
        GpiMove(hpsPaint, ptlWork);
        ptlWork.y:= rclPaint.yTop    - 2;
        GpiLine(hpsPaint, ptlWork);
        ptlWork.x:= rclPaint.xRight  - 1;
        GpiLine(hpsPaint, ptlWork);

        GpiSetColor(hpsPaint,CLR_WHITE);

        ptlWork.y:= rclPaint.yBottom    ;
        GpiLine(hpsPaint, ptlWork);
        ptlWork.x:= rclPaint.xLeft      ;
        GpiLine(hpsPaint, ptlWork);

        dec(rclPaint.yTop,3);
        inc(rclPaint.yBottom);
        dec(rclPaint.xRight,2);
        inc(rclPaint.xLeft);

        WinDrawText(hpsPaint, -1, 'Status message', rclPaint, CLR_BLACK, 0, DT_LEFT OR DT_VCENTER);
        WinEndPaint(hpsPaint);
        EXIT;
      END;
  END;
  result:=WinDefWindowProc(Window, msg, mp1, mp2);
END;

VAR Anchor   :HAB;
    mq       :HMQ;
    msg      :QMSG;
    hwndTmp  :HWND;
    swp      :os2pmapi.SWP;
    hwndSubframe:HWND;
CONST
    lColor   :LONG=CLR_PALEGRAY;
    cFontMy  :pchar='8.Helv';
BEGIN
    Anchor:=WinInitialize(0);
    IF Anchor=0 THEN HALT(-1);

    mq:=WinCreateMsgQueue(Anchor, 0);

    IF mq=0 THEN BEGIN
        WinTerminate(Anchor);
        HALT(-2);
    END;

    ToolkitInit(Anchor);

    WinRegisterClass(Anchor,
                     'StatusLine',
                     StatusLineProc,
                     CS_SIZEREDRAW,
                     sizeof(ULONG));

    WinQueryWindowPos(HWND_DESKTOP, swp);

    hwndFrame:=CreateCell(mainClient, HWND_DESKTOP, 0);

    IF hwndFrame<>0 THEN BEGIN
        hwndSubframe:=CellWindowFromID(hwndFrame, ID_LPANE);

        WinSetWindowPos(hwndFrame,
                        NULLHANDLE,
                        swp.x + swp.cx div 8,
                        swp.y + swp.cy div 8,
                        (swp.cx div 4) * 3,
                        (swp.cy div 4) * 3,
                        SWP_ACTIVATE OR SWP_MOVE OR SWP_SIZE OR SWP_SHOW);

        hwndTB:=NullHandle;
        hwndTB:=CreateToolbar(hwndFrame,mainTb);


        (* Set status line font *)

        hwndTmp:=CellWindowFromID(hwndFrame, ID_STATUS);

        WinSetPresParam(hwndTmp, PP_FONTNAMESIZE, strlen(cFontMy)+1, cFontMy);

        (* Set MLE color *)

        hwndTmp:= CellWindowFromID(hwndFrame, ID_MLE);

        WinSendMsg(hwndTmp, MLM_SETBACKCOLOR, CLR_PALEGRAY, MLE_INDEX);

        (* Set list color *)

        hwndTmp:= CellWindowFromID(hwndFrame, ID_LIST);

        WinSetPresParam(hwndTmp,
                        PP_BACKGROUNDCOLORINDEX,
                        sizeof(lColor),
                        @@lColor);

        // -------------------------------
        WHILE WinGetMsg(Anchor,msg,0,0,0) DO WinDispatchMsg(Anchor,msg);
        // -------------------------------
        WinDestroyWindow(hwndFrame);
    END;

    WinDestroyMsgQueue(mq);
    WinTerminate(Anchor);
END.


@


2.5
log
@*** empty log message ***
@
text
@d71 1
a71 1
            (NuID:TB_ENTRYFIELD;cText:''),
@


2.4
log
@ツールバーの出し入れ自由に
@
text
@d71 1
a71 1
            (NuID:TB_SEPARATOR;cText:''),
@


2.3
log
@ポップアップを改良
@
text
@d13 3
a15 1
VAR hwndFrame:HWND;
d103 5
a107 2
                    CVis:=NOT CVis;
                    ShowCell(hwndFrame,ID_LIST,CVis);
a168 1
    hwndTb   :HWND;
d209 3
a211 1
        CreateToolbar(hwndFrame,mainTb);
@


2.2
log
@ Editorを入れ込めるよーに。
@
text
@d62 13
a74 14
      mainItems:ARRAY [0..12] OF TBItemData=(
            (NormalID:IDB_FILENEW ;cText:' Create new file '),
            (NormalID:IDB_FILEOPEN;cText:' Open existing file '),
            (NormalID:IDB_FILESAVE;cText:' Save file '),
            (NormalID:IDB_FILSAVAS;cText:' Save file As New Name'),
            (NormalID:TB_SEPARATOR;cText:''),
            (NormalID:IDB_EXIT    ;cText:' Exit Application '),
            (NormalID:TB_SEPARATOR;cText:''),
            (NormalID:IDB_EDITCOPY;cText:' Copy Text '),
            (NormalID:IDB_EDITCUT ;cText:' Cut Text'),
            (NormalID:IDB_EDITFIND;cText:' Find Text'),
            (NormalID:IDB_EDITFNNX;cText:' Find Next Text'),
            (NormalID:TB_EDITCTRL;cText:''),
            (NormalID:0)
d78 1
a78 1
                            TB_BUBBLE OR TB_NuStyle;
@


2.1
log
@クラス化の端緒
@
text
@d62 1
a62 1
      mainItems:ARRAY [0..11] OF TBItemData=(
d74 1
@


2.0
log
@ボタンクラス化への伏線
@
text
@d114 1
a114 1
        end;
@


1.5
log
@リソースをプログラム中に書くように変更
@
text
@@


1.4
log
@ 定義を変えた
@
text
@d63 13
a75 13
             (NormalID:IDB_FILENEW; cText:' Create new file '),
             (NormalID:IDB_FILEOPEN;cText:' Open existing file '),
             (NormalID:IDB_FILESAVE;cText:' Save file '),
             (NormalID:IDB_FILSAVAS;cText:' Save file with new name '),
             (NormalID:TB_SEPARATOR),
             (NormalID:IDB_EXIT    ;cText:'Exit app '),
             (NormalID:TB_SEPARATOR),
             (NormalID:IDB_EDITCOPY;cText:' Copy selection to clipboard '), 
             (NormalID:IDB_EDITCUT ;cText:' Cut selection to clipboard  '),
             (NormalID:IDB_EDITFIND;cText:' Search '),
             (NormalID:IDB_EDITFNNX;cText:' Search again '),
             (NormalID:0)
                             );
d114 1
a114 1
        END;
@


1.3
log
@ButtonUpのメッセージを追加
@
text
@d62 14
a75 8
      mainItems:ARRAY [0..11] OF LONGINT=(
                             IDB_FILENEW , IDB_FILEOPEN,
                             IDB_FILESAVE, IDB_FILSAVAS,
                             TB_SEPARATOR,
                             IDB_EXIT    ,
                             TB_SEPARATOR,
                             IDB_EDITCOPY, IDB_EDITCUT ,
                             IDB_EDITFIND, IDB_EDITFNNX, 0);
@


1.2
log
@キーワードの正規かだけ
@
text
@d2 1
a2 1
USES 
d76 2
a77 1
CONST MLE_INDEX = 0;
d79 2
a80 7
FUNCTION OKMsgBox(pszText:pchar):LONGINT;
BEGIN
  result:=WinMessageBox(HWND_DESKTOP, HWND_DESKTOP, pszText, 'Cell Demo', 0,
    MB_OK OR MB_INFORMATION OR MB_APPLMODAL);
END;

CONST CVis:BOOLEAN=true;
d83 2
a84 1
VAR pWCtlData:PWindowCellCtlData;
d86 12
a97 13
  pWCtlData:=PWindowCellCtlData(WinQueryWindowULong(Window,QWL_USER));
  result   :=0;
  CASE msg OF
    WM_COMMAND:BEGIN
        CASE SHORT1FROMMP(mp1) OF
          IDB_EXIT:BEGIN
              WinPostMsg(Window, WM_QUIT, 0, 0);
              EXIT;
            END;
          IDB_FILENEW:BEGIN
              CVis:=NOT CVis;
              ShowCell(hwndFrame,ID_LIST,CVis);
              EXIT;
d100 10
a109 10
      END;
    WM_CLOSE:BEGIN
        WinPostMsg(Window, WM_QUIT, 0, 0);
        EXIT;
      END;
  END;
  IF pWCtlData<>NIL THEN
    result:=pWCtlData^.pOldProc(Window, msg, mp1, mp2)
  ELSE
    result:=WinDefWindowProc(Window, msg, mp1, mp2);
d166 2
a167 2
  Anchor:=WinInitialize(0);
  IF Anchor=0 THEN HALT(-1);
d169 1
a169 1
  mq:=WinCreateMsgQueue(Anchor, 0);
d171 4
a174 5
  IF mq=0 THEN
  BEGIN
    WinTerminate(Anchor);
    HALT(-2);
  END;
d176 1
a176 1
  ToolkitInit(Anchor);
d178 5
a182 1
  WinRegisterClass(Anchor, 'StatusLine', StatusLineProc, CS_SIZEREDRAW, sizeof(ULONG));
d184 1
a184 1
  WinQueryWindowPos(HWND_DESKTOP, swp);
d186 1
a186 1
  hwndFrame:=CreateCell(mainClient, HWND_DESKTOP, 0);
d188 2
a189 3
  IF hwndFrame<>0 THEN
  BEGIN
    hwndSubframe:=CellWindowFromID(hwndFrame, ID_LPANE);
d191 7
a197 3
    WinSetWindowPos(hwndFrame, NULLHANDLE, swp.x + swp.cx div 8,
      swp.y + swp.cy div 8, (swp.cx div 4) * 3, (swp.cy div 4) * 3,
        SWP_ACTIVATE OR SWP_MOVE OR SWP_SIZE OR SWP_SHOW);
d199 1
a199 1
    CreateToolbar(hwndFrame,mainTb);
d201 1
a201 1
    (* Set status line font *)
d203 1
a203 1
    hwndTmp:=CellWindowFromID(hwndFrame, ID_STATUS);
d205 1
a205 1
    WinSetPresParam(hwndTmp, PP_FONTNAMESIZE, strlen(cFontMy)+1, cFontMy);
d207 1
a207 1
    (* Set MLE color *)
d209 1
a209 1
    hwndTmp:= CellWindowFromID(hwndFrame, ID_MLE);
d211 1
a211 1
    WinSendMsg(hwndTmp, MLM_SETBACKCOLOR, CLR_PALEGRAY, MLE_INDEX);
d213 1
a213 1
    (* Set list color *)
d215 1
a215 1
    hwndTmp:= CellWindowFromID(hwndFrame, ID_LIST);
d217 4
a220 1
    WinSetPresParam(hwndTmp, PP_BACKGROUNDCOLORINDEX, sizeof(lColor), @@lColor);
d222 5
a226 5
    // -------------------------------
    WHILE WinGetMsg(Anchor,msg,0,0,0) DO WinDispatchMsg(Anchor,msg);
    // -------------------------------
    WinDestroyWindow(hwndFrame);
  END;
d228 2
a229 2
  WinDestroyMsgQueue(mq);
  WinTerminate(Anchor);
@


1.1
log
@Initial revision
@
text
@d1 2
a2 2
program Base;
uses 
d13 1
a13 1
var hwndFrame:HWND;
d15 1
a15 1
function MainClientProc(Window: HWnd; Msg: ULong; Mp1,Mp2: MParam): MResult; cdecl; forward;
d19 1
a19 1
const
d23 1
a23 1
                         ulStyle:LS_NOADJUSTPOS or WS_VISIBLE;
d29 1
a29 1
                         ulStyle:MLS_BORDER or WS_VISIBLE;
d32 2
a33 2
    rPanel     :CellDef=(lType:CELL_VSPLIT or CELL_SPLITBAR or CELL_SPLIT30x70;
                         pszClass:nil;
d39 2
a40 2
                         pClassProc:nil;
                         pClientClassProc:nil);
d48 2
a49 2
    mainClient :CellDef=(lType:CELL_HSPLIT or CELL_FIXED or CELL_SIZE1;
                         pszClass:nil;
d51 3
a53 3
                         ulStyle:FCF_TITLEBAR or FCF_SYSMENU or
                                 FCF_MENU or FCF_MINMAX or
                                 FCF_TASKLIST or FCF_SIZEBORDER;
d56 1
a56 1
                         pClassProc:nil;          // Frame subclass proc
d62 1
a62 1
      mainItems:array [0..11] of longint=(
d71 2
a72 2
      mainTb:TbDef = (lType:TB_VERTICAL or TB_ATTACHED_TP or
                            TB_BUBBLE or TB_NuStyle;
d76 1
a76 1
const MLE_INDEX = 0;
d78 2
a79 2
function OKMsgBox(pszText:pchar):longint;
begin
d81 2
a82 2
    MB_OK or MB_INFORMATION or MB_APPLMODAL);
end;
d84 1
a84 1
const CVis:boolean=true;
d86 3
a88 3
function MainClientProc(Window: HWnd; Msg: ULong; Mp1,Mp2: MParam): MResult;
var pWCtlData:PWindowCellCtlData;
begin
d91 4
a94 4
  case msg of
    WM_COMMAND:begin
        case SHORT1FROMMP(mp1) of
          IDB_EXIT:begin
d96 4
a99 4
              exit;
            end;
          IDB_FILENEW:begin
              CVis:=not CVis;
d101 5
a105 5
              exit;
            end;
        end;
      end;
    WM_CLOSE:begin
d107 4
a110 4
        exit;
      end;
  end;
  if pWCtlData<>nil then
d112 1
a112 1
  else
d114 1
a114 1
end;
d116 2
a117 2
function StatusLineProc(Window: HWnd; Msg: ULong; Mp1,Mp2: MParam): MResult; cdecl;
var hpsPaint :HPS;
d120 1
a120 1
begin
d122 3
a124 3
  case msg of
    WM_PAINT:begin
        hpsPaint:= WinBeginPaint(Window, 0, nil);
d151 1
a151 1
        WinDrawText(hpsPaint, -1, 'Status message', rclPaint, CLR_BLACK, 0, DT_LEFT or DT_VCENTER);
d153 3
a155 3
        exit;
      end;
  end;
d157 1
a157 1
end;
d159 1
a159 1
var Anchor   :HAB;
d166 1
a166 1
const
d169 1
a169 1
begin
d171 1
a171 1
  if Anchor=0 then halt(-1);
d175 2
a176 2
  if mq=0 then
  begin
d178 2
a179 2
    halt(-2);
  end;
d189 2
a190 2
  if hwndFrame<>0 then
  begin
d195 1
a195 1
        SWP_ACTIVATE or SWP_MOVE or SWP_SIZE or SWP_SHOW);
d218 1
a218 1
    while WinGetMsg(Anchor,msg,0,0,0) do WinDispatchMsg(Anchor,msg);
d221 1
a221 1
  end;
d225 1
a225 1
end.
@
