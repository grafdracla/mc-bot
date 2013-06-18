unit uIdle_LookAtPlayers;

interface

uses
  ExtCtrls,

  mcTypes,
  uPlugins;

type
  TIdle_LookAtPlayer = class(TInterfacedObject, ITask)
  private
    fClient:IClient;
    fTime:TTimer;

    fState:string;

    fLastPlayer:string;
    fLastPos:TPos;

    procedure DoTime(Sender: TObject);
  public
    constructor Create(Client:IClient);
    destructor Destroy; override;

    function GetInfo:string;

    function Name:string;
    function GetState:string;

    function Help:string;

    procedure Event(Name, Data:string);
  end;

implementation

uses
  qStrUtils;

const
  cMaxDistance = 8;

{ TIdle_LookAtPlayer }

constructor TIdle_LookAtPlayer.Create(Client:IClient);
begin
  fClient := Client;

  fState := '';

  fLastPos := ToPos(0,0,0);
  fLastPlayer := '';

  fTime := TTimer.Create( nil );
  fTime.Interval := 200;
  fTime.Enabled := false;
  fTime.OnTimer := DoTime;
  fTime.Enabled := true;
end;

destructor TIdle_LookAtPlayer.Destroy;
begin
  fTime.Free;

  inherited;
end;

function TIdle_LookAtPlayer.Name: string;
begin
  result := 'idle.LookAtPlayers';
end;

function TIdle_LookAtPlayer.GetInfo: string;
begin
  Result := '{'+
    '"name":"idle.LookAtPlayers",'+
    '"events":["state"]'+
  '}';
end;

function TIdle_LookAtPlayer.GetState:string;
begin
  if fState = 'idle' then
    Result := 'work'
  else
    Result := '-';
end;

function TIdle_LookAtPlayer.Help: string;
begin
  result := '';
end;

procedure TIdle_LookAtPlayer.Event(Name, Data: string);
begin
  if name = 'state' then
    fState := data;
end;

procedure TIdle_LookAtPlayer.DoTime(Sender: TObject);
var
  fEnt:IEntity;
  fDist:Extended;
  fPos:TPos;
begin
  // Test state
  if fState <> 'idle' then exit;

  // Find player
  fEnt := fClient.GetNearEntity( fClient.Pos, etPlayer, 0, cMaxDistance, fDist );
  if fEnt = nil then begin
    fLastPlayer := '';
    exit;
  end;

  fPos := fEnt.GetPos;
  if ComparePos( fLastPos, fPos ) then exit;

  fClient.LookAt( fPos );

  fLastPos := fPos;
  fLastPlayer := fEnt.Title;
end;

end.
