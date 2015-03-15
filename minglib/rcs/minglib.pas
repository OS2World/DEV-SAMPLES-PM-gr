head	1.3;
access;
symbols;
locks;
comment	@ * @;


1.3
date	2007.06.19.14.21.27;	author Average;	state Exp;
branches;
next	1.2;

1.2
date	2007.06.19.13.37.59;	author Average;	state Exp;
branches;
next	1.1;

1.1
date	2007.06.19.13.36.49;	author Average;	state Exp;
branches;
next	;


desc
@@


1.3
log
@FinishEncodedをheigth+1で終了するように。
アドホックすぎるか?
@
text
@unit MINGlib;

{ visit: www.hoernig.purespace.de // home page of MiNGLIB }

interface

  uses mingutil,crc,zutil,zlib,zinflate,zdeflate,zuncompr,zcompres,

       jmorecfg,jerror,jpeglib,jingdest,jcparam,jcapimin,jcapistd,
       jdapimin,jingsrc,jdapistd,classes;

  {$i mingdef.inc}
  {$i chunknam.inc}

  const output_gamma    : dword = 100000;

  const MingLib_Version         = $0038; { 0.38 }
        MingLib_Date            = '02/14/2000';
        MingLib_LibName         = 'MiNG Graphics Library';
        MingLib_Copyright       = 'Created by E. Hoernig, 1999-2000';
        MingLib_SoftwareID      = 'Created using MiNG Graphics Library by E. Hoernig.';

        MingLib_Built           = {$i built.inc} ;


  { based on: MNG (Multiple-image Network Graphics) Format Version 0.96 }
  { source:   ftp://swrinde.nde.swri.edu/pub/mng/documents/             }
  { reads/writes file types: PiNG, JiNG, MiNG                           }
  { extensions:              .PNG, .JNG, .MNG                           }

  {***** MING Signature *****}
  type tMingSignature = array[0..7] of byte;

//  operator = (a,b:tMingSignature)c:boolean;

  const MingSign_MiNG   : tMingSignature = ($8A,$4D,$4E,$47,$0D,$0A,$1A,$0A);
        MingSign_PiNG   : tMingSignature = ($89,$50,$4E,$47,$0D,$0A,$1A,$0A);
        MingSign_JiNG   : tMingSignature = ($8B,$4A,$4E,$47,$0D,$0A,$1A,$0A);

        MingType_NoMiNG       = $00;
        MingType_MiNG         = $01;
        MingType_PiNG         = $02;
        MingType_JiNG         = $03;

        MingType_CreateMiNG   = $80;
        MingType_NoFile       = $FF;

  { Graphics I/O }
  type tcolor = packed record case integer of
         { gray }
         0: (gray       : dword);
         { paletted }
         1: (index      : dword);
         { colored }
         2: (red        : dword;
             green      : dword;
             blue       : dword;
             alpha      : dword);
       end;
       tMingPalette = array[0..255] of tcolor;

       tALine = array[0..2147483647] of byte;
       pALine = ^tAline;

  const ming_unp_None           = $0000;
        ming_unp_NewFrame       = $0001;


  const Adam7_PixPos : record
          XStart : array[0..7] of longint;
          YStart : array[0..7] of longint;
          XStep  : array[0..7] of longint;
          YStep  : array[0..7] of longint;
          XDist  : array[0..7] of longint;
          YDist  : array[0..7] of longint;
        end = (
          xstart:(0,0,4,0,2,0,1,0);
          ystart:(0,0,0,4,0,2,0,1);
          xstep:(1,8,8,4,4,2,2,1);
          ystep:(1,8,8,8,4,4,2,2);
          xdist:(1,8,4,4,2,2,1,1);
          ydist:(1,8,8,4,4,2,2,1));

  {***** MING Chunks *****}
  type tMingChunk = packed record
         ChunkLength       : dword;
         ChunkType         : dword;
         { chunk data }
         CRC               : dword;
         { additional }
         ChunkPos          : dword;
       end;

        { MHDR }
  const MingChunk_MiNGHead_SimplicityProfileThere      = $00000001;
        MingChunk_MiNGHead_SimpleMNGFeatures           = $00000002;
        MingChunk_MiNGHead_ComplexMNGFeatures          = $00000004;
        MingChunk_MiNGHead_EssentialTransparency       = $00000008;
        MingChunk_MiNGHead_JiNGPresent                 = $00000010;
        MingChunk_MiNGHead_DeltaPiNG                   = $00000020;

        { IHDR }
        MingChunk_PiNGHead_GrayscaleImage              = $00;
        MingChunk_PiNGHead_RGBImage                    = $02;
        MingChunk_PiNGHead_PaletteIndexed              = $03;
        MingChunk_PiNGHead_GrayscaleAlpha              = $04;
        MingChunk_PiNGHead_RGBAlpha                    = $06;

        MingChunk_PiNGHead_ZLIB8                       = $00;
        MingChunk_PiNGHead_AdaptiveFilter              = $00;
        MingChunk_PiNGHead_NoInterlace                 = $00;
        MingChunk_PiNGHead_Adam7                       = $01;

  type tMingChunkData = packed record
         ChunkLength       : dword;
         ChunkType         : dword;
         CRC               : dword;
         ChunkPos          : dword;
         case dword of
           0: (NoChunk : array[0..32767] of byte);
           { only chunks holding information, including palette }
           1: (MiNGHead : packed record
                FrameWidth        : dword;
                FrameHeight       : dword;
                TicksPerSec       : dword;
                NominalLayerCnt   : dword;
                NominalFrameCnt   : dword;
                NominalPlayTime   : dword;
                SimplicityProfile : dword;
              end);
           2: (PiNGHead : packed record
                Width             : longint;
                Height            : longint;
                BitDepth          : byte;
                ColorType         : byte;
                CompressionType   : byte;
                FilterType        : byte;
                InterlaceType     : byte;
              end);
           3: (DefineObj : packed record
                ObjectID          : word;
                DoNotShowFlag     : byte;
                ConcreteFlag      : byte;
                XLocation         : longint;
                YLocation         : longint;
                LeftCB            : longint;
                RightCB           : longint;
                TopCB             : longint;
                BottomCB          : longint;
              end);
           4: (PiNGPalette : tMingPalette);
           5: (LatinText : record
                keyword           : string;
                nlines            : dword;
                textdata          : array[0..255] of string[127];
              end);
           6: (CompressedText : record
                keyword           : string;
                nlines            : dword;
                textdata          : array[0..255] of string[127];
              end);
           7: (GammaExp : record
                Gamma             : dword; { *100000 }
              end);
           8: (FrameDef : record
                FramingMode       : dword;
                SubframeName      : string;
                ChgFrameDelay     : dword;
                ChgTermination    : dword;
                ChgSubframeClip   : dword;
                ChgSyncID         : dword;
                InterframeDelay   : dword;
                TimeOut           : dword;
                SubframeBoundType : dword;
                LeftFB            : longint;
                RightFB           : longint;
                TopFB             : longint;
                BottomFB          : longint;
                SyncID            : dword;
              end);
           9: (JingHead : packed record
                Width             : dword;
                Height            : dword;
                ColorType         : byte;
                {  8  Gray Y      }
                { 10  Color YCC   }
                { 12  Gray YA     }
                { 14  Color YCCA  }
                ImageSampleDepth  : byte;
                {  8  8-bit       }
                { 12  12-bit      }
                { 16  2x8-bit     }
                { 20  12+8-bit    }
                CompressionMethod : byte;
                {  8  ISO-10918-1 }
                ImageInterlace    : byte;
                {  0  Sequential  }
                {  1  Adam7       }
                {  8  Progressive }
                AlphaSampleDepth  : byte;
                {  0..16          }
                AlphaCompression  : byte;
                {  0  PNG gray    }
                AlphaFilter       : byte;
                {  0  Adaptive    }
                AlphaInterlace    : byte;
                {  0  n.i.        }
                {  1  Adam7       }
              end);
       end;

  type tSetPixelProc = procedure (x,y:longint;c:tcolor);
       tGetPixelProc = function (x,y:longint):tcolor;
       tUserNewsProc = procedure (n:dword);
       tResponseProc = procedure (m:tmingchunkdata);

  type tMingEncode = class
           { error }
           errcode           : dword;
           { file }
           f                 : file;

           mingtype          : dword;

           { chunk writing }
           mingchunk         : tmingchunk;
           mingchunkdata     : tmingchunkdata;

           { graphics I/O }
           UserSetPixProc    : tSetPixelProc;
           UserGetPixProc    : tGetPixelProc;
           UserNewsProc      : tUserNewsProc;
           UserResponseProc  : tResponseProc;

           { write PNG }
           png_quality       : dword;
           { 0 - exactly                                }
           { 1 - lossy       (invisible data loss)      }
           { 2 - very lossy  (visible data loss)        }
           png_compression   : dword;
           { 0 - store                                  }
           { 1 - fastest                                }
           { 6 - default                                }
           { 9 - best                                   }
           supportpng16      : boolean;
           pingpalette       : tmingpalette;

           png_width         : longint;
           png_height        : longint;
           png_ok            : boolean;
           png_dataform      : longint;
           { 10h  RGB 8x8x8          }
           { 11h  RGB 16x16x16       }
           { 20h  RGBA 8x8x8x8       }
           { 21h  RGBA 16x16x16x16   }
           { 30h  GRAY 8             }
           { 31h  GRAY 16            }
           { 32h  GRAY 4             }
           { 33h  GRAY 2             }
           { 34h  GRAY 1             }
           { 40h  GRAY+A 8x8         }
           { 41h  GRAY+A 16x16       }
           { 50h  PAL 8              }
           { 52h  PAL 4              }
           { 53h  PAL 2              }
           { 54h  PAL 1              }
           png_linelength    : longint;
           png_nbytesback    : longint;
           png_line1         : pALine;
           png_line2         : pALine;
           png_currentline   : pALine;
           png_lastline      : pALine;
           png_filteredline  : pALine;
           png_encodebuf     : array[0..32767] of byte;
           png_yline         : dword;
           png_mystream      : z_stream;
           png_infresult     : longint; { = deflate result }
           png_curlinelength : dword;
           png_curpass       : dword;
           png_line1current  : boolean;
           png_curlinepixels : longint;

           jng_ok            : boolean;
           jng_cinfo         : jpeg_compress_struct;
           jng_err           : jpeg_error_mgr;
           jng_rowpointer    : jsamprow;
           jng_rowstride     : dword;
           jng_currentline   : pALine;


           function  ErrString(errc:dword):string;

           procedure OpenSession (name:string;ftype:dword);
           procedure CloseSession;

           procedure WriteChunk_MHDR (mdat:tmingchunkdata);
           procedure WriteChunk_IHDR (mdat:tmingchunkdata);
           procedure WriteChunk_JHDR (mdat:tmingchunkdata);
           procedure WriteChunk_PLTE (mdat:tmingchunkdata); { 256 entries }
           procedure WriteChunk_ePLTE (mdat:tmingchunkdata;entries:dword);
           procedure WriteChunk_pePLTE (mpal:tmingpalette;entries:dword);
           procedure WriteChunk_pPLTE (mpal:tmingpalette);
           procedure WriteChunk_TEXT (mdat:tmingchunkdata);
           procedure WriteChunk_kTEXT (keyword,textdata:string);
           procedure WriteChunk_ZTXT (mdat:tmingchunkdata);
           procedure WriteChunk_IEND;
           procedure WriteChunk_MEND;

           procedure MSetPix (x,y:longint;c:tcolor);
           function  MGetPix (x,y:longint):tcolor;virtual;
           procedure MUserNews (n:dword);
           procedure MResponse (m:tmingchunkdata);

           procedure InitPiNGEncode (ihdr:tmingchunkdata);
           function  PiNGEncodeFinished:boolean;
           procedure FinishPiNGEncode;
           procedure EncodePiNG;
           procedure png_FlushBuffer (nbytes:dword);
           procedure png_EncodeLine;
           procedure png_InputLine;
           procedure png_FLT_NONE;
           procedure png_FLT_SUB;
           procedure png_FLT_UP;
           procedure png_FLT_Average;
           procedure png_FLT_Paeth;
           function  png_FLT_CountBytes:longint;
           function  png_PaethFunc(a,b,c:longint):longint;
           procedure png_Reduce1;

           { write JNG }
           procedure InitJingEncode (mdat:tmingchunkdata);
           function  JiNGEncodeFinished:boolean;
           procedure FinishJiNGEncode;
           procedure EncodeJiNG;
           procedure jng_EncodeLine;
           procedure jng_InputLine;
       end;

  {***** MING Decode Object *****}
  type tMiNGObject = class
           { error }
           errcode           : dword;

           f                 : file;
           mingtype          : dword;

           { chunk }
           mingchunk         : tmingchunk;
           mingchunkdata     : tmingchunkdata;

           { graphics I/O }
           UserGetPixProc    : tGetPixelProc;
           UserNewsProc      : tUserNewsProc;
           UserResponseProc  : tResponseProc;

           { load PNG }
           adam7fillbox      : boolean; { default=false; not use if delta! }
           supportpng16      : boolean; { d=false; support 16-bit PNGs?    }
           { if true: pixel output is 8x8x8x8 rather than 16x16x16x16      }
           pingpalette       : tmingchunkdata; { palette if there          }
           currentcolorindex : dword; { index into color table if there    }

           png_codec_ok      : boolean;
           png_curfilter     : dword;
           png_type          : tMiNGChunkData;
           png_idat          : tMingChunk;
           png_lastchk       : tMingChunk;
           png_yline         : longint;
           png_width         : longint;
           png_dataform      : longint;
           { 10h  RGB 8x8x8          }
           { 11h  RGB 16x16x16       }
           { 20h  RGBA 8x8x8x8       }
           { 21h  RGBA 16x16x16x16   }
           { 30h  GRAY 8             }
           { 31h  GRAY 16            }
           { 32h  GRAY 4             }
           { 33h  GRAY 2             }
           { 34h  GRAY 1             }
           { 40h  GRAY+A 8x8         }
           { 41h  GRAY+A 16x16       }
           { 50h  PAL 8              }
           { 52h  PAL 4              }
           { 53h  PAL 2              }
           { 54h  PAL 1              }
           png_line1         : pALine; { lines (2*x)            }
           png_line2         : pALine; { lines (2*x+1)          }
           png_linelength    : longint;{ length of line 1 and 2 }
           png_curlinelength : longint;{ used for adam-7 decode }
           png_curlinepixels : longint;{ nr of pixels of curln  }
           png_currentline   : pALine; { yline                  }
           png_lastline      : pALine; { yline-1                }
           png_line1current  : boolean;{ true if line 2!=cur    }
           png_decodebuf     : array[0..32767] of byte;
           png_inchunkbytes  : longint;
           png_mystream      : z_stream;
           png_infresult     : dword;
           png_curpass       : dword;  { if adam-7, current p   }
           png_nbytesback    : longint;{ bytes back @@filtering  }
           png_chk           : tmingchunkdata;
           png_gamma8        : array[0..255] of dword;
           png_gamma         : dword; { *100000 }

           { load Object }
           curimgxadd        : longint;
           curimgyadd        : longint;
           curimgx1          : longint;
           curimgy1          : longint;
           curimgx2          : longint;
           curimgy2          : longint;


           jng_ok            : boolean;
           jng_currentline   : pALine;
           jng_linelength    : dword;
           jng_rowstride     : dword;
           jng_cinfo         : jpeg_decompress_struct;

           mng_chk           : tmingchunk;
           mng_ok            : boolean;
           mng_objtype       : dword;
           { 0 = NONE    }
           { 1 = BASI    }
           { 2 = PING    }
           { 3 = JING    }
           mng_firstimgdone  : boolean;
           mng_ticklength    : dword; { length of a tick in 誑 }
           mng_delaytype     : dword;
           { 0 = never                                  }
           { 1 = before each IHDR/JHDR                  }
           { 2 = before each FRAM                       }
           mng_lasttime      : dword;
           mng_currenttime   : dword;
           function  ErrString(errc:dword):string;
           { file }
           procedure OpenSession (fname:string);
           procedure CloseSession;

           { signature }
           function  ReadMingSignature:tMingSignature;
           function  IdentifyMing:dword;

           function  NrOfChunks:dword;
           function  GetChunk(cnum:dword):tMingChunk;
           function  AncillaryChunk (cchunk:tMingChunk):boolean;
           function  PrivateChunk (cchunk:tMingChunk):boolean;
           function  SafeToCopyChunk (cchunk:tMingChunk):boolean;
           function  CalculateCRC (cchunk:tMingChunk):dword;

           { chunk streaming }
           function  GetFirstChunk:tMingChunk;
           procedure SkipChunkData (var thischk:tMingChunk);
           function  SkipChunkDataGetCRC (var thischk:tMingChunk):dword;
           function  GetNextChunk (lastchk:tMingChunk):tMingChunk;
           function  LastChunk(thischk:tMingChunk):boolean;
           function  GetChunkData (var thischk:tMingChunk;var mdat:tMingChunkData):dword;

           { chunk processing }
           function  Process_MHDR (var mdat:tMingChunkData):dword;
           function  Process_IHDR (var mdat:tMingChunkData):dword;
           function  Process_JHDR (var mdat:tMingChunkData):dword;
           function  Process_DEFI (var mdat:tMingChunkData):dword;
           function  Process_PLTE (var mdat:tMingChunkData):dword;
           function  Process_TEXT (var mdat:tMingChunkData):dword;
           function  Process_ZTXT (var mdat:tMingChunkData):dword;
           function  Process_GAMA (var mdat:tMingChunkData):dword;
           function  Process_FRAM (var mdat:tMingChunkData):dword;

           procedure UserSetPixProc(x,y:longint;c:tcolor);virtual;
           procedure MSetPix(x,y:longint;c:tcolor);
           function  MGetPix (x,y:longint):tcolor;
           procedure MUserNews (n:dword);
           procedure MResponse (m:tmingchunkdata);

           procedure InitPiNGLoad (phead:tMingChunkData);
           procedure PiNGLoad;
           function  PiNGLoadFinished:boolean;
           procedure FinishPiNGLoad;
           { for 16-bit data: gamma is calculated every time }
           procedure png_DecompressLine;
           procedure png_DeFilterLine;
           procedure png_OutputLine;
           procedure png_ReadBuffer;
           procedure png_SeekToNextIDAT;
           procedure png_DeFLT_SUB;
           procedure png_DeFLT_UP;
           procedure png_DeFLT_AVERAGE;
           procedure png_DeFLT_PAETH;
           function  png_PaethFunc(a,b,c:longint):longint;

           { /// old /// }
           procedure InitObjectLoad (pchk:tMingChunkData);
           { This procedure begins to load a MNG layer, frame or image     }
           { into memory, it should be placed at a DEFI or IHDR/JHDR/BASI  }
           { chunk                                                         }
           procedure ObjectLoad;
           function  ObjectLoadFinished:boolean;
           procedure FinishObjectLoad;

           { load JNG }
           procedure InitJiNGLoad (phead:tMingChunkData);
           procedure JiNGLoad;
           function  JiNGLoadFinished:boolean;
           procedure FinishJiNGLoad;

           { load MNG }
           procedure InitMiNGLoad; { starts with the first chunk           }
           procedure MiNGLoad;
           function  MiNGLoadFinished:boolean;
           function  MiNGLoadFirstImageFinished:boolean;
           procedure FinishMiNGLoad;

       end;

implementation

const ming_errstring : array[0..7] of string = (
 { 0 }  'No error found.',
 { 1 }  'Wrong file type.',
 { 2 }  'Chunk does not exist.',
 { 3 }  'File not found.',
 { 4 }  'Unknown chunk type, skipping.',
 { 5 }  'Could not decode graphics.',
 { 6 }  'Unknown error code.',
 { 7 }  'Could not encode graphics.');

function  tMingObject.ErrString(errc:dword):string;

begin
  errstring:=ming_errstring[errc mod (high(ming_errstring)+1)];
end;

function  tMingEncode.ErrString(errc:dword):string;

begin
  errstring:=ming_errstring[errc mod (high(ming_errstring)+1)];
end;

procedure tMingObject.InitJingLoad (phead:tMingChunkData);

begin
  jng_ok:=false;

  jng_rowstride:=phead.jinghead.width*3;
  getmem(jng_currentline,jng_rowstride);

  jpeg_create_decompress(@@jng_cinfo);
  jpeg_stdio_src(@@jng_cinfo,@@f);


  jng_ok:=true;
end;

procedure tMingObject.JiNGLoad;

begin
end;

function  tMingObject.JiNGLoadFinished:boolean;

begin
end;

procedure tMingObject.FinishJiNGLoad;

begin
  if jng_ok then begin
    freemem(jng_currentline,jng_rowstride);

    jng_ok:=false;
  end;
end;

procedure tMingEncode.InitJingEncode (mdat:tmingchunkdata);

var c:tcolor;
    x:dword;
    ck:tmingchunk;

begin
  jng_ok:=false;
  { start encode }
  jng_cinfo.err:=jpeg_std_error(jng_err);
  jng_err.trace_level:=3;
  jpeg_create_compress(@@jng_cinfo);
  jpeg_stdio_dest(@@jng_cinfo,@@f);

  jng_cinfo.image_width:=mdat.jinghead.width;
  jng_cinfo.image_height:=mdat.jinghead.height;
  jng_cinfo.input_components:=3;
  jng_cinfo.in_color_space:=JCS_RGB;
  jpeg_set_defaults(@@jng_cinfo);
  jpeg_set_quality(@@jng_cinfo,100,true);

  jpeg_start_compress(@@jng_cinfo,true);
  jng_rowstride:=mdat.jinghead.width*3;


  getmem(jng_currentline,jng_rowstride);

  jng_ok:=true;
end;

function  tMingEncode.JingEncodeFinished:boolean;

begin
  if jng_ok and (jng_cinfo.next_scanline<jng_cinfo.image_height)
    then jingencodefinished:=false
    else jingencodefinished:=true;
end;

procedure tMingEncode.jng_EncodeLine;

begin
  jng_rowpointer:=jsamprow(jng_currentline);
  jpeg_write_scanlines(@@jng_cinfo,jsamparray(@@jng_rowpointer),1);
end;

procedure tMingEncode.FinishJingEncode;

begin
  if jng_ok then begin
    jpeg_finish_compress(@@jng_cinfo);
    jpeg_destroy_compress(@@jng_cinfo);
    freemem(jng_currentline,jng_rowstride);
    jng_ok:=false;
  end;
end;

procedure tMingEncode.jng_InputLine;

var c:tcolor;
    z,x:dword;

begin
  z:=0;
  for x:=0 to jng_cinfo.image_width-1 do begin
    c:=mgetpix(x,jng_cinfo.next_scanline);
    jng_currentline^[z]:=c.red and $FF;   inc(z);
    jng_currentline^[z]:=c.green and $FF; inc(z);
    jng_currentline^[z]:=c.blue and $FF;  inc(z);
  end;
end;

procedure tMingEncode.EncodeJing;

begin
  if jingencodefinished then exit;

  jng_InputLine;
  jng_EncodeLine;
end;

procedure tMingEncode.png_FlushBuffer (nbytes:dword);

var ck:tmingchunk;
    p:pbytef;
    mycrc:dword;

begin
  { set up }
  nbytes:=smallest(nbytes,32768);
  ck.chunklength:=nbytes;
  ck.chunktype:=mingchunk_imagedata;
  dbswap32(ck.chunklength);

  { calculate CRC }
  mycrc:=crc32(0,z_null,0);
  p:=@@ck.chunktype;  mycrc:=crc32(mycrc,p,4);
  p:=@@png_encodebuf; mycrc:=crc32(mycrc,p,nbytes);
  dbswap32(mycrc);

  { flush }
  blockwrite (f,ck,8);
  blockwrite (f,png_encodebuf,nbytes);
  blockwrite (f,mycrc,4);
end;

function  tMingEncode.PiNGEncodeFinished:boolean;

begin
  if ((png_curpass=0) and (png_ok) and (png_yline<=png_height)) or
     ((png_curpass>=1) and (png_ok) and (png_curpass<8))
    then pingencodefinished:=false
    else pingencodefinished:=true;
end;

procedure tMingEncode.FinishPiNGEncode;

begin
  if png_ok then begin
    png_ok:=false;
    deflateend(png_mystream);
    png_FlushBuffer(32768-png_mystream.avail_out);
    freemem(png_line1,png_linelength);
    freemem(png_line2,png_linelength);
    freemem(png_filteredline,png_linelength);
  end;
end;

procedure tMingEncode.png_EncodeLine;

begin
  png_mystream.next_in:=@@(png_filteredline^);
  png_mystream.avail_in:=png_curlinelength;
  png_mystream.total_in:=$FFFFFFFF;
  while true do begin
    if png_mystream.avail_out=0 then begin
      png_FlushBuffer(32768);
      png_mystream.next_out:=@@png_encodebuf;
      png_mystream.avail_out:=32768;
      png_mystream.total_out:=$FFFFFFFF;
    end;
    if png_mystream.avail_in=0 then break;
    png_infresult:=deflate(png_mystream,z_sync_flush);
    if png_infresult<0 then break;
  end;
end;

procedure tMingEncode.png_InputLine;

type warray = array[0..1147483647 div 2] of word;

var x,z:longint;
    c:tcolor;
    w:^warray;
    a:longint;

begin
  z:=1;
  w:=@@(png_currentline^[1]);
  case png_dataform of
    $10: for x:=0 to png_curlinepixels-1 do begin
           c:=mgetpix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline);
           png_currentline^[z]:=c.red;   inc(z);
           png_currentline^[z]:=c.green; inc(z);
           png_currentline^[z]:=c.blue;  inc(z);
         end;
    $11: if supportpng16 then begin
           z:=0;
           for x:=0 to png_curlinepixels-1 do begin
             c:=mgetpix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline);
             w^[z]:=c.red;   inc(z);
             w^[z]:=c.green; inc(z);
             w^[z]:=c.blue;  inc(z);
           end;
         end else begin
           z:=0;
           for x:=0 to png_curlinepixels-1 do begin
             c:=mgetpix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline);
             w^[z]:=c.red*257;   inc(z);
             w^[z]:=c.green*257; inc(z);
             w^[z]:=c.blue*257;  inc(z);
           end;
         end;
    $20: for x:=0 to png_curlinepixels-1 do begin
           c:=mgetpix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline);
           png_currentline^[z]:=c.red;   inc(z);
           png_currentline^[z]:=c.green; inc(z);
           png_currentline^[z]:=c.blue;  inc(z);
           png_currentline^[z]:=c.alpha; inc(z);
         end;
    $21: if supportpng16 then begin
           z:=0;
           for x:=0 to png_curlinepixels-1 do begin
             c:=mgetpix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline);
             w^[z]:=c.red;   inc(z);
             w^[z]:=c.green; inc(z);
             w^[z]:=c.blue;  inc(z);
             w^[z]:=c.alpha; inc(z);
           end;
         end else begin
           z:=0;
           for x:=0 to png_curlinepixels-1 do begin
             c:=mgetpix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline);
             w^[z]:=c.red*257;   inc(z);
             w^[z]:=c.green*257; inc(z);
             w^[z]:=c.blue*257;  inc(z);
             w^[z]:=c.alpha*267; inc(z);
           end;
         end;
    $30: for x:=0 to png_curlinepixels-1 do begin
           c:=mgetpix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline);
           png_currentline^[x+1]:=c.gray;
         end;
    $31: if supportpng16 then begin
           z:=0;
           for x:=0 to png_curlinepixels-1 do begin
             c:=mgetpix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline);
             w^[x]:=c.gray;
           end;
         end else begin
           z:=0;
           for x:=0 to png_curlinepixels-1 do begin
             c:=mgetpix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline);
             w^[x]:=c.gray*257;
           end;
         end;
    $32: for x:=0 to png_curlinepixels-1 do begin
           c:=mgetpix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline);
           case (x and 1) of
             0: a:=(c.index and $0F) shl 4;
             1: a:=(c.index and $0F) or a;
           end;
           if (x and 1=1) or (x=png_curlinepixels-1) then begin
             png_currentline^[z]:=a;
             inc(z);
           end;
         end;
    $33: for x:=0 to png_curlinepixels-1 do begin
           c:=mgetpix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline);
           case (x and 3) of
             0: a:=(c.index and $03) shl 6;
             1: a:=((c.index and $03) shl 4) or a;
             2: a:=((c.index and $03) shl 2) or a;
             3: a:=(c.index and $03) or a;
           end;
           if (x and 3=3) or (x=png_curlinepixels-1) then begin
             png_currentline^[z]:=a;
             inc(z);
           end;
         end;
    $34: for x:=0 to png_curlinepixels-1 do begin
           c:=mgetpix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline);
           case (x and 7) of
             0: a:=(c.index and 1) shl 7;
             1: a:=a or ((c.index and 1) shl 6);
             2: a:=a or ((c.index and 1) shl 5);
             3: a:=a or ((c.index and 1) shl 4);
             4: a:=a or ((c.index and 1) shl 3);
             5: a:=a or ((c.index and 1) shl 2);
             6: a:=a or ((c.index and 1) shl 1);
             7: a:=a or (c.index and 1);
           end;
           if (x and 7=7) or (x=png_curlinepixels-1) then begin
             png_currentline^[z]:=a;
             inc(z);
           end;
         end;
    $40: for x:=0 to png_curlinepixels-1 do begin
           c:=mgetpix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline);
           png_currentline^[z]:=c.gray;  inc(z);
           png_currentline^[z]:=c.alpha; inc(z);
         end;
    $41: if supportpng16 then begin
           z:=0;
           for x:=0 to png_curlinepixels-1 do begin
             c:=mgetpix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline);
             w^[z]:=c.gray; inc(z);
             w^[z]:=c.alpha;inc(z);
           end;
         end else begin
           z:=0;
           for x:=0 to png_curlinepixels-1 do begin
             c:=mgetpix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline);
             w^[z]:=c.gray*257;  inc(z);
             w^[z]:=c.alpha*257; inc(z);
           end;
         end;
    $50: for x:=0 to png_curlinepixels-1 do begin
           c:=mgetpix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline);
           png_currentline^[x+1]:=c.index;
         end;
    $52: for x:=0 to png_curlinepixels-1 do begin
           c:=mgetpix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline);
           case (x and 1) of
             0: a:=(c.index and $0F) shl 4;
             1: a:=(c.index and $0F) or a;
           end;
           if (x and 1=1) or (x=png_curlinepixels-1) then begin
             png_currentline^[z]:=a;
             inc(z);
           end;
         end;
    $53: for x:=0 to png_curlinepixels-1 do begin
           c:=mgetpix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline);
           case (x and 3) of
             0: a:=(c.index and $03) shl 6;
             1: a:=((c.index and $03) shl 4) or a;
             2: a:=((c.index and $03) shl 2) or a;
             3: a:=(c.index and $03) or a;
           end;
           if (x and 3=3) or (x=png_curlinepixels-1) then begin
             png_currentline^[z]:=a;
             inc(z);
           end;
         end;
    $54: for x:=0 to png_curlinepixels-1 do begin
           c:=mgetpix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline);
           case (x and 7) of
             0: a:=(c.index and 1) shl 7;
             1: a:=a or ((c.index and 1) shl 6);
             2: a:=a or ((c.index and 1) shl 5);
             3: a:=a or ((c.index and 1) shl 4);
             4: a:=a or ((c.index and 1) shl 3);
             5: a:=a or ((c.index and 1) shl 2);
             6: a:=a or ((c.index and 1) shl 1);
             7: a:=a or (c.index and 1);
           end;
           if (x and 7=7) or (x=png_curlinepixels-1) then begin
             png_currentline^[z]:=a;
             inc(z);
           end;
         end;
  end;
