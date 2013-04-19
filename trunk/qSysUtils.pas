unit qSysUtils;

interface

{$I compilers.inc}

uses
  Classes, Windows, SysUtils, MaskUtils,
  Forms, WinSock, Messages, COntrols;

const
  MaxLong24  = $FFFFFF;
  MaxInt24   = $7FFFFF;
  MinInt24   = $800000;

type
  TConvState = function (Max, Pos:Integer; Text:string):boolean of object;
  TListIndexCompare = function(Data:Pointer; Item:Pointer):integer;
  TListIndexCompareStr = function(Data:string; Item:Pointer):integer;
//  TListIndexCompareEx = function(Data:Pointer; Index:Integer):integer;

  TWordType = (wtIntel, wtMotorolla);  // wtIntel - Litel endian, wtMotorolla - Big endian

//=== System ===
procedure InitDefLocate(); // Nide when change program location

//==============

function isFloat(s:string; var Value:Extended):boolean; overload;
function isFloat(s:string; var Value:Extended; const FormatSettings: TFormatSettings):boolean; overload;
function isFloatEng(s:string; var Value:Extended):boolean;

function isNum(s:string; var V:byte):boolean; overload;
function isNum(s:string; var V:Smallint):boolean; overload;
function isNum(s:string; var V:integer):boolean; overload;
function isNum(s:string; var V:Word):boolean; overload;
function isNum(s:string; var V:LongWord):boolean; overload;
function isNum(s:string; var V:int64):boolean; overload;

function RoundTop(val:Extended):Integer;

procedure SwapVals(var val1, val2:Integer);

function StrToBuff(Str:String; Buff:Pointer; Size:Integer):boolean;

function BuffToStr(str:string):string;
function StrToData(Str:String; var Data:Pointer; var Size:integer; Func:TConvState = nil):boolean; overload;
function StrToData(Str:String; var Data:Pointer; var Size:LongWord; Func:TConvState = nil):boolean; overload;
function StrToData(Str:String; var Data:Pointer; var Size:Word; Func:TConvState = nil):boolean; overload;
function StrToData(Str:String; var Data:Pointer; var Size:byte; Func:TConvState = nil):boolean; overload;
function DataToStr(Data:Pointer; Size:integer;
                  HaveRet:boolean = false; NewLineStr:string = ''; RetSize:Integer = 8;
                  DivChar:string = ' '):string;
function DataToString(Data:Pointer; Size:integer):string;

function StrToArray(Str:string; var Arr:array of byte; ArrSize:integer):boolean;

function MakeLongWord(A, B: Word): LongWord;
function GetMaxUnsingle(Size:integer):LongWord;

function GetMaskBitSizeEx(Val:LongWord; var StartBit:integer):integer;
function GetMaskBitSize(Val:LongWord):integer;

function GetWord (Buf:Pointer; pos:integer; WordType:TWordType):word;
function Get3byte(Buf:Pointer; pos:integer; WordType:TWordType):LongWord;
function GetDWord(Buf:Pointer; pos:integer; WordType:TWordType):LongWord;

procedure SetWord(Buf:Pointer; pos:integer; Val:Word; WordType:TWordType);
procedure Set3Byte(Buf:Pointer; pos:integer; Val:LongWord; WordType:TWordType);
procedure SetDWord(Buf:Pointer; pos:integer; Val:LongWord; WordType:TWordType);

function  GetDataSize(Buf:Pointer; Posit, Size:integer; WordType:TWordType):LongWord;
procedure SetDataSize(Val:LongWord; Buf:Pointer; Posit, Size:integer; WordType:TWordType);
procedure SetMaskedData(Val, Mask:LongWord; Buf:Pointer; Posit, Size:integer; WordType:TWordType);
procedure OrBuff(Dest, Source:Pointer; Size:integer);
procedure FillBuff(Buf:Pointer; Posit, Size:integer; Val:Byte);

procedure BuffToList(Str:string; List:TList);
function  ListToBuff(List:TList):string;

function TestMaskedValue(const Value, Mask: string; var Pos: Integer): Boolean;
function TestMaskBuff(Buff, Mask:Pointer; Size:Integer; Full:boolean = true):boolean;

