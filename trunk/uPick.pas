unit uPick;

interface

uses
  mcTypes,

  uPlugins;

  function Pick(Src, Dest:TPos):integer;

implementation

uses
  Math;

// -1 - No picl
//  0 - Error

//  1 - Left side
//  2 - Right side
//  3 - Up side
//  4 - Down side
//  5 - Front side
//  6 - Back side

function Pick(Src, Dest:TPos):integer;
var
  fVX, fVY, fVZ:Extended;
  fCosAngle, fCosEdgeVector:Extended;
  fPointVectorX, fPointVectorY, fPointVectorZ:Extended;
begin
  result := -1;

  // Vector
  fVX := Dest.X - Src.X;
  fVY := Dest.Y - Src.Y;
  fVZ := Dest.Z - Src.Z;

  // Test not out
  if (Floor(Src.X+fVX) = Floor(Src.X)) and
     (Floor(Src.Y+fVY) = Floor(Src.Y)) and
     (Floor(Src.Z+fVZ) = Floor(Src.Z)) then
    exit;

  // Horizontal
  if fVZ > 0 then
    if fVX > 0 then begin
      fCosAngle := fVX / ( Sqr( Power(fVX, 2)+Power(fVZ, 2) )*1.0 );
      fPointVectorX := Ceil(Src.X)-Src.X;
      fPointVectorZ := Ceil(Src.Z)-Src.Z;
      fCosEdgeVector := fPointVectorX / ( Sqr( Power(fPointVectorX, 2) + Power(fPointVectorZ, 2)) );

      if fCosAngle > fCosEdgeVector then
        // Right side
        result := 2

      else
        // Front side
        result := 5;
    end
    else
      If fVX = 0 then
        // Front side
        result := 5

      else begin
        fCosAngle := fVX / ( Sqr( Power(fVX, 2)+Power(fVZ, 2) )*1.0 );
        fPointVectorX := Floor(Src.X)-Src.X;
        fPointVectorZ := Ceil(Src.Z)-Src.Z;
        fCosEdgeVector := fPointVectorX / ( Sqr( Power(fPointVectorX, 2) + Power(fPointVectorZ, 2)) );

        If fCosAngle < fCosEdgeVector then
          // Left side
          result := 1

        else
          // Front side
          result := 5
      end

  else
    if fVZ = 0 then
      if fVX > 0 then
        // Right side
        result := 2

      else
        if fVX = 0 then
          // None
          Result := 0

        else
          // Left side
          result := 1
    else
      If fVX > 0 then begin
        fCosAngle := fVX / ( Sqr( Power(fVX, 2)+Power(fVZ, 2) )*1.0 );
        fPointVectorX := Ceil(Src.X)-Src.X;
        fPointVectorZ := Floor(Src.Z)-Src.Z;
        fCosEdgeVector := fPointVectorX / ( Sqr( Power(fPointVectorX, 2) + Power(fPointVectorZ, 2)) );

        if fCosAngle > fCosEdgeVector then
          // Right side
          result := 2
        else
          // Back side
          result := 6;
      end
      else
        If fVX = 0 then
          // Back side
          result := 6

        else begin
          fCosAngle := fVX / ( Sqr( Power(fVX, 2)+Power(fVZ, 2) )*1.0 );
          fPointVectorX := Floor(Src.X)-Src.X;
          fPointVectorZ := Floor(Src.Z)-Src.Z;
          fCosEdgeVector := fPointVectorX / ( Sqr( Power(fPointVectorX, 2) + Power(fPointVectorZ, 2)) );

          If fCosAngle < fCosEdgeVector then
            // Left side
            result := 1
          else
            // Back side
            result := 6;
        end;

  // Vertical
  If fVY <> 0 then
    if fVY > 0 then
      case result of
        // Left side, Right side
        1, 2:begin
          fCosAngle := fVX / ( Sqr( Power(fVX, 2)+Power(fVY, 2) )*1.0 );
          fPointVectorY := Ceil(Src.Y)-Src.Y;

          // Left side
          if Result = 1 then begin
            fPointVectorX := Floor(Src.X)-Src.X;
            fCosEdgeVector := fPointVectorX / ( Sqr( Power(fPointVectorX, 2) + Power(fPointVectorY, 2)) );

            if fCosAngle > fCosEdgeVector then
              // Up side
              result := 3;
          end
          // Right side
          else begin
            fPointVectorX := Ceil(Src.X)-Src.X;
            fCosEdgeVector := fPointVectorX / ( Sqr( Power(fPointVectorX, 2) + Power(fPointVectorY, 2)) );

            if fCosAngle < fCosEdgeVector then
              // Up side
              result := 3;
          end;
        end;
        // Front side, Back side
        5, 6:begin
          fCosAngle := fVZ / ( Sqr( Power(fVZ, 2)+Power(fVY, 2) )*1.0 );
          fPointVectorY := Ceil(Src.Y)-Src.Y;

          // Front side
          if result = 5 then begin
            fPointVectorZ := Ceil(Src.Z)-Src.Z;
            fCosEdgeVector := fPointVectorZ / ( Sqr( Power(fPointVectorZ, 2) + Power(fPointVectorY, 2)) );

            if fCosAngle < fCosEdgeVector then
              // Up side
              Result := 3;
          end
          // Back side
          else begin
            fPointVectorZ := Floor(Src.Z)-Src.Z;
            fCosEdgeVector := fPointVectorZ / ( Sqr( Power(fPointVectorZ, 2) + Power(fPointVectorY, 2)) );

            if fCosAngle > fCosEdgeVector then
              // Up side
              Result := 3;
          end;
        end;
        // None
        0:begin
          // Up side
          result := 3;
        end;
      end

    else
      case result of
        // Left side, Right side
        1, 2:begin
          fCosAngle := fVX / ( Sqr( Power(fVX, 2)+Power(fVY, 2) )*1.0 );
          fPointVectorY := Floor(Src.Y)-Src.Y;

          // Left side
          if result = 1 then begin
            fPointVectorX := Floor(Src.X)-Src.X;
            fCosEdgeVector := fPointVectorX / ( Sqr( Power(fPointVectorX, 2) + Power(fPointVectorY, 2)) );

            if fCosAngle > fCosEdgeVector then
              // Down side
              result := 4;
          end
          // Right side
          else begin
            fPointVectorX := Ceil(Src.X)-Src.X;
            fCosEdgeVector := fPointVectorX / ( Sqr( Power(fPointVectorX, 2) + Power(fPointVectorY, 2)) );

            if fCosAngle < fCosEdgeVector then
              // Down side
              result := 4;
          end;
        end;
        // Front side, Back side
        5, 6:begin
          fCosAngle := fVZ / ( Sqr( Power(fVZ, 2)+Power(fVY, 2) )*1.0 );
          fPointVectorY := Floor(Src.Y)-Src.Y;

          // Front side
          if result = 5 then begin
            fPointVectorZ := Ceil(Src.Z)-Src.Z;
            fCosEdgeVector := fPointVectorZ / ( Sqr( Power(fPointVectorZ, 2) + Power(fPointVectorY, 2)) );

            if fCosAngle < fCosEdgeVector then
              // Down side
              result := 4;
          end
          // Back side
          else begin
            fPointVectorZ := Floor(Src.Z)-Src.Z;
            fCosEdgeVector := fPointVectorZ / ( Sqr( Power(fPointVectorZ, 2) + Power(fPointVectorY, 2)) );

            if fCosAngle > fCosEdgeVector then
              // Down side
              result := 4;
          end;
        end;
        // None
        0:begin
          // Down side
          result := 4;
        end;
      end;

