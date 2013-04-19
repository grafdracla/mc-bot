unit uRender_25D;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.Samples.Spin, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.Menus,

  uRenderUtils, uPlugins;

type
  TRender_25D = class(TFrame, IRender)
    PMapCtrl: TPanel;
    SBMapUpdate: TSpeedButton;
    LMY: TLabel;
    LMX: TLabel;
    LMZ: TLabel;
    SBPosFill: TSpeedButton;
    SEMY: TSpinEdit;
    SEMX: TSpinEdit;
    SEMZ: TSpinEdit;
    SEMBS: TSpinEdit;
    CBUpdate: TCheckBox;
    CMCamCenter: TCheckBox;
    RefreshMap: TTimer;
    PBDraw: TPaintBox;
    pmMap: TPopupMenu;
    MOpen: TMenuItem;
    Right1: TMenuItem;
    Eat1: TMenuItem;
    NPoint: TMenuItem;
    SBDirectionLeft: TSpeedButton;
    SBDirectionRight: TSpeedButton;
    procedure RefreshMapTimer(Sender: TObject);
    procedure CBUpdateClick(Sender: TObject);
    procedure SBPosFillClick(Sender: TObject);
    procedure PBDrawMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PBDrawMouseLeave(Sender: TObject);
    procedure PBDrawMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MOpenClick(Sender: TObject);
    procedure Right1Click(Sender: TObject);
    procedure pmMapPopup(Sender: TObject);
    procedure Eat1Click(Sender: TObject);
    procedure NPointClick(Sender: TObject);
    procedure SBDirectionLeftClick(Sender: TObject);
  private
    fPar:TRenderParams;

    //fClient:IClient;
    fImg:TBitmap;
    fHint: THintWindow;

    fMousePos: TAbsPos;
    fPopPos: TAbsPos;

    // Z + + - -
    // X + - - +
    fDirection:Integer;

    function GetPosFromMouse(X, Y, YLevel:Integer):TPos;

    procedure ShowHint(Ctrl: TControl; X, Y: Integer; str: string);
  public
    constructor Create(AOwner: TWinControl);
    destructor Destroy; override;

    procedure Init( RenderParams:TRenderParams );

    procedure DoUpdate;

    procedure Active(Val: Boolean);
    procedure UpdatePos;
  end;

implementation

uses
  Generics.Collections,

  Math,

  qSysUtils,

  mcConsts,
  mcTypes,
  uIBase;

{$R *.dfm}

const
  cBlockHeight = 0.6;
  cXOffsetDiv = 2;
  cYoffsetDiv = 8;

  cLevelMax = 2;
  cLevelMin = -6;

type
  TMarkerType = (mtEntity, mtPoint);

  TMarker = class
    MType: TMarkerType;
    Color: TColor;
    Yaw: Extended;
  end;

// Brightness
function Brightness(Color: TColor; Value: Integer): TColor;
var
  r, g, b: Byte;
begin
  Color := ColorToRGB(Color);
  r := GetRValue(Color);
  g := GetGValue(Color);
  b := GetBValue(Color);
  if Value < 0 then begin
    Value := abs(Value);
    r := r - muldiv(r, Value, 100); // ïðîöåíò% óìåíüøåíèÿ ÿðêîñòè
    g := g - muldiv(g, Value, 100);
    b := b - muldiv(b, Value, 100);
  end
  else begin
    r := r + muldiv(255 - r, Value, 100); // ïðîöåíò% óâåëè÷åíèÿ ÿðêîñòè
    g := g + muldiv(255 - g, Value, 100);
    b := b + muldiv(255 - b, Value, 100);
  end;
  result := RGB(r, g, b);
end;

constructor TRender_25D.Create(AOwner: TWinControl);
begin
  inherited Create(AOwner);

  Parent := AOwner;
  Align := alClient;

  fDirection := 0;

  fMousePos := AbsPos(0, 0, 0);
  fPopPos := AbsPos(0, 0, 0);

  fHint := THintWindow.Create(nil);

  fImg := TBitmap.Create;
end;

destructor TRender_25D.Destroy;
begin
  fImg.Free;

  fHint.Free;

  inherited;
end;