function Int24ToInteger(Val:LongWord):integer;
function IntegerToInt24(Val:integer):LongWord;

function GetTickDiff(const AOldTickCount, ANewTickCount : Cardinal):Cardinal;

function FindIndexPos(List:TList; Data:Pointer; Compare:TListIndexCompare):integer;
function FindIndexPosStr(List:TList; Data:string; Compare:TListIndexCompareStr):integer;

function CompareBuff(Buf1, Buf2:Pointer; Size:Integer):Integer;

//function FindIndexPosEx(Min, Max:Integer; Data:Pointer; Compare:TListIndexCompareEx):Integer;

procedure CopyList(Source, Result:TList);

function Win32ErrorText(const ErrorCode: cardinal; var ret:String): boolean;

function GetSysVariable(VarName:string):string;

function GetProxyFromIE(pType:string; var Proxy:string; var Port:integer):boolean;

function LookupName(const Name: String): TInAddr;

{$IFDEF WIN32}
  function ReturnAddr: Pointer;
{$ELSE}
  function ReturnAddr: Pointer; assembler;
{$ENDIF}

function WaitFlag(Application:TApplication; var Flag:boolean; TimeOut:LongWord):boolean; overload;
function WaitFlag(Application:TApplication; var Flag:Integer; DefRez:Integer; TimeOut:LongWord):boolean; overload;

function PtInRange(Low, Hight, Val:Integer):boolean;
function RangeInRange(L1, H1, L2, H2:Integer):boolean;

procedure NormalizeRect(var Rect:TRect);

function GetMaxCpuId:Longword;register;


function CreateWMMessage(Msg: Integer; WParam: Integer; LParam: Longint): TMessage; overload;
function CreateWMMessage(Msg: Integer; WParam: Integer; LParam: TControl): TMessage; overload;

var
//  cRusFormatString:TFormatSettings;
  cEngFormatString:TFormatSettings;
  cDefFormatString:TFormatSettings;

implementation

uses
  Registry,
  Math,
  qStrUtils;

type
  TSHGetFolderPathProc = function(hWnd: HWND; CSIDL: Integer; hToken: THandle;
    dwFlags: DWORD; pszPath: PChar): HResult; stdcall;

var
  SHGetFolderPathProc: TSHGetFolderPathProc = nil;

function CreateWMMessage(Msg: Integer; WParam: Integer; LParam: Longint): TMessage;
begin
  Result.Msg := Msg;
  Result.WParam := WParam;
  Result.LParam := LParam;
  Result.Result := 0;
end;

function CreateWMMessage(Msg: Integer; WParam: Integer; LParam: TControl): TMessage;
begin
  Result := CreateWMMessage(Msg, WParam, Integer(LParam));
end;

function CompareBuff(Buf1, Buf2:Pointer; Size:Integer):Integer;
var i:integer;
begin
  result := 0;

  for i := 0 to Size-1 do begin
    result := PByteArray(Buf1)^[i] - PByteArray(Buf2)^[i];
    if result <> 0 then break;      
  end;
end;

function GetMaxCpuId : Longword;register;
  asm  //EAX, EDX, ECX - Универсальные регистры можно смело их использовать
   push ebx  // а вот EBX надо бы сохранить
   mov eax,1 // режим работы cpuid
   cpuid
   shr ebx, 16 // сдвигаем впрво
   and ebx, $f // маскируем
   mov eax,ebx // копируем результат
   pop ebx
end;

{$IFDEF WIN32}
  function ReturnAddr: Pointer;
  asm
          MOV     EAX,[EBP+4]
  end;
{$ELSE}
  function ReturnAddr: Pointer; assembler;
  asm
          MOV     AX,[BP].Word[2]
          MOV     DX,[BP].Word[4]
  end;
{$ENDIF}

function RangeInRange(L1, H1, L2, H2:Integer):boolean;
begin
  result := PtInRange(L2, H2, L1) or PtInRange(L2, H2, H1) or
            PtInRange(L1, H1, L2) or PtInRange(L1, H1, H2);
end;

procedure NormalizeRect(var Rect:TRect);
begin
  if rect.Left > rect.Right then
    SwapVals(rect.Left, rect.Right);

  if rect.Top > rect.Bottom then
    SwapVals(rect.Top, rect.Bottom);