end;

procedure tMingEncode.MSetPix(x,y:longint;c:tcolor);

begin
  usersetpixproc(x,y,c);
end;

function  tMingEncode.MGetPix(x,y:longint):tcolor;

begin
  mgetpix:=usergetpixproc(x,y);
end;

procedure tMingEncode.MUserNews (n:dword);

begin
  usernewsproc(n);
end;

procedure tMingEncode.MResponse (m:tmingchunkdata);

begin
  userresponseproc(m);
end;

function  tMingEncode.png_FLT_CountBytes:longint;

type tarray=array[0..2147483647] of byte;

var x,t,u:longint;
    s:^tarray;

begin
  t:=0;
  s:=@@(png_filteredline^);
  for x:=1 to png_curlinelength-1 do begin
    u:=abs(s^[x]);
    inc(t,u);
  end;
  png_flt_countbytes:=t;
end;

procedure tMingEncode.png_FLT_SUB;

var x:dword;
    z0,z1:longint;

begin
  for x:=1 to png_curlinelength-1 do begin
    z0:=png_currentline^[x];
    if (x>png_nbytesback) then z1:=png_currentline^[x-png_nbytesback]
                          else z1:=0;
    png_filteredline^[x]:=(z0-z1) and $FF;
  end;
  png_filteredline^[0]:=1;
