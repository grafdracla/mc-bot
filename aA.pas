unit aA;

interface

//{$DEFINE DEBUG_A}

uses
  Types, Generics.Collections,

  mcTypes, uPlugins;

type
  TTestBlock = procedure(Pos: TAbsPos; var Fly:boolean; var Passability: Extended) of object;
  TCheckBlock = function(Pos: TAbsPos):Boolean of object;

  PCellInfo = ^TCellInfo;
  TCellInfo = packed record
    Pos: TAbsPos;
    Parent: TAbsPos;
    Fly:Boolean;
    Gravity:byte;

    G: Integer;
    H: Integer;
    F: Integer;
  end;

  TAArray = Generics.Collections.TDictionary<TAbsPos, PCellInfo>;

// S - Start
// F - finish
function AFind(S, F:TAbsPos; TestBlock: TTestBlock; Path: TPath;
    MaxPath, FinishRange:Integer; Nerest:boolean = false; DebugSteck:TAArray = nil): boolean;

// S - Start
// C - Center region
// HeightT - region height top
// HeightB - region height bottom
function ANerest(S, C:TAbsPos; CheckBlock: TCheckBlock; Radius, HeightT, HeightB:Integer; var Point:TAbsPos):Boolean;

procedure AClearItems(LArray:TAArray);

implementation

uses
  Classes,
  SysUtils,
  qSysUtils;

const
  cOrtoMove = 10;
  cDiagMove = 14;

  cMaxJamp = 3;

// This function estimates the distance from a given square to the
// target square, usually refered to as H or the H cost.
function EstimateHcost(x, y, z: Integer; Targ:TAbsPos): Integer;
begin
  // (1) Manhattan (dx+dy)
  result := cOrtoMove *
    (
      Abs(x - Targ.x) +
      Abs(y - Targ.y) +
      Abs(z - Targ.z)
    );
end;

function CompareFCeel(Data:Pointer; Item:Pointer):integer;
begin
  result := PCellInfo(Item).F - Integer(Data);
end;

procedure AClearItems(LArray:TAArray);
var Elm:TPair<TAbsPos, PCellInfo>;
begin
  for Elm in LArray do
    Dispose(Elm.Value);

  LArray.Clear;
end;

procedure ACopyItems(FromArray:TAArray; var ToArray:TAArray);
var Elm:TPair<TAbsPos, PCellInfo>;
begin
  for Elm in FromArray do
    ToArray.Add( Elm.Key, Elm.Value );
end;

function AFind(S, F:TAbsPos; TestBlock: TTestBlock; Path: TPath;
    MaxPath, FinishRange:Integer; Nerest:boolean = false; DebugSteck:TAArray = nil): boolean;

{$IFDEF DEBUG_A}
var
  fLog:TStringList;
{$ENDIF}

var
  fOpenList:TAArray;
  fCloseList:TAArray;
  fOpenIndx:TList;