procedure TRender_25D.Init( RenderParams:TRenderParams );
begin
  fPar := RenderParams;
end;

procedure TRender_25D.Active(Val: Boolean);
begin
  if Val then begin
    RefreshMap.Enabled := CBUpdate.Checked;
    DoUpdate;
  end
  else
    RefreshMap.Enabled := False;
end;

procedure TRender_25D.CBUpdateClick(Sender: TObject);
begin
  Active(True);
end;

procedure TRender_25D.RefreshMapTimer(Sender: TObject);
var
  fPos:TPos;
begin
  if RefreshMap.Tag <> 0 then exit;

  RefreshMap.Tag := 1;
  try
    // Cam center
    if CMCamCenter.Checked then begin
      fPos := fPar.Client.Pos;

      SEMY.Value := Trunc( fPos.Y-2 );
      SEMX.Value := Trunc( fPos.X );
      SEMZ.Value := Trunc( fPos.Z );
    end;

    DoUpdate;
  finally
    RefreshMap.Tag := 0;
  end;
end;

procedure TRender_25D.SBDirectionLeftClick(Sender: TObject);
begin
  if Sender = SBDirectionLeft then
    Inc(fDirection)
  else
    Dec(fDirection);

  if fDirection > 3 then fDirection := 0;
  if fDirection < 0 then fDirection := 3;

  DoUpdate;
end;

procedure TRender_25D.SBPosFillClick(Sender: TObject);
begin
  UpdatePos;
end;

procedure TRender_25D.ShowHint(Ctrl: TControl; X, Y: Integer; str: string);
var
  r: TRect;
begin
  if str = fHint.Caption then
    exit;

  r := fHint.CalcHintRect(400, str, nil);
  r.Offset(Ctrl.ClientToScreen(Point(X + 16, Y + 16)));
  fHint.ActivateHint(r, str);
end;

procedure TRender_25D.UpdatePos;
var
  fPos:TPos;
begin
  fPos := fPar.Client.Pos;

  SEMY.Value := Trunc(fPos.Y);
  SEMX.Value := Trunc(fPos.X);
  SEMZ.Value := Trunc(fPos.Z);
end;

function TRender_25D.GetPosFromMouse(X, Y, YLevel: Integer): TPos;
const
  a = 2;
  b = 1;
var
  fBlockW, fBlocksCnt, fBlockHeight: Integer;
  fXOffset, fYOffset: Integer;
  fXS, fYS, fZS, C: Integer;
  fPX, fPZ:Extended;
begin
  // Calck
  fBlockW := SEMBS.Value;

  fBlocksCnt := Min(fImg.Width, fImg.Height) div fBlockW;

  fBlockHeight := Round(fBlockW * cBlockHeight);

  Y := Y - fBlockHeight;
  X := X - fBlockW;

  fYS := YLevel;

  // Dec blocks vertical offset
  Y := Y - fBlockHeight * (SEMY.Value - fYS);

  fXS := SEMX.Value - (fBlocksCnt div 2);
  fZS := SEMZ.Value - (fBlocksCnt div 2);

  C := fBlockW;

  fXOffset := fImg.Width div cXOffsetDiv;
  fYOffset := -(fImg.Height div cYoffsetDiv);

  fPX := (((X - fXOffset) / a + (Y - fYOffset) / b) / C);
  fPZ := (-((X - fXOffset) / a - (Y - fYOffset) / b) / C);

  case fDirection of
    1:begin
      result.X := fXS + (fBlocksCnt-fPZ);
      result.Z := fZS + fPX;
    end;
    2:begin
      result.X := fXS + (fBlocksCnt-fPX);
      result.Z := fZS + (fBlocksCnt-fPZ);
    end;
    3:begin
      result.X := fXS + fPZ;
      result.Z := fZS + (fBlocksCnt-fPX);
    end;
    else begin
      result.X := fXS + fPX;
      result.Z := fZS + fPZ;
    end;
  end;
  result.Y := fYS;
end;

procedure TRender_25D.PBDrawMouseLeave(Sender: TObject);
begin
  fHint.ReleaseHandle;

  // Focus
  fMousePos := AbsPos(0, 0, 0);
  DoUpdate;
end;