end;

procedure tMingEncode.png_FLT_UP;

var x:dword;
    z0,z1:longint;

begin
  for x:=1 to png_curlinelength-1 do begin
    z0:=png_currentline^[x];
    z1:=png_lastline^[x];
    png_filteredline^[x]:=(z0-z1) and $FF;
  end;
  png_filteredline^[0]:=2;
end;

procedure tMingEncode.png_FLT_Average;

var x:dword;
    z0,z1,z2:longint;

begin
  for x:=1 to png_curlinelength-1 do begin
    z0:=png_currentline^[x];
    z2:=png_lastline^[x];
    if x>png_nbytesback then z1:=png_currentline^[x-png_nbytesback]
                        else z1:=0;
    png_filteredline^[x]:=(z0-((z1+z2) shr 1)) and $FF;
  end;
  png_filteredline^[0]:=3;
end;

procedure tMingEncode.png_FLT_Paeth;

var x:dword;
    z0,z1,z2,z3:longint;

begin
  for x:=1 to png_curlinelength-1 do begin
    z0:=png_currentline^[x];
    z2:=png_lastline^[x];
    if x>png_nbytesback then begin
      z1:=png_currentline^[x-png_nbytesback];
      z3:=png_lastline^[x-png_nbytesback];
    end else begin
      z1:=0;
      z3:=0;
    end;
    png_filteredline^[x]:=(z0-png_PaethFunc(z1,z2,z3)) and $FF;
  end;
  png_filteredline^[0]:=4;
end;

procedure tMingEncode.png_FLT_None;

begin
  move(png_currentline^[1],png_filteredline^[1],png_curlinelength-1);
  png_filteredline^[0]:=0;
end;

procedure tMingEncode.png_Reduce1;

type t1 = array[0..1147483647 div 2] of word;

var x:dword;
    w:^t1;

begin
  { 8->7   }
  { 16->12 }
  w:=@@(png_currentline^[1]);
  case png_dataform of
    $10,$20,$30: for x:=1 to png_curlinelength-1 do png_currentline^[x]:=png_currentline^[x] and $FE;
    $11,$21,$41: for x:=0 to (png_curlinelength shr 1)-1 do w^[x]:=w^[x] and $FFF0;
  end;
end;

procedure tMingEncode.EncodePiNG;

var x:longint;
    nsub,
    nup,
    navg,
    npae     : longint;

begin
  if pingencodefinished then exit;
  { set up }
  case png_line1current of
    true:  begin png_currentline:=png_line2; png_lastline:=png_line1; end;
    false: begin png_currentline:=png_line1; png_lastline:=png_line2; end;
  end;

  { get data }
  png_InputLine;

  { reduce quality }
  case png_quality of
    0:;
    1,2: png_Reduce1;
  end;

  { filter }
  png_FLT_Sub;     nsub:=png_flt_countbytes;
  png_FLT_Up;      nup :=png_flt_countbytes;
  png_FLT_Average; navg:=png_flt_countbytes;
  png_FLT_Paeth;   npae:=png_flt_countbytes;

  if (nsub<nup) and (nsub<navg) and (nsub<npae) then begin
    png_flt_sub;
  end else begin
    if (nup<navg) and (nup<npae) then begin
      png_flt_up;
    end else begin
      if (navg<npae) then begin
        png_flt_average;
      end else begin
        { nothing to do }
      end;
    end;
  end;


  { encode }
  png_encodeline;

  { done }
  inc(png_yline,adam7_pixpos.ystep[png_curpass]);
  png_line1current:=not png_line1current;
  if (png_yline>=png_height) and (png_curpass>=1) and (png_curpass<8) then begin
    png_line1current:=true;
    repeat
      inc(png_curpass);
      png_yline:=adam7_pixpos.ystart[png_curpass];
      png_curlinepixels:=(png_width-
                          adam7_pixpos.xstart[png_curpass]+
                          adam7_pixpos.xstep[png_curpass]-1) div
                          adam7_pixpos.xstep[png_curpass];
    until ((adam7_pixpos.ystart[png_curpass]<png_height) and
           (png_curlinepixels>0)) or (png_curpass>=8);
    case png_dataform of
      $10: png_curlinelength:=png_curlinepixels*3+1;
      $11: png_curlinelength:=png_curlinepixels*6+1;

      $20: png_curlinelength:=png_curlinepixels shl 2+1;
      $21: png_curlinelength:=png_curlinepixels shl 3+1;

      $30: png_curlinelength:=png_curlinepixels+1;
      $31: png_curlinelength:=png_curlinepixels shl 1+1;
      $32: png_curlinelength:=(png_curlinepixels+1) shr 1+1;
      $33: png_curlinelength:=(png_curlinepixels+3) shr 2+1;
      $34: png_curlinelength:=(png_curlinepixels+7) shr 3+1;

      $40: png_curlinelength:=png_curlinepixels shl 1+1;
      $41: png_curlinelength:=png_curlinepixels shl 2+1;

      $50: png_curlinelength:=png_curlinepixels+1;
      $52: png_curlinelength:=(png_curlinepixels+1) shr 1+1;
      $53: png_curlinelength:=(png_curlinepixels+3) shr 2+1;
      $54: png_curlinelength:=(png_curlinepixels+7) shr 3+1;
    end;
    for x:=0 to png_curlinelength-1 do png_line1^[x]:=0;
    for x:=0 to png_curlinelength-1 do png_line2^[x]:=0;
  end;
end;

procedure tMingEncode.InitPiNGEncode (ihdr:tmingchunkdata);

var x:longint;

begin
  png_ok:=false;
  with ihdr.pinghead do begin
    if (width<=0) or (height<=0) then begin errcode:=7; exit; end;
    if (compressiontype>0) or (filtertype>0) or (interlacetype>1) then begin
      errcode:=7;
      exit;
    end;
    png_width:=width;
    png_height:=height;
    png_dataform:=0;
    case colortype of
      mingchunk_pinghead_grayscaleimage: case bitdepth of
                                           16: png_dataform:=$31;
                                            8: png_dataform:=$30;
                                            4: png_dataform:=$32;
                                            2: png_dataform:=$33;
                                            1: png_dataform:=$34;
                                         end;
      mingchunk_pinghead_rgbimage:       case bitdepth of
                                           16: png_dataform:=$11;
                                            8: png_dataform:=$10;
                                         end;
      mingchunk_pinghead_paletteindexed: case bitdepth of
                                            8: png_dataform:=$50;
                                            4: png_dataform:=$52;
                                            2: png_dataform:=$53;
                                            1: png_dataform:=$54;
                                         end;
      mingchunk_pinghead_grayscalealpha: case bitdepth of
                                           16: png_dataform:=$41;
                                            8: png_dataform:=$40;
                                         end;
      mingchunk_pinghead_rgbalpha:       case bitdepth of
                                           16: png_dataform:=$21;
                                            8: png_dataform:=$20;
                                         end;
    end;
    if png_dataform=0 then begin
      errcode:=7;
      exit;
    end;
  end;
  if (png_quality>=3) or (png_compression>=10) then begin
    errcode:=7;
    exit;
  end;
  case png_dataform of
    $10: png_linelength:=png_width*3+1;
    $11: png_linelength:=png_width*6+1;

    $20: png_linelength:=png_width shl 2+1;
    $21: png_linelength:=png_width shl 3+1;

    $30: png_linelength:=png_width+1;
    $31: png_linelength:=png_width shl 1+1;
    $32: png_linelength:=(png_width+1) shr 1+1;
    $33: png_linelength:=(png_width+3) shr 2+1;
    $34: png_linelength:=(png_width+7) shr 3+1;

    $40: png_linelength:=png_width shl 1+1;
    $41: png_linelength:=png_width shl 2+1;

    $50: png_linelength:=png_width+1;
    $51: png_linelength:=png_width shl 1+1;
    $52: png_linelength:=(png_width+1) shr 1+1;
    $53: png_linelength:=(png_width+3) shr 2+1;
    $54: png_linelength:=(png_width+7) shr 3+1;
  end;
  case png_dataform of
    $10: png_nbytesback:=3;
    $11: png_nbytesback:=6;

    $20: png_nbytesback:=4;
    $21: png_nbytesback:=8;

    $30: png_nbytesback:=1;
    $31: png_nbytesback:=2;
    $32: png_nbytesback:=1;
    $33: png_nbytesback:=1;
    $34: png_nbytesback:=1;

    $40: png_nbytesback:=2;
    $41: png_nbytesback:=4;

    $50: png_nbytesback:=1;
    $51: png_nbytesback:=2;
    $52: png_nbytesback:=1;
    $53: png_nbytesback:=1;
    $54: png_nbytesback:=1;
  end;
  getmem(png_line1,png_linelength);
  getmem(png_line2,png_linelength);
  getmem(png_filteredline,png_linelength);
  for x:=0 to png_linelength-1 do png_line1^[x]:=0;
  for x:=0 to png_linelength-1 do png_line2^[x]:=0;
  { start encode }
  png_mystream.zalloc:=nil;
  png_mystream.zfree:=nil;
  png_mystream.opaque:=nil;
  png_mystream.next_in:=nil;
  png_mystream.avail_in:=0;
  png_mystream.total_in:=$FFFFFFFF;
  png_mystream.next_out:=@@png_encodebuf;
  png_mystream.avail_out:=32768;
  png_mystream.total_out:=$FFFFFFFF;
  png_infresult:=deflateinit(png_mystream,png_compression);
  png_yline:=0;
  png_line1current:=true;
  writechunk_ihdr(ihdr);
  case ihdr.pinghead.interlacetype of
    0: begin
         png_curpass:=0;
         png_curlinelength:=png_linelength;
         png_curlinepixels:=png_width;
       end;
    1: begin
         png_curpass:=1;
         png_curlinepixels:=(png_width-
                             adam7_pixpos.xstart[png_curpass]+
                             adam7_pixpos.xstep[png_curpass]-1) div
                            adam7_pixpos.xstep[png_curpass];
         case png_dataform of
           $10: png_curlinelength:=png_curlinepixels*3+1;
           $11: png_curlinelength:=png_curlinepixels*6+1;

           $20: png_curlinelength:=png_curlinepixels shl 2+1;
           $21: png_curlinelength:=png_curlinepixels shl 3+1;

           $30: png_curlinelength:=png_curlinepixels+1;
           $31: png_curlinelength:=png_curlinepixels shl 1+1;
           $32: png_curlinelength:=(png_curlinepixels+1) shr 1+1;
           $33: png_curlinelength:=(png_curlinepixels+3) shr 2+1;
           $34: png_curlinelength:=(png_curlinepixels+7) shr 3+1;

           $40: png_curlinelength:=png_curlinepixels shl 1+1;
           $41: png_curlinelength:=png_curlinepixels shl 2+1;

           $50: png_curlinelength:=png_curlinepixels+1;
           $52: png_curlinelength:=(png_curlinepixels+1) shr 1+1;
           $53: png_curlinelength:=(png_curlinepixels+3) shr 2+1;
           $54: png_curlinelength:=(png_curlinepixels+7) shr 3+1;
         end;
       end;
  end;
  png_ok:=true;
