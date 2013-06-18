unit uSys_Login;

interface

uses
  uPlugins;

type
  TSys_Login = class(TInterfacedObject, ITask, ITaskEventChat)
    fClient:IClient;
    UserPass:string;
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
  SysUtils;

{ TSys_Login }

constructor TSys_Login.Create(Client: IClient);
begin
  fClient := Client;

  UserPass := fClient.GetParam('server', 'password');
end;

function TSys_Login.Name: string;
begin
  Result := 'sys.login';
end;

function TSys_Login.GetInfo: string;
begin
  Result := '{"name":"sys.login"}';
end;

function TSys_Login.GetState:string;
begin
  Result := 'Wait';
end;

function TSys_Login.Help: string;
begin
  result := '';
end;

procedure TSys_Login.Event(Name, Data: string);
begin
  //
end;

procedure TSys_Login.ChatMessage(MType, From, Text: string);
begin
  if Pos('/login', Text) <> 0 then
    fClient.SendChatMsg('/login ' + UserPass);
end;

end.
