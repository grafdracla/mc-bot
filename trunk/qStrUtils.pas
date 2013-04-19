unit qStrUtils;

interface

{$I compilers.inc}

uses
  SysUtils, Classes;

type
  TCharSet = TSysCharSet;

const
  cDataDelim:TCharSet = [' ', #13, #10, #9];

  function WordPosition(const N: Integer; const S: string; const WordDelims: TCharSet; Quote:TCharSet = []): Integer;
  function WordCount(const S: string; const WordDelims: TCharSet; Quote:TCharSet = []): Integer;
  function ExtractWord(N: Integer; const S: string; const WordDelims: TCharSet; Quote:TCharSet = []): string;
  function ExtractDelimited(N: Integer; const S: string; const Delims: TCharSet; Quote:TCharSet = []): string;
  function ExtractDelim(N: Integer; const S: string; const WordDelims: TCharSet; Quote:TCharSet = []):string;
  function ChangeWord(N:Integer; S: string; const Value: string; const WordDelims: TCharSet; Quote:TCharSet = [];
                      AddDelim:string = ','; AddData:string = '0'):string;
  function DelWord(N: Integer; const S: string; const WordDelims: TCharSet; Quote:TCharSet = []):string;

  //------ Sub strs -------------
  function ExtractSubstr(const S: string; var Pos: Integer; const Delims: TCharSet): string;

  //------ Other ----------------
  function ReplaceStr(const S, Srch, Replace: string): string; overload;
  function ReplaceStr(const S, Srch, Replace: WideString): WideString; overload;

  function ReplaceStrQuote(const S, Srch, Replace: string; Quote:String): string;

  function DelEndRet(Str: string):string;
  function DelQuote(Str: string): string;
  function DelESpace(const S: string): string;
  function DelEEndStrings(const S: string): string;

  function ReplCodeString(const S:string): string;

  function AppendFirstChar(str:string; Size:Integer; Char:string):string;
  function RepeatStr(Str:string; Count:Integer; SubDiv:string = ''):string;

  function  WStrNew(Str:PWideChar):PWideChar;
  procedure WStrDispose(var str:PWideChar);

  function  LoadWCharB(strm:TStream):PWideChar;
  function  LoadWCharDW(strm:TStream):PWideChar;

  procedure SetChar(var Dest: array of Char; Str:String);

  procedure SetWideChar(var Dest: array of WideChar; Str:WideString); overload;
  procedure SetWideChar(Dest: PWideChar; DestLen: Integer; Str:WideString); overload;

  procedure CopyWideChar(Source, Dest: PWideChar; SourceSize: Integer);

  function StrMatches(const Substr, S: string; const Index: Integer): Boolean;

{$IFNDEF DELPHI12_UP}
function CharInSet(const Ch: AnsiChar; const SetOfChar: TCharSet): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF SUPPORTS_INLINE}
{$ENDIF ~DELPHI12_UP}

implementation

uses StrUtils;

{$IFNDEF DELPHI12_UP}
function CharInSet(const Ch: AnsiChar; const SetOfChar: TCharSet): Boolean;
begin
  Result := Ch in SetOfChar;
end;
{$ENDIF ~DELPHI12_UP}

procedure SetChar(var Dest: array of Char; Str:string);
begin
  StrLCopy( @Dest, PChar(Str), SizeOf(Dest) );
end;

function LoadWCharDW(strm:TStream):PWideChar;
var WStr:WideString;
    dw:LongWord;
begin
  strm.Read(dw, Sizeof(dw));
  SetLength(WStr, dw div 2);
  strm.Read(PWideChar(WStr)^, dw);

  result := WStrNew( PWideChar(WStr) );
end;

function LoadWCharB(strm:TStream):PWideChar;
var WStr:WideString;
    b:byte;
begin
  strm.Read(b, Sizeof(b));
  SetLength(WStr, b div 2);
  strm.Read(PWideChar(WStr)^, b);

  result := WStrNew( PWideChar(WStr) );
end;

procedure WStrDispose(var str:PWideChar);
begin
  if Str = nil then exit;
  FreeMem(Str, Length(str)*2+2);
  Str := nil;
end;

Function WStrNew(Str:PWideChar):PWideChar;
var strLen:Integer;
begin
  strLen := Length(str)*2;
  GetMem(Result, strLen+2);
  Move(Str^, Result^, strLen);
  PByteArray(Result)^[ strLen   ] := 0;
  PByteArray(Result)^[ strLen+1 ] := 0;
