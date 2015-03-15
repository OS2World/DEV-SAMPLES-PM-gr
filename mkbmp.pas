UNIT MkBMP;

{ Copyright (C) 1994-1996, Thomas G. Lane.
  This code contributed by James Arthur Boucher.

  This file contains routines to write output images in Microsoft "BMP"
  format (MS Windows 3.x and OS/2 1.x flavors).
  Either 8-bit colormapped or 24-bit full-color format can be written.
  No compression is supported. }

INTERFACE

{$I jconfig.inc}

USES
  jinclude,
  jdeferr,jdapimin,jdapistd,jdatasrc,
//  jdmarker,
  jdmaster,cdjpeg,
  jmorecfg, jerror, jpeglib,
  jdatadst, jcparam, jcapimin, jcapistd,
  math,OS2Def,OS2BASE,Os2PmApi,SysUtils,classes,
  minglib,mingutil;

CONST
    MaxArrayNum=1024*1024*32;
    AllocMemSize=1024*1024*3+5120;

TYPE
    GraphicAttr=(jpg,png,bmp);

    BMPArray=ARRAY[0..MaxArrayNum*3] OF BYTE;
    PalettRecord=RECORD
        CASE INTEGER OF
        0:(Palett:ARRAY[0..1023] OF BYTE);
        1:(qArray:ARRAY[0..255,0..3] OF BYTE);
    END;

    BitmapRecord=RECORD
       cbSize:LONGINT;
       sCx,sCy:INTEGER;
       bmpCx,bmpCy: INTEGER;
       CASE INTEGER OF
         1:( InfoHeader2:BitmapInfoHeader2;
             PalAry:PalettRecord;
             rg:BMPArray;
             );
         0:(Info2:BitmapInfo2;);
    END;
    pBitmapRecord=^BitmapRecord;

    JpegViewClass=CLASS
        OrgWidth    :INTEGER;
        Ganmma      :extended;
        GraphAttr   :GraphicAttr;
        cinfo       :jpeg_decompress_struct;
        dest_mgr    :djpeg_dest_ptr;
        jerr        : jpeg_error_mgr;
        FileName    :String;
        pBMPBody    :pBitmapRecord;
        AGanmma:PalettRecord;
        constructor Create;virtual;
        PROCEDURE MakeGanmmaPalette;
        PROCEDURE ReAlloc(px,py:INTEGER);
        PROCEDURE SetupHeader(px,py:INTEGER);
        PROCEDURE SetupGrayHeader(px,py:INTEGER);
        PROCEDURE SetupData(VAR rg:BMPArray);
        PROCEDURE JpegFileLoad;
        PROCEDURE JpegFileSave(st: string;  quality : int);
    END;
    tMingBMPObject=CLASS(tMingObject)
        px,py:INTEGER;
        pBMP:pBitmapRecord;
        yOffset:INTEGER;
        AGanmma:PalettRecord;
        constructor Create(pB:pBitmapRecord);
        PROCEDURE UserSetPixProc(x,y:LONGINT;c:tcolor);OverRide;
    END;
    tMingBMPEncode=CLASS(tMingEncode)
        px,py:INTEGER;
        pBMP:pBitmapRecord;
        yOffset:INTEGER;
        PROCEDURE SetBMPPointer(pB:pBitmapRecord);
        FUNCTION  MGetPix (x,y:LONGINT):tcolor;OverRide;
    END;

    MingViewClass=CLASS(JpegViewClass)
        m:tMingBMPObject;
        e:tMingBMPEncode;
        constructor Create;OverRide;
        PROCEDURE MingFileLoad;
        PROCEDURE SetPngPalette;
        PROCEDURE PingFileSave(st:string);
        FUNCTION WriteBitmap(FN:String):BOOLEAN;
    END;

    BitmapViewClass=CLASS(MingViewClass)
        PROCEDURE BMPFileLoad;
    END;

FUNCTION GetBMPSize(x,y:INTEGER):INTEGER;


IMPLEMENTATION

FUNCTION GetBMPSize(x,y:INTEGER):INTEGER;
BEGIN
    result:=x*y*3+SizeOf(bitmapInfoHeader2)+2048+5000;
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
    TargetSize:=GetBMPSize(px,py);
    IF TargetSize>pBMPBody^.cbSize THEN BEGIN
        ReAllocMem(pBMPBody,TargetSize);
        pBMPBody^.cbSize:=TargetSize;
    END;
