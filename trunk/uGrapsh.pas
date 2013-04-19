unit uGrapsh;

interface

type
  TPointEx = packed record
    X:Double;
    Y:Double;
  end;

  function PointEx(X, Y:Double):TPointEx; inline;

implementation

function PointEx(X, Y:Double):TPointEx; inline;
begin
  result.X := X;
  result.Y := Y;
end;

function Subtract(AVec1, AVec2 : TPointEx) : TPointEx;
begin
  Result.X := AVec1.X - AVec2.X;
  Result.Y := AVec1.Y - AVec2.Y;
end;

function LinesCross(LineAP1, LineAP2, LineBP1, LineBP2 : TPointEx) : boolean;
Var
  diffLA, diffLB : TPointEx;
  CompareA, CompareB : Double;
begin
  Result := False;

  diffLA := Subtract(LineAP2, LineAP1);
  diffLB := Subtract(LineBP2, LineBP1);

  CompareA := diffLA.X*LineAP1.Y - diffLA.Y*LineAP1.X;
  CompareB := diffLB.X*LineBP1.Y - diffLB.Y*LineBP1.X;

  if ( ((diffLA.X*LineBP1.Y - diffLA.Y*LineBP1.X) < CompareA) xor
       ((diffLA.X*LineBP2.Y - diffLA.Y*LineBP2.X) < CompareA) ) and
     ( ((diffLB.X*LineAP1.Y - diffLB.Y*LineAP1.X) < CompareB) xor
       ((diffLB.X*LineAP2.Y - diffLB.Y*LineAP2.X) < CompareB) ) then
    result := True;
end;

function LineIntersect(LineAP1, LineAP2, LineBP1, LineBP2 : TPointEx) : TPointEx;
Var
  LDetLineA, LDetLineB, LDetDivInv : Double;
  LDiffLA, LDiffLB : TPointEx;
begin
  LDetLineA := LineAP1.X*LineAP2.Y - LineAP1.Y*LineAP2.X;
  LDetLineB := LineBP1.X*LineBP2.Y - LineBP1.Y*LineBP2.X;

  LDiffLA := Subtract(LineAP1, LineAP2);
  LDiffLB := Subtract(LineBP1, LineBP2);

  LDetDivInv := 1 / ((LDiffLA.X*LDiffLB.Y) - (LDiffLA.Y*LDiffLB.X));

  Result.X := ((LDetLineA*LDiffLB.X) - (LDiffLA.X*LDetLineB)) * LDetDivInv;
  Result.Y := ((LDetLineA*LDiffLB.Y) - (LDiffLA.Y*LDetLineB)) * LDetDivInv;
end;

end.