end;

procedure CopyWideChar(Source, Dest: PWideChar; SourceSize: Integer);
begin
  Move(Source^, Dest^, SourceSize);
end;

procedure SetWideChar(var Dest: array of WideChar; Str:WideString); overload;
begin
  SetWideChar(@Dest, Sizeof(Dest), Str);
end;

procedure SetWideChar(Dest: PWideChar; DestLen: Integer; Str:WideString);
var strLen:Integer;
    BufLen:Integer;
begin
  strLen := Length(str);
  BufLen := DestLen div 2 -1;

  if strLen < BufLen then begin
    Move(PWideChar(Str)^, Dest^, strLen*2);
    PWordArray(Dest)^[ strLen ] := 0;
  end
  else begin
    Move(PWideChar(Str)^, Dest^, BufLen*2);
    PWordArray(Dest)^[ BufLen ] := 0;
  end;
end;

function RepeatStr(Str:string; Count:Integer; SubDiv:string = ''):string;
var i:integer;
begin
  result := '';
  for i := 0 to Count-1 do begin
    if result <> '' then result := result + SubDiv;
    result := result + str;
  end;
end;

function AppendFirstChar(str:string; Size:Integer; Char:string):string;
begin
  result := str;

  while Length(result) < Size do
    result := Char+result;
end;

