unit uCmd_Walk;

interface

//{$DEFINE ADEBUG}

uses
  ExtCtrls,

  mcTypes,
  uPlugins;

type
  TCmd_Walk = class(TInterfacedObject, ITask)
  private
    fClient:IClient;
    fTime:TTimer;
    fWork:boolean;

    fInfo:string;

    fDoorNideClose:Integer;
    fDoorPos:TAbsPos;

    fPath: TPath;

    procedure DoMove(Sender:TObject);

    procedure TestBlock(Pos: TAbsPos; var Fly: Boolean; var Passability: Extended);
  public
    constructor Create(Client:IClient);
    destructor Destroy; override;

    function GetInfo:string;

    function Name:string;
    function GetState:string;

    function Help:string;

    procedure Event(Name, Data:string);

    property Path:TPath read fPath;
  end;

implementation

uses
  Windows,
  SysUtils,
  Math,
  DBXJSON,

  qSysUtils,
  qStrUtils,

  aTestBlock,
  aA,

  mcConsts,
  uEntity;

{ TLookAtPlayer }

constructor TCmd_Walk.Create(Client:IClient);
begin
  fClient := Client;

  fInfo := '';

  fPath := TPath.Create;
  fWork := true; //false;

  fDoorNideClose := 0;

  fTime := TTimer.Create(nil);
  fTime.Interval := cWalkPointInterval;
  fTime.Enabled := true;
  fTime.OnTimer := DoMove;
end;

destructor TCmd_Walk.Destroy;
begin
  fTime.Free;
  fPath.Free;

  inherited;
end;

function TCmd_Walk.Name: string;
begin
  result := 'cmd.walk';
end;

function TCmd_Walk.GetInfo: string;
begin
  Result := '{'+
    '"name":"cmd.walk",'+
    '"events":["cmd.walk.set","cmd.walk.work","cmd.walk.abort"]'+
  '}';
end;

function TCmd_Walk.GetState:string;
begin
  if fWork then
    result := fInfo
  else
    result := '-';
end;

function TCmd_Walk.Help: string;
begin
  result := '';
end;

procedure TCmd_Walk.Event(Name, Data: string);
var
  fJSON:TJSONObject;
  fX,fY,fZ:Extended;
  fFRange, fMaxPath:Integer;
  fNearest:boolean;
  val:string;
begin
  // Set destanation
  if Name = 'cmd.walk.set' then begin

    fJSON := TJSONObject.ParseJSONValue(Data) as TJSONObject;
    try
      fX := 0;
      fY := 0;
      fZ := 0;
      fFRange := 0;
      fNearest := false;

      // Point
      if fJSON.Get('place') <> nil then begin
        val := fClient.GetParam('points', fJSON.Get('place').JsonValue.Value);

        if val = '' then begin
          fClient.SendEvent('cmd.walk.error','Place not found');

          {$IFDEF ADEBUG}
            fClient.AddLog('% Place not found');
          {$ENDIF}

          exit;
        end;

        fX := StrToFloat( ExtractWord(1, val, [';']) );
        fY := StrToFloat( ExtractWord(2, val, [';']) );
        fZ := StrToFloat( ExtractWord(3, val, [';']) );
      end;

      // Coord
      if fJSON.Get('point') <> nil then begin
        val := fJSON.Get('point').JsonValue.Value;

        fX := StrToFloat( ExtractWord(1, val, [';']) );
        fY := StrToFloat( ExtractWord(2, val, [';']) );
        fZ := StrToFloat( ExtractWord(3, val, [';']) );
      end;

      // Range
      if fJSON.Get('frange') <> nil then
        fFRange := (fJSON.Get('frange').JsonValue as TJSONNumber).AsInt;

      // Type
      if fJSON.Get('type') <> nil then
        fNearest := fJSON.Get('type').JsonValue.Value = 'nearest';

    finally
      fJSON.Free;
    end;

    fInfo := 'Calck path';

    fMaxPath := Floor( GetDistance( fClient.Pos, ToPos(fX, fY, fZ)) )*3*14;// 200 * 10;

    if not AFind(
      PosToAbsPos( fClient.Pos ),
      PosToAbsPos( ToPos(fX, fY, fZ) ), TestBlock, fPath, fMaxPath, fFRange, fNearest) then begin
      fClient.SendEvent('cmd.walk.error','Can''t move: path not found');
{$IFDEF ADEBUG}
      fClient.AddLog('% Can''t move: path not found');
{$ENDIF}
      exit;
    end;

    fInfo := '';

    if fPath.Count = 0 then
      fClient.SendEvent('cmd.walk.end', '');
  end
  //Set work
  else if Name = 'cmd.walk.work' then begin
    fWork := Data = 'on';
  end
  // Abort
  else if Name = 'cmd.walk.abort' then begin
    fInfo := '';
    fPath.Clear;
  end;
end;

procedure TCmd_Walk.TestBlock(Pos: TAbsPos; var Fly: Boolean; var Passability: Extended);
begin
  DefTestBlock( fClient, Pos, nil, Fly, Passability );
end;

procedure TCmd_Walk.DoMove(Sender: TObject);
var
  fPoint: TAbsPos;
  fBlockId: Integer;
  fBlockMeta: Byte;
  fXDiv, fYDiv, fZDiv, fYaw, fPitch: Extended;
  fBlockInfo0, fBlockInfoG: IBlockInfo;
