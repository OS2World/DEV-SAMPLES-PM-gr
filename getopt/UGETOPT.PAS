Unit uGetOpt;
Interface

type
    GetOptClass=Class
        constructor Create(OptSt:string;OptArgSt:string);
        function isEnd:boolean;
        function isOptEnd:boolean;
        function GetOptCh:Char;
        function GetOptArg:string;
        function GetNextArg:String;
      private
        ArgPos:integer;
        OptAry,OptArgAry:string;
        OptArgStr:string;
    end;
implementation

constructor GetOptClass.Create(OptSt:string;OptArgSt:string);
begin
    OptAry:=OptSt;
    OptArgAry:=OptArgSt;
    ArgPos:=1;
end;

function GetOptClass.isEnd:boolean;
begin
    IF ParamCount<ArgPos THEN BEGIN
        isEnd:=TRUE;
    end
    else
        isEnd:=FALSE;
end;

function GetOptClass.isOptEnd:boolean;
begin
    IF isEnd THEN BEGIN
        isOptEnd:=TRUE;
        exit;
    end;
    if ParamStr(ArgPos)[1]='-' THEN
        isOptEnd:=FALSE
    ELSE
        isOptEnd:=TRUE;
end;

function GetOptClass.GetOptCh:Char;
var
    ch:char;
begin
    IF isOptEnd THEN BEGIN
        GetOptCh:=#0;
        exit;
    end;
    ch:=ParamStr(ArgPos)[2];
    IF pos(ch,OptAry)>0 THEN BEGIN
        GetOptCh:=Ch;
        OptArgStr:='';
    END;
    IF pos(ch,OptArgAry)>0 THEN BEGIN
        GetOptCh:=ch;
        Inc(ArgPos);
        OptArgStr:=ParamStr(ArgPos);
    END;
    inc(ArgPos);
end;

function GetOptClass.GetOptArg:string;
begin
    GetOptArg:=OptArgStr;
end;

function GetOptClass.GetNextArg:string;
begin
    IF ArgPos<=ParamCount THEN
        GetNextArg:=ParamStr(ArgPos)
    ELSE
        GetNextArg:='';
    Inc(ArgPos);
end;
begin
end.
var
    GetOpt:GetOptClass;
    DebugFlag:BOOLEAN;
begin
    DebugFlag:=FALSE;
    GetOpt:=GetOptClass.Create('d','');
    while GetOpt.isOptEnd=FALSE DO BEGIN
        case GetOpt.GetOptCh of
            #0:begin
            end;
            'd':begin
                DebugFlag:=TRUE;
            end;
        end;
    end;
    writeln('Flag=',DebugFlag);
    writeln(' Arg=',GetOpt.GetNextArg);
end.

