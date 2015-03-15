program test;
uses uGetOpt,SysUtils;
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
    Writeln(' color value $AACCFF=',IntToHex(StrToInt('$AACCFF'),6 ) );
end.

begin
end;