end;

procedure tMingEncode.WriteChunk_IEND;

var mycrc:dword;
    mdat:tmingchunkdata;
    p:pbytef;

begin
  { set up }
  mdat.chunklength:=0;
  mdat.chunktype:=mingchunk_IEND;
  { swap bytes }
  dbswap32(mdat.chunklength);
  { calculate CRC }
  mycrc:=crc32(0,z_null,0);
  p:=@@mdat.chunktype;   mycrc:=crc32(mycrc,p,4);
  dbswap32(mycrc);
  { write data }
  blockwrite (f,mdat.chunklength,8);
  blockwrite (f,mycrc,4);
end;

procedure tMingEncode.WriteChunk_MEND;

var mycrc:dword;
    mdat:tmingchunkdata;
    p:pbytef;

begin
  { set up }
  mdat.chunklength:=0;
  mdat.chunktype:=mingchunk_MEND;
  { swap bytes }
  dbswap32(mdat.chunklength);
  { calculate CRC }
  mycrc:=crc32(0,z_null,0);
  p:=@@mdat.chunktype;   mycrc:=crc32(mycrc,p,4);
  dbswap32(mycrc);
  { write data }
  blockwrite (f,mdat.chunklength,8);
  blockwrite (f,mycrc,4);
end;

procedure tMingEncode.WriteChunk_kTEXT (keyword,textdata:string);

var mdat:tmingchunkdata;

begin
  mdat.latintext.keyword:=keyword;
  mdat.latintext.nlines:=1;
  mdat.latintext.textdata[0]:=textdata;
  writechunk_text(mdat);
end;

procedure tMingEncode.WriteChunk_ZTXT (mdat:tmingchunkdata);

var mbuf:array[0..32767] of byte;
    mbuf2:array[0..32899] of byte;
    mkey:array[0..255] of byte;
    mkeyl:dword;
    mbuf2l:dword;
    x,y,p:dword;
    b,mycrc:dword;
    pf:pbytef;

begin
  { set up }
  mdat.chunktype:=mingchunk_ztxt;
  { form data: key word }
  if length(mdat.latintext.keyword)=0 then mdat.latintext.keyword:='Undefined';
  p:=0;
  for x:=0 to length(mdat.latintext.keyword)-1 do begin
    b:=ord(mdat.latintext.keyword[x+1]);
    if ((b>= 32) and (b<=126)) or
       ((b>=161) and (b<=255)) then begin
      mkey[p]:=b;
      inc(p);
    end;
  end;
  if p=0 then begin
    mkey[0]:=ord('U'); mkey[1]:=ord('n'); mkey[2]:=ord('d'); mkey[3]:=ord('e');
    mkey[4]:=ord('f'); mkey[5]:=ord('i'); mkey[6]:=ord('n'); mkey[7]:=ord('e');
    mkey[8]:=ord('d');
    p:=9;
  end;
  mkey[p]:=0;  inc(p); { NULL           }
  mkey[p]:=0;  inc(p); { compression    }
  mkeyl:=p;
  p:=0;
  { form data: text string }
  if mdat.latintext.nlines>0 then for y:=0 to mdat.latintext.nlines-1 do begin
    if length(mdat.latintext.textdata[y])>0 then for x:=0 to length(mdat.latintext.textdata[y])-1 do begin
      b:=ord(mdat.latintext.textdata[y][x+1]);
      if ((b>= 32) and (b<=126)) or
         ((b>=161) and (b<=255)) then begin
        mbuf[p]:=b;
        inc(p);
      end;
    end;
    if y<(mdat.latintext.nlines-1) then begin
      mbuf[p]:=10;
      inc(p);
    end;
  end;
  { compress }
  pf:=@@mbuf2;
  mbuf2l:=32900;
  compress2 (pf,mbuf2l,mbuf,p,9);
  mdat.chunklength:=mbuf2l+mkeyl;
  { swap bytes }
  dbswap32(mdat.chunklength);
  { calculate CRC }
  mycrc:=crc32(0,z_null,0);
  pf:=@@mdat.chunktype;   mycrc:=crc32(mycrc,pf,4);
  pf:=@@mkey;             mycrc:=crc32(mycrc,pf,mkeyl);
  pf:=@@mbuf2;            mycrc:=crc32(mycrc,pf,mbuf2l);
  dbswap32(mycrc);
  { write data }
  blockwrite (f,mdat.chunklength,8);
  blockwrite (f,mkey,mkeyl);
  blockwrite (f,mbuf2,mbuf2l);
  blockwrite (f,mycrc,4);
end;

procedure tMingEncode.WriteChunk_TEXT (mdat:tmingchunkdata);

var mbuf:array[0..32767] of byte;
    x,y,p:dword;
    b,mycrc:dword;
    pf:pbytef;

begin
  { set up }
  mdat.chunktype:=mingchunk_text;
  { form data: key word }
  if length(mdat.latintext.keyword)=0 then mdat.latintext.keyword:='Undefined';
  p:=0;
  for x:=0 to length(mdat.latintext.keyword)-1 do begin
    b:=ord(mdat.latintext.keyword[x+1]);
    if ((b>= 32) and (b<=126)) or
       ((b>=161) and (b<=255)) then begin
      mbuf[p]:=b;
      inc(p);
    end;
  end;
  if p=0 then begin
    mbuf[0]:=ord('U'); mbuf[1]:=ord('n'); mbuf[2]:=ord('d'); mbuf[3]:=ord('e');
    mbuf[4]:=ord('f'); mbuf[5]:=ord('i'); mbuf[6]:=ord('n'); mbuf[7]:=ord('e');
    mbuf[8]:=ord('d');
    p:=9;
  end;
  mbuf[p]:=0;
  inc(p);
  { form data: text string }
  if mdat.latintext.nlines>0 then for y:=0 to mdat.latintext.nlines-1 do begin
    if length(mdat.latintext.textdata[y])>0 then for x:=0 to length(mdat.latintext.textdata[y])-1 do begin
      b:=ord(mdat.latintext.textdata[y][x+1]);
      if ((b>= 32) and (b<=126)) or
         ((b>=161) and (b<=255)) then begin
        mbuf[p]:=b;
        inc(p);
      end;
    end;
    if y<(mdat.latintext.nlines-1) then begin
      mbuf[p]:=10;
      inc(p);
    end;
  end;
  mdat.chunklength:=p;
  { swap bytes }
  dbswap32(mdat.chunklength);
  { calculate CRC }
  mycrc:=crc32(0,z_null,0);
  pf:=@@mdat.chunktype;   mycrc:=crc32(mycrc,pf,4);
  pf:=@@mbuf;             mycrc:=crc32(mycrc,pf,p);
  dbswap32(mycrc);
  { write data }
  blockwrite (f,mdat.chunklength,8);
  blockwrite (f,mbuf,p);
  blockwrite (f,mycrc,4);
end;

procedure tMingEncode.WriteChunk_pePLTE (mpal:tmingpalette;entries:dword);

var mdat:tmingchunkdata;

begin
  mdat.pingpalette:=mpal;
  writechunk_eplte(mdat,entries);
end;

procedure tMingEncode.WriteChunk_pPLTE (mpal:tmingpalette);

var mdat:tmingchunkdata;

begin
  mdat.pingpalette:=mpal;
  writechunk_plte(mdat);
end;

procedure tMingEncode.WriteChunk_PLTE (mdat:tmingchunkdata);

begin
  writechunk_eplte(mdat,256);
end;

procedure tMingEncode.WriteChunk_ePLTE (mdat:tmingchunkdata;entries:dword);

var mycrc:dword;
    p:pbytef;
    x:dword;
    coltab : array[0..255] of array[0..2] of byte;

begin
  { set up }
  if entries>256 then entries:=256;
  for x:=0 to entries-1 do with mdat.pingpalette[x] do begin
    coltab[x][0]:=red;
    coltab[x][1]:=green;
    coltab[x][2]:=blue;
  end;
  mdat.chunklength:=entries*3;
  mdat.chunktype:=mingchunk_PLTE;
  { swap bytes }
  dbswap32(mdat.chunklength);
  { calculate CRC }
  mycrc:=crc32(0,z_null,0);
  p:=@@mdat.chunktype;   mycrc:=crc32(mycrc,p,4);
  p:=@@coltab;           mycrc:=crc32(mycrc,p,entries*3);
  dbswap32(mycrc);
  { write data }
  blockwrite (f,mdat.chunklength,8);
  blockwrite (f,coltab,entries*3);
  blockwrite (f,mycrc,4);
end;

procedure tMingEncode.WriteChunk_IHDR (mdat:tmingchunkdata);

var mycrc:dword;
    p:pbytef;

begin
  { set up }
  mdat.chunklength:=13;
  mdat.chunktype:=mingchunk_IHDR;
  { swap bytes }
  dbswap32(mdat.chunklength);
  dbswap32(mdat.pinghead.width);
  dbswap32(mdat.pinghead.height);
  { calculate CRC }
  mycrc:=crc32(0,z_null,0);
  p:=@@mdat.chunktype;   mycrc:=crc32(mycrc,p,4);
  p:=@@mdat.pinghead;    mycrc:=crc32(mycrc,p,13);
  dbswap32(mycrc);
  { write data }
  blockwrite (f,mdat.chunklength,8);
  blockwrite (f,mdat.pinghead,13);
  blockwrite (f,mycrc,4);
end;

procedure tMingEncode.WriteChunk_JHDR (mdat:tmingchunkdata);

var mycrc:dword;
    p:pbytef;

begin
  { set up }
  mdat.chunklength:=16;
  mdat.chunktype:=mingchunk_JHDR;
  { swap bytes }
  dbswap32(mdat.chunklength);
  with mdat.jinghead do begin
    dbswap32(width);
    dbswap32(height);
  end;
  { calculate CRC }
  mycrc:=crc32(0,z_null,0);
  p:=@@mdat.chunktype;   mycrc:=crc32(mycrc,p,4);
  p:=@@mdat.jinghead;    mycrc:=crc32(mycrc,p,16);
  dbswap32(mycrc);
  { write data }
  blockwrite (f,mdat.chunklength,8);
  blockwrite (f,mdat.jinghead,16);
  blockwrite (f,mycrc,4);
end;

procedure tMingEncode.WriteChunk_MHDR (mdat:tmingchunkdata);

var mycrc:dword;
    p:pbytef;

begin
  { set up }
  mdat.chunklength:=28;
  mdat.chunktype:=mingchunk_MHDR;
  { swap bytes }
  dbswap32(mdat.chunklength);
  dbswap32(mdat.minghead.framewidth);
  dbswap32(mdat.minghead.frameheight);
  dbswap32(mdat.minghead.tickspersec);
  dbswap32(mdat.minghead.nominallayercnt);
  dbswap32(mdat.minghead.nominalframecnt);
  dbswap32(mdat.minghead.nominalplaytime);
  dbswap32(mdat.minghead.simplicityprofile);
  { calculate CRC }
  mycrc:=crc32(0,z_null,0);
  p:=@@mdat.chunktype;   mycrc:=crc32(mycrc,p,4);
  p:=@@mdat.minghead;    mycrc:=crc32(mycrc,p,28);
  dbswap32(mycrc);
  { write data }
  blockwrite (f,mdat.chunklength,8);
  blockwrite (f,mdat.minghead,28);
  blockwrite (f,mycrc,4);
end;

procedure tMingEncode.OpenSession (name:string;ftype:dword);

begin
  usersetpixproc:=nil;
  usergetpixproc:=nil;
  usernewsproc:=nil;
  userresponseproc:=nil;
  png_quality:=0;
  png_compression:=6;
  supportpng16:=false;
  png_ok:=false;
  jng_ok:=false;
  if (ftype<1) or (ftype>3) then exit;
  assign (f,name);
  rewrite (f,1);
  mingtype:=ftype;
  case mingtype of
    MingType_MiNG: blockwrite (f,mingsign_ming,8);
    MingType_PiNG: blockwrite (f,mingsign_ping,8);
    MingType_JiNG: blockwrite (f,mingsign_jing,8);
  end;
end;

procedure tMingEncode.CloseSession;

begin
  {$i-}
  close (f);
  {$i+}
end;

function  tMingObject.MiNGLoadFirstImageFinished:boolean;

begin
  if (not mng_ok) or (mng_firstimgdone) then mingloadfirstimagefinished:=true
                                        else mingloadfirstimagefinished:=false;
end;

procedure tMingObject.InitMiNGLoad;

begin
  mng_chk.chunkpos:=0;
  case mingtype of
    mingtype_MiNG,
    mingtype_JiNG,
    mingtype_PiNG: mng_ok:=true;
  end;
  mng_objtype:=0;
  mng_firstimgdone:=false;
  mng_ticklength:=0;
  mng_delaytype:=1; { by default }
end;

function  tMingObject.MiNGLoadFinished:boolean;

begin
  if (not mng_ok) or (lastchunk(mng_chk) and (mng_chk.chunkpos>0))
    then begin
      mingloadfinished:=true;
    end else begin
      mingloadfinished:=false;
  end;
end;

procedure tMingObject.FinishMiNGLoad;

