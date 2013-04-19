unit uPlugins;

interface

uses
  SysUtils, Generics.Collections;

const
  cDroppedItem = 2;

type
  TEntityType = (etUnknown, etObjectVehicle, etMob, etPlayer, etPainting, etExperienceOrb);

  TBType = (btBlock, btFluid, btItem, btPlant, btIngredient,
            btRawMaterials, btTool, btWeapons, btArmor, btFood);

  TMType = (etPassive, etNeutral, etHostile);

  TMButton = (mbLeft, mbRight, mbShift, mbMidle);

  TUserGroup = (ugNone, ugAdmin);

  TAbsPos = record
    X:Integer;
    Y:Integer;
    Z:Integer;
  end;

  TPos = record
    X:Extended;
    Y:Extended;
    Z:Extended;
  end;

  TChunkPos = record
    X:Integer;
    Z:Integer;
  end;

  IBlockInfo = interface
    ['{80887222-3EC3-4812-B630-DE31A465DC6D}']

    function BlockId:Integer;
    function BlockType:TBType;
    function Title:String;
    function Demage:Extended;
    function Resistance:Extended;
    function Stackable:Integer;
    function Height(Meta:Byte):Extended;

    function GetToolCount:Integer;
    function GetTool(Ind:Integer):Integer;

    // For debug
    function Color:LongWord;
    function Hint:string;
    function TypeName:string;
  end;

  IMobInfo = interface
    ['{B8313959-02A0-4119-98FD-78572F8B99BA}']

    function MType:TMType;
    function Title:string;
  end;

  IObjInfo = interface
    ['{B8313959-02A0-4119-98FD-78572F8B99BA}']

    function Title:string;
  end;

  ISlot = interface
    ['{763E6A60-A6CB-475D-9DC8-502538B73649}']

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

    property BlockId:Integer read GetBlockId write SetBlockId;
    property Count:Integer read GetCount write SetCount;
    property Damage:Word read GetDamage write SetDamage;
    property Params:TBytes read GetParams write SetParams;
  end;

  IWindow = interface
    ['{A4980101-57FF-4A63-B856-22EE4FECB876}']

    function GetTitle:string;

    function WCount:Integer;              // Window slot count
    function Count:Integer;               // All slot count
    function GetSlot(Ind:Integer):ISlot;
  end;

  IEntity = interface
    ['{B6491BE2-B735-4D93-B82A-EC56959BC7D3}']

    function GetEType:TEntityType;
    procedure SetEType( val:TEntityType );

    function GetSubType:Integer;
    procedure SetSubType( val:Integer );

    function GetPos:TPos;
    procedure SetPos( val:TPos );

    function GetVelocity:TPos;
    procedure SetVelocity( val:TPos );

    function GetYaw:Extended;
    procedure SetYaw(val:Extended);

    function GetSlot( AIndex:Byte ):ISlot;
    procedure SetSlot( AIndex:Byte; Val:ISlot );

    function GetMeta( AIndex:Byte ):OleVariant;
    procedure SetMeta( AIndex:Byte; Val:OleVariant );

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

    procedure SetEffect(Effect: Byte);
    procedure UnSetEffect(Effect: Byte);

    function GetTypeName:string;

    //-------------------------------------------
    property EType:TEntityType read GetEType write SetEType;
    property SubType:Integer read GetSubType write SetSubType;

    property Pos:TPos read GetPos write SetPos;
    property Velocity:TPos read GetVelocity write SetVelocity;

    property Yaw:Extended read GetYaw write SetYaw;
    property Pitch:Extended read GetPitch write SetPitch;
    property HeadYaw:Extended read GetHeadYaw write SetHeadYaw;

    property LastStatus:Byte read GetLastStatus write SetLastStatus;
    property AttachVehile:LongWord read GetAttachVehile write SetAttachVehile;
    property Leashe:Boolean read GetLeashe write SetLeashe;

    property Roll:Byte read GetRoll write SetRoll;
    property Count:Integer read GetCount write SetCount;

    property Title:string read GetTitle write SetTitle;

    property Slots[AIndex: Byte]: ISlot read GetSlot write SetSlot;

    property Meta[AIndex: Byte]:OleVariant read GetMeta write SetMeta;
  end;

  IPlayer = interface
    ['{EFCC040A-1830-44CB-8B18-72EB761C6FB0}']

    function GetName:string;
    procedure SetName(Val:string);

    function GetPing:Word;
    procedure SetPing(Val:Word);

    function GetEId:LongWord;
    procedure SetEId(val:LongWord);

    property Name:string read GetName write SetName;
    property Ping:Word read GetPing write SetPing;
    property EID:LongWord read GetEId write SetEId;
  end;

  IClient = interface
    ['{C4D4F86E-4FCC-4E48-A62A-2308936E3A5E}']

    // System
    procedure AddLog(str:string);
    procedure SendEvent(Name, Data:string);

    // Params
    function Health:Single;
    function Food:Integer;
    function FoodSaturation:Single;

    // Cmd
    procedure SendChatMsg(msg: string);

    procedure LookAt(Pos:TPos);
    procedure PlayerPosition(X, Y, Z, Stance: Double; Jamp: Boolean);
    procedure PlayerPositionLook(X, Y, Z, Stance: Double; Yaw, Pitch: Single; Jamp: Boolean);

    procedure HeldItemChange(Slot: SmallInt);

    procedure Digging(Pos:TAbsPos; Status, Face: Byte);
    procedure Place(Pos:TAbsPos; Direction, SubX, SubY, SubZ: Byte);

    procedure Animation(Num:Byte);

    function GetPlayer( Title:string ):IPlayer;

    function CalckYaw(X, Z: Extended): Extended;
    function CalckPith(X, Y, Z: Extended): Extended;

    // Privileges
    function GetUserGroup(UName:string):TUserGroup;

    // Params
    function  GetParam(Sesion, Ident: string): string;
    procedure SetParam(Sesion, Ident, Value: string);
    procedure DelParam(Sesion, Ident: string);

    // Bloks
    function GetBlock(Pos:TAbsPos; var BlockId: Integer; var Meta:Byte): Boolean;
    function GetBlockInfo(BlockId:Integer):IBlockInfo;

    // Windows
    function GetWindow(WId:byte):IWindow;

    function ClickWindow(WId: Byte; Slot: Word; MB: TMButton; Shift: Boolean):Integer;
    procedure CloseWindow(WId: Byte);

    // Entity
    function GetEntity( EID:LongWord ):IEntity;
    function GetNearEntity( Pos:TPos; EType:TEntityType; SubType:Byte; MaxDistance:Extended; var Distance:Extended ):IEntity;
    procedure GetNearEntitys( Pos:TPos; MaxDistance:Extended; List:TList<IEntity> );

    // User property
    function GetPos:TPos;
    function GetYaw:Extended;

    property Pos:TPos read GetPos;
    property Yaw:Extended read GetYaw;
  end;

  ITaskEventChat = interface
    ['{861064EE-3576-4905-A9DF-6494D129E6CE}']

    procedure ChatMessage(msg:string);
  end;

  ITaskEventEntity = interface
    ['{91AAA81B-7520-45BA-B26D-C8A8C268AFD4}']

    procedure SpawnEntity(Entity:IEntity);
    procedure DestroyEntity(Entity:IEntity);
  end;

  ITaskUpdateHealth = interface
    ['{B6887760-D8CE-46FA-B952-48F0E1662499}']

    procedure UpdateHealth;
  end;

  ITaskChangeBlocks = interface
    ['{9A0A5EB5-5326-4D8F-8EB7-C6E404C77268}']

    procedure BlockChange( Pos:TAbsPos );
    procedure BlockChangeMulti( X,Y:Integer );
  end;

  ITaskEnentWindow = interface
    ['{2030CED4-DBF3-47DB-AE6E-F7AAB1927F1D}']

    procedure OpenWindow(WID:Byte);
    procedure CloseWindow(WID:Byte);
    procedure ConfirmTransaction(WID:Byte; TransId:Word; Accept:boolean);
  end;

  ITask = interface
    ['{2388B177-6AEA-402A-A5F8-5B440570BAF8}']

    function GetInfo:string;

    function Name:string;
    function GetState:string;

    procedure Event(Name, Data:string);
  end;

  function PosToAbsPos( Pos:TPos ):TAbsPos;

  function ChunkId(X, Z:Integer):TChunkPos;
  function ChunkIdFromCoord(X, Z:Integer):TChunkPos;
  procedure GetPosInChunk(X,Z:Integer; var CX, CZ:Byte);