end;

function PtInRange(Low, Hight, Val:Integer):boolean;
begin
  result := (Val >= Low) and (val <= Hight);
end;

function WaitFlag(Application:TApplication; var Flag:boolean; TimeOut:LongWord):boolean;
var fTime:LongWord;
begin
  result := false;

  fTIme := GetTickCOunt();
  while not Flag do begin
    if GetTickDiff(fTime, GetTickCOunt) > TimeOut then exit;
    Application.ProcessMessages;
  end;

  result := true;
end;

function WaitFlag(Application:TApplication; var Flag:Integer; DefRez:Integer; TimeOut:LongWord):boolean;
var fTime:LongWord;
begin
  result := false;

  fTIme := GetTickCOunt();
  while Flag = DefRez do begin
    if GetTickDiff(fTime, GetTickCOunt) > TimeOut then exit;
    Application.ProcessMessages;
  end;

  result := true;
end;

function GetSysVariable(VarName:string):string;
var S: array [0..2048] of Char;
begin
  if GetEnvironmentVariable(PChar(VarName), S, SizeOf(S) - 1) > 0 then
    Result := StrPas(S)
  else
    Result := '';
end;

function LookupName(const Name: String): TInAddr;
var
  HostEnt: PHostEnt;
  HostName:AnsiString;
begin
  HostName := AnsiString(Name);

  if HostName = '' then
    result.S_addr := htonl(INADDR_ANY)
  else if (AnsiPos(Name[1], '0123456789') > 0) then // is dot notation already
    result.S_addr := inet_addr(PAnsiChar(HostName))
  else begin
    HostEnt := gethostbyname(PAnsiChar(HostName));
    if HostEnt <> nil then begin
      result.S_un_b.s_b1 := AnsiChar(HostEnt.h_addr^[0]);
      result.S_un_b.s_b2 := AnsiChar(HostEnt.h_addr^[1]);
      result.S_un_b.s_b3 := AnsiChar(HostEnt.h_addr^[2]);
      result.S_un_b.s_b4 := AnsiChar(HostEnt.h_addr^[3]);
    end
    else begin
      result.S_un_b.s_b1 := #127;
      result.S_un_b.s_b2 := #0;
      result.S_un_b.s_b3 := #0;
      result.S_un_b.s_b4 := #1;
    end;
  end;
end;

function GetProxyFromIE(pType:string; var Proxy:string; var Port:integer):boolean;
var str, itm:String;
    i:integer;
    Reg:TRegistry;
begin
  result := false;
  pType := UpperCase(pType);

  Reg := TRegistry.Create;
  try
    if Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Internet Settings', false) then
      if Reg.ValueExists('ProxyEnable') and
         reg.ReadBool('ProxyEnable') and
         reg.ValueExists('ProxyServer') then begin

        str := Reg.ReadString('ProxyServer');

        for i := 1 to WordCount(str, [';']) do begin
          itm := ExtractWord(i, str, [';']);
          if Pos('=', itm) <> 0 then begin
            if UpperCase(ExtractWord(1, itm, ['='])) <> pType then continue;
            itm := ExtractWord(2, itm, ['=']);
          end;

          Proxy := ExtractWord(1, itm, [':']);
          isNum(ExtractWord(2, itm, [':']), Port);
          result := true;
          break;
        end;
      end;
  finally
    Reg.Free;
  end;
end;

function Win32ErrorText(const ErrorCode: cardinal; var ret:string): boolean; overload;
const
  BufSize = 256;
var
  Buf: array [Byte] of Char;
begin
 result := FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil,  ErrorCode, LOCALE_USER_DEFAULT, Buf, BufSize, nil) <> 0;
 ret := Buf;
end;

function GetTickDiff(const AOldTickCount, ANewTickCount : Cardinal):Cardinal;
begin
  {This is just in case the TickCount rolled back to zero}
    if ANewTickCount >= AOldTickCount then begin
      Result := ANewTickCount - AOldTickCount;
    end else begin
      Result := High(Cardinal) - AOldTickCount + ANewTickCount;
    end;
end;

function GetMaxUnsingle(Size:integer):LongWord;
begin
  case Size of
    1: Result := MaxByte;
    2: Result := MaxWord;
    3: Result := $FFFFFF;
    4: Result := MaxDWord;
  else
    Result := 0;
  end;