procedure TRender_25D.PBDrawMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  fPos: TPos;
  fBlockPos: TAbsPos;
  fBlockId, I: Integer;
  fBlockMeta: Byte;
  fChunkXZ: TChunkPos;
  fCX, fCZ: Byte;
  str, fBlockHint: string;

  fList:TList<IEntity>;
  fEntity:IEntity;
  fBlockInfo: IBlockInfo;
  fMobInfo: IMobInfo;
  fObjInfo: IObjInfo;
begin
  fPos := fPar.GetCursorPos();

  fPos := GetPosFromMouse(X, Y, Floor(fPos.Y) );

  fBlockPos := PosToAbsPos( fPos );

  if not fPar.Client.GetBlock(fBlockPos, fBlockId, fBlockMeta) then
    fBlockId := -1;

  fChunkXZ := ChunkIdFromCoord(fBlockPos.X, fBlockPos.Z);
  GetPosInChunk(fBlockPos.X, fBlockPos.Z, fCX, fCZ);

  str := 'X, Z: ' + FloatToStr(fPos.X) + ', ' + FloatToStr(fPos.Z) + #13#10 +
    '  Pos: ' + FloatToStr(fBlockPos.X) + ', ' + FloatToStr(fBlockPos.Z) +
    #13#10 + '  Chunk: ' + IntToStr(fChunkXZ.X) + ', ' + IntToStr(fChunkXZ.Z) +
    #13#10 + '  Chunk XZ: ' + IntToStr(fCX) + ', ' + IntToStr(fCZ);


  fBlockHint := '';
  fBlockInfo := BloksInfos.GetInfo(fBlockId);
  if fBlockInfo <> nil then begin
    str := str + #13#10 + 'Block: ' + IntToHex(fBlockId, 2);
    str := str + #13#10 + '  meta: ' + IntToHex(fBlockMeta, 2);
    str := str + #13#10 + '  title: ' + fBlockInfo.Title;
    str := str + #13#10 + '  type: ' + fBlockInfo.TypeName();
    str := str + #13#10 + '  height: ' + FloatToStr( fBlockInfo.Height(fBlockMeta) );

    fBlockHint := fBlockInfo.Hint;
  end
  else
    str := str + #13#10 + 'Block: ' + IntToHex(fBlockId, 2);

  fList := TList<IEntity>.Create;
  try
    fPar.Client.GetNearEntitys( fPos, 1.5, fList );

    for i := 0 to fList.Count-1 do begin
      fEntity := fList.Items[i];

      str := str + #13#10'Entity: ' + fEntity.GetTypeName();

      case fEntity.EType of
        etMob:begin
          fMobInfo := EntityInfos.GetMobInfo(fEntity.SubType);
          if fMobInfo <> nil then begin
            str := str + #13#10 + '  title: ' + fMobInfo.Title();
          end
          else
            str := str + #13#10 + '  id: ' + IntToHex(fEntity.SubType, 2);
        end;
        etObjectVehicle:begin
          fObjInfo := EntityInfos.GetObjInfo(fEntity.SubType);
          if fObjInfo <> nil then begin
            str := str + #13#10 + '  title: ' + fObjInfo.Title();
          end
          else
            str := str + #13#10 + '  id: ' + IntToHex(fEntity.SubType, 2);
        end;
        else
          str := str + #13#10 + '  id: ' + IntToHex(fEntity.SubType, 2);
      end;

    end;

  finally
    fList.Free;
  end;

  if fBlockHint <> '' then
    str := str + #13#10 + '----------'#13#10 + fBlockHint;

  ShowHint(PBDraw, X + 32, Y + 32, str);

  // Focus
  if not CompareAbsPos(fMousePos, fBlockPos) then begin
    fMousePos := fBlockPos;
    DoUpdate;
  end;
end;

procedure TRender_25D.PBDrawMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  fPos, fCur: TPos;
  fCy: Integer;
  fBlockId, i: Integer;
  fBlockInfo: IBlockInfo;
  fBlockMeta: Byte;
