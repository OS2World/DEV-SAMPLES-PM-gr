PROGRAM Base;
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
                         pPanel1:@cdLeftPane;
                         pPanel2:@cdRightPane;
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
                         pPanel1:@Panel1; pPanel2:@rPanel;
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
                      tbItems:@mainItems);

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
                        @lColor);
        WinSendMsg(NuTBList.GetTBClass(IDB_FILEOPEN).NuWnd,
                   WM_ENABLE,Ord(FALSE),0);
        // -------------------------------
        WHILE WinGetMsg(Anchor,msg,0,0,0) DO WinDispatchMsg(Anchor,msg);
        // -------------------------------
        WinDestroyWindow(hwndFrame);
    END;

    WinDestroyMsgQueue(mq);
    WinTerminate(Anchor);
END.


