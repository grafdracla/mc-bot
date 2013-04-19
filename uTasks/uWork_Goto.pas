unit uWork_Goto;

interface

uses
  Classes,
  uPlugins;

type
  TWork_Goto = class(TInterfacedObject, ITask, ITaskEventChat)
    fClient:IClient;

    fWork:Boolean;

    fState:string;
    fLastState:string;
  public
    constructor Create(Client:IClient);

    function GetInfo:string;

    function Name:string;
    function GetState:string;

    procedure Event(Name, Data:string);

    procedure ChatMessage(msg:string);
  end;

implementation

uses
  SysUtils,
  StrUtils,

  qStrUtils;

{ TWork_Goto }

constructor TWork_Goto.Create(Client: IClient);
begin
  fClient := Client;

  fState := '';
  fLastState := '';

  fWork := false;
end;

function TWork_Goto.Name: string;
begin
  Result := 'work.goto';
end;

function TWork_Goto.GetInfo: string;
begin
  Result := '{'+
     '"name":"work.goto",'+
     '"dependence":["cmd.walk"],'+
     '"events":["cmd.walk.end", "cmd.walk.error", "cmd.walk.abort", "state"]'+
  '}';
end;

function TWork_Goto.GetState: string;
begin
  if fWork then
    Result := 'Work'
  else
    Result := '-';
end;

procedure TWork_Goto.Event(Name, Data: string);
begin
  if Name = 'state' then
    fState := Data

  else if fWork and (
    (Name = 'cmd.walk.end') or
    (Name = 'cmd.walk.error') ) then begin

    fClient.SendEvent('state', fLastState);
    fLastState := '';
    fWork := false;
  end;
end;

procedure TWork_Goto.ChatMessage(msg: string);
var
  fUser:string;
  fCmd:string;
  fPlayer:IPlayer;
  fTarget:IEntity;

  str:string;
  fPos:TPos;
begin
  // Test whispers
  if trim( lowercase( ExtractWord(2, msg, [' ']) ) ) <> 'whispers' then exit;

  // Test user
  fUser := ExtractWord(1, msg, [' ']);
  case fClient.GetUserGroup(fUser) of
    ugAdmin:;
    else
      exit;
  end;

  // Patch 1.5
  if ExtractWord(3, msg, [' ']) = 'to' then
    msg := trim( lowercase( Copy(msg, WordPosition(2, msg, [':']), Length(msg)) ) )

  else
    msg := trim( lowercase( Copy(msg, WordPosition(3, msg, [' ']), Length(msg)) ) );

  // Test command
  if lowercase( ExtractWord(1, msg, [' ']) ) <> 'goto' then Exit;

  fCmd := ExtractWord(2, msg, [' ']);
  if fCmd = 'me' then begin
    // Find player
    fPlayer := fClient.GetPlayer( fUser );
    if fPlayer = nil then begin
      fPlayer := nil;
      exit;
    end;

    // Player find
    if fPlayer.EID = 0 then begin
      fPlayer := nil;
      exit;
    end;

    // Get entoty
    fTarget := fClient.GetEntity( fPlayer.EID );
    if fTarget = nil then begin
      fTarget := nil;
      Exit;
    end;

    fPos := fTarget.Pos;

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
  end
  else if fCmd = 'place' then begin
    str := '{'+
        '"place":"'+ExtractWord(3, msg, [' '])+'"'+
      '}';
  end
  else
    exit;

  // Set state
  fWork := true;
  fLastState := fState;
  fClient.SendEvent('state', 'work.comehere');

  fClient.SendEvent('cmd.walk.set', str);
end;

end.