END;

PROCEDURE JpegViewClass.SetupHeader(px,py:INTEGER);
BEGIN
    ReAlloc(px,py);
    FillChar(pBMPBody^.bmpCx,sizeof(BitmapInfoHeader2)+16,0);
    WITH pBMPBody^.InfoHeader2 DO BEGIN
        cbFix:=sizeof( BITMAPINFOHEADER2 );
        cx:=pX;
        cy:=pY;
        cPlanes:=1;
        cBitCount:=24;
        cbImage:=(px*py)*3;
        cclrused:=0;
        cclrImportant:=0;
    END;
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
        AGanmma.Palett[i*4  ]:= gv;
        AGanmma.Palett[i*4+1]:= gv;
        AGanmma.Palett[i*4+2]:= gv;
        AGanmma.Palett[i*4+3]:= gv;
    END;
    pBMPBody^.PalAry:=AGanmma;
END;

PROCEDURE JpegViewClass.SetupGrayHeader(px,py:INTEGER);
VAR
    i:INTEGER;
BEGIN
    ReAlloc(px,py);
    FillChar(pBMPBody^.bmpCx,sizeof(BitmapInfoHeader2)+16,0);
    WITH pBMPBody^.InfoHeader2 DO BEGIN
        cbFix:=sizeof( BITMAPINFOHEADER2 );
        cx:=pX;
        cy:=pY;
        cPlanes:=1;
        cBitCount:=8;
        cbImage:=(px*py);
        cclrused:=0;
        cclrImportant:=0;
    END;
    pBMPBody^.PalAry:=AGanmma;

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
            outptr^.r := AGanmma.qArray[inptr^,0];
            Inc(inptr);
            outptr^.g := AGanmma.qArray[inptr^,1];
            Inc(inptr);
            outptr^.b := AGanmma.qArray[inptr^,2];
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
        IF (cinfo.out_color_space = JCS_RGB) THEN BEGIN
            OrgWidth:=cinfo.output_width;
            cinfo.output_width:=(cinfo.output_width+3) div 4 *4;
            SetupHeader(cinfo.output_width,cinfo.output_height);
        END
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
            Inc(base,cinfo.output_width*3);
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

PROCEDURE JpegViewClass.JpegFileSave(st: string;  quality : int);

{ <setjmp.h> is used for the optional error recovery mechanism shown in
  the second part of the example. }


{******************* JPEG COMPRESSION SAMPLE INTERFACE ******************}

{ This half of the example shows how to feed data into the JPEG compressor.
  We present a minimal version that does not worry about refinements such
  as error recovery (the JPEG code will just exit() if it gets an error). }


{ IMAGE DATA FORMATS:

  The standard input image format is a rectangular array of pixels, with
  each pixel having the same number of "component" values (color channels).
  Each pixel row is an array of JSAMPLEs (which typically are unsigned chars).
  If you are working with color data, then the color values for each pixel
  must be adjacent in the row; for example, R,G,B,R,G,B,R,G,B,... for 24-bit
  RGB color.

  For this example, we'll assume that this data structure matches the way
  our application has stored the image in memory, so we can just pass a
  pointer to our image buffer.  In particular, let's say that the image is
  RGB color and is described by: }

{ Sample routine for JPEG compression.  We assume that the target file name
  and a compression quality factor are passed in. }

VAR
  { This struct contains the JPEG compression parameters and pointers to
    working space (which is allocated as needed by the JPEG library).
    It is possible to have several such structures, representing multiple
    compression/decompression processes, in existence at once.  We refer
    to any one struct (and its associated working data) as a "JPEG object". }
  cinfo2 : jpeg_compress_struct;
  { This struct represents a JPEG error handler.  It is declared separately
    because applications often want to supply a specialized error handler
    (see the second half of this file for an example).  But here we just
    take the easy way out and use the standard error handler, which will
    print a message on stderr and call exit() if compression fails.
    Note that this struct must live as long as the main JPEG parameter
    struct, to avoid dangling-pointer problems. }

  jerr : jpeg_error_mgr;
  { More stuff }
  outfile : TFileStream;       { target file }
  p:POINTER;
  TopSuffix:INTEGER;
  CurAry:ARRAY[0..8192*3] OF BYTE;
  row_stride : int;     { physical row width in image buffer }

  PROCEDURE SetCurAry(sc:INTEGER);
  VAR
    c1,c2:INTEGER;
  BEGIN
    c1:=0;
    WHILE c1<row_stride DO BEGIN
        CurAry[c1]   :=pBMPBody.rg[sc+c1+2];
        CurAry[c1+1] :=pBMPBody.rg[sc+c1+1];
        CurAry[c1+2] :=pBMPBody.rg[sc+c1+0];
        inc(c1,3);
    END;
  END;