begin
  fCur := fPar.GetCursorPos();

  // Find ground
  if ssCtrl in Shift then begin
    fCy := Trunc( fCur.Y );

    for i := cLevelMax downto cLevelMin do begin
      fPos := GetPosFromMouse(X, Y, fCy + i);

      if not fPar.Client.GetBlock( PosToAbsPos( fPos ), fBlockId, fBlockMeta) then
        Continue;

      fBlockInfo := BloksInfos.GetInfo(fBlockId);
      if fBlockInfo = nil then Continue;

      if fBlockInfo.Height(fBlockMeta) <> 0 then begin
        fCur.Y := fCy + i + 1;

        fPar.SetCursorPos( fCur );
        Break;
      end;
    end;
  end;

  fPos := GetPosFromMouse( X, Y, Trunc( fCur.Y ) );

  fPopPos := PosToAbsPos( fPos );

  fPar.SetCursorPos( fPos );

  DoUpdate();
end;

procedure TRender_25D.pmMapPopup(Sender: TObject);
var
  fBlockId: Integer;
  fBlockMeta: Byte;
begin
  if not fPar.Client.GetBlock(fPopPos, fBlockId, fBlockMeta) then exit;

  pmMap.Tag := fBlockId;

  MOpen.Visible := true;
end;

procedure TRender_25D.MOpenClick(Sender: TObject);
var
  str:string;
begin
  str := '{'+
    '"point":"'+
      FloatToStr(fPopPos.X)+';'+
      FloatToStr(fPopPos.Y)+';'+
      FloatToStr(fPopPos.Z)+
    '"'+
  '}';

  fPar.Client.SendEvent('cmd.digg.set', str);
end;

procedure TRender_25D.Right1Click(Sender: TObject);
begin
  fPar.Client.Place(fPopPos, 0, 0, 0, 0);  //@@@
end;

procedure TRender_25D.Eat1Click(Sender: TObject);
begin
  fPar.Client.Place( AbsPos(-1, 255, -1), 255, 0, 0, 0); //@@@
end;

procedure TRender_25D.NPointClick(Sender: TObject);
var
  s:string;
  fPos:TPos;
begin
  s := '';
  if not InputQuery('Points', 'Name', s) then exit;

  fPos := fPar.GetCursorPos( );

  fPar.Client.SetParam('points', s,
    FloatToStr(fPos.X)+';'+
    FloatToStr(fPos.Y)+';'+
    FloatToStr(fPos.Z)
  );
end;

procedure TRender_25D.DoUpdate;
var
  fCanv: TCanvas;
  fBlockW, fBlockW2, fBlockW4, fBlockW8: Integer;
  fBlocksCnt: Integer;
  fEntyR: Integer;
  fXOffset, fYOffset: Integer;
  fXS, fYS, fZS: Integer;

  procedure Rotate(var Point: TPoint; Center: TPoint; CosAng, SinAng: Extended);
  var
    DX, DY: Integer;
  begin
    DX := Point.X - Center.X;
    DY := Point.Y - Center.Y;

    Point.X := Center.X + Round(DX * SinAng + DY * CosAng);
    Point.Y := Center.Y + Round(DX * CosAng - DY * SinAng);
  end;

  procedure SinCos(AngleRad: Extended; var ASin, ACos: Extended);
  begin
    ASin := Sin(AngleRad);
    ACos := Cos(AngleRad);
  end;

  procedure DrawMarker(X, Y: Integer; Yaw: Extended; Color: TColor);
  var
    i: Integer;
    fPoints: array [0 .. 3] of TPoint;
    SinAng, CosAng, fAddons: Extended;
  begin
    fPoints[0].X := X;
    fPoints[0].Y := Y - fEntyR;

    fPoints[1].X := X - (fEntyR div 2);
    fPoints[1].Y := Y + fEntyR;

    fPoints[2].X := X;
    fPoints[2].Y := Y + (fEntyR div 2);

    fPoints[3].X := X + (fEntyR div 2);
    fPoints[3].Y := Y + fEntyR;

    case fDirection of
      1: fAddons := 90;
      2: fAddons := 180;
      3: fAddons := 270;
      else
        fAddons := 0;
    end;

    SinCos((360 - Yaw + 45 + fAddons) * (Pi / 180), SinAng, CosAng);

    for i := 0 to Length(fPoints) - 1 do
      Rotate(fPoints[i], Point(X, Y), CosAng, SinAng);

    fCanv.Brush.Color := Color;
    fCanv.Pen.Color := Color;

    fCanv.Polygon(fPoints);
    // fCanv.Ellipse( fXP-fEntyR, fZP-fEntyR, fXP+fEntyR, fZP+fEntyR );
  end;

  procedure DrawPoint(X,Y:Integer);
  begin
    fCanv.Ellipse(X - 2, Y - 2, X + 2, Y + 2);
  end;

  procedure DrawBlock(X, Y, Z, BlockHeight,
     BlockId: Integer; Meta: Byte; BlockInfo: IBlockInfo;
     Select: Boolean; Markers: TList<TMarker>);
  var
    fX, fY, i, fBlkHeight: Integer;
    fPoints: array [0 .. 4] of TPoint;
    fT1, fT2, fT3, fT4,
    fP1, fP2, fP3, fP4,
    fB1, fB2, fB3, fB4: TPoint;
    fMarker: TMarker;
    BCOlor: TColor;