end;

procedure SetDataSize(Val:LongWord; Buf:Pointer; Posit, Size:integer; WordType:TWordType);
begin
  case Size of
    1: PByteArray(Buf)^[Posit] := Byte(Val);
    2: SetWord (Buf, Posit, Word(Val), WordType);
    3: Set3Byte(Buf, Posit, Val, WordType);
    4: SetDWord(Buf, Posit, Val, WordType);
  end;
end;

procedure SetMaskedData(Val, Mask:LongWord; Buf:Pointer; Posit, Size:integer; WordType:TWordType);
var fOld:LongWord;
begin
  fOld := GetDataSize(Buf, Posit, Size, WordType);
  Val := (fOld and not Mask) or (Val and Mask);
  SetDataSize(Val, Buf, Posit, Size, WordType);
end;

procedure OrBuff(Dest, Source:Pointer; Size:integer);
var i:integer;
begin
  for i := 0 to Size-1 do
    PByteArray(Dest)^[i] := PByteArray(Dest)^[i] or PByteArray(Source)^[i];
end;

procedure FillBuff(Buf:Pointer; Posit, Size:integer; Val:Byte);
var i:integer;
begin
  for i := Posit to Posit+Size-1 do
    PByteArray(Buf)^[i] := Val;
end;

function GetDataSize(Buf:Pointer; Posit, Size:integer; WordType:TWordType):LongWord;
begin
  case Size of
    1: result := PByteArray(Buf)^[Posit];
    2: result := GetWord (Buf, Posit, WordType);
    3: result := Get3Byte(Buf, Posit, WordType);
    4: result := GetDWord(Buf, Posit, WordType);
    else
      result := 0;
  end;
end;

function FindIndexPos(List:TList; Data:Pointer; Compare:TListIndexCompare):integer;
var i, fL, fH:integer;
begin
  fL := 0;
  fH := List.count;
  while fL < fH do begin
    i := (fL + fH) shr 1;

    if Compare(Data, List.Items[i]) < 0 then
      fL := i+1
    else
      fH := i;
  end;

  result := fL;
end;

function FindIndexPosStr(List:TList; Data:string; Compare:TListIndexCompareStr):integer;
var i, fL, fH:integer;
begin
  fL := 0;
  fH := List.count;
  while fL < fH do begin
    i := (fL + fH) shr 1;

    if Compare(Data, List.Items[i]) < 0 then
      fL := i+1
    else
      fH := i;
  end;

  result := fL;
end;

{function FindIndexPosEx(Min, Max:Integer; Data:Pointer; Compare:TListIndexCompareEx):Integer;
var i, fL, fH:integer;
begin
  fL := Min;
  fH := Max;
  while fL < fH do begin
    i := (fL + fH) shr 1;

    if Compare(Data, i) < 0 then
      fL := i+1
    else
      fH := i;
  end;

  result := fL;
end;}

procedure CopyList(Source, Result:TList);
var i:integer;
begin
  for i := 0 to Source.Count-1 do
    Result.Add( Source.Items[i] );
end;

function Int24ToInteger(Val:LongWord):integer;
begin
  Val := Val and MaxLong24;
  if Val <= MaxInt24 then
    result := Val
  else
    result := Integer(Val) - Integer(MaxLong24)-1;
end;

function IntegerToInt24(Val:integer):LongWord;
begin
  if Val >= 0 then
    result := Val
  else
    result := Val + MaxLong24+1;
end;

function GetWord(Buf:Pointer; pos:integer; WordType:TWordType):word;
begin
  // intel
  case WordType of
    wtIntel:
      result := MakeWord(
                          PByteArray(Buf)^[Pos],
                          PByteArray(Buf)^[Pos+1]
                        );
    wtMotorolla:
      result := MakeWord(
                          PByteArray(Buf)^[Pos+1],
                          PByteArray(Buf)^[Pos]
                        );
    else
      result := 0;
  end;
end;

