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

    function Help:string;

    procedure Event(Name, Data:string);

    procedure ChatMessage(MType, From, Text:string);
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

function TWork_Goto.Help: string;
begin
  result :=
    'goto me'#13#10+
    'goto place';
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

procedure TWork_Goto.ChatMessage(MType, From, Text: string);
var
  fCmd:string;
  fPlayer:IPlayer;
  fTarget:IEntity;
  fPos:TPos;
  str:string;
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
  if lowercase( ExtractWord(1, Text, [' ']) ) <> 'goto' then Exit;

  fCmd := ExtractWord(2, Text, [' ']);
  if fCmd = 'me' then begin
    // Find player
    fPlayer := fClient.GetPlayer( From );
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
        '"place":"'+ExtractWord(3, Text, [' '])+'"'+
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