//    fP: TPoint;
  begin
    fX := fXOffset + (X - Z) * fBlockW;
    fY := fYOffset + (X + Z) * fBlockW2;
    fY := fY - Y * BlockHeight;

    // Color to Y
    if BlockInfo = nil then begin
      BCOlor := clBlack;
      fBlkHeight := BlockHeight;
    end
    else begin
      BCOlor := Brightness(BlockInfo.Color, Y * 10);
      fBlkHeight := Round( BlockHeight*BlockInfo.Height(Meta) );
    end;

    //      @2
    // @1        @4
    //      @3

    //      #2
    // #1        #4
    //      #3

    // Top
    fT1 := Point(fX               , fY + fBlockW2 );
    fT2 := Point(fX + fBlockW     , fY            );
    fT3 := Point(fX + fBlockW     , fY + fBlockW  );
    fT4 := Point(fX + fBlockW * 2 , fY + fBlockW2 );

    // Bottom
    fB1 := Point( fT1.X, fT1.Y + BlockHeight);
    fB2 := Point( fT2.X, fT2.Y + BlockHeight);
    fB3 := Point( fT3.X, fT3.Y + BlockHeight);
    fB4 := Point( fT4.X, fT4.Y + BlockHeight);

    // Level
    fP1 := Point( fB1.X, fB1.Y - fBlkHeight);
    fP2 := Point( fB2.X, fB2.Y - fBlkHeight);
    fP3 := Point( fB3.X, fB3.Y - fBlkHeight);
    fP4 := Point( fB4.X, fB4.Y - fBlkHeight);

    // Back select
    if Select then begin
      fCanv.Pen.Color := clRed;

      fCanv.MoveTo(fT2.X, fT2.Y);
      fCanv.LineTo(fB2.X, fB2.Y);
      fCanv.LineTo(fB1.X, fB1.Y);

      fCanv.MoveTo(fB2.X, fB2.Y);
      fCanv.LineTo(fB4.X, fB4.Y);
    end;

    fCanv.Pen.Color := clBlack;

    if BlockInfo <> nil then
      case BlockInfo.BlockType of
        btBlock, btFluid, btItem:
          case BlockID of
            btNone:;
            btAir:;

            btTorch, btRedstoneTorch_Off, btRedstoneTorch_On,
            btVines,
            btLever,
            btStoneButton, btWoodenButton,
            btWallMounted:
              begin
                fCanv.Brush.Color := BlockInfo.Color;

                case Meta and $07 of
                  // West
                  1:case fDirection of
                      0: DrawPoint( fP1.X+fBlockW2, fP2.Y+fBlockW8 );
                      //1:;
                      //2:;
                      3: DrawPoint( fP2.X+fBlockW2, fP2.Y+fBlockW8 );
                    end;
                  // East
                  2:case fDirection of
                      //0:;
                      1: DrawPoint( fP2.X+fBlockW2, fP2.Y+fBlockW8 );
                      2: DrawPoint( fP1.X+fBlockW2, fP2.Y+fBlockW8 );
                      //3:;
                    end;
                  // South
                  3:case fDirection of
                      0: DrawPoint( fP2.X+fBlockW2, fP2.Y+fBlockW8 );
                      1: DrawPoint( fP1.X+fBlockW2, fP2.Y+fBlockW8 );
                      //2:;
                      //3:;
                    end;
                  // North
                  4:case fDirection of
                      //0:;
                      //1:;
                      2: DrawPoint( fP2.X+fBlockW2, fP2.Y+fBlockW8 );
                      3: DrawPoint( fP1.X+fBlockW2, fP2.Y+fBlockW8 );
                    end;
                  // Floor, Graund
                  5, 6:
                    DrawPoint( fB2.X, fB1.Y );
                end;
              end;

