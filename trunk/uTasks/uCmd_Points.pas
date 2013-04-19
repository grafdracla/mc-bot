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

    procedure Event(Name, Data:string);

    procedure ChatMessage(msg:string);
  end;

implementation

uses
  StrUtils,
  SysUtils,

  uLkJSON,

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

procedure TCmd_Points.Event(Name, Data: string);
var
  fJSON {, fVal}:TlkJSONbase;
begin
  // Add
  if name = 'cmd.points.add' then begin
    fJSON := TlkJSON.ParseText( Data );
    try
      AddPoint( fJSON.Field['name'].Value );
    finally
      fJSON.Free;
    end;
  end
  // Del
  else if name = 'cmd.points.del' then begin
    fJSON := TlkJSON.ParseText( Data );
    try
      DelPoint( fJSON.Field['name'].Value );
    finally
      fJSON.Free;
    end;
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

procedure TCmd_Points.ChatMessage(msg: string);
var
  fUser, fCmd, fPoint:string;
begin
  // Test whispers
  if trim( lowercase( ExtractWord(2, msg, [' ']) ) ) <> 'whispers' then exit;

  // Test user
  fUser := LowerCase( ExtractWord(1, msg, [' ']) );
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

  fCmd := LowerCase( ExtractWord(1, msg, [' ']) );
  if fCmd <> 'points' then exit;

  fCmd := LowerCase( ExtractWord(2, msg, [' ']) );
  if fCmd = 'add' then begin
    fPoint := ExtractWord(3, msg, [' ']);

    if fPoint = '' then exit;

    AddPoint( fPoint );
  end
  else if fCmd = 'delete' then begin
    fPoint := ExtractWord(3, msg, [' ']);
    if fPoint = '' then exit;

    DelPoint( fPoint );
  end;
end;

end.
