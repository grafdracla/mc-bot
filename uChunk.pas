unit uChunk;

interface

uses
  Generics.Collections, Classes, Types,

  mcTypes, mcConsts, uPlugins;

const
  cBlockSize        = 4096;
  cMetaDataSize     = 2048;
  cLightDataSize    = 2048;
  cSkyLightDataSize = 2048;
  cAddDataSize      = 2048;
  cBiomeSize        = 256;

type
  TChunkData = array[0..16*cMaxY*16] of Byte;
  TMetaData = array[0..(16*cMaxY*16) div 2] of Byte;

  TChunk = class
  public
//    Unload:boolean;
//    Loaded:boolean;
    Data:TChunkData;
    Meta:TMetaData;

    constructor Create;

    procedure Clear;

    procedure SetBlockChunk(Pos:TAbsPos; BlockId, MetaData:Byte);
    function  GetBlockChunk(Pos:TAbsPos; var BlockId:Byte; var MetaData:Byte):boolean;
  end;

  TChunkPair  = TPair<TChunkPos, TChunk>;

  TChunks = class
  private
    fBounds:TRect;

    fItems:TDictionary<TChunkPos, TChunk>;
  public
    constructor Create;
    destructor Destroy; override;

    function Count:Integer;
    function CountLoaded:Integer;

    procedure Clear;

    property Itenms:TDictionary<TChunkPos, TChunk> read fItems;
    property Bounds:TRect read fBounds;

    function  Init(X, Z:Integer):TChunk;

    function  GetBlock(Pos:TAbsPos; var BlockId:Integer; var Meta:Byte):Boolean;
    procedure SetBlock(Pos:TAbsPos; BlockId:Byte; MetaData:Byte);

    function Chunk(X, Z:Integer):TChunk;
    function ChunkAbsolut(X, Z:Integer):TChunk;
  end;

implementation

uses
  SysUtils,
  ZLib;

{ TChunks }

constructor TChunks.Create;
begin
  fBounds.Empty;

  fItems := TDictionary<TChunkPos, TChunk>.Create;
end;

destructor TChunks.Destroy;
begin
  Clear;

  fItems.Free;
end;

function TChunks.Count: Integer;
begin
  result := fItems.Count;
end;

function TChunks.CountLoaded: Integer;
var fChunkPair:TChunkPair;
begin
  result := 0;

  for fChunkPair in fItems do
    Inc(result);
end;

function TChunks.Init(X, Z: Integer):TChunk;
var fChunkCoord:TChunkPos;
begin
  fChunkCoord := ChunkId( X, Z );

  if X < fBounds.Left then
    fBounds.Left := X;

  if X > fBounds.Right then
    fBounds.Right := X;

  if Z < fBounds.Top then
    fBounds.Top := Z;

  if Z > fBounds.Bottom then
    fBounds.Bottom := Z;

  // New
  if not fItems.TryGetValue( fChunkCoord, result ) then begin
    result := TChunk.Create;

    fItems.Add( fChunkCoord, result );
  end;

//  result.Unload := Unload;
end;

procedure TChunks.SetBlock(Pos:TAbsPos; BlockId, MetaData: byte);
var CX, CZ:Byte;
    fChunk:TChunk;
begin
  fChunk := ChunkAbsolut(Pos.X, Pos.Z);
  if fChunk = nil then exit;

  GetPosInChunk(Pos.x, pos.z, CX, CZ);

  fChunk.SetBlockChunk( AbsPos(CX, Pos.Y, CZ), BlockId, MetaData);
end;

function TChunks.GetBlock(Pos:TAbsPos; var BlockId: Integer; var Meta:Byte): Boolean;
var
  fChunk:TChunk;
  CX, CZ:Byte;
  fBId:Byte;
begin
  result := false;
  BlockId := -1;
  Meta := 0;

  fChunk := ChunkAbsolut(Pos.X, Pos.Z);
  if fChunk = nil then exit;

  GetPosInChunk(Pos.x, Pos.z, CX, CZ);

  result := fChunk.GetBlockChunk( AbsPos(CX, Pos.Y, CZ), fBId, Meta);
  if not result then Exit;

  BlockId := fBId;
end;

function TChunks.Chunk(X, Z: Integer): TChunk;
begin
  if not fItems.TryGetValue( ChunkId( X, Z ), result ) then
    result := nil;
end;

function TChunks.ChunkAbsolut(X, Z: Integer): TChunk;
begin
  if not fItems.TryGetValue( ChunkIdFromCoord( X, Z ), result ) then
    result := nil;
end;

procedure TChunks.Clear;
var
  fChunkPair:TChunkPair;
begin
  for fChunkPair in fItems do
    fChunkPair.Value.Free;
  fItems.Clear;
end;

{ TChunk }

procedure TChunk.Clear;
begin
  // Zero
  FillChar( Data, SizeOf(Data), btAir);
  FillChar( Meta, SizeOf(Meta), 0);
end;

constructor TChunk.Create;
begin
  Clear;
end;

function TChunk.GetBlockChunk(Pos:TAbsPos; var BlockId:Byte; var MetaData: Byte): boolean;
var
  n, m:Integer;
begin
  Result := False;

  if Pos.Y < 0 then exit;
  if Pos.Y > cMaxY then exit;

  // BlockId
  n := (Pos.Y*(cBlockInCube*cBlockInCube))+
       (Pos.Z*cBlockInCube)+
        Pos.X;

  BlockId := Data[n];

  // Block meta
  m := n div 2;

  if n mod 2 = 0 then
    MetaData := Meta[m] and $0F

  else
    MetaData := Meta[m] shr 4;

  result := True;
end;

procedure TChunk.SetBlockChunk(Pos:TAbsPos; BlockId, MetaData: Byte);
var
  n, m:Integer;
begin
  if Pos.Y < 0 then exit;
  if Pos.Y > cMaxY then exit;

  // Block Id
  n := (Pos.Y*(cBlockInCube*cBlockInCube))+
       (Pos.Z*cBlockInCube)+
        Pos.X;

  Data[n] := BlockId;

  // Block meta
  m := n div 2;

  MetaData := MetaData and $0F;
  if n mod 2 = 0 then
    Meta[m] := (Meta[m] and $F0) or MetaData

  else
    Meta[m] := (Meta[m] and $0F) or (MetaData shl 4);
end;

end.