begin
  { close any open file load }
  case mng_objtype of
    2: finishpingload;
    3: finishjingload;
  end;
  mng_ok:=false;
end;

procedure tMingObject.MiNGLoad;

var mchkdat        : tmingchunkdata;
    nchkdat        : tmingchunkdata;

begin
  if mingloadfinished then exit;
  case mng_objtype of
    0: begin
         mng_chk:=getnextchunk(mng_chk);
         getchunkdata(mng_chk,mchkdat);
         case mng_chk.chunktype of
           mingchunk_framedef: begin
                                 if mng_delaytype=2 then
{                                  delay(mng_ticklength*mchkdat.framedef.interframedelay div 1000);}
                                 mresponse(mchkdat);
                               end;
           mingchunk_mhdr: begin
                             mng_lasttime:=getcurrentsystemtime;
                             if mchkdat.minghead.tickspersec<>0 then
                               mng_ticklength:=1000000 div mchkdat.minghead.tickspersec;
                             mresponse(mchkdat);
                           end;
           mingchunk_ihdr: begin
                             mng_lasttime:=getcurrentsystemtime;
                             mng_objtype:=2;
                             mresponse(mchkdat);
                             mng_chk:=getnextchunk(mng_chk);
                             while (mng_chk.chunktype<>mingchunk_idat) and
                                   (mng_chk.chunktype<>mingchunk_iend) do begin
                               getchunkdata(mng_chk,nchkdat);
                               mresponse(nchkdat);
                               mng_chk:=getnextchunk(mng_chk);
                             end;
                             initpingload (mchkdat);
                             if pingloadfinished then begin
                               finishpingload;
                               mng_objtype:=0;
                             end;
                           end;
           mingchunk_jhdr: begin
                             mng_lasttime:=getcurrentsystemtime;
                             mng_objtype:=3;
                             mresponse(mchkdat);
                             mng_chk:=getnextchunk(mng_chk);
                             while (mng_chk.chunktype<>mingchunk_jdat) and
                                   (mng_chk.chunktype<>mingchunk_iend) do begin
                               getchunkdata(mng_chk,nchkdat);
                               mresponse(nchkdat);
                               mng_chk:=getnextchunk(mng_chk);
                             end;
                             initjingload (mchkdat);
                             if jingloadfinished then begin
                               finishjingload;
                               mng_objtype:=0;
                             end;
                           end;
           mingchunk_defi: begin
                             mresponse(mchkdat);
                             curimgxadd:=mchkdat.defineobj.xlocation;
                             curimgyadd:=mchkdat.defineobj.ylocation;
                             curimgx1:=mchkdat.defineobj.leftcb;
                             curimgx2:=mchkdat.defineobj.rightcb;
                             curimgy1:=mchkdat.defineobj.topcb;
                             curimgy2:=mchkdat.defineobj.bottomcb;
                           end;
           else            begin
                             mresponse(mchkdat);
                           end;
         end;
       end;
    2: begin
         if not pingloadfinished then pingload else begin
           finishpingload;
           getchunkdata(mng_chk,mchkdat);
           mresponse(mchkdat);
           while mng_chk.chunktype<>mingchunk_iend do begin
             mng_chk:=getnextchunk(mng_chk);
             getchunkdata(mng_chk,mchkdat);
             mresponse(mchkdat);
           end;
           mng_objtype:=0;
           mng_firstimgdone:=true;
           if mng_delaytype=1 then begin
 {           mng_currenttime:=mng_lasttime+(mng_ticklength*mchkdat.framedef.interframedelay div 1000);}
             mng_currenttime:=mng_lasttime+(mng_ticklength div 1000);
             repeat
             until getcurrentsystemtime>=mng_currenttime;
           end;
         end;
       end;
    3: begin
         if not jingloadfinished then jingload else begin
           finishjingload;
           getchunkdata(mng_chk,mchkdat);
           mresponse(mchkdat);
           while mng_chk.chunktype<>mingchunk_iend do begin
             mng_chk:=getnextchunk(mng_chk);
             getchunkdata(mng_chk,mchkdat);
             mresponse(mchkdat);
           end;
           mng_objtype:=0;
           mng_firstimgdone:=true;
           if mng_delaytype=1 then begin
 {           mng_currenttime:=mng_lasttime+(mng_ticklength*mchkdat.framedef.interframedelay div 1000);}
             mng_currenttime:=mng_lasttime+(mng_ticklength div 1000);
             repeat
             until getcurrentsystemtime>=mng_currenttime;
           end;
         end;
       end;
  end;
end;

procedure tMingObject.MResponse (m:tmingchunkdata);

begin
    userresponseproc(m);
end;

function  tMingObject.ObjectLoadFinished:boolean;

begin
  if (mng_objtype<2) or (mng_objtype>2) then objectloadfinished:=true else case mng_objtype of
    2: objectloadfinished:=pingloadfinished;
  end;
end;

procedure tMingObject.FinishObjectLoad;

begin
  case mng_objtype of
    2: finishpingload;
  end;
  mng_objtype:=0;
end;

procedure tMingObject.ObjectLoad;

begin
  case mng_objtype of
    2: pingload;
  end;
end;

procedure tMingObject.InitObjectLoad (pchk:tMingChunkData);

var ck:tMingChunk;
    hdck:tMingChunkData;

begin
  curimgxadd:=0;
  curimgyadd:=0;
  if pchk.chunktype=MingChunk_DefineObj then begin
    curimgxadd:=pchk.defineobj.xlocation;
    curimgyadd:=pchk.defineobj.ylocation;
{   ck:=pchk;}
    ck.chunklength:=pchk.chunklength;
    ck.chunktype:=pchk.chunktype;
    ck.crc:=pchk.crc;
    ck.chunkpos:=pchk.chunkpos;
    ck:=getnextchunk(ck);
    while (ck.chunktype<>mingchunk_ihdr) and
          (ck.chunktype<>mingchunk_jhdr) and
          (ck.chunktype<>mingchunk_basi) and
          (ck.chunktype<>mingchunk_mend) and
          (ck.chunktype<>mingchunk_iend) do begin
      ck:=getnextchunk(ck);
    end;
  end else begin
    ck.chunklength:=pchk.chunklength;
    ck.chunktype:=pchk.chunktype;
    ck.crc:=pchk.crc;
    ck.chunkpos:=pchk.chunkpos;
  end;

  { IHDR/JHDR/BASI }
  getchunkdata(ck,hdck);
  case hdck.chunktype of
    MingChunk_IHDR: begin
                      mng_objtype:=2;
                      initpingload(hdck);
                    end;
    else            begin
                      mng_objtype:=0;
                      exit;
                    end;
  end;
end;

procedure tMingObject.MUserNews (n:dword);

begin
  usernewsproc(n);
end;

procedure tMingObject.FinishPiNGLoad;

var ck:tMingChunk;

begin
  if png_codec_ok then begin
    png_codec_ok:=false;
    png_infresult:=inflateend(png_mystream);
    freemem(png_line1,png_linelength);
    freemem(png_line2,png_linelength);
  end;
end;

function  tMingObject.PiNGLoadFinished:boolean;

begin
  if ((png_curpass=0) and (png_codec_ok) and (png_yline<png_type.pinghead.height)) or
     ((png_curpass>=1) and (png_codec_ok) and (png_curpass<8))
    then pingloadfinished:=false
    else pingloadfinished:=true;
end;

procedure tMingObject.png_SeekToNextIDAT;

var chk:tmingchunkdata;
    x:longint;

begin
  if png_lastchk.chunktype=mingchunk_iend then exit;
  repeat
    png_lastchk:=getnextchunk(png_lastchk);
    png_idat:=png_lastchk;

    case png_lastchk.chunktype of
      mingchunk_idat: begin
                        seek (f,png_lastchk.chunkpos+8);
                        png_inchunkbytes:=png_lastchk.chunklength;
                        chk.chunktype:=png_lastchk.chunktype;
                        chk.chunkpos:=png_lastchk.chunkpos;
                        chk.chunklength:=png_lastchk.chunklength;
                        chk.crc:=png_lastchk.crc;
                        break;
                      end;
      mingchunk_iend: begin
                        seek (f,png_lastchk.chunkpos+8);
                        png_inchunkbytes:=0;
                        break;
                      end;
      mingchunk_plte: begin
                        getchunkdata(png_lastchk,chk);
                        pingpalette:=chk;
                        for x:=0 to 255 do with pingpalette.pingpalette[x] do begin
                          red  :=calcgamma(red  ,png_gamma,output_gamma);
                          green:=calcgamma(green,png_gamma,output_gamma);
                          blue :=calcgamma(blue ,png_gamma,output_gamma);
                        end;
                      end;
      mingchunk_gama: begin
                        getchunkdata(png_lastchk,chk);
                        case (png_dataform and $0F) of
                          { 8 BPP }
                          0,2,3,4: for x:=0 to 255 do begin
                                     png_gamma8[x]:=calcgamma(x,chk.gammaexp.gamma,output_gamma);
                                   end;
                                1: if not supportpng16 then for x:=0 to 255 do begin
                                     png_gamma8[x]:=calcgamma(x,chk.gammaexp.gamma,output_gamma);
                                   end;
                        end;
                        png_gamma:=chk.gammaexp.gamma;
                      end;
    end;
  until false;
end;

procedure tMingObject.png_ReadBuffer;

var btsread:dword;
    chk:tmingchunkdata;

begin
  if png_inchunkbytes<=0 then png_seektonextidat;

  blockread (f,png_decodebuf,smallest(png_inchunkbytes,32768));
  png_mystream.next_in:=@@png_decodebuf;
  png_mystream.avail_in:=smallest(png_inchunkbytes,32768);
  png_mystream.total_in:=$FFFFFFFF;
  dec(png_inchunkbytes,32768);
end;

procedure tMingObject.png_DecompressLine;

begin
  png_mystream.next_out:=@@(png_currentline^);
  png_mystream.avail_out:=png_curlinelength;
  png_mystream.total_out:=$FFFFFFFF;
  while true do begin
    if png_mystream.avail_in=0 then png_ReadBuffer;
    if png_mystream.avail_out=0 then break;
    png_infresult:=inflate(png_mystream,z_sync_flush);
    if png_infresult<0 then break;
  end;
end;

procedure tMingObject.png_DeFLT_SUB;

var x:dword;
    z0,z1:dword;

begin
  for x:=1 to png_curlinelength-1 do begin
    z0:=png_currentline^[x];
    if (x>png_nbytesback) then z1:=png_currentline^[x-png_nbytesback]
                          else z1:=0;
    png_currentline^[x]:=(z0+z1) and $FF;
  end;
end;

procedure tMingObject.png_DeFLT_UP;

var x:dword;
    z0,z1:dword;

begin
  for x:=1 to png_curlinelength-1 do begin
    z0:=png_currentline^[x];
    z1:=png_lastline^[x];
    png_currentline^[x]:=(z0+z1) and $FF;
  end;
end;

procedure tMingObject.png_DeFLT_AVERAGE;

var x:dword;
    z0,z1,z2:dword;

begin
  for x:=1 to png_curlinelength-1 do begin
    z0:=png_currentline^[x];
    z2:=png_lastline^[x];
    if (x>png_nbytesback) then z1:=png_currentline^[x-png_nbytesback]
                          else z1:=0;
    png_currentline^[x]:=(z0+((z1+z2) shr 1)) and $FF;
  end;
end;

procedure tMingObject.png_DeFLT_PAETH;

var x:dword;
    z0,z1,z2,z3:dword;

begin
  for x:=1 to png_curlinelength-1 do begin
    z0:=png_currentline^[x];
    z2:=png_lastline^[x];
    if (x>png_nbytesback) then begin
      z1:=png_currentline^[x-png_nbytesback];
      z3:=png_lastline^[x-png_nbytesback];
    end else begin
      z1:=0;
      z3:=0;
    end;
    png_currentline^[x]:=(z0+png_PaethFunc(z1,z2,z3)) and $FF;
  end;
end;

function  tMingObject.PNG_PaethFunc(a,b,c:longint):longint;

var p,pa,pb,pc:longint;

begin
  { a = left, b = above, c = upper left }
  p:=a+b-c;        { initial estimate }
  pa:=abs(p-a);    { distances to a, b, c }
  pb:=abs(p-b);
  pc:=abs(p-c);
  { return nearest of a, b, c }
  { breaking ties in order a, b, c }
  if (pa<=pb) and (pa<=pc) then begin
    png_paethfunc:=a;
    exit;
  end;
  if (pb<=pc) then begin
    png_paethfunc:=b;
    exit;
  end;
  png_paethfunc:=c;
end;

function  tMingEncode.PNG_PaethFunc(a,b,c:longint):longint;

var p,pa,pb,pc:longint;

begin
  { a = left, b = above, c = upper left }
  p:=a+b-c;        { initial estimate }
  pa:=abs(p-a);    { distances to a, b, c }
  pb:=abs(p-b);
  pc:=abs(p-c);
  { return nearest of a, b, c }
  { breaking ties in order a, b, c }
  if (pa<=pb) and (pa<=pc) then begin
    png_paethfunc:=a;
    exit;
  end;
  if (pb<=pc) then begin
    png_paethfunc:=b;
    exit;
  end;
  png_paethfunc:=c;
end;

procedure tMingObject.png_DeFilterLine;

begin
  case png_currentline^[0] of
    0: { "NONE"    } ;
    1: { "SUB"     } png_DeFLT_SUB;
    2: { "UP"      } png_DeFLT_UP;
    3: { "AVERAGE" } png_DeFLT_AVERAGE;
    4: { "PAETH"   } png_DeFLT_PAETH;
  end;
end;

procedure tMingObject.png_OutputLine;

type twordarray = array[0..$3FFFFFFF div 2] of word;

var myword : ^twordarray;

var c:tcolor;
    x,w,z:dword;
    a,b:longint;

