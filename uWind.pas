unit uWind;

interface

uses
  SysUtils, Classes, Generics.Collections,

  uPlugins;

type
  TSlot = class(TInterfacedObject, ISlot)
  private
    fBlockId:Integer;
    fCount:byte;
    fDamage:Word;

    fParams:TBytes;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Empty;
    procedure Put(var Source: ISlot; PutCount:Integer);

    function GetBlockId:Integer;
    procedure SetBlockId(Val:Integer);

    function GetCount:Integer;
    procedure SetCount(Val:Integer);

    function GetDamage:Word;
    procedure SetDamage(Val:Word);

    function GetParams:TBytes;
    procedure SetParams(Val:TBytes);
  end;

  TWindow = class(TInterfacedObject, IWindow)
  private
    fTitle:String;
    fWType:Integer;
    fItems:TList<ISlot>;
    fWCount:Integer;
  public
    constructor Create( WCount, Count:Integer; Title:string; WType:Integer );
    destructor Destroy; override;

    procedure Clear;

    property WType:Integer read fWType;

    function GetTitle:string;

    function WCount:Integer;
    function Count:Integer;
    function GetSlot(Index:Integer):ISlot;
  end;

  TWindows = TDictionary<Byte, IWindow>;

implementation

{ TWindow }

constructor TWindow.Create(WCount, Count:Integer; Title:string; WType:Integer);
var
  i:Integer;
begin
  fTitle := Title;
  fWType := WType;
  fWCount := WCount;

  fItems := TList<ISlot>.Create;

  for i := 0 to Count-1 do
    fItems.Add( TSlot.Create );
end;

destructor TWindow.Destroy;
begin
  Clear;
  fItems.Free;
end;

procedure TWindow.Clear;
var
  i:Integer;
begin
  for i := 0 to fItems.Count-1 do
    fItems.Items[i] := nil;

  fItems.Clear;
end;

function TWindow.GetTitle:string;
begin
  Result := fTitle;
end;

function TWindow.WCount:Integer;
begin
  result := fWCount;
end;

function TWindow.Count: Integer;
begin
  result := fItems.Count;
end;

function TWindow.GetSlot(Index: Integer): ISlot;
begin
  result := nil;

  if Index <  0 then exit;
  if Index >= fItems.Count then exit;

  result := fItems.Items[Index];
end;

{ TSlot }

constructor TSlot.Create;
begin
  Empty;
end;

destructor TSlot.Destroy;
begin
  Empty;
end;

procedure TSlot.Empty;
begin
  fBlockId := -1;
  fCount := 0;
  fDamage := 0;

  SetLength(fParams, 0);
end;

function TSlot.GetBlockId: Integer;
begin
  Result := fBlockId;
end;

procedure TSlot.SetBlockId(Val: Integer);
begin
  fBlockId := Val;
end;

function TSlot.GetCount: Integer;
begin
  Result := fCount;
end;

procedure TSlot.SetCount(Val: Integer);
begin
  fCount := Val;
end;

function TSlot.GetDamage: Word;
begin
  Result := fDamage;
end;

procedure TSlot.SetDamage(Val: Word);
begin
  fDamage := Val;
end;

function TSlot.GetParams: TBytes;
begin
  Result := fParams;
end;

procedure TSlot.SetParams(Val: TBytes);
begin
  fParams := val;
end;

procedure TSlot.Put(var Source: ISlot; PutCount:Integer);
var
  fTBId:Integer;
  fTCount:Byte;
  fTDamage:Word;
begin
  // Change
  if (fBlockId <> -1) and (fBlockId <> Source.BlockId) then begin
    fTBId := fBlockId;
    fTCount := fCount;
    fTDamage := fDamage;
    //@@@ Fparams

    fBlockId := Source.BlockId;
    fCount   := Source.Count;
    fDamage  := Source.Damage;
    //@@@ Fparams

    Source.BlockId := fTBId;
    Source.Count := fTCount;
    Source.Damage := fTDamage;
    //@@@ Fparams
  end
  // Put
  else begin
    fBlockId := Source.BlockId;
    fCount   := fCount + PutCount;
    fDamage  := Source.Damage;
  end;
end;

end.
