program test;

{ Copyright (C) 1994-1996, Thomas G. Lane.
  This code contributed by James Arthur Boucher.

  This file contains routines to write output images in Microsoft "BMP"
  format (MS Windows 3.x and OS/2 1.x flavors).
  Either 8-bit colormapped or 24-bit full-color format can be written.
  No compression is supported. }


{$I jconfig.inc}

USES
  jinclude,
  jmorecfg,
  jpeglib,
  jerror,
//  RdColMap,
  jdeferr,
  jdapimin,
  jdapistd,
  jdatasrc,
//  jdmarker,
  jdmaster,
  cdjpeg,
  math,SysUtils,classes,
  minglib,mingutil;

CONST
    MaxArrayNum=1024*1024*32;
    AllocMemSize=1024*1024*3+5120;

TYPE
    GraphicAttr=(jpg,png,bmp);

    BMPArray=ARRAY[0..MaxArrayNum*3] OF BYTE;
    PalettArray=ARRAY[0..1023] OF BYTE;

    BitmapRecord=RECORD
       cbSize:LONGINT;
       sCx,sCy:INTEGER;
       bmpCx,bmpCy: INTEGER;
       PalAry:PalettArray;
       rg:BMPArray;
    END;
    pBitmapRecord=^BitmapRecord;

    JpegViewClass=CLASS
        Ganmma      :extended;
        GraphAttr   :GraphicAttr;
        cinfo       :jpeg_decompress_struct;
        dest_mgr    :djpeg_dest_ptr;
        jerr        : jpeg_error_mgr;
        FileName    :String;
        pBMPBody    :pBitmapRecord;
        GanmmaPalett:PalettArray;
        constructor Create;virtual;
        PROCEDURE MakeGanmmaPalette;
        PROCEDURE ReAlloc(px,py:INTEGER);
        PROCEDURE SetupHeader(px,py:INTEGER);
        PROCEDURE SetupGrayHeader(px,py:INTEGER);
        PROCEDURE SetupData(VAR rg:BMPArray);
        PROCEDURE JpegFileLoad;
    END;
    tMingBMPObject=CLASS(tMingObject)
        px,py:INTEGER;
        pBMP:pBitmapRecord;
        yOffset:INTEGER;
        constructor Create(pB:pBitmapRecord);
        PROCEDURE UserSetPixProc(x,y:LONGINT;c:tcolor);OverRide;
    END;
    tMingBMPEncode=Class(tMingEncode)
        px,py:integer;
        pBMP:pBitmapRecord;
        yOffset:integer;
        constructor Create(pB:pBitmapRecord);
        function  MGetPix (x,y:longint):tcolor;OverRide;
    end;
    MingViewClass=CLASS(JpegViewClass)
        m:tMingBMPObject;
        e:tMingBMPEncode;
        constructor Create;OverRide;
        PROCEDURE MingFileLoad(Arg:string);
        procedure MingFileSave;
    END;