{            btLadders:begin
               //!
             end;

             btWoodenStairs, btCobblestoneStairs, btBrickStairs, btStoneBrickStairs,
             btNetherBrickStairs, btSandstoneStairs:begin
               //!
             end;
}

{            // Inc
             btLadders: begin
                fCanv.Brush.Color := BlockInfo.Color;

                if Meta and bpincNorth <> 0 then begin
                  fP.X := fP1.X + fBlockW2;
                  fP.Y := fP2.Y + BlockHeight;

                  fCanv.Ellipse(fP.X - 2, fP.Y - 2, fP.X + 2, fP.Y + 2);
                end;

                if Meta and bpincWest <> 0 then begin
                  fP.X := fP2.X + fBlockW2;
                  fP.Y := fP2.Y + BlockHeight;

                  fCanv.Ellipse(fP.X - 2, fP.Y - 2, fP.X + 2, fP.Y + 2);
                end;
              end;}

{            // On
            btWoodenDoor, btIronDoor:
              begin
                fP.X := fB2.X;
                fP.Y := fB1.Y;

                fCanv.Brush.Color := BlockInfo.Color;
                fCanv.Ellipse(fP.X - 2, fP.Y - 2, fP.X + 2, fP.Y + 2);
              end;}

            else begin
              // Top
              fCanv.Brush.Color := BCOlor;

              fPoints[0] := fP1;
              fPoints[1] := fP2;
              fPoints[2] := fP4;
              fPoints[3] := fP3;
              fPoints[4] := fP1;

              fCanv.Polygon(fPoints);

              // Left bottom
              fCanv.Brush.Color := Brightness(BCOlor, -55);

              fPoints[0] := fP1;
              fPoints[1] := fP3;
              fPoints[2] := fB3;
              fPoints[3] := fB1;
              fPoints[4] := fP1;

              fCanv.Polygon(fPoints);

              // Right bottom
              fCanv.Brush.Color := Brightness(BCOlor, -30);

              fPoints[0] := fP4;
              fPoints[1] := fB4;
              fPoints[2] := fB3;
              fPoints[3] := fP3;
              fPoints[4] := fP4;

              fCanv.Polygon(fPoints);

      {       fP.X := fB2.X;
              fP.Y := fB1.Y;

              fCanv.Brush.Color := clWhite;
              fCanv.Ellipse(fP.X - 2, fP.Y - 2, fP.X + 2, fP.Y + 2);}
            end;
          end;
      end;

    // Dram markers
    if Markers <> nil then
      for i := 0 to Markers.Count - 1 do begin
        fMarker := Markers.Items[i];

        case fMarker.MType of
          mtEntity:
            DrawMarker(fP1.X + fBlockW, fP1.Y + BlockHeight, fMarker.Yaw, fMarker.Color);

          mtPoint:
            begin
              fCanv.Brush.Color := fMarker.Color;
              fCanv.Ellipse(fB2.X - 2, fB1.Y - 2, fB2.X + 2, fB1.Y + 2);
            end;
        end;
      end;

    // Front select
    if Select then begin
      fCanv.Pen.Color := clRed;

      fCanv.MoveTo(fT1.X, fT1.Y);
      fCanv.LineTo(fT2.X, fT2.Y);
      fCanv.LineTo(fT4.X, fT4.Y);
      fCanv.LineTo(fB4.X, fB4.Y);
      fCanv.LineTo(fB3.X, fB3.Y);
      fCanv.LineTo(fB1.X, fB1.Y);
      fCanv.LineTo(fT1.X, fT1.Y);

      fCanv.LineTo(fT3.X, fT3.Y);
      fCanv.LineTo(fT4.X, fT4.Y);

      fCanv.MoveTo(fT3.X, fT3.Y);
      fCanv.LineTo(fB3.X, fB3.Y);

      fCanv.Pen.Color := clBlack;
    end;
  end;

