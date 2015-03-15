unit CRC;

interface

  {$i zconf.inc}
  {$I mingdef.inc}

  {---CRC_FPC.INC is a 80386-assembler version, written for FPC---}

  {$IFDEF USEASM}
    {$IFDEF FPC}
      {$i crc_fpc.inc}
    {$ELSE}
      {$i crc_tp.inc}
    {$ENDIF}
  {$ELSE}
    {$i crc_tp.inc}
  {$ENDIF}

end.