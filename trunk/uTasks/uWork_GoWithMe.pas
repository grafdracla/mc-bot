unit uWork_GoWithMe;

interface

uses
  Classes,
  ExtCtrls,

  mcTypes,
  uPlugins;

type
  TWork_GoWithMe = class(TInterfacedObject, ITask, ITaskEventEntity, ITaskEventChat)
  private
    fClient:IClient;
    fTime:TTimer;

    fLastState:string;
    fState:string;

    fTarget:IEntity;
    fTargetLastPos:TPos;

    procedure DoMove(Sender: TObject);
  public
    constructor Create(Client:IClient);
    destructor Destroy; override;

    function GetInfo:string;

    function Name:string;
    function GetState:string;
    procedure Event(Name, Data:string);

    procedure SpawnEntity(Entity:IEntity);
    procedure DestroyEntity(Entity:IEntity);

    procedure ChatMessage(MType, From, Text:string);
  end;

implementation

uses
  SysUtils,
  StrUtils,

  qStrUtils;

{ TWork_GoWithMe }

constructor TWork_GoWithMe.Create(Client: IClient);
begin
  fClient := Client;

  fState := '';

  fTarget := nil;
  fTargetLastPos := ToPos(0,0,0);

  fTime := TTimer.Create( nil );
  fTime.Interval := 500;
  fTime.Enabled := false;
  fTime.OnTimer := DoMove;
end;

destructor TWork_GoWithMe.Destroy;
begin
  fTime.Free;

  inherited;
end;

function TWork_GoWithMe.Name: string;
begin
  Result := 'work.GoWithMe';
end;

function TWork_GoWithMe.GetInfo: string;
begin
  Result := '{'+
    '"name":"work.GoWithMe",'+
    '"dependence":["cmd.walk"],'+
    '"events":["cmd.walk.end", "cmd.walk.error", "state"]'+
  '}';
end;

function TWork_GoWithMe.GetState: string;
begin
  if fTime.Enabled and (fTarget <> nil) then
    result := fTarget.Title
  else
    result := '-';
end;

procedure TWork_GoWithMe.Event(Name, Data: string);
begin
  if Name = 'state' then
    fState := Data

  else if fTime.Enabled and (
    (Name = 'cmd.walk.end') or
    (Name = 'cmd.walk.error')) then begin

//    fClient.SendEvent('state', fLastState);
//    fLastState := '';
  end;
end;

procedure TWork_GoWithMe.SpawnEntity(Entity: IEntity);
begin
  if fTarget <> nil then exit;
  if Entity.EType <> etPlayer then exit;

  case fClient.GetUserGroup( Entity.Title ) of
    ugAdmin:;
    else
      exit;
  end;

  fTarget := Entity;
end;

procedure TWork_GoWithMe.DestroyEntity(Entity: IEntity);
begin
  if fTarget = nil then exit;
  if Entity.EType <> etPlayer then exit;
  if Entity.Title <> fTarget.Title then Exit;

  fTarget := nil;
end;

procedure TWork_GoWithMe.DoMove(Sender: TObject);
var
  str:string;
  fPos:TPos;
begin
  if fTarget = nil then exit;

  fPos := fTarget.Pos;

  // Test last state
  if ComparePos( fTargetLastPos, fPos ) then Exit;

  // Recalck pos
  if GetDistance( fClient.Pos, fPos ) < 3 then Exit;

  // Do move
  str :=
    '{'+
      '"point":"'+
        FloatToStr( fPos.X )+';'+
        FloatToStr( fPos.Y )+';'+
        FloatToStr( fPos.Z )+
      '",'+
      '"frange":"3"'+
    '}';

  fClient.SendEvent('cmd.walk.set', str);

  fTargetLastPos := fPos;
end;

procedure TWork_GoWithMe.ChatMessage(MType, From, Text: string);
begin
  // Test whispers
  if MType <> 'commands.message.display.incoming' then exit;

  // Test user
  case fClient.GetUserGroup(From) of
    ugAdmin:;
    else
      exit;
  end;

  // Test command
  if Text = 'come with me' then begin
    // Set state
    fLastState := fState;
    fClient.SendEvent('state', 'work.gowithme');

    fTime.Enabled := true;
  end
  else if Text = 'stay here' then begin
    fTarget := nil;
    fTime.Enabled := false;

    fClient.SendEvent('state', fLastState);
    fLastState := '';
  end;
end;

end.