var
  fMarkers: TObjectDictionary<TAbsPos, TObjectList<TMarker>>;

  procedure AddMarker(Pos: TAbsPos; MType: TMarkerType; Yaw: Extended;
    Color: TColor);
  var
    fPointList: TObjectList<TMarker>;
    fMarker: TMarker;
  begin
    try
      if not fMarkers.TryGetValue(Pos, fPointList) then
      begin
        fPointList := TObjectList<TMarker>.Create;
        fMarkers.Add(Pos, fPointList);
      end;

      fMarker := TMarker.Create;
      fMarker.MType := MType;
      fMarker.Color := Color;
      fMarker.Yaw := Yaw;

      fPointList.Add(fMarker);
    except
      messagebeep(0);
    end;
  end;

  procedure SideOfWord();
  const
    cN1W = 30;
    cN1H = 40;
    cN2 = 15;
  var
    s:string;
    fH, fW:Integer;
  begin
    fCanv.Brush.Style := bsClear;

    fH := fCanv.TextHeight('|');
    fW := fCanv.TextWidth('_');

    // Lines
    fCanv.MoveTo( fImg.Width-cN1W+fW, fImg.Height-cN1H+fH );
    fCanv.LineTo( fImg.Width-cN2,     fImg.Height-cN2 );

    fCanv.MoveTo( fImg.Width-cN1W+fW, fImg.Height-cN2 );
    fCanv.LineTo( fImg.Width-cN2,     fImg.Height-cN1H+fH );

    // Left Top
    case fDirection of
      1: s := 'W';
      2: s := 'N';
      3: s := 'E';
      else
        s := 'S';
    end;
    fCanv.TextOut( fImg.Width-cN1W, fImg.Height-cN1H, s );

    // Right Top
    case fDirection of
      1: s := 'N';
      2: s := 'E';
      3: s := 'S';
      else
        s := 'W';
    end;
    fCanv.TextOut( fImg.Width-cN2, fImg.Height-cN1H, s );

    // Left bottom
    case fDirection of
      1: s := 'S';
      2: s := 'W';
      3: s := 'N';
      else
        s := 'E';
    end;
    fCanv.TextOut( fImg.Width-cN1W, fImg.Height-cN2, s );

    // Right bottom
    case fDirection of
      1: s := 'E';
      2: s := 'S';
      3: s := 'W';
      else
        s := 'N';
    end;
    fCanv.TextOut( fImg.Width-cN2, fImg.Height-cN2, s );
  end;

var
  fX, fZ, fY {, fXP, fYP, fZP}: Integer;
  fBlockId, i, {j,} fBlockHeight: Integer;
  fCenterPos:TPos;
  fPos, fFocusPos: TAbsPos;

  fBlockMeta: Byte;
  fBlockInfo: IBlockInfo;
  fFocus: Boolean;

  fPointList: TObjectList<TMarker>;
  fEntitysList: TList<IEntity>;
  fEntity:IEntity;

  fColor {, fUColor}: TColor;
  MType: TMarkerType;
  fMobInfo:IMobInfo;
