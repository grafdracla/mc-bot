unit uIdle_Gravitation;

interface

uses
  ExtCtrls,

  uPlugins;

type
  TIdle_Gravitation = class(TInterfacedObject, ITask)
  private
    fClient:IClient;
    fTime:TTimer;

    fState:string;

    procedure DoTime(Sender: TObject);
  public
    constructor Create(Client:IClient);
    destructor Destroy; override;

    function GetInfo:string;

    function Name:string;
    function GetState:string;

    procedure Event(Name, Data:string);
  end;

implementation

uses
  qStrUtils,
  mcConsts;

{ TIdle_Gravitation }

constructor TIdle_Gravitation.Create(Client: IClient);
begin
  fClient := Client;

  fState := '';

  fTime := TTimer.Create(nil);
  fTime.Interval := 200;
  fTime.OnTimer := DoTime;
  fTime.Enabled := True;
end;

destructor TIdle_Gravitation.Destroy;
begin
  fTime.Free;

  inherited;
end;

function TIdle_Gravitation.Name: string;
begin
  result := 'idle.gravitation';
end;

function TIdle_Gravitation.GetInfo: string;
begin
  Result := '{'+
    '"name":"idle.gravitation",'+
    '"events":["state"]'+
  '}';
end;

function TIdle_Gravitation.GetState: string;
begin
  if fState = 'idle' then
    Result := 'work'
  else
    Result := '-';
end;

procedure TIdle_Gravitation.Event(Name, Data: string);
begin
  if name = 'state' then
    fState := data;
end;

procedure TIdle_Gravitation.DoTime(Sender: TObject);
var
  fPos:TPos;
  fAbsPos:TAbsPos;
  fBlockId:Integer;
  fMeta:Byte;
begin
  // Test state
  if fState <> 'idle' then exit;

  fPos := fClient.Pos;

  fAbsPos := PosToAbsPos( fPos );

  fAbsPos.Y := fAbsPos.Y - 1;
  if fAbsPos.Y < 0 then exit;

  if not fClient.GetBlock( fAbsPos, fBlockId, fMeta ) then exit;
  if fBlockId <> btAir then exit;

  if fPos.Y = Trunc(fPos.Y) then
    fPos.Y := fPos.Y - 1
  else
    fPos.Y := Trunc(fPos.Y);

  fClient.PlayerPosition( fPos.X, fPos.Y, fPos.Z, fPos.Y+cStance, false );
end;

end.
