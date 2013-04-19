unit mcTypes;

interface

uses
  Generics.Collections,

  uPlugins;

type
  TPath = Generics.Collections.TList<TAbsPos>;

  function AbsPos(X, Y, Z:Integer):TAbsPos;
  function ToPos(X, Y, Z:Extended):TPos;
  function CompareAbsPos(A, B:TAbsPos):Boolean;
  function ComparePos(A, B:TPos):Boolean;

  function GetDistance(P1, P2:TPos):Extended; overload;
  function GetDistance(P1, P2:TAbsPos):Extended; overload;

implementation

uses
  Math;

function CompareAbsPos(A, B:TAbsPos):Boolean;
begin
  result := (A.X = B.X) and (A.Y = B.Y) and (A.Z = B.Z);
end;

function ComparePos(A, B:TPos):Boolean;
begin
  result := (A.X = B.X) and (A.Y = B.Y) and (A.Z = B.Z);
end;

function AbsPos(X, Y, Z:Integer):TAbsPos;
begin
  Result.X := X;
  Result.Y := Y;
  Result.Z := Z;
end;

function ToPos(X, Y, Z:Extended):TPos;
begin
  result.X := X;
  result.Y := Y;
  result.Z := Z;
end;

function GetDistance(P1, P2:TPos):Extended;
begin
  result := Abs( Sqrt(
    Sqr(p2.X-p1.X)+
    Sqr(P2.Y-p1.Y)+
    Sqr(P2.Z-p1.Z) ));
end;

function GetDistance(P1, P2:TAbsPos):Extended;
begin
  result := Abs( Sqrt(
    Sqr(p2.X-p1.X)+
    Sqr(P2.Y-p1.Y)+
    Sqr(P2.Z-p1.Z) ));
end;

end.