//  i: Integer;

  procedure OpenAdd(Pos:TAbsPos; Cell:PCellInfo);
  var
    fInd:Integer;
  begin
    // From list
    fOpenList.Add( Pos, Cell );

    // From index
    fInd := FindIndexPos( fOpenIndx, Pointer(Cell.F), CompareFCeel );
    fOpenIndx.Insert(fInd, Cell);
  end;

  procedure OpenRemove(Cell:PCellInfo);
  begin
    // From list
    fOpenList.Remove( Cell.Pos );

    // From index
    fOpenIndx.Remove( Cell );
  end;

  procedure TestOptimizePath(MCell, Cell:PCellInfo);
  var fCG:Integer;
      fPassability1, fPassability2:Extended;
      fFly:boolean;
  begin
    // Test not fly
    if Cell.Fly or MCell.Fly then begin
      //fCG := fCg;
      exit;
    end;

    // Get move
    if (Cell.Pos.X = MCell.Pos.X) or
       (Cell.Pos.Z = MCell.Pos.Z) then
      fCG := Cell.G + cOrtoMove
    else
      fCG := Cell.G + cDiagMove;

    if fCG < MCell.G then begin
      // ≈сли клетка не проходима наискось
      if not (
        (Cell.Pos.X = MCell.Pos.X) or
        (Cell.Pos.Z = MCell.Pos.Z)
      ) then begin

        TestBlock( AbsPos( Cell.Pos.X,  Cell.Pos.Y, MCell.Pos.Z ), fFly, fPassability1);
        TestBlock( AbsPos( MCell.Pos.X, Cell.Pos.Y, Cell.Pos.Z  ), fFly, fPassability2);

        if (fPassability1 <> 1) or (fPassability2 <> 1) then
          exit;
      end;

      MCell.Parent := Cell.Pos;

      MCell.G := fCG;
      MCell.F := Cell.G + Cell.H;

      {$IFDEF DEBUG_A}
        fLog.Add(#9'$'#9+
          'X:'+IntToStr(MCell.Pos.X)+#9+
          'Z:'+IntToStr(MCell.Pos.Z)+#9+
          'Y:'+IntToStr(MCell.Pos.Y)+#9+
          'G:'+IntToStr(MCell.G)+#9+
          'H:'+IntToStr(MCell.H)+#9+
          'F:'+IntToStr(MCell.F) );
      {$ENDIF}
    end;
  end;

  function AppendCeel(Pos:TAbsPos; MCell:PCellInfo):boolean;
  var
    fCell: PCellInfo;
    fFly:boolean;
    fPassability:Extended;
  begin
    result := false;

    // ≈сли клетка находитс€ в закрытом списке, игнорируем ее
    if not fCloseList.TryGetValue( Pos, fCell ) then
      fCell := nil;

    if fCell <> nil then begin
      TestOptimizePath(MCell, fCell);
      exit;
    end;

    // ≈сли клетка непроходима€, игнорируем ее
    TestBlock( Pos, fFly, fPassability);
    if fPassability = 0 then exit;

    // ≈сли клетка еще не в открытом списке, то добавл€ем ее туда.
    // ƒелаем текущую клетку родительской дл€ это клетки.
    // –асчитываем стоимости F, G и H клетки.
    if not fOpenList.TryGetValue( Pos, fCell ) then
      fCell := nil;

    if fCell = nil then begin
      New(fCell);
      fCell.Pos     := Pos;
      fCell.Parent  := MCell.Pos;
      fCell.Fly     := fFly;
      if fFly then
        fCell.Gravity := MCell.Gravity +1
      else
        fCell.Gravity := 0;

      if (pos.Z = MCell.Pos.Z) or (Pos.x = MCell.Pos.X) then
        fCell.G := MCell.G + cOrtoMove
      else
        fCell.G := MCell.G + cDiagMove;

      fCell.H := EstimateHcost(pos.X, pos.y, pos.z, F);
      fCell.F := fCell.G + fCell.H;

      OpenAdd(fCell.Pos, fCell);

      {$IFDEF DEBUG_A}
        fLog.Add(#9'#'+
                 #9'X:'+IntToStr(fCell.Pos.X)+
                 #9'Z:'+IntToStr(fCell.Pos.Z)+
                 #9'Y:'+IntToStr(fCell.Pos.Y)+
                 #9'G:'+IntToStr(fCell.G)+
                 #9'H:'+IntToStr(fCell.H)+
                 #9'F:'+IntToStr(fCell.F) );
      {$ENDIF}
    end

    // ≈сли клетка уже в открытом списке, то провер€ем, не дешевле ли будет путь через эту клетку.
    // ƒл€ сравнени€ используем стоимость G. Ѕолее низка€ стоимость G указывает на то, что путь будет дешевле.
    // Ёсли это так, то мен€ем родител€ клетки на текущую клетку и пересчитываем дл€ нее стоимости G и F.
    else
      TestOptimizePath(MCell, fCell);

    // Found end
    if GetDistance(Pos, F) <= FinishRange then begin
      OpenRemove( fCell );
      fCloseList.Add(Pos, fCell);
      result := true;
    end;
  end;

var
  fMCell, fCell: PCellInfo;
  ix, iz, iy, fNearDest: Integer;
  fNewPos, fFoundPos, fNearPos:TAbsPos;
  fPassability, fPassability1, fPassability2:Extended;
  fFly, fFlySub:boolean;
begin
  result := false;

  Path.Clear;

  // ≈сли конечна€ клетка непроходима
  if not Nerest then begin
    TestBlock( AbsPos(S.X, S.Y, S.Z), fFly, fPassability);
    if fPassability = 0 then exit;
  end;

  // Found end
  if GetDistance(S, F) <= FinishRange then begin
    result := true;
    exit;
  end;

{$IFDEF DEBUG_A}
  fLog := TStringList.Create;
{$ENDIF}

  fOpenList := TAArray.Create;
  fCloseList := TAArray.Create;
  fOpenIndx := TList.Create;
  try
    // ƒобавл€ем стартовую клетку в открытый список.
    New(fCell);
    fCell.Pos := S;
    fCell.Parent := AbsPos(0,0,0);
    fCell.Fly := fFly;
    if fFly then
      fCell.Gravity := 1
    else
      fCell.Gravity := 0;

    fCell.G := 0;
    fCell.H :=  EstimateHcost(S.X, S.y, S.z, F);
    fCell.F := fCell.G + fCell.H;
    OpenAdd( fCell.Pos, fCell );

    // Near pos
    fNearPos := S;
    fNearDest := EstimateHcost(S.X, S.y, S.z, F);

    while fOpenList.Count <> 0 do begin

      // »щем в открытом списке клетку с наименьшей стоимостью F. ƒелаем ее текущей клеткой.
      fMCell := fOpenIndx.First;

      // Ќайти должна хоть 1 т.к. проверка списка на пустоту (выше) <> 0

      // ќграничение на длину пути
      if MaxPath > 0 then
        if fMCell.G > MaxPath then
          break;

      {$IFDEF DEBUG_A}
        fLog.Add('@'#9'X:'+IntToStr(fMCell.Pos.X)+
                    #9'Z:'+IntToStr(fMCell.Pos.Z)+
                    #9'Y:'+IntToStr(fMCell.Pos.Y)+
                    #9'G:'+IntToStr(fMCell.G)+
                    #9'H:'+IntToStr(fMCell.H)+
                    #9'F:'+IntToStr(fMCell.F) );
      {$ENDIF}

      // ѕомещаем ее в закрытый список. (» удал€ем с открытого)
      OpenRemove( fMCell );

      fCloseList.Add(fMCell.Pos, fMCell);

      // Set near
      if (fMCell.G <> 0) and (fNearDest > fMCell.H) then begin
        fNearDest := fMCell.H;
        fNearPos := fMCell.Pos;
      end;

      // Append up
      if not fMCell.Fly then begin
        fNewPos := AbsPos(fMCell.Pos.X, fMCell.Pos.Y+1, fMCell.Pos.Z);
        result := AppendCeel( fNewPos, fMCell );

        if result then
          fFoundPos := fNewPos;
      end;

      // Append down
      if fMCell.Gravity < cMaxJamp then begin
        fNewPos := AbsPos(fMCell.Pos.X, fMCell.Pos.Y-1, fMCell.Pos.Z);
        result := AppendCeel( fNewPos, fMCell );

        if result then
          fFoundPos := fNewPos;
      end;

      // ƒл€ каждой из соседних 8-ми клеток ...
      if not result then
        for iz := fMCell.Pos.Z-1 to fMCell.Pos.Z+1 do begin
          for ix := fMCell.Pos.X-1 to fMCell.Pos.X+1 do begin
            iy := fMCell.Pos.Y;

            // ≈сли клетка не проходима наискось @@@
            if not ((iz = fMCell.Pos.Z) or (ix = fMCell.Pos.X)) then begin
              TestBlock( AbsPos( ix, iy, fMCell.Pos.Z ), fFlySub, fPassability1);
              TestBlock( AbsPos( fMCell.Pos.X, iy, iz ), fFlySub, fPassability2);

              if (fPassability1 <> 1) or (fPassability2 <> 1) then
                continue;
            end;

            fNewPos := AbsPos(ix, iy, iz);
            Result := AppendCeel( fNewPos, fMCell );
            if result then begin
              fFoundPos := fNewPos;
              break;
            end;
          end;

          // Found
          if result then
            Break;
        end;

      // Found
      if result then
        Break;
    end;

    // === Save path ===
    // Nerest
    if not result then begin
      if not Nerest then exit;

      if not fCloseList.TryGetValue( fNearPos, fMCell ) then begin
        result := False;
        exit;
      end;

      result := true;
    end
    // End point
    else
      if not fCloseList.TryGetValue( AbsPos(fFoundPos.X, fFoundPos.Y, fFoundPos.Z), fMCell ) then begin
        result := False;
        exit;
      end;

    while fMCell <> nil do begin
      Path.Insert(0, AbsPos(fMCell.Pos.X, fMCell.Pos.Y, fMCell.Pos.Z));

      if CompareAbsPos(fMCell.Pos, S) then
        break;

      if not fCloseList.TryGetValue( AbsPos(fMCell.Parent.X, fMCell.Parent.Y, fMCell.Parent.Z), fMCell ) then
        fMCell := nil;
    end;

  finally
    if DebugSteck <> nil then begin
      ACopyItems(fCloseList, DebugSteck);
      ACopyItems(fOpenList,  DebugSteck);
    end;

    {$IFDEF DEBUG_A}
      fLog.SaveToFile('d:\path.txt');
    {$ENDIF}

    AClearItems(fOpenList);
    fOpenList.free;

    AClearItems(fCloseList);
    fCloseList.free;

    fOpenIndx.Free;

    {$IFDEF DEBUG_A}
      fLog.Free;
    {$ENDIF}
  end;
end;

function ANerest(S, C:TAbsPos; CheckBlock: TCheckBlock; Radius, HeightT, HeightB:Integer; var Point:TAbsPos):Boolean;
var
  fOpenList, fCloseList:TAArray;
  fOpenIndx:TList;

  procedure OpenAdd(Pos:TAbsPos; Cell:PCellInfo);
  var
    fInd:Integer;
  begin
    // From list
    fOpenList.Add( Pos, Cell );

    // From index
    fInd := FindIndexPos( fOpenIndx, Pointer(Cell.F), CompareFCeel );
    fOpenIndx.Insert(fInd, Cell);
  end;

  procedure OpenRemove(Cell:PCellInfo);
  begin
    // From list
    fOpenList.Remove( Cell.Pos );

    // From index
    fOpenIndx.Remove( Cell );
  end;

  function AppendCeel(Pos:TAbsPos; MCell:PCellInfo):Boolean;
  var
    fCell:PCellInfo;
  begin
    Result := false;

    // ≈сли клетка находитс€ в закрытом списке, игнорируем ее
    if fCloseList.TryGetValue( Pos, fCell ) then exit;

    // ≈сли клетка еще не в открытом списке, то добавл€ем ее туда.
    // ƒелаем текущую клетку родительской дл€ это клетки.
    // –асчитываем стоимости F, G и H клетки.
    if fOpenList.TryGetValue( Pos, fCell ) then exit;

    // Test block
    result := CheckBlock(Pos);
    if result then exit;

    New(fCell);
    fCell.Pos := Pos;
    fCell.F   := EstimateHcost(pos.X, pos.y, pos.z, S);

    OpenAdd(fCell.Pos, fCell);
  end;

var
  fCell, fMCell:PCellInfo;
  ix, iz, iy: Integer;
  fNewPos:TAbsPos;
begin
  result := false;

  fOpenList := TAArray.Create;
  fCloseList := TAArray.Create;
  fOpenIndx := TList.Create;
  try
    // ƒобавл€ем стартовую клетку в открытый список.
    New(fCell);
    fCell.Pos := S;
    fCell.F := 0;
    OpenAdd( fCell.Pos, fCell );

    while fOpenList.Count <> 0 do begin
      // »щем в открытом списке клетку с наименьшей стоимостью F. ƒелаем ее текущей клеткой.
      fMCell := fOpenIndx.First;

      {$IFDEF DEBUG_A}
        fLog.Add('@'#9'X:'+IntToStr(fMCell.Pos.X)+
                    #9'Z:'+IntToStr(fMCell.Pos.Z)+
                    #9'Y:'+IntToStr(fMCell.Pos.Y)+
                    #9'F:'+IntToStr(fMCell.F) );
      {$ENDIF}

      // ѕомещаем ее в закрытый список. (» удал€ем с открытого)
      OpenRemove( fMCell );

      fCloseList.Add(fMCell.Pos, fMCell);

      for iz := fMCell.Pos.Z-1 to fMCell.Pos.Z+1 do begin
        if (iz < c.Z - Radius) or (iz > c.Z + Radius) then Continue;

        for ix := fMCell.Pos.X-1 to fMCell.Pos.X+1 do begin
          if (ix < c.X - Radius) or (ix > c.X + Radius) then continue;

          for iy := fMCell.Pos.Y-1 to fMCell.Pos.Y+1 do begin
            if (iy < c.Y - HeightT) or (iy > c.Y + HeightB) then Continue;

            fNewPos := AbsPos(ix, iy, iz);
            Result := AppendCeel( fNewPos, fMCell );
            if result then begin
              Point := fNewPos;
              exit;
            end;
          end;
        end;
      end;

    end;

  finally
    fOpenIndx.Free;

    AClearItems(fOpenList);
    fOpenList.free;

    AClearItems(fCloseList);
    fCloseList.free;
  end;
end;

end.
