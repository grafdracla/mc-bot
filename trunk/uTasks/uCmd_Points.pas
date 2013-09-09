unit uCmd_Points;

interface

uses
  Classes,

  uPlugins;

type
  TCmd_Points = class(TInterfacedObject, ITask, ITaskEventChat)
  private
    fClient:IClient;

    procedure AddPoint(Point:string);
    procedure DelPoint(Point:string);
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
  StrUtils,
  SysUtils,

  DBXJSON,

  qStrUtils;

{ TCmd_Points }

constructor TCmd_Points.Create(Client: IClient);
begin
  fClient := Client;
end;

function TCmd_Points.GetInfo: string;
begin
  Result := '{'+
    '"name":"cmd.points"'+
    '"events":["cmd.points.add", "cmd.points.del"]'+
  '}';
end;

function TCmd_Points.Name: string;
begin
  result := 'cmd.points';
end;

function TCmd_Points.GetState: string;
begin
  result := '-';
end;

function TCmd_Points.Help: string;
begin
  result :=
    'points add <point name>'#13#10+
    'points delete <point name>';
end;

procedure TCmd_Points.Event(Name, Data: string);
//var
//  fJSON {, fVal}:TlkJSONbase;
begin
  // Add
  if name = 'cmd.points.add' then begin
    raise Exception.Create('@@@');

(*
    fJSON := TlkJSON.ParseText( Data );
    try
      AddPoint( fJSON.Field['name'].Value );
    finally
      fJSON.Free;
    end;
*)
  end
  // Del
  else if name = 'cmd.points.del' then begin
    raise Exception.Create('@@@');

(*
    fJSON := TlkJSON.ParseText( Data );
    try
      DelPoint( fJSON.Field['name'].Value );
    finally
      fJSON.Free;
    end;
*)
  end;
end;

procedure TCmd_Points.AddPoint(Point: string);
begin
  fClient.SetParam('points', Point,
    FloatToStr(fClient.Pos.X)+';'+
    FloatToStr(fClient.Pos.Y)+';'+
    FloatToStr(fClient.Pos.Z)
  );
end;

procedure TCmd_Points.DelPoint(Point:string);
begin
  fClient.DelParam('points', Point);
end;

procedure TCmd_Points.ChatMessage(MType, From, Text: string);
var
  fCmd, fPoint:string;
begin
  // Test whispers
  if MType <> 'commands.message.display.incoming' then exit;

  // Test user
  case fClient.GetUserGroup(From) of
    ugAdmin:;
    else
      exit;
  end;

  fCmd := LowerCase( ExtractWord(1, Text, [' ']) );
  if fCmd <> 'points' then exit;

  fCmd := LowerCase( ExtractWord(2, Text, [' ']) );
  if fCmd = 'add' then begin
    fPoint := ExtractWord(3, Text, [' ']);

    if fPoint = '' then exit;

    AddPoint( fPoint );
  end
  else if fCmd = 'delete' then begin
    fPoint := ExtractWord(3, Text, [' ']);
    if fPoint = '' then exit;

    DelPoint( fPoint );
  end;
end;

end.
