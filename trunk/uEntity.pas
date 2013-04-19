unit uEntity;

interface

uses
  Generics.Collections,

  mcTypes, uWind, uPlugins;

type
  TEntity = class(TInterfacedObject, IEntity)
  private
    fEType:TEntityType;
    fSubType:Integer;

    fPos:TPos;
    fVelocity:TPos;

    fYaw:Extended;
    fPitch:Extended;
    fHeadYaw:Extended;

    fLastStatus:Byte;
    fAttachVehile:LongWord;
    fLeashe:Boolean;

    // Drop items
    fRoll:Byte;
    fCount:Integer;
    //DamageData:Integer;

    // Painting
    fTitle:string;

    fSlots:array[0..4] of ISlot;

    Effects:TList<Byte>;
    Meta:TDictionary<Byte, OleVariant>;

    function GetEType:TEntityType;
    procedure SetEType( val:TEntityType );

    function GetSubType:Integer;
    procedure SetSubType( val:Integer );

    function GetPos:TPos;
    procedure SetPos( val:TPos );

    function GetVelocity:TPos;
    procedure SetVelocity( val:TPos );

    function GetYaw:Extended;
    procedure SetYaw( val:Extended );

    function GetPitch:Extended;
    procedure SetPitch( Val:Extended );

    function GetHeadYaw:Extended;
    procedure SetHeadYaw( Val:Extended );

    function GetLastStatus:Byte;
    procedure SetLastStatus(val:Byte);

    function GetAttachVehile:LongWord;
    procedure SetAttachVehile(val:LongWord);

    function GetLeashe:Boolean;
    procedure SetLeashe(Val:Boolean);

    function GetRoll:Byte;
    procedure SetRoll( Val:Byte );

    function GetCount:Integer;
    procedure SetCount( Val:Integer );

    function GetTitle:string;
    procedure SetTitle( Val:string );

    function GetSlot(Ind:Byte):ISlot;
    procedure SetSlot( Ind:Byte; Val:ISlot );

    function GetMeta( AIndex:Byte ):OleVariant;
    procedure SetMeta( AIndex:Byte; Val:OleVariant );
  public
//    EId:LongWord;
//    Animation:Byte;

    constructor Create;
    destructor  Destroy; override;

    procedure SetEffect(Effect: Byte);
    procedure UnSetEffect(Effect: Byte);

    function GetTypeName:string;
  end;

  TEntityPair = TPair<LongWord, IEntity>;

  TEntitys = class(TDictionary<LongWord, IEntity>);

implementation

uses
  Variants,
  SysUtils;

{ TEntity }

constructor TEntity.Create;
var
  i:Integer;
begin
//  EId     := 0;
  fEType   := etUnknown;
  fSubType := 0;

  fPos.X := 0;
  fPos.Y := 0;
  fPos.Z := 0;

  fVelocity.X := 0;
  fVelocity.Y := 0;
  fVelocity.Z := 0;

  fYaw := 0;
  fPitch := 0;
  fHeadYaw := 0;

//  Direction := 0;
//  Animation := 0;

  fAttachVehile := 0;

  // Drop items
  fRoll := 0;

  fCount := 0;
//  DamageData := 0;

  fLastStatus := 0;

  for i := 0 to Length(fSlots)-1 do
    fSlots[i] := TSlot.Create;

  Effects := TList<Byte>.Create;
  Meta := TDictionary<Byte, OleVariant>.Create;

  // Painting
  fTitle := '';
end;

destructor TEntity.Destroy;
var
  i:Integer;
begin
  Effects.Free;

  Meta.Free;

  for i := 0 to Length(fSlots)-1 do
    fSlots[i] := nil;

  inherited;
end;

function TEntity.GetEType: TEntityType;
begin
  Result := fEType;
end;

procedure TEntity.SetEType(val: TEntityType);
begin
  fEType := val;
end;

function TEntity.GetSubType:Integer;
begin
  result := fSubType;
end;

procedure TEntity.SetSubType( val:Integer );
begin
  fSubType := val;
end;

function TEntity.GetSlot(Ind:Byte):ISlot;
begin
  if Ind > 4 then
    result := nil
  else
    Result := fSlots[Ind];
end;

procedure TEntity.SetSlot( Ind:Byte; Val:ISlot );
begin
  if Ind > 4 then exit;

  fSlots[Ind] := Val;
end;

function TEntity.GetMeta(AIndex: Byte): OleVariant;
begin
  if not Meta.TryGetValue( AIndex, result ) then
    result := null;
end;

procedure TEntity.SetMeta(AIndex: Byte; Val: OleVariant);
begin
  Meta.AddOrSetValue( AIndex, Val );
end;

function TEntity.GetTitle:string;
begin
  Result := fTitle;
end;

procedure TEntity.SetTitle( Val:string );
begin
  fTitle := Val;
end;

function TEntity.GetCount:Integer;
begin
  result := fCount;
end;

procedure TEntity.SetCount( Val:Integer );
begin
  fCount := Val;
end;

function TEntity.GetPos: TPos;
begin
  result := fPos;
end;

procedure TEntity.SetPos(Val: TPos);
begin
  fPos := Val;
end;

function TEntity.GetVelocity: TPos;
begin
  Result := fVelocity;
end;

procedure TEntity.SetVelocity(val: TPos);
begin
  fVelocity := val;
end;

function TEntity.GetYaw: Extended;
begin
  result := fYaw;
end;

procedure TEntity.SetYaw(val: Extended);
begin
  fYaw := Val;
end;

function TEntity.GetPitch: Extended;
begin
  Result := fPitch;
end;

procedure TEntity.SetPitch(Val: Extended);
begin
  fPitch := Val;
end;

function TEntity.GetHeadYaw:Extended;
begin
  result := fHeadYaw;
end;

procedure TEntity.SetHeadYaw( Val:Extended );
begin
  fHeadYaw := Val;
end;

function TEntity.GetLastStatus:Byte;
begin
  Result := fLastStatus;
end;

procedure TEntity.SetLastStatus(val:Byte);
begin
  fLastStatus := val;
end;

function TEntity.GetAttachVehile:LongWord;
begin
  Result := fAttachVehile;
end;

procedure TEntity.SetAttachVehile(val:LongWord);
begin
  fAttachVehile := val;
end;

function TEntity.GetLeashe:Boolean;
begin
  result := fLeashe;
end;

procedure TEntity.SetLeashe(Val:Boolean);
begin
  fLeashe := val;
end;

function TEntity.GetRoll:Byte;
begin
  Result := fRoll;
end;

procedure TEntity.SetRoll( Val:Byte );
begin
  fRoll := Val;
end;

procedure TEntity.SetEffect(Effect: Byte);
begin
  if Effects.IndexOf(Effect) <> -1 then exit;

  Effects.Add(Effect);
end;

procedure TEntity.UnSetEffect(Effect: Byte);
begin
  Effects.Remove(Effect);
end;

function TEntity.GetTypeName: string;
begin
  case fEType of
    etObjectVehicle:
      result := 'Object/Vehicle';

    etMob:
      result := 'Mob';

    etPlayer:
      result := 'Player';

    etPainting:
      result := 'Painting';

    etExperienceOrb:
      result := 'Experience Orb';

    else
      result := '?';
  end;
end;

end.