begin
  c.red:=0;
  c.green:=0;
  c.blue:=0;
  c.alpha:=0;
  z:=1;
  myword:=@@png_currentline^[1];
  case png_dataform of
    $10: for x:=0 to png_curlinepixels-1 do begin
           z:=x*3+1;
           c.red:=  png_gamma8[png_currentline^[z+0]];
           c.green:=png_gamma8[png_currentline^[z+1]];
           c.blue:= png_gamma8[png_currentline^[z+2]];
           if not adam7fillbox then
             MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline,c)
           else for b:=0 to adam7_pixpos.ydist[png_curpass]-1 do
             for a:=0 to adam7_pixpos.xdist[png_curpass]-1 do
               MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass]+a,png_yline+b,c);
         end;
    $11: begin
           z:=0;
           if not supportpng16 then for x:=0 to png_curlinepixels-1 do begin
             with c do begin
               red  :=myword^[z]; inc(z); dbswap16(red);   red  :=png_gamma8[red shr 8];
               green:=myword^[z]; inc(z); dbswap16(green); green:=png_gamma8[green shr 8];
               blue :=myword^[z]; inc(z); dbswap16(blue);  blue :=png_gamma8[blue shr 8];
               alpha:=0;
             end;
             if not adam7fillbox then
               MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline,c)
             else for b:=0 to adam7_pixpos.ydist[png_curpass]-1 do
               for a:=0 to adam7_pixpos.xdist[png_curpass]-1 do
                 MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass]+a,png_yline+b,c);
           end else for x:=0 to png_curlinepixels-1 do begin
             with c do begin
               red  :=myword^[z]; inc(z); dbswap16(red);
               green:=myword^[z]; inc(z); dbswap16(green);
               blue :=myword^[z]; inc(z); dbswap16(blue);
               alpha:=0;
             end;
             if not adam7fillbox then
               MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline,c)
             else for b:=0 to adam7_pixpos.ydist[png_curpass]-1 do
               for a:=0 to adam7_pixpos.xdist[png_curpass]-1 do
                 MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass]+a,png_yline+b,c);
           end;
         end;
    $20: for x:=0 to png_curlinepixels-1 do begin
           z:=x shl 2+1;
           c.red:=  png_gamma8[png_currentline^[z+0]];
           c.green:=png_gamma8[png_currentline^[z+1]];
           c.blue:= png_gamma8[png_currentline^[z+2]];
           c.alpha:=png_currentline^[z+3];
           if not adam7fillbox then
             MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline,c)
           else for b:=0 to adam7_pixpos.ydist[png_curpass]-1 do
             for a:=0 to adam7_pixpos.xdist[png_curpass]-1 do
               MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass]+a,png_yline+b,c);
         end;
    $21: begin
           z:=0;
           if not supportpng16 then for x:=0 to png_curlinepixels-1 do begin
             with c do begin
               red  :=myword^[z]; inc(z); dbswap16(red);   red  :=png_gamma8[red shr 8];
               green:=myword^[z]; inc(z); dbswap16(green); green:=png_gamma8[green shr 8];
               blue :=myword^[z]; inc(z); dbswap16(blue);  blue :=png_gamma8[blue shr 8];
               alpha:=myword^[z]; inc(z); dbswap16(alpha); alpha:=alpha shr 8;
             end;
             if not adam7fillbox then
               MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline,c)
             else for b:=0 to adam7_pixpos.ydist[png_curpass]-1 do
               for a:=0 to adam7_pixpos.xdist[png_curpass]-1 do
                 MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass]+a,png_yline+b,c);
           end else for x:=0 to png_curlinepixels-1 do begin
             with c do begin
               red  :=myword^[z]; inc(z); dbswap16(red);
               green:=myword^[z]; inc(z); dbswap16(green);
               blue :=myword^[z]; inc(z); dbswap16(blue);
               alpha:=myword^[z]; inc(z); dbswap16(alpha);
             end;
             if not adam7fillbox then
               MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline,c)
             else for b:=0 to adam7_pixpos.ydist[png_curpass]-1 do
               for a:=0 to adam7_pixpos.xdist[png_curpass]-1 do
                 MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass]+a,png_yline+b,c);
           end;
         end;
    $30: for x:=0 to png_curlinepixels-1 do begin
           with c do begin
             red:=png_gamma8[png_currentline^[x+1]];
             green:=red;
             blue:=red;
             alpha:=0;
           end;
           if not adam7fillbox then
             MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline,c)
           else for b:=0 to adam7_pixpos.ydist[png_curpass]-1 do
             for a:=0 to adam7_pixpos.xdist[png_curpass]-1 do
               MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass]+a,png_yline+b,c);
         end;
    $31: if not supportpng16 then for x:=0 to png_curlinepixels-1 do begin
           with c do begin
             red:=myword^[x];
             dbswap16(red);
             red:=png_gamma8[red shr 8];
             green:=red;
             blue:=red;
             alpha:=0;
           end;
           if not adam7fillbox then
             MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline,c)
           else for b:=0 to adam7_pixpos.ydist[png_curpass]-1 do
             for a:=0 to adam7_pixpos.xdist[png_curpass]-1 do
               MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass]+a,png_yline+b,c);
         end else for x:=0 to png_curlinepixels-1 do begin
           with c do begin
             red:=myword^[x];
             dbswap16(red);
             green:=red;
             blue:=red;
             alpha:=0;
           end;
           if not adam7fillbox then
             MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline,c)
           else for b:=0 to adam7_pixpos.ydist[png_curpass]-1 do
             for a:=0 to adam7_pixpos.xdist[png_curpass]-1 do
               MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass]+a,png_yline+b,c);
         end;
    $32: for x:=0 to png_curlinepixels-1 do begin
           with c do begin
             case (x and 1) of
               0: red:=png_currentline^[z] shr 4;
               1: begin
                    red:=png_currentline^[z] and 15;
                    inc(z);
                  end;
             end;
             red:=png_gamma8[red*17];
             green:=red;
             blue:=red;
             alpha:=0;
           end;
           if not adam7fillbox then
             MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline,c)
           else for b:=0 to adam7_pixpos.ydist[png_curpass]-1 do
             for a:=0 to adam7_pixpos.xdist[png_curpass]-1 do
               MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass]+a,png_yline+b,c);
         end;
    $33: for x:=0 to png_curlinepixels-1 do begin
           with c do begin
             case (x and 3) of
               0: red:=png_currentline^[z] shr 6;
               1: red:=(png_currentline^[z] shr 4) and 3;
               2: red:=(png_currentline^[z] shr 2) and 3;
               3: red:=png_currentline^[z] and 3;
             end;
             if (x and 3)=3 then inc(z);
             red:=png_gamma8[red*85];
             green:=red;
             blue:=red;
             alpha:=0;
           end;
           if not adam7fillbox then
             MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline,c)
           else for b:=0 to adam7_pixpos.ydist[png_curpass]-1 do
             for a:=0 to adam7_pixpos.xdist[png_curpass]-1 do
               MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass]+a,png_yline+b,c);
         end;
    $34: for x:=0 to png_curlinepixels-1 do begin
           with c do begin
             case (x and 7) of
               0: red:=png_currentline^[z] shr 7;
               1: red:=(png_currentline^[z] shr 6) and 1;
               2: red:=(png_currentline^[z] shr 5) and 1;
               3: red:=(png_currentline^[z] shr 4) and 1;
               4: red:=(png_currentline^[z] shr 3) and 1;
               5: red:=(png_currentline^[z] shr 2) and 1;
               6: red:=(png_currentline^[z] shr 1) and 1;
               7: begin
                    red:=png_currentline^[z] and 1;
                    inc(z);
                  end;
             end;
             red:=red*255;
             green:=red;
             blue:=red;
             alpha:=0;
           end;
           if not adam7fillbox then
             MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline,c)
           else for b:=0 to adam7_pixpos.ydist[png_curpass]-1 do
             for a:=0 to adam7_pixpos.xdist[png_curpass]-1 do
               MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass]+a,png_yline+b,c);
         end;
    $40: for x:=0 to png_curlinepixels-1 do begin
           with c do begin
             red:=png_gamma8[png_currentline^[z]]; inc(z);
             green:=red;
             blue:=red;
             alpha:=png_currentline^[z]; inc(z);
           end;
           if not adam7fillbox then
             MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline,c)
           else for b:=0 to adam7_pixpos.ydist[png_curpass]-1 do
             for a:=0 to adam7_pixpos.xdist[png_curpass]-1 do
               MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass]+a,png_yline+b,c);
         end;
    $41: begin
           z:=0;
           if not supportpng16 then for x:=0 to png_curlinepixels-1 do begin
             with c do begin
               red:=myword^[z]; inc(z);
               dbswap16(red);
               red:=red shr 8;
               green:=red;
               blue:=red;
               alpha:=myword^[z]; inc(z);
             end;
             if not adam7fillbox then
               MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline,c)
             else for b:=0 to adam7_pixpos.ydist[png_curpass]-1 do
               for a:=0 to adam7_pixpos.xdist[png_curpass]-1 do
                 MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass]+a,png_yline+b,c);
           end else for x:=0 to png_curlinepixels-1 do begin
             with c do begin
               red:=myword^[z]; inc(z);
               dbswap16(red);
               green:=red;
               blue:=red;
               alpha:=myword^[z]; inc(z);
             end;
             if not adam7fillbox then
               MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline,c)
             else for b:=0 to adam7_pixpos.ydist[png_curpass]-1 do
               for a:=0 to adam7_pixpos.xdist[png_curpass]-1 do
                 MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass]+a,png_yline+b,c);
           end;
         end;
    $50: begin
           with c do begin
             green:=0;
             blue:=0;
             alpha:=0;
           end;
           for x:=0 to png_curlinepixels-1 do begin
             currentcolorindex:=png_currentline^[x+1];
             c:=pingpalette.pingpalette[currentcolorindex];
             if not adam7fillbox then
               MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline,c)
             else for b:=0 to adam7_pixpos.ydist[png_curpass]-1 do
               for a:=0 to adam7_pixpos.xdist[png_curpass]-1 do
                 MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass]+a,png_yline+b,c);
           end;
         end;
    $52: for x:=0 to png_curlinepixels-1 do begin
           case (x and 1) of
             0: currentcolorindex:=png_currentline^[z] shr 4;
             1: begin
                  currentcolorindex:=png_currentline^[z] and 15;
                  inc(z);
                end;
           end;
           c:=pingpalette.pingpalette[currentcolorindex];
           if not adam7fillbox then
             MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline,c)
           else for b:=0 to adam7_pixpos.ydist[png_curpass]-1 do
             for a:=0 to adam7_pixpos.xdist[png_curpass]-1 do
               MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass]+a,png_yline+b,c);
         end;
    $53: for x:=0 to png_curlinepixels-1 do begin
           case (x and 3) of
             0: currentcolorindex:=png_currentline^[z] shr 6;
             1: currentcolorindex:=(png_currentline^[z] shr 4) and 3;
             2: currentcolorindex:=(png_currentline^[z] shr 2) and 3;
             3: currentcolorindex:=png_currentline^[z] and 3;
           end;
           if (x and 3)=3 then inc(z);
           c:=pingpalette.pingpalette[currentcolorindex];
           if not adam7fillbox then
             MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline,c)
           else for b:=0 to adam7_pixpos.ydist[png_curpass]-1 do
             for a:=0 to adam7_pixpos.xdist[png_curpass]-1 do
               MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass]+a,png_yline+b,c);
         end;
    $54: for x:=0 to png_curlinepixels-1 do begin
           case (x and 7) of
             0: currentcolorindex:=png_currentline^[z] shr 7;
             1: currentcolorindex:=(png_currentline^[z] shr 6) and 1;
             2: currentcolorindex:=(png_currentline^[z] shr 5) and 1;
             3: currentcolorindex:=(png_currentline^[z] shr 4) and 1;
             4: currentcolorindex:=(png_currentline^[z] shr 3) and 1;
             5: currentcolorindex:=(png_currentline^[z] shr 2) and 1;
             6: currentcolorindex:=(png_currentline^[z] shr 1) and 1;
             7: begin
                    currentcolorindex:=png_currentline^[z] and 1;
                    inc(z);
                  end;
           end;
           c:=pingpalette.pingpalette[currentcolorindex];
           if not adam7fillbox then
             MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass],png_yline,c)
           else for b:=0 to adam7_pixpos.ydist[png_curpass]-1 do
             for a:=0 to adam7_pixpos.xdist[png_curpass]-1 do
               MSetPix(adam7_pixpos.xstart[png_curpass]+x*adam7_pixpos.xstep[png_curpass]+a,png_yline+b,c);
         end;
  end;
end;

procedure tMingObject.PiNGLoad;

var x:longint;

begin
  if pingloadfinished then exit;
  { set current/last line }
  case png_line1current of
    true:  begin png_currentline:=png_line2; png_lastline:=png_line1; end;
    false: begin png_currentline:=png_line1; png_lastline:=png_line2; end;
  end;
  png_curfilter:=png_currentline^[0];
  { do decode }
  png_DecompressLine;
  png_DeFilterLine;
  png_OutputLine;
  { increase vars }
  inc(png_yline,adam7_pixpos.ystep[png_curpass]);
  png_line1current:=not png_line1current;
  if (png_yline>=png_type.pinghead.height) and (png_curpass>=1) and (png_curpass<8) then begin
    png_line1current:=true;
    repeat
      inc(png_curpass);
      png_yline:=adam7_pixpos.ystart[png_curpass];
      png_curlinepixels:=(png_type.pinghead.width-
                          adam7_pixpos.xstart[png_curpass]+
                          adam7_pixpos.xstep[png_curpass]-1) div
                          adam7_pixpos.xstep[png_curpass];
    until ((adam7_pixpos.ystart[png_curpass]<png_type.pinghead.height) and
           (png_curlinepixels>0)) or (png_curpass>=8);
    case png_dataform of
      $10: png_curlinelength:=png_curlinepixels*3+1;
      $11: png_curlinelength:=png_curlinepixels*6+1;

      $20: png_curlinelength:=png_curlinepixels*4+1;
      $21: png_curlinelength:=png_curlinepixels*8+1;

      $30: png_curlinelength:=png_curlinepixels+1;
      $31: png_curlinelength:=png_curlinepixels*2+1;
      $32: png_curlinelength:=(png_curlinepixels+1) shr 1+1;
      $33: png_curlinelength:=(png_curlinepixels+3) shr 2+1;
      $34: png_curlinelength:=(png_curlinepixels+7) shr 3+1;

      $40: png_curlinelength:=png_curlinepixels*2+1;
      $41: png_curlinelength:=png_curlinepixels*4+1;

      $50: png_curlinelength:=png_curlinepixels+1;
      $52: png_curlinelength:=(png_curlinepixels+1) shr 1+1;
      $53: png_curlinelength:=(png_curlinepixels+3) shr 2+1;
      $54: png_curlinelength:=(png_curlinepixels+7) shr 3+1;
    end;
    for x:=0 to png_curlinelength-1 do png_line1^[x]:=0;
    for x:=0 to png_curlinelength-1 do png_line2^[x]:=0;
  end;