BEGIN
  { Step 1: allocate and initialize JPEG compression object }

  { We have to set up the error handler first, in case the initialization
    step fails.  (Unlikely, but it could happen if you are out of memory.)
    This routine fills in the contents of struct jerr, and returns jerr's
    address which we place into the link field in cinfo. }

  cinfo2.err := jpeg_std_error(jerr);
  { msg_level that will be displayed. (Nomssi) }
  jerr.trace_level := 3;
  { Now we can initialize the JPEG compression object. }
  jpeg_create_compress(@cinfo2);

  { Step 2: specify data destination (eg, a file) }
  { Note: steps 2 and 3 can be done in either order. }

  { Here we use the library-supplied code to send compressed data to a
    stdio stream.  You can also write your own code to do something else.
    VERY IMPORTANT: use "b" option to fopen() if you are on a machine that
    requires it in order to write binary files. }

  outfile:=TFileStream.Create(st,fmCreate);
  jpeg_stdio_dest(@cinfo2, @outfile);

  { Step 3: set parameters for compression }

  { First we supply a description of the input image.
    Four fields of the cinfo struct must be filled in: }

  cinfo2.image_width := pBMPBody^.bmpCx; { image width and height, in pixels }
  cinfo2.image_height := pBMPBody^.bmpCy;
  cinfo2.input_components := 3;      { # of color components per pixel }
  cinfo2.in_color_space := JCS_RGB;  { colorspace of input image }
  { Now use the library's routine to set default compression parameters.
    (You must set at least cinfo.in_color_space before calling this,
    since the defaults depend on the source color space.) }

  jpeg_set_defaults(@cinfo2);
  { Now you can set any non-default parameters you wish to.
    Here we just illustrate the use of quality (quantization table) scaling: }

  jpeg_set_quality(@cinfo2, quality, TRUE { limit to baseline-JPEG values });

  { Step 4: Start compressor }

  { TRUE ensures that we will write a complete interchange-JPEG file.
    Pass TRUE unless you are very sure of what you're doing. }

  jpeg_start_compress(@cinfo2, TRUE);

  { Step 5: while (scan lines remain to be written) }
  {           jpeg_write_scanlines(...); }

  { Here we use the library's state variable cinfo.next_scanline as the
    loop counter, so that we don't have to keep track ourselves.
    To keep things simple, we pass one scanline per call; you can pass
    more if you wish, though. }

  row_stride := pBMPBody^.bmpCx*3;    { JSAMPLEs per row in image_buffer }
  TopSuffix:=(pBMPBody^.bmpCy-1)*row_stride;
  WHILE (cinfo2.next_scanline < cinfo2.image_height) DO
  BEGIN
    { jpeg_write_scanlines expects an array of pointers to scanlines.
      Here the array is only one element long, but you could pass
      more than one scanline at a time if that's more convenient. }
    SetCurAry(TopSuffix-cinfo2.next_scanline*row_stride );
{
    move(pBMPBody^.rg[TopSuffix-cinfo2.next_scanline*row_stride],
         CurAry,
         row_stride);
}
    p:= @CurAry;
    jpeg_write_scanlines(@cinfo2, JSAMPARRAY(@p), 1);
  END;

  { Step 6: Finish compression }

  jpeg_finish_compress(@cinfo2);
  { After finish_compress, we can close the output file. }
  outfile.Free;

  { Step 7: release JPEG compression object }

  { This is an important step since it will release a good deal of memory. }
  jpeg_destroy_compress(@cinfo2);

  { And we're done! }


{ SOME FINE POINTS:

  In the above loop, we ignored the return value of jpeg_write_scanlines,
  which is the number of scanlines actually written.  We could get away
  with this because we were only relying on the value of cinfo.next_scanline,
  which will be incremented correctly.  If you maintain additional loop
  variables then you should be careful to increment them properly.
  Actually, for output to a stdio stream you needn't worry, because
  then jpeg_write_scanlines will write all the lines passed (or else exit
  with a fatal error).  Partial writes can only occur if you use a data
  destination module that can demand suspension of the compressor.
  (If you don't know what that's for, you don't need it.)

  If the compressor requires full-image buffers (for entropy-coding
  optimization or a multi-scan JPEG file), it will create temporary
  files for anything that doesn't fit within the maximum-memory setting.
  (Note that temp files are NOT needed if you use the default parameters.)
  On some systems you may need to set up a signal handler to ensure that
  temporary files are deleted if the program is interrupted.  See libjpeg.doc.

  Scanlines MUST be supplied in top-to-bottom order if you want your JPEG
  files to be compatible with everyone else's.  If you cannot readily read
  your data in that order, you'll need an intermediate array to hold the
  image.  See rdtarga.c or rdbmp.c for examples of handling bottom-to-top
  source data using the JPEG code's internal virtual-array mechanisms. }


END;

constructor tMingBMPObject.Create(pB:pBitmapRecord);
BEGIN
    pBMP:=pB;
END;

PROCEDURE tMingBMPObject.usersetpixproc(x,y:LONGINT;c:tcolor);
BEGIN
    pBMP^.RG[yOffset-(y*px)*3+x*3+0]:=AGanmma.qArray[c.blue,0];
    pBMP^.RG[yOffset-(y*px)*3+x*3+1]:=AGanmma.qArray[c.Green,1];
    pBMP^.RG[yOffset-(y*px)*3+x*3+2]:=AGanmma.qArray[c.Red,2];
END;

PROCEDURE tMingBMPEncode.SetBMPPointer(pB:pBitmapRecord);
BEGIN
    pBMP:=pB;
    px:=pBMP^.bmpCx;
    py:=pBMP^.bmpCy;
    yOffset:=px*py*3;
END;

FUNCTION  tMingBMPEncode.MGetPix (x,y:LONGINT):tcolor;
VAR
    suffix:INTEGER;
BEGIN
    suffix:=yOffset-(y*px-x)*3;
    result.blue:=   pBMP^.rg[Suffix  ];
    result.Green:=  pBMP^.rg[Suffix+1];
    result.Red:=    pBMP^.rg[Suffix+2];
END;

constructor MingViewClass.Create;
BEGIN
    inherited Create;
    m:=tMingBMPObject.Create(pBMPBody);
    e:=tMingBMPEncode.Create;
    SetPngPalette;
END;

PROCEDURE MingViewClass.SetPngPalette;
BEGIN
    m.AGanmma:=AGanmma;
END;



PROCEDURE MingViewClass.MingFileLoad;
VAR
    name:String;
    attr:INTEGER;
BEGIN
    GraphAttr:=PNG;

    name:=FileName;
    Attr:=FileGetAttr(name);
    IF Attr AND faReadOnly>0 THEN FileSetAttr(name,Attr - faReadOnly);
    m.OpenSession (Name);
    m.mingchunk:=m.GetFirstChunk;
    WHILE m.mingchunk.chunktype<>mingchunk_pinghead DO BEGIN
        m.skipchunkdata(m.mingchunk);
        m.mingchunk:=m.getnextchunk(m.mingchunk);
    END;
    m.getchunkdata(m.mingchunk,m.mingchunkdata);
    OrgWidth:=m.mingchunkdata.pinghead.width;
    m.px:=((m.mingchunkdata.pinghead.width+3)div 4 )*4;
    m.py:=m.mingchunkdata.pinghead.height;
    m.yOffset:=m.px*m.py*3;
    SetupHeader(m.px,m.py);
    m.pBMP:=pBMPBody;

    m.initpingload(m.mingchunkdata);
    WHILE NOT(m.pingloadfinished) DO
        m.pingload;
    m.finishpingload;
    m.CloseSession;
END;


PROCEDURE MingViewClass.PingFileSave(st:string);
VAR
   iHDR:tMingChunkData;
BEGIN
    e.SetBMPPointer(pBMPBody);
    e.OpenSession (st,MingType_Ping);
    iHDR.chunktype:=mingchunk_pinghead;
    WITH iHDR.pinghead DO BEGIN
        width:=e.pBMP^.bmpCx;
        height:=e.pBMP^.bmpCy;
        compressiontype:=0;
        filterType:=0;
        interlaceType:=0;
        colortype:=mingchunk_pinghead_rgbimage;
        bitdepth:=8;
    END;
    e.InitPingEncode(iHDR);
    WHILE NOT(e.PiNGEncodeFinished) DO
        e.EncodePing;
    e.finishpingEncode;
    e.CloseSession;
END;

FUNCTION MingViewClass.WriteBitmap(FN:string):BOOLEAN;
VAR
    B:File;
    BMPSize:INTEGER;
    BFINFO2:BitmapFileHeader2;
    size:INTEGER;
BEGIN
    BFInfo2.usType:=BFT_BMAP;
    BFInfo2.cbSize:=SizeOf(BitmapFileHeader2);
    BFInfo2.Offbits:=SizeOf(BitmapFileHeader2);
    BFInfo2.xHotSpot:=0;
    BFInfo2.yHotSpot:=0;
    BFInfo2.bmp2:=pBMPBody^.Infoheader2;
    size:=SizeOf(BitmapFileHeader2);
    Assign(B,FN);rewrite(B,1);
    BMPSize:=(pBMPBody^.bmpCx*pBMPBody^.bmpCy)*3;
    IF pBMPBody^.cbSize>BMPSize THEN  BEGIN
        BlockWrite(B,BFInfo2,SizeOf(BitmapFileHeader2));
//        BlockWrite(B,pBMPBody^.PalAry,1023);
        BlockWrite(B,pBMPBody^.rg,BMPSize);
    END;
    Close(b);
END;

PROCEDURE BitmapViewClass.BMPFileLoad;
VAR
    BUF:ARRAY[0..1024*1024*4] OF BYTE;
    pbmp2:PBITMAPINFOHEADER2;
    pbfh2:pBitmapFileHeader2;
    tfh:PBITMAPARRAYFILEHEADER2;
    bih:PBITMAPINFOHEADER;
    t:file;
    Fid,Count,cScans,OffBits:INTEGER;
    BufferSize:LONGINT;
    Info:TSearchRec;

BEGIN
    GraphAttr:=BMP;
    FindFirst(FileName,faAnyFile,Info);
    BufferSize:=Info.Size;
    Fid:=FileOpen(FileName,fmOpenRead);
    count:=FileRead(Fid,BUF,BufferSize);
    FileClose(Fid);

    pbfh2 := @BUF;
    pbmp2 := NIL;     { only set this when we validate type }

    CASE pbfh2^.usType OF
        BFT_BITMAPARRAY:
        BEGIN
           tfh:=@BUF;
           pbfh2 := @tfh^.bfh2;
           pbmp2 := @pbfh2^.bmp2;  { pointer to info header (readability) }
        END;
        BFT_BMAP:pbmp2:=@pbfh2^.bmp2;{ pointer to info header (readability) }
        ELSE BEGIN
            EXIT;
        END;
     END; {case}
     IF pbmp2^.cbFix = sizeof(BITMAPINFOHEADER) THEN   { old format? }
     BEGIN
          bih:=POINTER(pbmp2);
          pBMPBody^.bmpCy:= bih^.cy;
          pBMPBody^.bmpCx:=bih^.cx;
     END
     ELSE  BEGIN{ new PM format, Windows, or other }
         pBMPBody^.bmpCx:=pbmp2^.cx;
         pBMPBody^.bmpCy:=pbmp2^.cy;
     END;
     OffBits:=pbfh2^.offbits;

     Move(pbmp2^,pBMPBody^.InfoHeader2,OffBits);
     Move(BUF[OffBits],pBMPBody^.RG,BufferSize-OffBits);


END;




BEGIN
END.

///$Log: mkbmp.pas $
///Revision 7.1  2008/06/10 16:03:57  Average
///縮小時に画像が壊れる部分を修正
///
///Revision 7.0  2008/06/08 03:33:19  Average
///画像ファイルが見えなくなる問題を修正する版。これが初め
///
///Revision 6.1  2007/07/21 18:25:24  Average
///セーブオプションダイアログを導入
///
///Revision 5.3  2007/07/07 15:20:21  Average
///BMPのサイズを求める関数を追加
///
///Revision 5.2  2007/07/04 16:14:36  Average
///ばばんと変わった?
///
///Revision 5.3  2007/07/04 16:12:06  Average
///パラメータのセーブ/ロードを入れ込みはじめた
///
///Revision 5.2  2007/07/04 16:02:43  Average
///とりあえず、Render&Saveが動くように
///
///Revision 5.1  2007/07/04 12:44:23  Average
///周辺ぼかしをアルゴリズムじゃなくてぼかしで
///
///Revision 4.4  2007/06/26 14:45:58  Average
///縦横比の正確さを求める
///
///Revision 4.3  2007/06/26 14:03:08  Average
/// 一応Webページが表示できるように
///
///Revision 4.2  2007/06/25 15:49:58  Average
///とりあえずmakeroudしながらの閲覧は大丈夫になりました。
///これからWebページの構築へ
///
///Revision 4.1  2007/06/25 12:37:11  Average
/// Webアルバム化
///
///Revision 3.5  2007/06/23 14:30:59  Average
///ドロップした時の挙動をマシに
///
///Revision 3.4  2007/06/21 15:23:37  Average
///とりあえず縮小が上手く動くように
///
///Revision 3.3  2007/06/20 13:41:21  Average
///リサイズ直前リファクタ版
///
///Revision 3.2  2007/06/19 14:23:47  Average
///PNGファイルの書き込みを可能に
///
///Revision 3.1  2007/06/17 12:40:01  Average
///影の方向を色々に変更出来るように
///試行錯誤バージョン(変更はじめ)
///
///Revision 2.0  2007/06/13 16:06:57  Average
///BMP読み込みルーチンを削除
///
///Revision 1.3  2007/06/12 15:22:03  Average
///とりあえずダイアログを出した。
///
///Revision 1.2  2007/06/09 19:01:04  Average
///とりあえずbmpが4の倍数でない時の処理を追加
///
///Revision 1.1  2007/06/06 15:39:17  Average
///Initial revision
///
///Revision 1.56  2007/06/02 22:34:21  Average
///PNGにもパレットを
///
///Revision 1.55  2007/06/02 21:49:17  Average
///ガンマ値の設定を弄ってダイアログ廻りもちょっと修正。
///
///Revision 1.54  2006/12/16 15:29:36  Average
///ガンマ変換のダイアログ導入
///
///Revision 1.53  2006/12/09 06:13:19  Average
///*** empty log message ***
///
///Revision 1.52  2006/12/04 12:40:30  Average
///コントラスト設定を完全に抜いた
///
///Revision 1.51  2006/12/04 12:37:03  Average
///オプションの形式を変えて、ガンマ値の数値を指定可能に
///
///Revision 1.50  2006/11/09 12:27:54  Average
///内部構造を大分変えた版
///機能は前と変わらないが・・・
///
///Revision 1.3  2006/11/09 12:08:28  Average
///*** empty log message ***
///
///Revision 1.2  2006/11/08 11:12:16  Average
///タイマー間隔が間違えてました
///
///Revision 1.2  2006/11/07 16:03:08  Average
///一応リードオンリーの場合、落ちないように
///
///Revision 1.1  2006/11/04 05:34:48  Average
///*** empty log message ***
///
///Revision 0.11  2006/10/30 13:06:59  Average
///ドロップを成功させる
///
///Revision 0.10  2006/10/21 14:55:01  Average
///*** empty log message ***
///
///Revision 0.11  2006/10/17 16:08:43  Average
///MkBMPの致命的なミスを修正
///
///Revision 0.10  2006/10/13 16:43:07  Average
///定義が若干変わっただけ
///
///Revision 0.9  2006/10/07 14:56:00  Average
///*** empty log message ***
///
///Revision 1.100  2006/10/06 13:16:50  Average
///*** empty log message ***
///
///Revision 1.99  2006/09/16 17:35:44  Average
/// とりあえず配列を固定してスケールバグを修正
///
///Revision 1.10  2006/08/19 15:31:04  Average
///Frameサイズにそろえるオプション
///
///Revision 1.9  2006/07/02 15:44:35  Average
///さくっと入れました
///
///Revision 1.8  2006/07/02 15:37:30  Average
///ずらし作戦成功
///
///Revision 1.7  2006/07/01 16:39:01  Average
///とりあえずbabannと
///単発ファイル名でもオッケーに
///
///Revision 1.5  2006/06/27 17:57:16  Average
///動的に領域確保
///
///Revision 1.4  2006/06/26 17:13:56  Average
///ちょっとソースを変えた
///
///Revision 1.3  2006/06/26 17:01:19  Average
///最新の(1998年の)pasjpegを使った場合
///
///Revision 1.2  2006/06/26 15:30:51  Average
///とりあえず最新版。めもりバガ食い
///
///Revision 1.1  2005/09/11 16:57:57  Average
///Initial revision
///
///Revision 1.1  2002/05/09 14:49:24  Average
///Initial revision
//////