function Get3byte(Buf:Pointer; pos:integer; WordType:TWordType):LongWord;
begin
  case WordType of
    wtIntel:
      result := MakeLongWord(
                          MakeWord(
                                    PByteArray(Buf)^[Pos],
                                    PByteArray(Buf)^[Pos+1]
                                  ),
                          MakeWord(
                                    PByteArray(Buf)^[Pos+2],
                                    0
                                  )
                        );
    wtMotorolla:
      result := MakeLongWord(
                          MakeWord(
                                    PByteArray(Buf)^[Pos+2],
                                    PByteArray(Buf)^[Pos+1]
                                  ),
                          MakeWord(
                                    PByteArray(Buf)^[Pos],
                                    0
                                  )
                        );
    else
      result := 0;
  end;
end;

function GetDWord(Buf:Pointer; pos:integer; WordType:TWordType):LongWord;
begin
  case WordType of
    wtIntel:
        result := MakeLongWord(
                        MakeWord(
                                  PByteArray(Buf)^[Pos],
                                  PByteArray(Buf)^[Pos+1]
                                ),
                        MakeWord(
                                  PByteArray(Buf)^[Pos+2],
                                  PByteArray(Buf)^[Pos+3]
                                )
                      );
    wtMotorolla:
      result := MakeLongWord(
                          MakeWord(
                                    PByteArray(Buf)^[Pos+3],
                                    PByteArray(Buf)^[Pos+2]
                                  ),
                          MakeWord(
                                    PByteArray(Buf)^[Pos+1],
                                    PByteArray(Buf)^[Pos]
                                  )
                        );
    else
      result := 0;
  end;
end;

procedure SetWord(Buf:Pointer; pos:integer; Val:Word; WordType:TWordType);
begin
  case WordType of
    wtIntel:
      begin
        PByteArray(Buf)[Pos]   := Lo(Val);
        PByteArray(Buf)[Pos+1] := Hi(Val);
      end;
    wtMotorolla:
      begin
        PByteArray(Buf)[Pos]   := Hi(Val);
        PByteArray(Buf)[Pos+1] := Lo(Val);
      end;
  end;
end;

procedure Set3Byte(Buf:Pointer; pos:integer; Val:LongWord; WordType:TWordType);
begin
  case WordType of
    wtIntel:
      begin
        PByteArray(Buf)[Pos]   := Lo(LoWord(Val));
        PByteArray(Buf)[Pos+1] := Hi(LoWord(Val));
        PByteArray(Buf)[Pos+2] := Lo(HiWord(Val));
      end;
    wtMotorolla:
      begin
        PByteArray(Buf)[Pos]   := Lo(HiWord(Val));
        PByteArray(Buf)[Pos+1] := Hi(LoWord(Val));
        PByteArray(Buf)[Pos+2] := Lo(LoWord(Val));
      end;
  end;
end;

procedure SetDWord(Buf:Pointer; pos:integer; Val:LongWord; WordType:TWordType);
begin
  case WordType of
    wtIntel:
      begin
        PByteArray(Buf)[Pos]   := Lo(LoWord(Val));
        PByteArray(Buf)[Pos+1] := Hi(LoWord(Val));
        PByteArray(Buf)[Pos+2] := Lo(HiWord(Val));
        PByteArray(Buf)[Pos+3] := Hi(HiWord(Val));
      end;
    wtMotorolla:
      begin
        PByteArray(Buf)[Pos]   := Hi(HiWord(Val));
        PByteArray(Buf)[Pos+1] := Lo(HiWord(Val));
        PByteArray(Buf)[Pos+2] := Hi(LoWord(Val));
        PByteArray(Buf)[Pos+3] := Lo(LoWord(Val));
      end;
  end;
end;

function MakeLongWord(A, B: Word): LongWord;
begin
  Result := A or B shl 16;
end;

function TestMaskedValue(const Value, Mask: string; var Pos: Integer): Boolean;
var
  Offset, MaskOffset: Integer;
  CType: TMaskCharType;
begin
  Result := True;
  Offset := 1;
  for MaskOffset := 1 to Length(Mask) do begin
    CType := MaskGetCharType(Mask, MaskOffset);

    if CType in [mcLiteral, mcIntlLiteral, mcMaskOpt] then
      Inc(Offset)
    else if (CType = mcMask) and (Value <> '') then begin
      if ((Value[Offset] = ' ') and (Mask[MaskOffset] <> mMskAscii)) then begin
        Result := False;
        Pos := Offset - 1;
        Exit;
      end;
      Inc(Offset);
    end;
  end;