TYPE
    bmp_dest_ptr = ^bmp_dest_struct;
    bmp_dest_struct = RECORD
        pub : djpeg_dest_struct;{ public fields }

        whole_image : jvirt_sarray_ptr; { needed to reverse row order }
        data_width : JDIMENSION;{ JSAMPLEs per row }
        row_width : JDIMENSION; { physical width of one row in the BMP file }
        pad_bytes : int;        { number of padding bytes needed per row }
        cur_output_row : JDIMENSION;    { next row# to write to virtual array }
    END;


constructor JpegViewClass.create;
BEGIN
    Ganmma:=1;
    GetMem(pBMPBody,AllocMemSize);
    pBMPBody.cbSize:=AllocMemSize;
    FillChar(pBMPBody^,AllocMemSize,0);
    MakeGanmmaPalette;
END;
PROCEDURE JpegViewClass.ReAlloc(px,py:INTEGER);
VAR
    TargetSize:LONGINT;
BEGIN
    TargetSize:=px*py*3+2048+5000;
    IF TargetSize>pBMPBody^.cbSize THEN BEGIN
        ReAllocMem(pBMPBody,TargetSize);
        pBMPBody^.cbSize:=TargetSize;
    END;
END;

PROCEDURE JpegViewClass.SetupHeader(px,py:INTEGER);
BEGIN
    ReAlloc(px,py);
    pBMPBody^.bmpCx:=px;
    pBMPBody^.bmpCy:=py;
END;

PROCEDURE JpegViewClass.MakeGanmmaPalette;
VAR
    i:INTEGER;
    r:extended;
    gv:INTEGER;
BEGIN
    IF Ganmma>2.2 THEN Ganmma:=2.2;
    IF Ganmma<0 THEN Ganmma:=0;
    FOR i:=0 TO 255 DO BEGIN
        IF i=0 THEN
            r:=0
        ELSE BEGIN
            r:=i/255;
            r:=Power(r,(1/Ganmma))*255;
        END;
        IF r>255 THEN r:=255;
        gv:=round(r);
        GanmmaPalett[i*4  ]:= gv;
        GanmmaPalett[i*4+1]:= gv;
        GanmmaPalett[i*4+2]:= gv;
        GanmmaPalett[i*4+3]:= gv;
    END;
END;

PROCEDURE JpegViewClass.SetupGrayHeader(px,py:INTEGER);
VAR
    i:INTEGER;
BEGIN
    ReAlloc(px,py);
    pBMPBody^.PalAry:=GanmmaPalett;

    pBMPBody^.bmpCx:=px;
    pBMPBody^.bmpCy:=py;
END;

PROCEDURE JpegViewClass.SetupData(VAR rg:BMPArray);
BEGIN
    pBMPBody^.rg:=rg;
END;


PROCEDURE JpegViewClass.JpegFileLoad;
VAR
  {$ifdef PROGRESS_REPORT}
    progress : cdjpeg_progress_mgr;
  {$endif}
    num_scanlines : JDIMENSION;
    input_file:TFileStream;
    name:String;
    dest : bmp_dest_ptr;
    PROCEDURE JpegInit;
    VAR
      row_width : JDIMENSION;
    VAR
      progress : cd_progress_ptr;
    BEGIN
        dest := bmp_dest_ptr(cinfo.mem^.alloc_small (j_common_ptr(@cinfo),
                                                     JPOOL_IMAGE,
                                                     SIZEOF(bmp_dest_struct)));
        jpeg_calc_output_dimensions(@cinfo);

        row_width := cinfo.output_width * cinfo.output_components;
        dest^.data_width := row_width;
        WHILE ((row_width AND 3) <> 0) DO Inc(row_width);
        dest^.row_width := row_width;
        dest^.pad_bytes := int (row_width - dest^.data_width);

        dest^.whole_image:=cinfo.mem^.request_virt_sarray(j_common_ptr(@cinfo),
                                                          JPOOL_IMAGE,
                                                          FALSE,
                                                          row_width,
                                                          cinfo.output_height,
                                                          JDIMENSION (1));
        dest^.cur_output_row := 0;
        IF (cinfo.progress <> NIL) THEN BEGIN
            progress := cd_progress_ptr (cinfo.progress);
            Inc(progress^.total_extra_passes);
        END;

        dest^.pub.buffer := cinfo.mem^.alloc_sarray(j_common_ptr(@cinfo),
                                                    JPOOL_IMAGE,
                                                    row_width,
                                                    JDIMENSION (1));
        dest^.pub.buffer_height := 1;
        dest_mgr:= djpeg_dest_ptr(dest);
    END;(**JpegInit**)

    PROCEDURE put_gray_rows ;

    { This version is for grayscale OR quantized color output }
    VAR
      dest : bmp_dest_ptr;
      image_ptr : JSAMPARRAY;
      {register} inptr, outptr : JSAMPLE_PTR;
      {register} col : JDIMENSION;
      pad : int;
    BEGIN
      dest := bmp_dest_ptr (dest_mgr);

      { Access next row in virtual array }
        image_ptr := cinfo.mem^.access_virt_sarray( j_common_ptr(@cinfo),
                                                    dest^.whole_image,
                                                    dest^.cur_output_row,
                                                    JDIMENSION (1),
                                                    TRUE);
      Inc(dest^.cur_output_row);

      { Transfer data. }
      inptr := JSAMPLE_PTR(dest^.pub.buffer^[0]);
      outptr := JSAMPLE_PTR(image_ptr^[0]);
      FOR col := pred(cinfo.output_width) downto 0 DO
      BEGIN
        outptr^ := inptr^;  { can omit GETJSAMPLE() safely }
        Inc(outptr);
        Inc(inptr);
      END;

      { Zero out the pad bytes. }
      pad := dest^.pad_bytes;
      WHILE (pad > 0) DO
      BEGIN
        Dec(pad);
        outptr^ := 0;
        Inc(outptr);
      END;
    END;

    PROCEDURE put_jpeg_pixel_rows;
    VAR
        image_ptr : JSAMPARRAY;
        {register} inptr : JSAMPLE_PTR;
                   outptr : BGRptr;
        {register} col : JDIMENSION;
        pad : int;
    BEGIN
        dest := bmp_dest_ptr (dest_mgr);
        image_ptr := cinfo.mem^.access_virt_sarray( j_common_ptr(@cinfo),
                                                    dest^.whole_image,
                                                    dest^.cur_output_row,
                                                    JDIMENSION (1),
                                                    TRUE);
        Inc(dest^.cur_output_row);
        inptr := JSAMPLE_PTR(dest^.pub.buffer^[0]);
        outptr := BGRptr(image_ptr^[0]);
        FOR col := pred(cinfo.output_width) downto 0 DO BEGIN
            outptr^.r := inptr^;
            Inc(inptr);
            outptr^.g := inptr^;
            Inc(inptr);
            outptr^.b := inptr^;
            Inc(inptr);
            Inc(outptr);
        END;
        pad := dest^.pad_bytes;
        WHILE (pad > 0) DO BEGIN
            Dec(pad);
            JSAMPLE_PTR(outptr)^ := 0;
            Inc(JSAMPLE_PTR(outptr));
        END;
    END;(**put_jpeg_pixel_rows**)

    PROCEDURE JpegToBitmap;
    VAR
        image_ptr : JSAMPARRAY;
        row,base:LONGINT;
    BEGIN
        dest := bmp_dest_ptr(dest_mgr );
        IF (cinfo.out_color_space = JCS_RGB) THEN
            SetupHeader(cinfo.output_width,cinfo.output_height)
        ELSE
            SetupGrayHeader(cinfo.output_width,cinfo.output_height);
        base:=0;
        FOR row := cinfo.output_height downto 1 DO BEGIN
            image_ptr := cinfo.mem^.access_virt_sarray(j_common_ptr(@cinfo),
                                                        dest^.whole_image,
                                                        row-1,
                                                        JDIMENSION(1),
                                                        FALSE);

            Move(JSAMPLE_PTR(image_ptr^[0])^,
                 pBMPBody^.rg[base],
                 dest^.row_width);
            Inc(base,(dest^.row_width+3) div 4 *4);
        END;
    END;(**JpegToBitmap**)

VAR
    Attr:INTEGER;
BEGIN
    GraphAttr:=JPG;
    dest_mgr := NIL;
    cinfo.err := jpeg_std_error(jerr);
    jpeg_create_decompress(@cinfo);
    jerr.first_addon_message := JMSG_FIRSTADDONCODE;
    jerr.last_addon_message := JMSG_LASTADDONCODE;
  {$ifdef NEED_SIGNAL_CATCHER}
    enable_signal_catcher(j_common_ptr (@cinfo));
  {$endif}

    name:=FileName;
    IF FileExists(name) =FALSE THEN HALT(EXIT_FAILURE);
    input_file:=TFileStream.Create(name,fmOpenRead);

  {$ifdef PROGRESS_REPORT}
    start_progress_monitor(j_common_ptr (@cinfo), @progress);
  {$endif}

    jpeg_stdio_src(@cinfo, @input_file);

    {void} jpeg_read_header(@cinfo, TRUE);


    { Open the input file. }
    JpegInit;

    {void} jpeg_start_decompress(@cinfo);

    IF (cinfo.out_color_space = JCS_RGB) THEN BEGIN
        WHILE (cinfo.output_scanline < cinfo.output_height) DO BEGIN
            num_scanlines := jpeg_read_scanlines(@cinfo, dest_mgr^.buffer,
                                                  dest_mgr^.buffer_height);
            put_jpeg_pixel_rows ;
        END;
    END
    ELSE BEGIN
        WHILE (cinfo.output_scanline < cinfo.output_height) DO BEGIN
            num_scanlines := jpeg_read_scanlines(@cinfo, dest_mgr^.buffer,
                                                  dest_mgr^.buffer_height);
            put_gray_rows ;
        END;
    END;

  {$ifdef PROGRESS_REPORT}
    progress.pub.completed_passes := progress.pub.total_passes;
  {$endif}

    JpegToBitmap;
    {void} jpeg_finish_decompress(@cinfo);
    jpeg_destroy_decompress(@cinfo);
    input_file.Free;
END;

constructor tMingBMPObject.Create(pB:pBitmapRecord);
BEGIN
    pBMP:=pB;
END;

PROCEDURE tMingBMPObject.usersetpixproc(x,y:LONGINT;c:tcolor);
BEGIN
    pBMP^.RG[yOffset-(y*px)*3+x*3+0]:=c.blue;
    pBMP^.RG[yOffset-(y*px)*3+x*3+1]:=c.Green;
    pBMP^.RG[yOffset-(y*px)*3+x*3+2]:=c.Red;
END;

constructor tMingBMPEncode.Create(pB:pBitmapRecord);
begin
    pBMP:=pB;
end;

function tMingBMPEncode.MGetPix(x,y:longint):tcolor;
var
    c:tColor;
begin
    c.blue:=   pBMP^.rg[(y*px+x)*3+0];
    c.Green:=  pBMP^.rg[(y*px+x)*3+1];
    c.Red:=    pBMP^.rg[(y*px+x)*3+2];
    result:=c;
end;

constructor MingViewClass.Create;
BEGIN
    inherited Create;
    m:=tMingBMPObject.Create(pBMPBody);
    e:=tMingBMPEncode.Create(pBMPBody);
END;


PROCEDURE MingViewClass.MingFileLoad(Arg:string);
VAR
    name:String;
    attr:INTEGER;
BEGIN
    GraphAttr:=PNG;
    if arg='test.png' THEN begin
        Arg:=Arg;
    end;
    m.OpenSession (Arg);
    m.mingchunk:=m.GetFirstChunk;
    WHILE m.mingchunk.chunktype<>mingchunk_pinghead DO BEGIN
        m.skipchunkdata(m.mingchunk);
        m.mingchunk:=m.getnextchunk(m.mingchunk);
    END;
    m.getchunkdata(m.mingchunk,m.mingchunkdata);

    m.px:=((m.mingchunkdata.pinghead.width+3)div 4 )*4;
    m.py:=m.mingchunkdata.pinghead.height;
    m.yOffset:=m.px*m.py*3;
    SetupHeader(m.px,m.py);
    m.pBMP:=pBMPBody;

    m.initpingload(m.mingchunkdata);
    WHILE NOT(m.pingloadfinished) DO m.pingload;
    m.finishpingload;
    m.CloseSession;
END;

PROCEDURE MingViewClass.MingFileSave;
var
   iHDR:tMingChunkData;
begin
    e.pBMP:=pBMPBody;
    e.OpenSession ('test.png',MingType_Ping);
    iHDR.chunktype:=mingchunk_pinghead;
    with iHDR.pinghead do begin
        width:=e.pBMP^.bmpCx;
        height:=e.pBMP^.bmpCy;
        compressiontype:=0;
        filterType:=0;
        interlaceType:=0;
        colortype:=mingchunk_pinghead_rgbimage;
        bitdepth:=8;
    end;
    e.InitPingEncode(iHDR);
    WHILE NOT(e.PiNGEncodeFinished) DO
        e.EncodePing;
    e.finishpingEncode;
    e.CloseSession;
end;

var
    MV:MingViewClass;
BEGIN
    MV:=MingViewClass.Create;
    MV.MingFileLoad(ParamStr(1));
    MV.MingFileSave;
END.

