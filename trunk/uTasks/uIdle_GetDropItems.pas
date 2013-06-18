unit uIdle_GetDropItems;

interface

uses
  ExtCtrls,

  mcTypes,
  uPlugins;

type
  TPasive_GetDropItems = class(TInterfacedObject, ITask)
  private
    fClient:IClient;
    fTime:TTimer;

    fState:string;

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
  mcConsts,
  qStrUtils,
  SysUtils;

const
  cMaxDistance = 8;

{ TLookAtPlayer }

constructor TPasive_GetDropItems.Create(Client:IClient);
begin
  fClient := Client;

  fState := '';
  fLastPos := ToPos(0,0,0);

  fTime := TTimer.Create( nil );
  fTime.Interval := 800;
  fTime.Enabled := false;
  fTime.OnTimer := DoTime;
  fTime.Enabled := true;
end;

destructor TPasive_GetDropItems.Destroy;
begin
  fTime.Free;

  inherited;
end;

function TPasive_GetDropItems.Name: string;
begin
  result := 'idle.GetDropItems';
end;

function TPasive_GetDropItems.GetInfo: string;
begin
  Result := '{'+
    '"name":"idle.GetDropItems",'+
    '"events":["state"]'+
  '}';
end;

function TPasive_GetDropItems.GetState:string;
begin
  if fState = 'idle' then
    Result := 'work'
  else
    Result := '-';
end;

function TPasive_GetDropItems.Help: string;
begin
  result := '';
end;

procedure TPasive_GetDropItems.Event(Name, Data: string);
begin
  if name = 'state' then
    fState := Data;
end;

procedure TPasive_GetDropItems.DoTime(Sender: TObject);
var
  fEnt:IEntity;
  fDist:Extended;
begin
  // Test state
  if fState <> 'idle' then exit;
  
  // Find DropItems
  fEnt := fClient.GetNearEntity( fClient.Pos, etObjectVehicle, cDroppedItem, cMaxDistance, fDist );
  if fEnt <> nil then begin
    fLastPos := fEnt.GetPos;
    fClient.LookAt( fLastPos );
    exit;
  end;

  // Find Expiriens
  fEnt := fClient.GetNearEntity( fClient.Pos, etExperienceOrb, 0, cMaxDistance, fDist );
  if fEnt <> nil then begin
    fLastPos := fEnt.GetPos;
    fClient.LookAt( fLastPos );
    exit;
  end;
end;

end.
