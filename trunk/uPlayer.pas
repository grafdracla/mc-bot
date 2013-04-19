unit uPlayer;

interface

uses
  Generics.Collections,

  uPlugins;

type
  TPlayer = class(TInterfacedObject, IPlayer)
  private
    fName:string;
    fPing:Word;
    fEId:LongWord;
  public
    constructor Create;

    function GetName:string;
    procedure SetName(Val:string);

    function GetPing:Word;
    procedure SetPing(Val:Word);

    function GetEId:LongWord;
    procedure SetEId(val:LongWord);
  end;

  TPlayers = TObjectDictionary<string,IPlayer>;

implementation

{ TPlayer }

constructor TPlayer.Create;
begin
  fName := '';
  fPing := 0;
  fEId := 0;
end;

function TPlayer.GetName: string;
begin
  result := fName;
end;

procedure TPlayer.SetName(Val: string);
begin
  fName := val;
end;

function TPlayer.GetPing: Word;
begin
  result := 0;
end;

procedure TPlayer.SetPing(Val: Word);
begin
  fPing := Val;
end;

function TPlayer.GetEId: LongWord;
begin
  result := fEId;
end;

procedure TPlayer.SetEId(val: LongWord);
begin
  fEId := val;
end;

end.