begin
  if not fWork then Exit;
  if fPath.Count = 0 then exit;

  // Get stand point
  fPoint := fPath.First;

  // Test position
  if GetDistance( PosToAbsPos(fClient.Pos), fPoint) > 1 then begin
    fClient.SendEvent('cmd.walk.error','Invalid position');
    {$IFDEF ADEBUG}
      fClient.AddLog('%Invalid position');
    {$ENDIF}
    fPath.Clear;
    fInfo := '';
    exit;
  end;

  // Delete
  fPath.Delete(0);
  fInfo := 'Points :'+IntToStr(fPath.Count);

  // Check error
  if fPath.Count = 0 then begin
    fClient.SendEvent('cmd.walk.end', '');
    fInfo := '';
    exit;
  end;

  // Get next
  fPoint := fPath.First;

  // Get block data
  if not fClient.GetBlock(fPoint, fBlockId, fBlockMeta) then begin
    fClient.SendEvent('cmd.walk.error','Can''t move: invalid block');
    {$IFDEF ADEBUG}
      fClient.AddLog('@ Can''t move: invalid block');
    {$ENDIF}
    fPath.Clear;
    fInfo := '';
    exit;
  end;

  // Block info
  fBlockInfo0 := fClient.GetBlockInfo(fBlockId);
  if fBlockInfo0 = nil then begin
    fClient.SendEvent('cmd.walk.error','Can''t move: unknown block');
    {$IFDEF ADEBUG}
      fClient.AddLog('@ Can''t move: unknown block');
    {$ENDIF}
    fPath.Clear;
    fInfo := '';
    exit;
  end;

  // Test can move @@@
  if fBlockInfo0.Height(fBlockMeta) = 1 then begin
    fClient.SendEvent('cmd.walk.error','Can''t move: has block');
    {$IFDEF ADEBUG}
      fClient.AddLog('@ Can''t move: has block');
    {$ENDIF}
    fPath.Clear;
    fInfo := '';
    Exit;
  end;

  // Test block meta
  case fBlockId of
    btWoodenDoor:
      // Door close
      if fBlockMeta and $04 = 0 then begin
        fDoorNideClose := 2;
        fDoorPos := fPoint;

        fClient.Place( fPoint, 0, 0, 0, 0 );

        { TODO : Wait block change }
        Sleep(200); //@@@
      end;

    btIronDoor:
      // Door close
      if fBlockMeta and $04 = 0 then begin
        fClient.SendEvent('cmd.walk.error','Can''t move: close door');
        {$IFDEF ADEBUG}
          fClient.AddLog('@ Can''t move: close door');
        {$ENDIF}
        fPath.Clear;
        fInfo := '';
        exit;
      end;

    else begin
      // Door nide close
      if fDoorNideClose > 0 then begin
        if fDoorNideClose = 1 then
          fClient.Place( fDoorPos, 0, 0, 0, 0 );

        Dec(fDoorNideClose);
      end;
    end;
  end;

  // Test top
  // @@@

  // Test top + Height
  // @@@

  // Test ground
  if not fClient.GetBlock( AbsPos(fPoint.X, fPoint.Y - 1, fPoint.Z),  fBlockId, fBlockMeta) then begin
    fClient.SendEvent('cmd.walk.error','Can''t move: invalid block');
    {$IFDEF ADEBUG}
      fClient.AddLog('@ Can''t move: invalid block');
    {$ENDIF}
    fPath.Clear;
    fInfo := '';
    exit;
  end;

  fBlockInfoG := fClient.GetBlockInfo(fBlockId);
  if fBlockInfoG = nil then begin
    fClient.SendEvent('cmd.walk.error','Can''t move: unknown block');
    {$IFDEF ADEBUG}
      fClient.AddLog('@ Can''t move: unknown block');
    {$ENDIF}
    fPath.Clear;
    fInfo := '';
    exit;
  end;

  // Goto
  fXDiv := 0.5;
  fYDiv := fBlockInfo0.Height(fBlockMeta); //@@@
  fZDiv := 0.5;

  {$IFDEF ADEBUG}
    fClient.AddLog(
      '&  X:' + FloatToStr(fPoint.X + fXDiv) +
      #9+'Y:' + FloatToStr(fPoint.Y + fYDiv) +
      #9+'Z:' + FloatToStr(fPoint.Z + fZDiv)
    );
  {$ENDIF}

  // calck Yaw
  fYaw := fClient.CalckYaw(fPoint.X + fXDiv, fPoint.Z + fZDiv);
  fPitch := fClient.CalckPith( fPoint.X + fXDiv, fPoint.Y + fYDiv, fPoint.Y + fYDiv );

  // Move player
  fClient.PlayerPositionLook(
    fPoint.X + fXDiv,
    fPoint.Y + fYDiv,
    fPoint.Z + fZDiv,
    fPoint.Y + fYDiv + cStance,
    fyaw,
    fPitch,
    false);

  // End
  if fPath.Count = 1 then begin
    fClient.SendEvent('cmd.walk.end','');
    fPath.Delete(0);
    fInfo := '';
  end;
end;

end.