end;

procedure tMingObject.InitPiNGLoad(phead:tMingChunkData);

var x:dword;

begin
  { set vars }
  png_codec_ok:=false;
  png_type:=phead;
  png_yline:=0;
  png_width:=phead.pinghead.width;
  png_dataform:=$00;
  case phead.pinghead.colortype of
    MingChunk_PiNGHead_RGBImage:       case phead.pinghead.bitdepth of
                                          8: png_dataform:=$10;
                                         16: png_dataform:=$11;
                                       end;
    MingChunk_PiNGHead_RGBAlpha:       case phead.pinghead.bitdepth of
                                          8: png_dataform:=$20;
                                         16: png_dataform:=$21;
                                       end;
    MingChunk_PiNGHead_GrayscaleImage: case phead.pinghead.bitdepth of
                                          1: png_dataform:=$34;
                                          2: png_dataform:=$33;
                                          4: png_dataform:=$32;
                                          8: png_dataform:=$30;
                                         16: png_dataform:=$31;
                                       end;
    MingChunk_PiNGHead_GrayscaleAlpha: case phead.pinghead.bitdepth of
                                          8: png_dataform:=$40;
                                         16: png_dataform:=$41;
                                       end;
    MingChunk_PiNGHead_PaletteIndexed: case phead.pinghead.bitdepth of
                                          1: png_dataform:=$54;
                                          2: png_dataform:=$53;
                                          4: png_dataform:=$52;
                                          8: png_dataform:=$50;
                                       end;
  end;
  if png_dataform=0 then begin
    errcode:=5;
    exit;
  end;
  case png_dataform of
    $10: png_linelength:=png_width*3+1;
    $11: png_linelength:=png_width*6+1;

    $20: png_linelength:=png_width shl 2+1;
    $21: png_linelength:=png_width shl 3+1;

    $30: png_linelength:=png_width+1;
    $31: png_linelength:=png_width shl 1+1;
    $32: png_linelength:=(png_width+1) shr 1+1;
    $33: png_linelength:=(png_width+3) shr 2+1;
    $34: png_linelength:=(png_width+7) shr 3+1;

    $40: png_linelength:=png_width shl 1+1;
    $41: png_linelength:=png_width shl 2+1;

    $50: png_linelength:=png_width+1;
    $51: png_linelength:=png_width shl 1+1;
    $52: png_linelength:=(png_width+1) shr 1+1;
    $53: png_linelength:=(png_width+3) shr 2+1;
    $54: png_linelength:=(png_width+7) shr 3+1;
  end;
  case png_dataform of
    $10: png_nbytesback:=3;
    $11: png_nbytesback:=6;

    $20: png_nbytesback:=4;
    $21: png_nbytesback:=8;

    $30: png_nbytesback:=1;
    $31: png_nbytesback:=2;
    $32: png_nbytesback:=1;
    $33: png_nbytesback:=1;
    $34: png_nbytesback:=1;

    $40: png_nbytesback:=2;
    $41: png_nbytesback:=4;

    $50: png_nbytesback:=1;
    $51: png_nbytesback:=2;
    $52: png_nbytesback:=1;
    $53: png_nbytesback:=1;
    $54: png_nbytesback:=1;
  end;
  { assign memory buffers and fill with 0 }
  getmem(png_line1,png_linelength);
  getmem(png_line2,png_linelength);
  for x:=0 to png_linelength-1 do png_line1^[x]:=0;
  for x:=0 to png_linelength-1 do png_line2^[x]:=0;
  { start decode }
  png_inchunkbytes:=0;
  seek (f,phead.chunkpos+8);
  png_lastchk.chunklength:=phead.chunklength;
  png_lastchk.chunktype:=phead.chunktype;
  png_lastchk.crc:=phead.crc;
  png_lastchk.chunkpos:=phead.chunkpos;
  case phead.pinghead.interlacetype of
    0: begin
         png_curpass:=0;
         png_curlinelength:=png_linelength;
         png_curlinepixels:=png_type.pinghead.width;
       end;
    1: begin
         png_curpass:=1;
         png_curlinepixels:=(png_type.pinghead.width-
                             adam7_pixpos.xstart[png_curpass]+
                             adam7_pixpos.xstep[png_curpass]-1) div
                            adam7_pixpos.xstep[png_curpass];
         case png_dataform of
           $10: png_curlinelength:=png_curlinepixels*3+1;
           $11: png_curlinelength:=png_curlinepixels*6+1;

           $20: png_curlinelength:=png_curlinepixels*4+1;
           $21: png_curlinelength:=png_curlinepixels*8+1;

           $30: png_curlinelength:=png_curlinepixels+1;
           $31: png_curlinelength:=png_curlinepixels*2+1;
           $32: png_curlinelength:=(png_curlinepixels+1) shr 1+1;
           $33: png_curlinelength:=(png_curlinepixels+3) shr 2+1;
           $34: png_curlinelength:=(png_curlinepixels+7) shr 3+1;

           $40: png_curlinelength:=png_curlinepixels*2+1;
           $41: png_curlinelength:=png_curlinepixels*4+1;

           $50: png_curlinelength:=png_curlinepixels+1;
           $52: png_curlinelength:=(png_curlinepixels+1) shr 1+1;
           $53: png_curlinelength:=(png_curlinepixels+3) shr 2+1;
           $54: png_curlinelength:=(png_curlinepixels+7) shr 3+1;
         end;
       end;
  else begin
         errcode:=5;
         exit;
       end;
  end;
  png_line1current:=true;

  png_mystream.zalloc:=nil;
  png_mystream.zfree:=nil;
  png_mystream.opaque:=nil;
  png_mystream.next_in:=@@png_decodebuf;
  png_mystream.avail_in:=0;
  png_mystream.total_in:=$FFFFFFFF;
  png_mystream.next_out:=nil;
  png_mystream.avail_out:=0;
  png_mystream.total_out:=$FFFFFFFF;
  png_infresult:=inflateinit(png_mystream);
  png_codec_ok:=true;
end;

procedure tMingObject.UserSetPixProc(x,y:longint;c:tcolor);
begin
end;

procedure tMingObject.MSetPix (x,y:longint;c:tcolor);

begin
  if (x>=curimgx1) and (x<=curimgx2) and
     (y>=curimgy1) and (y<=curimgy2) then
    usersetpixproc(x+curimgxadd,y+curimgyadd,c);
end;

function  tMingObject.MGetPix (x,y:longint):tcolor;

begin
  mgetpix:=usergetpixproc(curimgxadd+x,curimgyadd+y);
end;

function  tMingObject.Process_PLTE (var mdat:tMingChunkData):dword;

var mycrc:dword;
    pbuffer:pbytef;
    x:dword;
    mypal:array[0..255] of array[0..2] of byte;

begin
  for x:=0 to 255 do begin
    mypal[x][0]:=0;
    mypal[x][1]:=0;
    mypal[x][2]:=0;
  end;
  seek (f,mdat.chunkpos+8);
  blockread(f,mypal,smallest(mdat.chunklength,768));
  pbuffer:=@@mdat.chunktype;
  mycrc:=crc32(0,z_null,0);
  mycrc:=crc32(mycrc,pbuffer,4);
  pbuffer:=@@mypal;
  mycrc:=crc32(mycrc,pbuffer,smallest(mdat.chunklength,768));
  process_plte:=mycrc;
  for x:=0 to 255 do begin
    with mdat.pingpalette[x] do begin
      red:=mypal[x][0];
      green:=mypal[x][1];
      blue:=mypal[x][2];
      alpha:=0;
    end;
  end;
end;

function  tMingObject.Process_ZTXT (var mdat:tMingChunkData):dword;

var mbuf_keyword : string;
    mbuf_comp    : dword;
    mbuf         : array[0..32767] of byte;
    mbuf2        : array[0..32767] of byte;
    pbuffer      : pbytef;
    mycrc        : dword;
    x,y          : longint;
    pdest        : pbytef;
    pdestlen     : ulong;

begin
  seek (f,mdat.chunkpos+8);
  blockread (f,mbuf,smallest(mdat.chunklength,32768));
  pbuffer:=@@mdat.chunktype;
  mycrc:=crc32(0,z_null,0);
  mycrc:=crc32(mycrc,pbuffer,4);
  pbuffer:=@@mbuf;
  mycrc:=crc32(mycrc,pbuffer,smallest(mdat.chunklength,32768));
  process_ztxt:=mycrc;

  with mdat.compressedtext do begin
    keyword:='';
    nlines:=0;
    for x:=0 to 255 do textdata[x]:='';
    x:=0;
    repeat
      if ((mbuf[x]>= 32) and (mbuf[x]<=126)) or
         ((mbuf[x]>=161) and (mbuf[x]<=255)) then keyword:=keyword+chr(mbuf[x]);
      inc(x);
    until (mbuf[x]=0) or (x>=256);
    inc(x);
    mbuf_comp:=mbuf[x];
    inc(x);
    pdest:=@@mbuf2;
    pdestlen:=32768;
    uncompress(pdest,pdestlen,mbuf[x],mdat.chunklength-x);
    x:=0;
    repeat
      if ((mbuf2[x]>= 32) and (mbuf2[x]<=126)) or
         ((mbuf2[x]>=161) and (mbuf2[x]<=255)) then textdata[nlines]:=textdata[nlines]+chr(mbuf2[x]);
      if mbuf2[x]=10 then inc(nlines);
      inc(x);
    until x>=pdestlen;
    inc(nlines);
  end;
end;

function  tMingObject.Process_TEXT (var mdat:tMingChunkData):dword;

var mbuf:array[0..32767] of byte;
    mycrc:dword;
    pbuffer:pbytef;
    x:dword;

begin
  seek (f,mdat.chunkpos+8);
  blockread (f,mbuf,smallest(mdat.chunklength,32768));
  pbuffer:=@@mdat.chunktype;
  mycrc:=crc32(0,z_null,0);
  mycrc:=crc32(mycrc,pbuffer,4);
  pbuffer:=@@mbuf;
  mycrc:=crc32(mycrc,pbuffer,smallest(mdat.chunklength,32768));
  process_text:=mycrc;

  with mdat.latintext do begin
    keyword:='';
    nlines:=0;
    for x:=0 to 255 do textdata[x]:='';
    x:=0;
    repeat
      if ((mbuf[x]>= 32) and (mbuf[x]<=126)) or
         ((mbuf[x]>=161) and (mbuf[x]<=255)) then keyword:=keyword+chr(mbuf[x]);
      inc(x);
    until (mbuf[x]=0) or (x>=256);
    inc(x);
    repeat
      if ((mbuf[x]>= 32) and (mbuf[x]<=126)) or
         ((mbuf[x]>=161) and (mbuf[x]<=255)) then textdata[nlines]:=textdata[nlines]+chr(mbuf[x]);
      if mbuf[x]=10 then inc(nlines);
      inc(x);
    until x>=mdat.chunklength;
    inc(nlines);
  end;
end;

function  tMingObject.Process_DEFI (var mdat:tMingChunkData):dword;

var mycrc:dword;
    pbuffer:pbytef;

begin
  seek (f,mdat.chunkpos+8);
  blockread(f,mdat.defineobj,smallest(mdat.chunklength,28));

  pbuffer:=@@mdat.chunktype;
  mycrc:=crc32(0,z_null,0);
  mycrc:=crc32(mycrc,pbuffer,4);
  pbuffer:=@@mdat.defineobj;
  mycrc:=crc32(mycrc,pbuffer,smallest(mdat.chunklength,28));
  process_defi:=mycrc;

  bswap16(mdat.defineobj.objectid);
  dbswap32(mdat.defineobj.xlocation);
  dbswap32(mdat.defineobj.ylocation);
  dbswap32(mdat.defineobj.leftcb);
  dbswap32(mdat.defineobj.rightcb);
  dbswap32(mdat.defineobj.topcb);
  dbswap32(mdat.defineobj.bottomcb);

  if mdat.chunklength<=2 then begin
    mdat.defineobj.donotshowflag:=0;
  end;
  if mdat.chunklength<=3 then begin
    mdat.defineobj.concreteflag:=1;
  end;
  if mdat.chunklength<=4 then begin
    mdat.defineobj.xlocation:=0;
    mdat.defineobj.ylocation:=0;
  end;
  if mdat.chunklength<=12 then begin
    mdat.defineobj.leftcb  :=-2147483647;
    mdat.defineobj.topcb   :=-2147483647;
    mdat.defineobj.rightcb := 2147483647;
    mdat.defineobj.bottomcb:= 2147483647;
  end;
end;

function  tMingObject.Process_MHDR (var mdat:tMingChunkData):dword;

var mycrc:dword;
    pbuffer:pbytef;

begin
  seek (f,mdat.chunkpos+8);
  blockread(f,mdat.minghead,28);

  pbuffer:=@@mdat.chunktype;
  mycrc:=crc32(0,z_null,0);
  mycrc:=crc32(mycrc,pbuffer,4);
  pbuffer:=@@mdat.minghead;
  mycrc:=crc32(mycrc,pbuffer,28);
  process_mhdr:=mycrc;

  dbswap32(mdat.minghead.framewidth);
  dbswap32(mdat.minghead.frameheight);
  dbswap32(mdat.minghead.tickspersec);
  dbswap32(mdat.minghead.nominallayercnt);
  dbswap32(mdat.minghead.nominalframecnt);
  dbswap32(mdat.minghead.nominalplaytime);
  dbswap32(mdat.minghead.simplicityprofile);
end;

function  tMingObject.Process_JHDR (var mdat:tMingChunkData):dword;

var mycrc:dword;
    pbuffer:pbytef;

begin
  seek (f,mdat.chunkpos+8);
  blockread (f,mdat.jinghead,16);

  mycrc:=crc32(0,z_null,0);
  pbuffer:=@@mdat.chunktype;   mycrc:=crc32(mycrc,pbuffer,4);
  pbuffer:=@@mdat.jinghead;    mycrc:=crc32(mycrc,pbuffer,16);
  process_jhdr:=mycrc;

  dbswap32(mdat.jinghead.width);
  dbswap32(mdat.jinghead.height);
