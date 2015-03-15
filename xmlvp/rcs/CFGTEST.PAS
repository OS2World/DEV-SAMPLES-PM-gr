head	1.3;
access;
symbols;
locks;
comment	@ * @;


1.3
date	2006.11.19.14.16.18;	author Average;	state Exp;
branches;
next	1.2;

1.2
date	2006.11.19.13.19.06;	author Average;	state Exp;
branches;
next	1.1;

1.1
date	2006.11.19.13.18.22;	author Average;	state Exp;
branches;
next	;


desc
@@


1.3
log
@xmlwrite.pasÇèëë÷Ç¶
àÍâûDOCTYPEwo
èëÇ≠ÇÊÇ§Ç…
@
text
@// $Id: cfgtest.pp,v 1.1 2000/07/13 06:33:46 michael Exp $

{$H+}

PROGRAM cfgtest;
USES xmlcfg;
VAR
  cfg: TXMLConfig;
  i: INTEGER;
  s: String;
  b: BOOLEAN;
BEGIN

  WRITELN('Writing a sample XML configuration to "testcfg.xml"...');

  cfg := TXMLConfig.Create('testcfg.xml');
  cfg.SetValueInteger('cfgtest/MainWindow/Constraints/Width', 600);
  cfg.SetValueInteger('cfgtest/MainWindow/Constraints/Height', 400);
  cfg.SetValue('cfgtest/MainWindow/Caption', 'TXMLConfig Test');
  cfg.SetValue('cfgtest/SomeForm/Presets/Preset1/Name', 'Example');
  cfg.SetValueBool('TipOfTheDay/Disabled', True);
  cfg.Free;

  WRITELN('Ok; now I''ll try to read back all values...');

  cfg := TXMLConfig.Create('testcfg.xml');

  i := cfg.GetValueInteger('cfgtest/MainWindow/Constraints/Width', 0);
  IF i <> 600 THEN
    WRITELN('Invalid value: cfgtest/MainWindow/Constraints/Width, got ', i);

  i := cfg.GetValueInteger('cfgtest/MainWindow/Constraints/Height', 400);
  IF i <> 400 THEN
    WRITELN('Invalid value: cfgtest/MainWindow/Constraints/Height, got ', i);

  s := cfg.GetValue('cfgtest/MainWindow/Caption', '');
  IF s <> 'TXMLConfig Test' THEN
    WRITELN('Invalid value: cfgtest/MainWindow/Caption, got "', s, '"');

  s := cfg.GetValue('cfgtest/SomeForm/Presets/Preset1/Name', '');
  IF s <> 'Example' THEN
    WRITELN('Invalid value: cfgtest/SomeForm/Presets/Preset1/Name, got "', s, '"');

  b := cfg.GetValueBool('TipOfTheDay/Disabled', FALSE);
  IF b <> True THEN
    WRITELN('Invalid value: TipOfTheDay/Disabled, got ', b);
  cfg.Free;

  WRITELN('Done!');
END.


{
  $Log: cfgtest.pp,v $
  Revision 1.1  2000/07/13 06:33:46  michael
  + Initial import

  Revision 1.4  2000/01/06 01:20:36  peter
    * moved out of packages/ back to topdir

  Revision 1.1  2000/01/03 19:33:10  peter
    * moved to packages dir

  Revision 1.2  1999/12/22 13:43:14  sg
  * Improved messages in the case of failure: Now the test prints the results
    it got from the XMLCfg unit

  Revision 1.1  1999/07/09 21:06:59  michael
  + Initial implementation by sebastian Guenther

}
@


1.2
log
@doctypeêÈåæì«Ç›çûÇ›(ÇΩÇæÇµxhtmlÇÃÇ›)
@
text
@@


1.1
log
@Initial revision
@
text
@@