function ReplCodeString(const S:string): string;
var i:integer;
begin
  result := '';
  for i := 1 to Length(s) do
    if ord(s[i]) < $20 then
      case ord(s[i]) of
        13, 10, 9: result := result + s[i]
        else
          result := result + '#'''+IntToStr(ord(s[i]))+'''';
      end
    else
      result := result + s[i]
end;

function DelEndRet(Str: string):string;
begin
  result := str;
  while Length(result) > 0 do
    case Byte(Result[Length(result)]) of
      13, 10:
        SetLength(result, Length(result)-1);
      else
        break;
    end;
end;

function DelQuote(Str: string): string;
var s,l:integer;
begin
  Str := Trim(Str);

  if str = '' then begin
    result := str;
    exit;
  end;

  if str[1] = '"' then
    s := 2
  else
    s := 1;

  l := Length(str);
  if str[l] = '"' then
    l := l-s
  else
    l := l-s+1;

  result := copy(str, s, l);
end;

function DelESpace(const S: string): string;
var
  I: Integer;
begin
  I := Length(S);
  while (I > 0) and (S[I] = ' ') do Dec(I);
  Result := Copy(S, 1, I);
end;

function DelEEndStrings(const S: string): string;
var i:integer;
    str:TStringList;
begin
  result := '';
  str := TStringList.Create;
  try
    str.Text := s;

    // Ragth space
    for i := 0 to str.Count-1 do
      str.Strings[i] := DelESpace(str.Strings[i]);

    // End ret
    for i := str.count-1 downto 0 do
      if str.Strings[i] <> '' then
        break
      else
        str.Delete(i);

    result := str.Text;
  finally
    str.Free;
  end;
end;

// Derived from "Like" by Michael Winter
function StrMatches(const Substr, S: string; const Index: Integer): Boolean;
var
  StringPtr: PChar;
  PatternPtr: PChar;
  StringRes: PChar;
  PatternRes: PChar;
begin
  if SubStr = '' then
    raise Exception.Create('RsBlankSearchString');

  Result := SubStr = '*';

  if Result or (S = '') then
    Exit;

  if (Index <= 0) or (Index > Length(S)) then
    raise Exception.Create('Argument out of range');

  StringPtr := PChar(@S[Index]);
  PatternPtr := PChar(SubStr);
  StringRes := nil;
  PatternRes := nil;

  repeat
    repeat
      case PatternPtr^ of
        #0:begin
          Result := StringPtr^ = #0;
          if Result or (StringRes = nil) or (PatternRes = nil) then
            Exit;

          StringPtr := StringRes;
          PatternPtr := PatternRes;
          Break;
        end;
        '*':begin
          Inc(PatternPtr);
          PatternRes := PatternPtr;
          Break;
        end;
        '?':begin
          if StringPtr^ = #0 then
            Exit;
          Inc(StringPtr);
          Inc(PatternPtr);
        end;
        else begin
          if StringPtr^ = #0 then
            Exit;
          if StringPtr^ <> PatternPtr^ then begin
            if (StringRes = nil) or (PatternRes = nil) then
              Exit;
            StringPtr := StringRes;
            PatternPtr := PatternRes;
            Break;
          end
          else begin
            Inc(StringPtr);
            Inc(PatternPtr);
          end;
        end;
      end;
    until False;

    repeat
      case PatternPtr^ of
        #0:begin
          Result := True;
          Exit;
        end;
        '*':begin
          Inc(PatternPtr);
          PatternRes := PatternPtr;
        end;
        '?':begin
          if StringPtr^ = #0 then
            Exit;
          Inc(StringPtr);
          Inc(PatternPtr);
        end;
      else
      begin
        repeat
          if StringPtr^ = #0 then
            Exit;
          if StringPtr^ = PatternPtr^ then
            Break;
          Inc(StringPtr);
        until False;
        Inc(StringPtr);
        StringRes := StringPtr;
        Inc(PatternPtr);
        Break;
      end;
      end;
    until False;
  until False;
end;

function ReplaceStr(const S, Srch, Replace: string): string;
var
  I: Integer;
  Source: string;
begin
  Source := S;
  Result := '';
  repeat
    I := Pos(Srch, Source);
    if I > 0 then begin
      Result := Result + Copy(Source, 1, I - 1) + Replace;
      Source := Copy(Source, I + Length(Srch), MaxInt);
    end
    else Result := Result + Source;
  until I <= 0;
end;

function ReplaceStr(const S, Srch, Replace: WideString): WideString;
var
  I: Integer;
  Source: WideString;
begin
  Source := S;
  Result := '';
  repeat
    I := Pos(Srch, Source);
    if I > 0 then begin
      Result := Result + Copy(Source, 1, I - 1) + Replace;
      Source := Copy(Source, I + Length(Srch), MaxInt);
    end
    else Result := Result + Source;
  until I <= 0;
end;

function ReplaceStrQuote(const S, Srch, Replace: string; Quote:string): string;
var
  I, QI, Pos:Integer;
  Source: string;
  Quoted:boolean;
begin
  Source := S;
  Result := '';
  Pos := 1;
  Quoted := false;
  while true do begin
    if Quoted then begin
      QI := PosEx(Quote, Source, Pos);
      if QI > 0 then begin
        Pos := Qi+1;
        Quoted := false;
      end
      else begin
        Result := Result + Source;
        exit;
      end;  
    end
    else begin
      I  := PosEx(Srch,  Source, Pos);
      QI := PosEx(Quote, Source, Pos);

      // Sub found
      if I > 0 then begin
        if (QI <> 0) and (QI < I) then begin
          Pos := Qi+1;
          Quoted := true;
        end
        else begin
          Result := Result + Copy(Source, 1, I - 1) + Replace;
          Source := Copy(Source, I + Length(Srch), MaxInt);
          Pos := 0;
        end;
      end
      else begin
        Result := Result + Source;
        exit;
      end;  
    end;
  end;
end;

function WordCount(const S: string; const WordDelims: TCharSet; Quote:TCharSet = []): Integer;
var
  SLen, I: Cardinal;
  QuotedFlag:boolean;
begin
  Result := 0;
  I := 1;
  QuotedFlag := False;
  SLen := Length(S);
  while I <= SLen do begin
    { skip over delimiters }
    while (I <= SLen) and CharInSet(S[I], WordDelims) do
      Inc(I);
    { if we're not beyond end of S, we're at the start of a word }
    if I <= SLen then
      Inc(Result);
    // get word
    while (I <= SLen) and ((not CharInSet(S[I], WordDelims) or CharInSet(S[I], Quote) or QuotedFlag)) do begin
      // Set quoted
      if CharInSet(s[I], Quote) then
        QuotedFlag := not QuotedFlag;

      Inc(I);
    end;
  end;
end;

function WordPosition(const N: Integer; const S: string; const WordDelims: TCharSet; Quote:TCharSet = []): Integer;
var
  Count, I: Integer;
  QuotedFlag:boolean;
begin
  Count := 0;
  I := 1;
  QuotedFlag := False;
  Result := 0;
  while (I <= Length(S)) and (Count <> N) do begin
    { skip over delimiters }
    while (I <= Length(S)) and CharInSet(S[I], WordDelims) do
      Inc(I);
    { if we're not beyond end of S, we're at the start of a word }
    if I <= Length(S)
      then Inc(Count);
    { if not finished, find the end of the current word }
    if Count <> N then
      while (I <= Length(S)) and ((not CharInSet(S[I], WordDelims) or CharInSet(S[I], Quote) or QuotedFlag)) do begin
        // Set quoted
        if CharInSet(s[I], Quote) then
          QuotedFlag := not QuotedFlag;

        Inc(I);
      end
    else
      Result := I;
  end;
end;

function ExtractWord(N: Integer; const S: string; const WordDelims: TCharSet; Quote:TCharSet = []): string;
var
  I: Integer;
  Len: Integer;
  QuotedFlag:boolean;
begin
  Len := 0;
  QuotedFlag := False;
  I := WordPosition(N, S, WordDelims, Quote);
  if I <> 0 then
    { find the end of the current word }
    while (I <= Length(S)) and ((not CharInSet(S[I], WordDelims) or CharInSet(S[I], Quote) or QuotedFlag)) do begin
      // Set quoted
      if CharInSet(s[I], Quote) then
        QuotedFlag := not QuotedFlag;

      { add the I'th character to result }
      Inc(Len);
      SetLength(Result, Len);
      Result[Len] := S[I];
      Inc(I);
    end;
  SetLength(Result, Len);
end;

function ExtractDelimited(N: Integer; const S: string; const Delims: TCharSet; Quote:TCharSet = []): string;
var
  CurWord: Integer;
  I, Len, SLen: Integer;
  QuotedFlag:boolean;
begin
  QuotedFlag := False;
  CurWord := 0;
  I := 1;
  Len := 0;
  SLen := Length(S);
  SetLength(Result, 0);
  while (I <= SLen) and (CurWord <> N) do begin
    if CharInSet(s[I], Quote) then
      QuotedFlag := not QuotedFlag;

    if not QuotedFlag then
      if CharInSet(S[I], Delims) then
        Inc(CurWord)
      else begin
        if CurWord = N - 1 then begin
          Inc(Len);
          SetLength(Result, Len);
          Result[Len] := S[I];
        end;
      end;

    Inc(I);
  end;
end;

function ExtractDelim(N: Integer; const S: string; const WordDelims: TCharSet; Quote:TCharSet = []):string;
var wp1, wp2:Integer;
    we1:Integer;
begin
  result := '';
  wp1 := WordPosition(N-1, S, WordDelims, Quote);
  if wp1 = 0 then wp1 := 1;
    
  wp2 := WordPosition(N,   S, WordDelims, Quote);

  we1 := wp1+Length( ExtractWord( N-1, S, WordDelims, Quote ) );

  result := Copy(S, we1, wp2-we1);
end;

function DelWord(N: Integer; const S: string; const WordDelims: TCharSet; Quote:TCharSet = []):string;
var Lpos, LNext:Integer;
begin
  LPos  := WordPosition(n, S, WordDelims, Quote);
  LNext := WordPosition(n+1, S, WordDelims, Quote);
  
  if LPos = 0 then begin
    result := S;
    exit;
  end;

  if LNext = 0 then begin
    result := copy(S, 1, LPos-2);
    exit;
  end;

  result := copy(S, 1, LPos-1)+copy(S, LNext, Length(S));
end;

function ChangeWord(N:Integer; S: string; const Value: string; const WordDelims: TCharSet; Quote:TCharSet = [];
                    AddDelim:string = ','; AddData:string = '0'):string;
var I, J:integer;
begin
  Result := '';

  i := WordPosition(N, s, WordDelims, Quote);
  if (i = 0) and (n <> 1) then begin
    Result := S;
    I := WordCount(S, WordDelims, Quote);
    for J := I+1 to N-1 do
      result := result + AddDelim+AddData;
    result := result + AddDelim + Value;
    exit;
  end
  else
    Result := copy(S, 1, I-1);

  Result := Result + Value;
  i := WordPosition(N, s, WordDelims, Quote);
  j := Length(ExtractWord(N, S, WordDelims, Quote));
  Result := Result + copy(S, i+j, Length(s));
end;

function ExtractSubstr(const S: string; var Pos: Integer;
  const Delims: TCharSet): string;
var
  I: Integer;
begin
  I := Pos;
  while (I <= Length(S)) and not CharInSet(S[I], Delims) do
    Inc(I);
  Result := Copy(S, Pos, I - Pos);
  if (I <= Length(S)) and CharInSet(S[I], Delims) then
    Inc(I);
  Pos := I;
end;

end.