end;

function  tMingObject.Process_IHDR (var mdat:tMingChunkData):dword;

var mycrc:dword;
    pbuffer:pbytef;

begin
  seek (f,mdat.chunkpos+8);
  blockread(f,mdat.pinghead,13);

  pbuffer:=@@mdat.chunktype;
  mycrc:=crc32(0,z_null,0);
  mycrc:=crc32(mycrc,pbuffer,4);
  pbuffer:=@@mdat.pinghead;
  mycrc:=crc32(mycrc,pbuffer,13);
  process_ihdr:=mycrc;

  dbswap32(mdat.pinghead.width);
  dbswap32(mdat.pinghead.height);
end;

function  tMingObject.Process_GAMA (var mdat:tMingChunkData):dword;

var mycrc:dword;
    pbuffer:pbytef;

begin
  blockread(f,mdat.gammaexp.gamma,4);
  mycrc:=crc32(0,z_null,0);
  pbuffer:=@@mdat.chunktype;        mycrc:=crc32(mycrc,pbuffer,4);
  pbuffer:=@@mdat.gammaexp.gamma;   mycrc:=crc32(mycrc,pbuffer,4);
  process_gama:=mycrc;
  dbswap32(mdat.gammaexp.gamma);
end;

function  tMingObject.Process_FRAM (var mdat:tMingChunkData):dword;

var mbuf:array[0..1023] of byte;
    mycrc:dword;
    pbuffer:pbytef;
    x:dword;
    mdw:^dword;

begin
  blockread(f,mbuf,mdat.chunklength);
  mycrc:=crc32(0,z_null,0);
  pbuffer:=@@mdat.chunktype;        mycrc:=crc32(mycrc,pbuffer,4);
  pbuffer:=@@mbuf;                  mycrc:=crc32(mycrc,pbuffer,mdat.chunklength);
  process_fram:=mycrc;
  with mdat.framedef do begin
    framingmode:=mbuf[0];
    subframename:='';
    chgframedelay:=0;
    chgtermination:=0;
    chgsubframeclip:=0;
    chgsyncid:=0;
    interframedelay:=0;
    timeout:=0;
    subframeboundtype:=0;
    leftfb:=0;
    rightfb:=0;
    topfb:=0;
    bottomfb:=0;
    syncid:=0;
    if mdat.chunklength>1 then begin
      x:=1;
      while (mbuf[x]<>0) and (x<=256) do begin
        if ((mbuf[x]>= 32) and (mbuf[x]<=126)) or
           ((mbuf[x]>=161) and (mbuf[x]<=255)) then subframename:=subframename+chr(mbuf[x]);
        inc(x);
      end;
      if x<mdat.chunklength-1 then begin
        inc(x);
        chgframedelay:=mbuf[x];  inc(x);
        chgtermination:=mbuf[x]; inc(x);
        chgsubframeclip:=mbuf[x];inc(x);
        chgsyncid:=mbuf[x];      inc(x);
        if chgframedelay<>0 then begin
          mdw:=@@mbuf[x];
          interframedelay:=mdw^;
          dbswap32(interframedelay);
          inc(x,4);
        end;
        if chgtermination<>0 then begin
          mdw:=@@mbuf[x];
          timeout:=mdw^;
          dbswap32(timeout);
          inc(x,4);
        end;
        if chgsubframeclip<>0 then begin
          subframeboundtype:=mbuf[x];    inc(x);
          mdw:=@@mbuf[x]; leftfb  :=mdw^; inc(x,4); dbswap32(leftfb  );
          mdw:=@@mbuf[x]; rightfb :=mdw^; inc(x,4); dbswap32(rightfb );
          mdw:=@@mbuf[x]; topfb   :=mdw^; inc(x,4); dbswap32(topfb   );
          mdw:=@@mbuf[x]; bottomfb:=mdw^; inc(x,4); dbswap32(bottomfb);
        end;
        if chgsyncid<>0 then begin
          mdw:=@@mbuf[x];
          syncid:=mdw^;
          dbswap32(syncid);
          inc(x,4);
        end;
      end;
    end;

    { to be continued }
  end;
end;

function  tMingObject.GetChunkData (var thischk:tMingChunk;var mdat:tMingChunkData):dword;

var z:boolean;

begin
  getchunkdata:=0;
  z:=false;
  mdat.chunklength:=thischk.chunklength;
  mdat.chunktype  :=thischk.chunktype;
  mdat.chunkpos   :=thischk.chunkpos;

  seek (f,mdat.chunkpos+8);
  case mdat.chunktype of
     MingChunk_PiNGHead:       getchunkdata:=Process_IHDR (mdat);
     MingChunk_MiNGHead:       getchunkdata:=Process_MHDR (mdat);
     MingChunk_JiNGHead:       getchunkdata:=Process_JHDR (mdat);
     MingChunk_DefineObj:      getchunkdata:=Process_DEFI (mdat);
     MingChunk_PiNGPalette:    getchunkdata:=Process_PLTE (mdat);
     MingChunk_LatinText:      getchunkdata:=Process_TEXT (mdat);
     MingChunk_CompressedText: getchunkdata:=Process_ZTXT (mdat);
     MingChunk_GammaExp:       getchunkdata:=Process_GAMA (mdat);
     MingChunk_FrameDef:       getchunkdata:=Process_FRAM (mdat);
     MingChunk_EndOfImage:;
     else                      getchunkdata:=skipchunkdatagetcrc(thischk);
  end;
  seek (f,mdat.chunkpos+mdat.chunklength+8);
  blockread (f,mdat.crc,4);
  dbswap32(mdat.crc);
end;

function  tMingObject.LastChunk(thischk:tMingChunk):boolean;

begin
  case mingtype of
    mingtype_MiNG: if thischk.chunktype=MingChunk_EndOfFile then lastchunk:=true else lastchunk:=false;
    mingtype_PiNG: if thischk.chunktype=MingChunk_EndOfImage then lastchunk:=true else lastchunk:=false;
    mingtype_JiNG: if thischk.chunktype=MingChunk_EndOfImage then lastchunk:=true else lastchunk:=false;
    else lastchunk:=true;
  end;
end;

function  tMingObject.GetNextChunk (lastchk:tMingChunk):tMingChunk;
var
    work:tMingChunk;
begin
  if lastchk.chunkpos=0 then begin
    getnextchunk:=getfirstchunk;
    exit;
  end;
  seek (f,lastchk.chunkpos+lastchk.chunklength+12);
  blockread (f,work,8);
  dbswap32(work.chunklength);
  work.crc:=0; { net yet read }
  work.chunkpos:=lastchk.chunkpos+lastchk.chunklength+12;
  GetNextChunk:=work;
end;

procedure tMingObject.SkipChunkData (var thischk:tMingChunk);

begin
  seek (f,thischk.chunkpos+thischk.chunklength+8);
  blockread (f,thischk.crc,4);
  dbswap32(thischk.crc);
end;

function  tMingObject.GetFirstChunk:tMingChunk;
var
    work:tMingChunk;
begin
  seek (f,8);
  blockread (f,work,8);
  dbswap32(work.chunklength);
  work.crc:=0; { net yet read }
  work.chunkpos:=8;
  GetFirstChunk:=work;
end;

function  tMingObject.CalculateCRC (cchunk:tMingChunk):dword;

var mycrc:dword;
    mybuf:array[0..32767] of byte;
    x,l,s:longint;
    pbuffer:pbytef;

begin
  pbuffer:=@@cchunk.chunktype;
  calculatecrc:=0;
  seek (f,cchunk.chunkpos+8);
  mycrc:=crc32(0,z_null,0);
  mycrc:=crc32(mycrc,pbuffer,4);
  l:=cchunk.chunklength;
  pbuffer:=@@mybuf;
  while l>0 do begin
    s:=smallest(l,32768);
    blockread(f,mybuf,s);
    mycrc:=crc32(mycrc,@@mybuf,s);
    dec(l,32768);
  end;
  calculatecrc:=mycrc;
end;

function  tMingObject.SkipChunkDataGetCRC (var thischk:tMingChunk):dword;

var mycrc:dword;
    mybuf:array[0..32767] of byte;
    x,l,s:longint;
    pbuffer:pbytef;

begin
  seek (f,thischk.chunkpos+8);
  pbuffer:=@@thischk.chunktype;
  skipchunkdatagetcrc:=0;
  mycrc:=crc32(0,z_null,0);
  mycrc:=crc32(mycrc,pbuffer,4);
  l:=thischk.chunklength;
  pbuffer:=@@mybuf;
  while l>0 do begin
    s:=smallest(l,32768);
    blockread(f,mybuf,s);
    mycrc:=crc32(mycrc,@@mybuf,s);
    dec(l,32768);
  end;
  skipchunkdatagetcrc:=mycrc;
  blockread (f,thischk.crc,4);
  dbswap32(thischk.crc);
end;

function  tMingObject.SafeToCopyChunk (cchunk:tMingChunk):boolean;

begin
  if ((cchunk.chunktype shr 24) and $FF) and 32=32 then safetocopychunk:=true
                                                   else safetocopychunk:=false;
end;

function  tMingObject.PrivateChunk (cchunk:tMingChunk):boolean;

begin
  if ((cchunk.chunktype shr 8) and $FF) and 32=32 then privatechunk:=true
                                                  else privatechunk:=false;
end;

function  tMingObject.AncillaryChunk (cchunk:tMingChunk):boolean;

begin
  if (cchunk.chunktype and $FF) and 32=32 then ancillarychunk:=true
                                          else ancillarychunk:=false;
end;

function  tMingObject.NrOfChunks:dword;

var mychunk:tmingchunk;
    myeof:dword;
    value:dword;

begin
  seek (f,8);
  value:=0;
  case mingtype of
    MingType_MiNG: myeof:=mingchunk_endoffile;
    MingType_PiNG: myeof:=mingchunk_endofimage;
    MingType_JiNG: myeof:=mingchunk_endofimage;
    else errcode:=1;
  end;
  repeat
    blockread (f,mychunk,8);
    dbswap32(mychunk.chunklength);
    seek (f,filepos(f)+mychunk.chunklength);
    blockread (f,mychunk.crc,4);
    inc(value);
  until mychunk.chunktype=myeof;
  NrOfChunks:=value;
end;

function  tMingObject.GetChunk(cnum:dword):tMingChunk;

var mychunk:tmingchunk;
    myeof:dword;
    x:dword;

begin
  seek (f,8);
  case mingtype of
    MingType_MiNG: myeof:=mingchunk_endoffile;
    MingType_PiNG: myeof:=mingchunk_endofimage;
    MingType_JiNG: myeof:=mingchunk_endofimage;
    else errcode:=1;
  end;
  for x:=cnum downto 0 do begin
    mychunk.chunkpos:=filepos(f);
    blockread (f,mychunk,8);
    dbswap32(mychunk.chunklength);
    seek (f,mychunk.chunkpos+8+mychunk.chunklength);
    blockread (f,mychunk.crc,4);
    dbswap32(mychunk.crc);
    if (mychunk.chunktype=myeof) and (x>0) then begin
      errcode:=2;
      getchunk.chunklength:=0;
(*    getchunk.chunktype[0]:=#32; { low: ancillary }
      getchunk.chunktype[1]:=#32; { low: private   }
      getchunk.chunktype[2]:=#64; { up:  res       }
      getchunk.chunktype[3]:=#64; { up:  unsafe    }*)
      getchunk.chunktype:=mingchunk_nochunk;
      getchunk.crc:=0;
      exit;
    end;
  end;
  getchunk:=mychunk;
end;

procedure tMingObject.CloseSession;

begin
  {$i-}
  close (f);
  {$i+}
  mingtype:=mingtype_nofile;
end;

procedure tMingObject.OpenSession (fname:string);

var x:longint;

begin
  usergetpixproc:=nil;
  //usersetpixproc:=nil;
  usernewsproc:=nil;
  userresponseproc:=nil;
  mng_ok:=false;
  curimgx1:=-2147483647;
  curimgy1:=-2147483647;
  curimgx2:=+2147483647;
  curimgy2:=+2147483647;
  for x:=0 to 255 do begin
    png_gamma8[x]:=calcgamma(x,100000,output_gamma);
  end;
  png_gamma:=100000;

  {$I-}
  assign(f,fname);
  reset(f,1);
  x:=filepos(f);
  {$I+}
  if not ((ioresult = 0) and (fname <> '')) then begin
    errcode:=3;
    mingtype:=$FF;
  end else begin
    mingtype:=identifyming;
  end;
  adam7fillbox:=false;
  supportpng16:=false;
  curimgxadd:=0;
  curimgyadd:=0;
end;
function IsEquale(a,b:tMingSignature):boolean;
var x:longint;

begin
  isEquale:=true;
  for x:=0 to 7 do begin
    if a[x]<>b[x] then begin
      isEquale:=false;
      exit;
    end;
  end;
end;

function  tMiNGObject.IdentifyMing:dword;

var mysign : tMingSignature;

begin
  mysign:=readmingsignature;
  identifyming:=mingtype_noming;
  if isEquale(mysign,mingsign_ming) then identifyming:=mingtype_ming;
  if isEquale(mysign,mingsign_ping) then identifyming:=mingtype_ping;
  if isEquale(mysign,mingsign_jing) then identifyming:=mingtype_jing;
end;

function  tMiNGObject.ReadMingSignature:tMingSignature;
var
    work:tMingSignature;
    i:integer;
begin
  seek (f,0);
  i:=FilePos(f);
  blockread (f,work,8);
  ReadMingSignature:=work;
end;

//const MingTarget        = {$i %fpctarget};

begin
  { Drop this message if you want to... :-( }
(**
  writeln ('Using ',minglib_libname,' v',minglib_version shr 8,'.',(minglib_version shr 4) and $0F,
           minglib_version and $0F,', ',minglib_date);
  writeln (minglib_copyright,', for ',mingtarget);
**)
end.
@


1.2
log
@書き込みのため、元に戻す
@
text
@d682 1
a682 1
  if ((png_curpass=0) and (png_ok) and (png_yline<png_height)) or
d1241 1
a1241 1
 writechunk_ihdr(ihdr);
@


1.1
log
@Initial revision
@
text
@d310 1
a310 1
           function  MGetPix (x,y:longint):tcolor;
d1241 1
a1241 1
{ writechunk_ihdr(ihdr);}
@