implementation

uses
  Math,

  mcConsts;

function PosToAbsPos( Pos:TPos ):TAbsPos;
begin
{  Result.X := Trunc(Pos.X);
  Result.Y := Trunc(Pos.Y);
  Result.Z := Trunc(Pos.Z);

  if Pos.X < 0 then Dec( Result.X );
  if Pos.Z < 0 then Dec( Result.Z );}

  Result.X := Floor(Pos.X);
  Result.Y := Floor(Pos.Y);
  Result.Z := Floor(Pos.Z);
end;

function ChunkId(X, Z:Integer):TChunkPos;
begin
  result.X := X;
  Result.Z := Z;
end;

function ChunkIdFromCoord(X, Z:Integer):TChunkPos;
begin
  if X >= 0 then
    result.X := x div cBlockInCube
  else
    result.X := ((x+1) div cBlockInCube)-1;

  if Z >= 0 then
    result.Z := z div cBlockInCube
  else
    result.Z := ((z+1) div cBlockInCube)-1;
end;

procedure GetPosInChunk(X,Z:Integer; var CX, CZ:Byte);
begin
  if x >= 0 then
    CX := X mod cBlockInCube
  else
    CX := cBlockInCube - 1 + ((x+1) mod cBlockInCube);

  if z >= 0 then
    CZ := Z mod cBlockInCube
  else
    Cz := cBlockInCube - 1 + ((z+1) mod cBlockInCube);
end;

end.
