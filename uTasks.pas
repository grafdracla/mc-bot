unit uTasks;

interface

uses
  Classes, Generics.Collections,

  uPlugins;

type
  TLogMsg = procedure(Msg: string) of object;

  TTasks = class(TList<ITask>)
  private
    fEvents:TObjectDictionary<string,TList<ITask>>;
    fOnLogMsg:TLogMsg;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(Task:ITask);
    procedure Remove(Name:string);

    function FindByName(Name:string):ITask;

    procedure SendEvent(Name, Data:string);

    property OnLogMsg:TLogMsg read fOnLogMsg write fOnLogMsg;
  end;

implementation

uses
  Generics.Defaults,

  DBXJSON;

{ TTasks }

constructor TTasks.Create();
begin
  inherited Create;

  fEvents := TObjectDictionary<string,TList<ITask>>.Create;
end;

destructor TTasks.Destroy;
begin
  fEvents.Free;

  inherited;
end;

function TTasks.FindByName(Name: string): ITask;
var
  i:Integer;
begin
  for i := 0 to Count-1 do
    if Items[i].Name = Name then begin
      result := Items[i];
      exit;
    end;
end;

procedure TTasks.Remove(Name: string);
begin
  inherited Remove( FindByName(Name) );
end;

procedure TTasks.Add(Task: ITask);
var
  fJSON: TJSONObject;
  fPair:TJSONPair;
  fJItems: TJSONArray;
  i:Integer;
  fList:TList<ITask>;
  Data, fKey:string;
begin
  Data := Task.GetInfo;

  fJSON := TJSONObject.ParseJSONValue(Data) as TJSONObject;
  try
    fPair := fJSON.Get('events');
    if fPair <> nil then begin

      fJItems := fPair.JsonValue as TJSONArray;
      if fJItems <> nil then
        for i := 0 to fJItems.Size-1 do begin
          fKey := fJItems.Get(i).Value;

          // Get list
          if not fEvents.TryGetValue( fKey, fList ) then begin
            // New list
            fList := TList<ITask>.Create;
            fEvents.Add( fKey, fList );
          end;

          fList.Add(Task);
        end;
    end;

  finally
    fJSON.Free;
  end;

  inherited Add(Task);
end;

procedure TTasks.SendEvent(Name, Data: string);
var
  i:Integer;
  fList:TList<ITask>;
begin
  if Assigned(fOnLogMsg) then
    fOnLogMsg('%Event: '+Name+'='+Data);

  if fEvents.TryGetValue(Name, fList) then
    for i := 0 to fList.Count-1 do
      fList.Items[i].Event( Name, Data );
end;

end.