begin
  if not IsNum(SEMY.Text, fX) then exit;
  if not IsNum(SEMX.Text, fX) then exit;
  if not IsNum(SEMZ.Text, fX) then exit;
  if not IsNum(SEMBS.Text, fX) then exit;

  fImg.Width := PBDraw.Width;
  fImg.Height := PBDraw.Height;

  fCanv := fImg.Canvas;

  // Flll
  fCanv.Brush.Style := bsSolid;
  fCanv.Brush.Color := clWhite;
  fCanv.FillRect(Rect(0, 0, fImg.Width, fImg.Height));

  // Calck
  fBlockW := SEMBS.Value;
  fBlockW2 := SEMBS.Value div 2;
  fBlockW4 := SEMBS.Value div 4;
  fBlockW8 := SEMBS.Value div 8;

  fBlocksCnt := Min(fImg.Width, fImg.Height) div fBlockW;

  fBlockHeight := Round(fBlockW * cBlockHeight);
  fEntyR := fBlockHeight;

  fXOffset := fImg.Width div cXOffsetDiv;
  fYOffset := -(fImg.Height div cYoffsetDiv);

  fCenterPos.X := StrToFloat( SEMX.Text );
  fCenterPos.Y := StrToFloat( SEMY.Text );
  fCenterPos.Z := StrToFloat( SEMZ.Text );

  fXS := Floor( fCenterPos.X ) - (fBlocksCnt div 2);
  fYS := Floor( fCenterPos.Y );
  fZS := Floor( fCenterPos.Z ) - (fBlocksCnt div 2);

  fFocusPos := PosToAbsPos( ToPos( SEMX.Value, SEMY.Value, SEMZ.Value) );
  fMarkers := TObjectDictionary < TAbsPos, TObjectList < TMarker >>.Create;
  try
    fEntitysList := TList<IEntity>.Create;
    try
      fPar.Client.GetNearEntitys( fCenterPos, fBlockW*2, fEntitysList );

      // Entitys
      for i := 0 to fEntitysList.Count-1 do begin
        fEntity := fEntitysList.Items[i];

        fColor := clRed;
        MType := mtEntity;

        case fEntity.EType of
          etUnknown:
            fColor := clWhite;

          etObjectVehicle:
            fColor := clBlue;

          etMob:begin
            fMobInfo := EntityInfos.GetMobInfo( fEntity.SubType );

            if (fMobInfo <> nil) and (fMobInfo.MType in [etHostile]) then
              fColor := clRed
            else
              fColor := clGreen;
          end;

          etPlayer:
            fColor := clFuchsia;

          etPainting:
            begin
              fCanv.Brush.Color := clYellow;
              MType := mtPoint;
            end;

  {        etDroppedItem:
            begin
              fCanv.Brush.Color := clNavy;
              MType := mtPoint;
            end;}

          etExperienceOrb:
            begin
              fCanv.Brush.Color := clNavy;
              MType := mtPoint;
            end;
        end;

        // Make marker
        AddMarker(
          PosToAbsPos( fEntity.GetPos ), MType, fEntity.Yaw, fColor);
      end;

    finally
      fEntitysList.Free;
    end;

(*
    // Path
    if fPath <> nil then
      for i := 0 to fPath.Count - 1 do
        AddMarker(fPath.Items[i], mtPoint, 0, clBlack);
*)

    // Player
    AddMarker( PosToAbsPos( fPar.Client.Pos ), mtEntity, fPar.Client.Yaw, clBlack );

    // Bloks
    for fY := cLevelMin to cLevelMax do begin
      for fZ := 0 to fBlocksCnt-1 do begin
        for fX := 0 to fBlocksCnt - 1 do begin

          // Point - direction
          case fDirection of
            1: fPos := AbsPos(fXS+(fBlocksCnt-fZ), fYS+fY, fZS            +fX ); // X- Z+
            2: fPos := AbsPos(fXS+(fBlocksCnt-fX), fYS+fY, fZS+(fBlocksCnt-fZ)); // Z- X-
            3: fPos := AbsPos(fXS+fZ             , fYS+fY, fZS+(fBlocksCnt-fX)); // X+ Z-
            else
               fPos := AbsPos(fXS+fX             , fYS+fY, fZS            +fZ ); // Z+ X+
          end;

          // Get block data
          if not fPar.Client.GetBlock(fPos, fBlockId, fBlockMeta) then
            fBlockId := -1;

          fBlockInfo := BloksInfos.GetInfo(fBlockId);

          fFocus := CompareAbsPos(fPos, fFocusPos) or
            CompareAbsPos(fPos, fMousePos);

          if not fMarkers.TryGetValue(fPos, fPointList) then
            fPointList := nil;

          DrawBlock(fX, fY, fZ, fBlockHeight,
            fBlockId, fBlockMeta, fBlockInfo,
            fFocus, fPointList);
        end;
      end;
    end;

    // Direction
    SideOfWord();

    PBDraw.Canvas.Draw(0, 0, fImg);

  finally
    fMarkers.Free;
  end;
end;

end.