end;

function TestMaskBuff(Buff, Mask:Pointer; Size:Integer; Full:boolean = true):boolean;
var i:integer;
begin
  if Full then begin
    result := true;

    for i := 0 to Size-1 do
      if PByteArray(Buff)^[i] and PByteArray(Mask)^[i] <> PByteArray(Mask)^[i] then begin
        result := false;
        break;
      end;
  end
  else begin
    result := false;

    for i := 0 to Size-1 do
      if PByteArray(Buff)^[i] and PByteArray(Mask)^[i] <> 0 then begin
        result := true;
        break;
      end;
  end;
end;

function BuffToStr(str:string):string;
var i:integer;
begin
  if Length(str) mod 2 = 1 then
    str := '0'+str;

  result := '';
  for i := (Length(str)-1) div 2 downto 0 do begin
    if result <> '' then result := ' '+result;

    result := copy(str, i*2+1, 2) + result;
  end;
end;

function StrToBuff(Str:String; Buff:Pointer; Size:Integer):boolean;
var Data:Pointer;
    DataSize:Integer;
begin
  Data := nil;
  DataSize := 0;

  try
    result := StrToData(Str, Data, DataSize);
    if not result then exit;

    if DataSize > Size then
      move(Data^, Buff^, Size)
    else
      move(Data^, Buff^, DataSize);

  finally
    FreeMem(Data, DataSize);
  end;
end;

function StrToData(Str:String; var Data:Pointer; var Size:integer; Func:TConvState = nil):boolean;
var i, Err:integer;
    NewData:Pointer;
    NewSize:Integer;
begin
  result := false;

  NewData := nil;
  NewSize := 0;

  try
    if Assigned(Func) then
      if not Func(0, 0, 'Analiz data') then exit;
    NewSize := WordCount(Str, cDataDelim);

    GetMem(NewData, NewSize);

    for i := 0 to NewSize-1 do begin
      if Assigned(Func) then
        if not Func(NewSize, i, 'Convert data') then exit;

      val('$'+ExtractWord(i+1, Str, cDataDelim), PByteArray(NewData)[i], Err);
      if Err <> 0 then exit;
    end;

    result := true;
  finally
    if result then begin
      if Assigned(Data) then FreeMem(Data, Size);
      Data := NewData;
      Size := NewSize;
    end
    else
      FreeMem(NewData);
  end;
end;

function StrToData(Str:String; var Data:Pointer; var Size:LongWord; Func:TConvState = nil):boolean; overload;
var fSize:integer;
begin
  fSize := Size;
  result := StrToData(Str, Data, fSize, Func);
  Size := fSize;
end;

function StrToData(Str:String; var Data:Pointer; var Size:Word; Func:TConvState = nil):boolean;
var fSize:integer;
begin
  fSize := Size;
  result := StrToData(Str, Data, fSize, Func);
  Size := fSize;
end;

function StrToData(Str:String; var Data:Pointer; var Size:byte; Func:TConvState = nil):boolean;
var fSize:integer;
begin
  fSize := Size;
  result := StrToData(Str, Data, fSize, Func);
  Size := fSize;
end;

function DataToStr(Data:Pointer; Size:integer;
                   HaveRet:boolean = false; NewLineStr:string = ''; RetSize:Integer = 8; 
                   DivChar:string = ' '):string;
var i:integer;
    bCount:integer;
begin
  result := '';

  bCount := 0;
  for i := 0 to Size-1 do begin
    if (bCount >= RetSize) and HaveRet then begin
      result := result + #13#10+NewLineStr;
      bCount := 0;
    end
    else
      if result <> '' then
        result := result + DivChar;

    try
      result := result + IntToHex(PByteArray(Data)[i], 2);
    except
      result := result + '??';
    end;

    inc(bCount);
  end;
end;

function DataToString(Data:Pointer; Size:integer):string;
var i:integer;
begin
  result := '';

  for i := 0 to Size-1 do
    if PByteArray(Data)^[i] = 0 then
      result := result + #01
    else
      result := result + Char(PByteArray(Data)^[i]);
end;