end;

(*
;Описываем переменные, какие мы будем использовать вне функции
Global PickX#
Global PickY#
Global PickZ#
Global PickVx#
Global PickVy#
Global PickVz#

Function Pick%(PointX#,PointY#,PointZ#,VectorX#=0,VectorY#=0,VectorZ#=0)
    Local CosAngle#,CosEdgeVector#
    Local PointVectorX#,PointVectorZ#,PointVectorY#
    Local Side=0
    Local X2#,Y2#,Z2#
    Local X#=PointX
    Local Y#=PointY
    Local Z#=PointZ
    Local VX#=VectorX
    Local VY#=VectorY
    Local VZ#=VectorZ

    Repeat


    :Если вектор вообще не выходит из куба (слишком короткий) - выходим из функции.
    If Floor(X+VX)=Floor(X) And Floor(Y+VY)=Floor(Y) And Floor(Z+VZ)=Floor(Z)
        PickX=X+VX
        PickY=Y+VY
        PickZ=Z+VZ
        PickVx=VX
        PickVy=VY
        PickVz=VZ
        Return World(Floor(X),Floor(Y),Floor(Z))
    EndIf

        If VZ>0
            If VX>0
                CosAngle=VX/(Sqr(VX^2+VZ^2)*1.0)
                PointVectorX=Ceil(X)-X
                PointVectorZ=Ceil(Z)-Z
                CosEdgeVector=PointVectorX/(Sqr(PointVectorX^2+PointVectorZ^2))
                If CosAngle>CosEdgeVector
                    ;=========================================================================Right side
                    Side=2
                Else
                    ;=========================================================================Front side
                    Side=5
                EndIf
            Else
                If VX=0
                    ;=========================================================================Front side
                    Side=5
                Else
                    CosAngle=VX/(Sqr(VX^2+VZ^2)*1.0)
                    PointVectorX=Floor(X)-X
                    PointVectorZ=Ceil(Z)-Z
                    CosEdgeVector=PointVectorX/(Sqr(PointVectorX^2+PointVectorZ^2))
                    If CosAngle<CosEdgeVector
                        ;=========================================================================Left side
                        Side=1
                    Else
                        ;=========================================================================Front side
                        Side=5
                    EndIf
                EndIf
            EndIf
        Else
            If VZ=0
                If VX>0
                    ;=========================================================================Right side
                    Side=2
                Else
                    If VX=0
                        Side=0
                    Else
                        ;=========================================================================Left side
                        Side=1
                    EndIf
                EndIf
            Else
                If VX>0
                    CosAngle=VX/(Sqr(VX^2+VZ^2)*1.0)
                    PointVectorX=Ceil(X)-X
                    PointVectorZ=Floor(Z)-Z
                    CosEdgeVector=PointVectorX/(Sqr(PointVectorX^2+PointVectorZ^2))
                    If CosAngle>CosEdgeVector
                        ;=========================================================================Right side
                        Side=2
                    Else
                        ;=========================================================================Back side
                        Side=6
                    EndIf
                Else
                    If VX=0
                        ;=========================================================================Back side
                        Side=6
                    Else
                        CosAngle=VX/(Sqr(VX^2+VZ^2)*1.0)
                        PointVectorX=Floor(X)-X
                        PointVectorZ=Floor(Z)-Z
                        CosEdgeVector=PointVectorX/(Sqr(PointVectorX^2+PointVectorZ^2))
                        If CosAngle<CosEdgeVector
                            ;=========================================================================Left side
                            Side=1
                        Else
                            ;=========================================================================Back side
                            Side=6
                        EndIf
                    EndIf
                EndIf
            EndIf
        EndIf

;Теперь, когда мы определили какую сторону пробивает вектор, определим, не пробивает ли он верх или низ?


        If VY<>0
            If VY>0
                Select True
                    Case Side=1 Or Side=2
                        CosAngle=VX/(Sqr(VX^2+VY^2)*1.0)
                        PointVectorY=Ceil(Y)-Y
                        If Side=1
                            PointVectorX=Floor(X)-X
                            CosEdgeVector=PointVectorX/(Sqr(PointVectorX^2+PointVectorY^2)*1.0)
                            If CosAngle>CosEdgeVector
                            ;=========================================================================Up side
                                Side=3
                            EndIf
                        Else
                            PointVectorX=Ceil(X)-X
                            CosEdgeVector=PointVectorX/(Sqr(PointVectorX^2+PointVectorY^2)*1.0)
                            If CosAngle<CosEdgeVector
                            ;=========================================================================Up side
                                Side=3
                            EndIf
                        EndIf
                    Case Side=5 Or Side=6
                        CosAngle=VZ/(Sqr(VZ^2+VY^2)*1.0)
                        PointVectorY=Ceil(Y)-Y
                        If Side=5
                            PointVectorZ=Ceil(Z)-Z
                            CosEdgeVector=PointVectorZ/(Sqr(PointVectorZ^2+PointVectorY^2)*1.0)
                            If CosAngle<CosEdgeVector
                            ;=========================================================================Up side
                                Side=3
                            EndIf
                        Else
                            PointVectorZ=Floor(Z)-Z
                            CosEdgeVector=PointVectorZ/(Sqr(PointVectorZ^2+PointVectorY^2)*1.0)
                            If CosAngle>CosEdgeVector
                            ;=========================================================================Up side
                                Side=3
                            EndIf
                        EndIf
                    Case Side=0
                        ;=========================================================================Up side
                        Side=3
                End Select
            Else
                Select True
                    Case Side=1 Or Side=2
                        CosAngle=VX/(Sqr(VX^2+VY^2)*1.0)
                        PointVectorY=Floor(Y)-Y
                        If Side=1
                            PointVectorX=Floor(X)-X
                            CosEdgeVector=PointVectorX/(Sqr(PointVectorX^2+PointVectorY^2)*1.0)
                            If CosAngle>CosEdgeVector
                            ;=========================================================================Down side
                                Side=4
                            EndIf
                        Else
                            PointVectorX=Ceil(X)-X
                            CosEdgeVector=PointVectorX/(Sqr(PointVectorX^2+PointVectorY^2)*1.0)
                            If CosAngle<CosEdgeVector
                            ;=========================================================================Down side
                                Side=4
                            EndIf
                        EndIf
                    Case Side=5 Or Side=6
                        CosAngle=VZ/(Sqr(VZ^2+VY^2)*1.0)
                        PointVectorY=Floor(Y)-Y
                        If Side=5
                            PointVectorX=Ceil(Z)-Z
                            CosEdgeVector=PointVectorZ/(Sqr(PointVectorZ^2+PointVectorY^2)*1.0)
                            If CosAngle<CosEdgeVector
                            ;=========================================================================Down side
                                Side=4
                            EndIf
                        Else
                            PointVectorX=Floor(Z)-Z
                            CosEdgeVector=PointVectorZ/(Sqr(PointVectorZ^2+PointVectorY^2)*1.0)
                            If CosAngle>CosEdgeVector
                            ;=========================================================================Down side
                                Side=4
                            EndIf
                        EndIf
                    Case Side=0
                        ;=========================================================================Down side
                        Side=4
                End Select
            EndIf
        Else
            If Side=0 Return 0
        EndIf

;Зная точную сторону вычисляем точку пика

        Select Side
            Case 1
                X2=Floor(X)-.001
                Y2=VY*(X2-X)/VX+Y
                Z2=VZ*(Y2-Y)/VY+Z
                VX=VX-(X2-X)
                VY=VY-(Y2-Y)
                VZ=VZ-(Z2-Z)
                X=X2
                Y=Y2
                Z=Z2
            Case 2
                X2=Ceil(X)+.001
                Y2=VY*(X2-X)/VX+Y
                Z2=VZ*(Y2-Y)/VY+Z
                VX=VX-(X2-X)
                VY=VY-(Y2-Y)
                VZ=VZ-(Z2-Z)
                X=X2
                Y=Y2
                Z=Z2
            Case 3
                Y2=Ceil(Y)+.001
                Z2=VZ*(Y2-Y)/VY+Z
                X2=VX*(Z2-Z)/VZ+X
                VX=VX-(X2-X)
                VY=VY-(Y2-Y)
                VZ=VZ-(Z2-Z)
                X=X2
                Y=Y2
                Z=Z2
            Case 4
                Y2=Floor(Y)-.001
                Z2=VZ*(Y2-Y)/VY+Z
                X2=VX*(Z2-Z)/VZ+X
                VX=VX-(X2-X)
                VY=VY-(Y2-Y)
                VZ=VZ-(Z2-Z)
                X=X2
                Y=Y2
                Z=Z2
            Case 5
                Z2=Ceil(Z)+.001
                X2=VX*(Z2-Z)/VZ+X
                Y2=VY*(X2-X)/VX+Y
                VX=VX-(X2-X)
                VY=VY-(Y2-Y)
                VZ=VZ-(Z2-Z)
                X=X2
                Y=Y2
                Z=Z2
            Case 6
                Z2=Floor(Z)-.001
                X2=VX*(Z2-Z)/VZ+X
                Y2=VY*(X2-X)/VX+Y
                VX=VX-(X2-X)
                VY=VY-(Y2-Y)
                VZ=VZ-(Z2-Z)
                X=X2
                Y=Y2
                Z=Z2
            Default
                RuntimeError "Something wrong!!!"
        End Select


            ;Если наткнулись на твердую породу или чтото еще - выходим из функции.
            If World(Floor(X),Floor(Y),Floor(Z))<>0
                PickX=X
                PickY=Y
                PickZ=Z
                PickVx=X-PointX
                PickVy=Y-PointY
                PickVz=Z-PointZ
                Return World(Floor(X),Floor(Y),Floor(Z))
            EndIf

    Forever

End Function
*)

end.
