unit uHelp;

interface

uses
  ExtCtrls,

  uPlugins;

type
  TCmd_Help = class(TInterfacedObject, ITask, ITaskEventChat)
  private
    fClient:IClient;
  public
    constructor Create(Client:IClient);
    destructor Destroy; override;

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
  Classes,

  qStrUtils,

  UMain;

{ TCmd_Help }

constructor TCmd_Help.Create(Client: IClient);
begin
  fClient := Client;
end;

destructor TCmd_Help.Destroy;
begin

  inherited;
end;

function TCmd_Help.Name: string;
begin
  result := 'cmd.help';
end;

function TCmd_Help.GetInfo: string;
begin
  Result := '{"name":"cmd.help"}';
end;

function TCmd_Help.GetState: string;
begin
  Result := 'work';
end;

procedure TCmd_Help.Event(Name, Data: string);
begin
  //!
end;

function TCmd_Help.Help:string;
begin
  result := '';
end;

procedure TCmd_Help.ChatMessage(MType, From, Text: string);
var
  fCmd, str:string;
  i, j:Integer;
  fTask:ITask;
  fStrs:TStringList;
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
  if fCmd <> 'help' then exit;

  fStrs := TStringList.Create;
  try

    for i := 0 to Main.fTasks.Count-1 do begin
      fTask := Main.fTasks.Items[i];

      str := fTask.Help;
      if str = '' then continue;

      for j := 1 to WordCount(str, [#13, #10]) do
        fStrs.Add( ExtractWord(j, str, [#13, #10]) );
    end;

    fStrs.Sort;

    for i := 0 to fStrs.Count-1 do
      fClient.SendChatMsg( '/tell '+from+' '+fStrs.Strings[i] );

  finally
    fStrs.Free;
  end;
end;

end.
