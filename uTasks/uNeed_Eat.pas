unit uNeed_Eat;

interface

uses
  Classes,
  uPlugins;

type
  TNeed_eat = class(TInterfacedObject, ITask, ITaskUpdateHealth)
  private
    fClient:IClient;
  public
    constructor Create(Client:IClient);

    function GetInfo:string;

    function Name:string;
    function GetState:string;

    function Help:string;

    procedure Event(Name, Data:string);
    procedure UpdateHealth;
  end;

implementation

{ TNeed_eat }

constructor TNeed_eat.Create(Client: IClient);
begin
  fClient := Client;
end;

function TNeed_eat.Name: string;
begin
  Result := 'need.eat';
end;

function TNeed_eat.GetInfo: string;
begin
  Result := '{"name":"need.eat"}';
end;

function TNeed_eat.GetState: string;
begin
  result := '-';
end;

function TNeed_eat.Help: string;
begin
  result := '';
end;

procedure TNeed_eat.Event(Name, Data: string);
begin
  //
end;

procedure TNeed_eat.UpdateHealth;
begin
  if fClient.Food <= 5 then
    fClient.SendChatMsg('I''m hungry');
end;

end.
