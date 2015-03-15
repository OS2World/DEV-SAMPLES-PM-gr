unit MiNGutil;

interface

  { Note: Please see following procedures if you want to convert the source
          to other platforms.
            * BSWAP32/BSWAP16 (drop contents if Mac)
            * GETCURRENTSYSTEMTIME (drop if not PC-compatible)

  }

  uses dos;

  {$i mingdef.inc}

  type float = real;
       dword = LongInt;

  procedure DBSWAP32(var a:dword);
  procedure BSWAP16(var a:word);
  procedure DBSWAP16(var a:dword);

  function  Smallest (a,b:longint):longint;
  function  Biggest (a,b:longint):longint;

  function  iYesNo (a:longint):string;
  function  bYesNo (a:boolean):string;

  function  FStr (a:longint):String;

  function  ChunkNameStr (a:dword):string;

  function  CalcGamma (a:dword;ingam,outgam:dword):dword; { uses FPU }
  { 0..255; gamma*100000 }

  function  BitSet (x,n:dword):boolean;  { n=0..31 }

  function  GetCurrentSystemTime:dword; { in ms }

implementation

var start_time          : dword;

function  BitSet (x,n:dword):boolean;

begin
  if (x and (1 shl n))>0 then bitset:=true
                         else bitset:=false;
end;

function  CalcGamma (a:dword;ingam,outgam:dword):dword;

var b,c,x,y:float;

{           B           }
{         ( - ) * ln x  }
{           C           }
{   y = e^              }

begin
  { check for certain input conditions }
  if a=  0 then begin calcgamma:=  0; exit; end;
  if a=255 then begin calcgamma:=255; exit; end;
  if ingam=0 then begin
    case a of
           0: calcgamma:=0;
      1..255: calcgamma:=255;
    end;
    exit;
  end;

  { normalize input }
  b:=outgam; b:=b/100000;
  c:=ingam;  c:=c/100000;
  x:=a;      x:=x/255;

  { calculate }
  y:=exp((b/c)*ln(x));

  { prepare output }
  calcgamma:=round(y*255);
end;

function  FStr (a:longint):String;
var
    st:string;
begin
  str(a,st);
  FStr:=St;
end;

function  bYesNo (a:boolean):string;

begin
  if a then byesno:='yes'
       else byesno:='no';
end;

function  iYesNo (a:longint):string;

begin
  if a<>0 then iyesno:='yes'
          else iyesno:='no';
end;

function  Smallest (a,b:longint):longint;

begin
  if a<=b then smallest:=a
          else smallest:=b;
end;

function  Biggest (a,b:longint):longint;

begin
  if a>=b then biggest:=a
          else biggest:=b;
end;

{.$IFDEF USEASM}
{procedure BSWAP16(var a:dword); assembler;

asm
       mov     eax,a
       xchg    ah,al
       mov     a,eax
end ['EAX'];}
{.$ELSE}
procedure DBSWAP16(var a:dword);

var b:dword;

begin
  b:=a;
  a:=a and $FF00;
  b:=b and $00FF;
  a:=a shr 8;
  b:=b shl 8;
  a:=a or b;
end;
{.$ENDIF}

{.$IFDEF USEASM}
{procedure BSWAP16(var a:word); assembler;

asm
       mov     ax,a
       xchg    ah,al
       mov     a,ax
end ['EAX'];}
{.$ELSE}
procedure BSWAP16(var a:word);

var b:word;

begin
  b:=a;
  a:=a and $FF00;
  b:=b and $00FF;
  a:=a shr 8;
  b:=b shl 8;
  a:=a or b;
end;
{.$ENDIF}

{.$IFDEF USEASM}
{procedure BSWAP32(var a:dword); assembler;
asm
       mov     eax,a
       bswap   eax
       mov     a,eax
end ['EAX'];}
{.$ELSE}
procedure DBSWAP32(var a:dword);

var b,c,d:dword;

begin
  b:=a;
  c:=a;
  d:=a;
  a:=a and $FF000000;
  b:=b and $00FF0000;
  c:=c and $0000FF00;
  d:=d and $000000FF;
  a:=a shr 24;
  b:=b shr 8;
  c:=c shl 8;
  d:=d shl 24;
  a:=a or b or c or d;
end;
{.$ENDIF}

function  ChunkNameStr (a:dword):string;
var
    st:string;
begin
  SetLength(st,4);
  st[1]:=chr(a and $FF);
  st[2]:=chr((a shr 8) and $FF);
  st[3]:=chr((a shr 16) and $FF);
  st[4]:=chr((a shr 24) and $FF);
  result:=st;
end;

function  GetCurrentSystemTime:dword;

//var r:registers;

begin
  (**
  { OS-dependant part }
  r.ah:=$00;
  intr ($1A,r);
  { BIOS function, should be available for Windows, DOS, Linux for PC }
  getcurrentsystemtime:=dword(r.dx) or (dword(r.cx) shl 16);
  if getcurrentsystemtime<start_time then inc(getcurrentsystemtime,$1800B0);
  { 18.2 Hz => ms }
  getcurrentsystemtime:=getcurrentsystemtime*55;
  **)
end;

begin
  start_time:=getcurrentsystemtime;
end.