function StrToArray(Str:string; var Arr:array of byte; ArrSize:integer):boolean;
var fData:Pointer;
    fSize, fDSize:integer;
begin
  fData := nil;
  fSize := 0;

  result := StrToData(Str, fData, fSize);
  if not result then exit;

  fDSize := fSize;
  if fDSize > ArrSize then fDSize := ArrSize;

  FillChar(Arr, ArrSize, 0);
  Move(fData^, Arr, fDSize);
  FreeMem(fData, fSize);
end;

function isFloat(s:string; var Value:Extended):boolean;
begin
  result := TextToFloat(PChar(S), Value, fvExtended, cDefFormatString);
end;

function isFloat(s:string; var Value:Extended; const FormatSettings: TFormatSettings):boolean;
begin
  result := TextToFloat(PChar(S), Value, fvExtended, FormatSettings);
end;

function isFloatEng(s:string; var Value:Extended):boolean; overload;
begin
  result := TextToFloat(PChar(S), Value, fvExtended, cEngFormatString);
end;

function isNum(s:string; var V:byte):boolean;
var e:integer;
begin
  Val(s, V, e);
  result := e = 0;
end;

function isNum(s:string; var V:Smallint):boolean;
var e:integer;
begin
  Val(s, V, e);
  result := e = 0;
end;

function isNum(s:string; var V:integer):boolean;
var e:integer;
begin
  Val(s, V, e);
  result := e = 0;
end;

function isNum(s:string; var V:Word):boolean;
var e:integer;
begin
  Val(s, V, e);
  result := e = 0;
end;

function isNum(s:string; var V:LongWord):boolean;
var e:integer;
begin
  Val(s, V, e);
  result := e = 0;
end;

function isNum(s:string; var V:int64):boolean; overload;
var e:integer;
begin
  Val(s, V, e);
  result := e = 0;
end;

function GetMaskBitSizeEx(Val:LongWord; var StartBit:integer):integer;
var i, min, max:integer;
    bCount:integer;
begin
  min := 0;
  max := 0;
  bCount := 0;
  StartBit := 0;

  for i := 0 to SizeOf(Val)*8-1 do
    if (1 shl i) and Val <> 0 then begin
      if bCount = 0 then begin
        min := i;
        StartBit := i;
      end
      else
        max := i;

      inc(bCount);
    end;

  if bCount < 2 then
    result := bCount
  else
    result := max-min+1;
end;

function GetMaskBitSize(Val:LongWord):integer;
var sb:integer;
begin
  result := GetMaskBitSizeEx(Val, sb);
end;

procedure BuffToList(Str:string; List:TList);
var i:integer;
    b:byte;
begin
  for i := 1 to WordCount(str, [' ']) do begin
    if not IsNum('$'+ExtractWord(i, str, [' ']), b) then continue;
    List.Add( Pointer(b) );
  end;
end;

function ListToBuff(List:TList):string;
var i:integer;
begin
  result := '';

  for i := 0 to List.Count-1 do begin
    if result <> '' then result := result + ' ';
    result := result + IntToHex(Byte(List.Items[i]), 2);
  end;
end;

function RoundTop(val:Extended):Integer;
var fMode:TFPURoundingMode;
begin
  fMode := GetRoundMode();
  SetRoundMode(rmUp);
  result := Round(val);
  SetRoundMode(fMode);
end;

procedure SwapVals(var val1, val2:Integer);
var temp:Integer;
begin
  temp := val1;
  val1 := val2;
  val2 := temp
end;

procedure InitDefLocate();
begin
{$WARN SYMBOL_DEPRECATED OFF}
{$WARN SYMBOL_PLATFORM OFF}
  GetLocaleFormatSettings(SysLocale.DefaultLCID, cDefFormatString);
{$WARN SYMBOL_DEPRECATED ON}
{$WARN SYMBOL_PLATFORM ON}
end;

initialization
  InitDefLocate;
{$WARN SYMBOL_PLATFORM OFF}
{$WARN SYMBOL_DEPRECATED OFF}
//  GetLocaleFormatSettings($419, cRusFormatString);
  GetLocaleFormatSettings($409, cEngFormatString);
{$WARN SYMBOL_DEPRECATED ON}
{$WARN SYMBOL_PLATFORM ON}

end.
