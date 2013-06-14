unit uConnection;

interface

//{$DEFINE SHOW_SERVERCMD_ALL}
//{$DEFINE OpenSSL}

uses
  System.Classes, ExtCtrls,
  SysUtils, Generics.Collections,
  SyncObjs, IniFiles,

  IdTCPClient, IdIOHandler, IdSSLOpenSSL, IdComponent, IdLogBase, IdGlobal,

  mcConsts, mcTypes, uEntity, uPlayer, uChunk, uWind, uPlugins, uTasks;

type
  TLogMsg = procedure(Msg: string) of object;

  TWndEvent = procedure(WId: Byte) of object;

  TClient = class(TThread)
  private
    fDebugCmdSteck:TList<Byte>;

    fWork: Boolean;
    fLog: string;

    fIOHandler: TIdIOHandler;
    fTCPClient: TIdTCPClient;
    fSSL:TIdSSLIOHandlerSocketOpenSSL;

    fReconect: TTimer;
    fKeepAlive: TTimer;
    fVelocity: TTimer;

    fServerVer: byte;
    fClientVer: string;

    fLogMsg: TLogMsg;

    fFirstPos: Boolean;

//    fOldTimeMove: LongWord;

    fActionNum: Word;

    fLock:TCriticalSection;

    fTransId: Word;

    fClbFrom:ISlot;
    fClbTo:ISlot;
    fClbInv:ISlot;
    fClbCount:Integer;

    fOnChangeConnection: TNotifyEvent;
    fOnChangePosition: TNotifyEvent;
    fOnOpenWindow: TWndEvent;
    fOnCloseWindow: TWndEvent;

    procedure DoStatus(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: string);

    procedure DoKeepAlive(Sender: TObject);
    procedure DoVelocity(Sender: TObject);
    procedure DoReconnect(Sender: TObject);

    function CalckYaw(X, Z: Extended): Extended;
    function CalckPith(X, Y, Z: Extended): Extended;

    procedure Clear;

    procedure DoLog;

    function GetSteck():string;

    function GetActiveSlot: ISlot;
  protected
    procedure AddLog(str: string);

    procedure SendStr(str: string);

    function ReadString(IOHandler: TIdIOHandler = nil): string;
    procedure ReadBuffer(Buf: Pointer; BufSize: Integer);

    procedure ReadMetaData(Entity: IEntity);

    function ReadSlotData(Slot: ISlot): string;
    function WriteSlotData(Slot: ISlot): string;

    procedure Execute; override;

    procedure c00_KeepAlive();
    procedure c01_Login();
    procedure c02_Handshake();
    procedure c03_ChatMessage();
    procedure c04_TimeUpdate();
    procedure c05_EntityEquipment();
    procedure c06_SpawnPosition();
    procedure c08_UpdateHealth();
    procedure c09_Respawn();
    procedure c0D_PlayerPosition_Look();
    procedure c10_HeldItemChange();
    procedure c11_UseBed();
    procedure c12_Animation();
    procedure c14_SpawnNamedEntity();
    procedure c15_SpawnDroppedItem();
    procedure c16_CollectItem();
    procedure c17_SpawnObject_Vehicle();
    procedure c18_SpawnMob();
    procedure c19_SpawnPainting();
    procedure c1A_SpawnExperienceOrb();
    procedure c1C_EntityVelocity();
    procedure c1D_DestroyEntity();
    procedure c1E_Entity();
    procedure c1F_EntityRelativeMove();
    procedure c20_EntityLook();
    procedure c21_EntityLook_RelativeMove();
    procedure c22_EntityTeleport();
    procedure c23_EntityHeadLook();
    procedure c26_EntityStatus();
    procedure c27_AttachEntity();
    procedure c28_EntityMetadata();
    procedure c29_EntityEffect();
    procedure c2A_RemoveEntityEffect();
    procedure c2B_SetExperience();
    procedure c2C_EntityProperties();
    procedure c32_MapColumnAllocation();
    procedure c33_MapChunks();
    procedure c34_MultiBlockChange();
    procedure c35_BlockChange();
    procedure c36_BlockAction();
    procedure c37_BlockBreakAnimation();
    procedure c38_MapChunkBulk();
    procedure c3C_Explosion();
    procedure c3D_SoundParticleEffect();
    procedure c3E_NamedSoundEffect();
    procedure c46_ChangeGameState();
    procedure c47_Thunderbolt();
    procedure c64_OpenWindow();
    procedure c65_CloseWindow();
    procedure c67_SetSlot();
    procedure c68_SetWindowItems();
    procedure c69_UpdateWindowProperty();
    procedure c6A_ConfirmTransaction();
    procedure c6B_CreativeInventoryAction();
    procedure c82_UpdateSign();
    procedure c83_ItemData();
    procedure c84_UpdateTileEntity();
    procedure cC8_IncrementStatistic();
    procedure cC9_PlayerListItem();
    procedure cCA_PlayerAbilities();
    procedure cCB_TabComplete();

    procedure cCE_CreateScoreboard();
    procedure cCF_UpdateScore();
    procedure cD0_DisplayScoreboard();
    procedure cD1_Teams();

    procedure cFA_PluginMessage();
    procedure cFD_EncryptionKeyRequest();
    procedure cFF_DisconnectKick();

    procedure DoConnect(NideServerVer:byte);
    procedure DoDisconect;
  public
    fTasks:TTasks;
    fIni:TIniFile;

    LevelType:string;
    GameMode:Integer;
    WorldHeight:Word;
    Dimension:Integer;
    Difficulty:Byte;
    MaxPlayers:Byte;

    Age:Int64;
    Time:Int64;

    Host: string;
    Port: Integer;
    UserName:string;

    Session:string;
    UserId:Integer;

    Position:TPos;
    SpawnPosition:TPos;

    Stance:Extended;
    Yaw:Extended;
    Pitch:Extended;
    Jamp:boolean;

    Health:Single;
    Food:SmallInt;
    FoodSaturation:Single;

    ExperienceBar:Single;
    Level:SmallInt;
    TotalExperience:SmallInt;

    Windows:TWindows;
    Entitys:TEntitys;
    Players:TPlayers;
    Chunks:TChunks;

    ActiveShield:SmallInt;
    Cursor:ISlot;

    constructor Create;
    destructor Destroy(); override;

    procedure Connect( NideServerVer:byte );
    procedure Disconect;
    function IsConnected: Boolean;

    procedure SendChatMsg(str: string);
    procedure ClientSettings(Locale:string; Distance:Byte; ChatFlags, Difficulty:Byte; ShowCape:boolean);

    procedure Respawn;

    procedure Animation(Num:Byte);
    procedure PlayerJamp(fJamp: Boolean);
    procedure PlayerPosition(X, Y, Z, fStance: Double; fJamp: Boolean);
    procedure PlayerLook(fYaw, fPitch: Single; fJamp: Boolean);
    procedure PlayerPositionLook(X, Y, Z, fStance: Double; fYaw, fPitch: Single; fJamp: Boolean);
    procedure EntyAction(EID:LongWord; Action:Byte; Unknown:LongWord);

    procedure LookAt( Pos:TPos );
    procedure LookAtEntity(EID: LongWord);

    procedure Digging(Pos:TAbsPos; Status, Face: Byte);
    procedure Place(Pos:TAbsPos; Direction, SubX, SubY, SubZ: Byte);

    function  ClickWindow(WId: Byte; Slot: Word; MB: TMButton; Shift: Boolean):Integer;
    procedure CloseWindow(WId: Byte);
    procedure CreateInventoryAction(Slot:Word; SlotData:ISlot);

    procedure HeldItemChange(Slot: SmallInt);

    property ActiveSlot:ISlot read GetActiveSlot;

    property Lock:TCriticalSection read fLock;

    property OnLog: TLogMsg read fLogMsg write fLogMsg;
    property OnChangeConnection: TNotifyEvent read fOnChangeConnection write fOnChangeConnection;
    property OnChangePosition: TNotifyEvent read fOnChangePosition write fOnChangePosition;

    //@@@
    property OnOpenWindow: TWndEvent read fOnOpenWindow write fOnOpenWindow;
    property OnCloseWindow: TWndEvent read fOnCloseWindow write fOnCloseWindow;
  end;

  TClientInt = class(TInterfacedObject, IClient)
  private
    fClient:TClient;

    fLogMsg: TLogMsg;

    fAdmins:TStringList;
  public
    constructor Create(Client:TClient);
    destructor Destroy; override;

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

    procedure Animation(Num:Byte);

    procedure Digging(Pos:TAbsPos; Status, Face: Byte);
    procedure Place(Pos:TAbsPos; Direction, SubX, SubY, SubZ: Byte);

    function GetPlayer( Title:string ):IPlayer;

    function CalckYaw(X, Z: Extended): Extended;
    function CalckPith(X, Y, Z: Extended): Extended;

    // Privileges
    function GetUserGroup(UName:string):TUserGroup;

    // Params
    function GetParam(Sesion, Ident: string): string;
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

    property OnLogMsg:TLogMsg read fLogMsg write fLogMsg;
  end;

implementation

uses
  Windows,
  Types,
  Math,
  StrUtils,
  Variants,
  ZLib,
  //ZLibExGZ,
  uLkJSON,

  IdHashSHA,

  qSysUtils,
  qStrUtils,
  {$IFDEF OpenSSL}
    libeay32,
  {$ENDIF}
  // Wcrypt2,
  // IdSSLOpenSSL,

  uIBase;

const
  cProtVerMin: Byte = 28; // 1.2.0
                   // 29     1.2.4  1.2.5
                   // 39     1.3.1  1.3.2
                   // 47     1.4.1
                   // 49     1.4.4, 1.4.5
                   // 51     1.4.6, 1.4.7

                   // 52     13w01a
                   // 53     13w02b
                   // 54     13w03a
                   // 55     13w04a
                   // 56     13w05a
                   // 57     13w05b
                   // 58     13w06a
                   // 59     13w09a
                   // 60     13w09c
                   // 61     1.5.2
                   // 62     13w16a
                   // 65     13w18b
                   // 67     13w22a
                   // 68     13w23b
  cProtVerMax: Byte = 69; // 13w24a

function mcHexDigest(strm:TStream):string;

  procedure performTwosCompliment(var buffer:TIdBytes);
  var
    carry:Boolean;
    i:Integer;
    newByte, value:Byte;
  begin
    carry := true;

    for i := Length(buffer)-1 downto 0 do begin
      value := buffer[i];
      newByte := byte(not value);
      if carry then begin
        carry := newByte = $FF;
        buffer[i] := newByte + 1;
      end
      else
        buffer[i] := newByte;
    end;
  end;

var
  fSHA1:TIdHashSHA1;
  fHash:TIdBytes;
  negative:boolean;
  i:Integer;
begin
  fSHA1 := TIdHashSHA1.Create;
  try
    fHash := fSHA1.HashStream(strm);

    // check for negative hashes
    negative := ShortInt(fHash[0]) < 0;

    if negative then
      performTwosCompliment(fhash);

    result := IntToHex(fhash[0], 1);
    for i := 1 to Length(fhash)-1 do
      result := result + IntToHex(fhash[i], 2);

    if negative then
      result := '-' + result;

    result := lowercase(result);
  finally
    fSHA1.Free;
  end;
end;

function GetTickDiff(const AOldTickCount, ANewTickCount: LongWord): LongWord;
{$IFDEF USE_INLINE}inline; {$ENDIF}
begin
  { This is just in case the TickCount rolled back to zero }
  if ANewTickCount >= AOldTickCount then
  begin
    Result := ANewTickCount - AOldTickCount;
  end
  else
  begin
    Result := High(LongWord) - AOldTickCount + ANewTickCount;
  end;
end;

{ TClient }

constructor TClient.Create;
begin
  inherited Create(false);

  FreeOnTerminate := True;

  fWork := false;

  Age := 0;
  Time := 0;

  LevelType := '';
  GameMode := 0;
  WorldHeight := 0;
  Dimension := 0;
  Difficulty := 0;
  MaxPlayers := 0;


  UserName := '';

  Session := '';
  UserId := 0;

  Position.X := 0;
  Position.Y := 0;
  Position.Z := 0;

  SpawnPosition.X := 0;
  SpawnPosition.Y := 0;
  SpawnPosition.Z := 0;

  Stance := 0;
  Yaw := 0;
  Pitch := 0;
  Jamp := false;

  ActiveShield := 0;

  Health := 0;
  Food := 0;
  FoodSaturation := 0;

  ExperienceBar := 0;
  Level := 0;
  TotalExperience := 0;

  Cursor := TSlot.Create;
  Windows := TWindows.Create;
  Players := TPlayers.Create;
  Entitys := TEntitys.Create;
  Chunks  := TChunks.Create;

  // --------------------------------------------
  fClbFrom := nil;
  fClbTo := nil;
  fClbInv := nil;
  fClbCount := 0;

  Host := '';
  Port := 0;

  fActionNum := 1;

  fKeepAlive := TTimer.Create(nil);
  fKeepAlive.Enabled := false;
  fKeepAlive.Interval := 200;
  fKeepAlive.OnTimer := DoKeepAlive;

  fVelocity := TTimer.Create(nil);
  fVelocity.Enabled := false;
  fVelocity.Interval := 200;
  fVelocity.OnTimer := DoVelocity;

  fReconect := TTimer.Create(nil);
  fReconect.Enabled := false;
  fReconect.Interval := 1000;
  fReconect.OnTimer := DoReconnect;

  fTCPClient := TIdTCPClient.Create(nil);
  fTCPClient.OnStatus := DoStatus;

  fIOHandler := nil;

  fSSL := nil;

  fLock := TCriticalSection.Create;

  fDebugCmdSteck := TList<Byte>.Create;
end;

destructor TClient.Destroy;
begin
  fDebugCmdSteck.Free;

  fIOHandler := nil;

  FreeAndNil( fLock );

  FreeAndNil(fKeepAlive);
  FreeAndNil(fVelocity);
  FreeAndNil( fReconect );

  FreeAndNil(fTCPClient);

  //-------------------------
  Clear;

  Entitys.Free;
  Players.Free;
  Windows.Free;
  Cursor := nil;
  Chunks.Free;
end;


procedure TClient.Clear;
begin
  Entitys.Clear;
  Players.Clear;
  Windows.Clear;
  Cursor.Empty;
  Chunks.Clear;
end;

procedure TClient.Connect( NideServerVer:byte );
begin
  fWork := true;
  DoConnect( NideServerVer );

  fReconect.Enabled := true;
end;

procedure TClient.DoConnect(NideServerVer:byte);

  function ExctarctSub(str: string; var Pos: Integer): string;
  var
    lpos: Integer;
  begin
    Result := '';
    if Pos = 0 then
      Exit;

    lpos := Pos;
    Pos := PosEx(#0, str, Pos);
    if Pos = 0 then
      Result := Copy(str, lpos, Length(str))

    else
    begin
      Result := Copy(str, lpos, Pos - lpos);
      Inc(Pos);
    end;
  end;

const
  cMagikByte: Byte = $01;

var
  fB: Byte;
  i, fV: Integer;
  str, sub: string;
  fTCPVer: TIdTCPClient;
begin
  if IsConnected then exit;

  Clear;
  DODisconect;

  fFirstPos := True;

  fTCPClient.Host := Host;
  fTCPClient.Port := Port;

  // === Test server ===
  str := '';

  fTCPVer := TIdTCPClient.Create;
  try
    fTCPVer.Host := Host;
    fTCPVer.Port := Port;

    try
      fTCPVer.Connect;
    except
      Exit;
    end;

    // === Get server version ===
    // Ping
    fTCPVer.Socket.Write(cmdServerListPing);

    // Magik byte >= 49
    fTCPVer.Socket.Write(cMagikByte);

    // --- Read data ---
    try
      fB := fTCPVer.Socket.ReadByte;
    except
      Exit;
    end;

    if fB <> cmdDisconnectKick then begin
      AddLog('#Invalid protocol');
      Exit;
    end;

    str := ReadString(fTCPVer.IOHandler);

    fTCPVer.Disconnect;
  finally
    fTCPVer.Free;
  end;

  i := 1;
  ExctarctSub(str, i);

  // Server ver
  sub := ExctarctSub(str, i);
  if not IsNum( sub, fServerVer ) then
    fServerVer := NideServerVer;

  fClientVer := ExctarctSub(str, i);

  if (fServerVer < cProtVerMin) or (fServerVer > cProtVerMax) then begin
    AddLog('#Unknow versin: ' + IntToStr(fServerVer) );
    Disconect;
    Exit;
  end;

  // === Test server ===
  fTCPClient.Connect;

  // === Hand shake ===
  // Cmd
  fTCPClient.Socket.Write(cmdHandshake);

  case fServerVer of
    // 1.3 -
    39..MaxByte:begin
      // Protocol
      fTCPClient.Socket.Write( fServerVer );

      // User name
      SendStr( UserName );

      // Server host
      SendStr(Host);

      // Server port
      fTCPClient.Socket.Write(Port);
    end;
    // - 1.2.5
    else begin
      // Data
      SendStr( UserName +';'+Host+':'+IntToStr(Port) );
    end;
  end;

  fIOHandler := fTCPClient.IOHandler;

  AddLog('#Server version: ' + IntToStr(fServerVer) );
  AddLog('#Client version: ' + fClientVer);
  AddLog('<<< '+ GetCmdName(cmdHandshake));

  // Login
  if fServerVer < 39 then begin
    // Cmd
    fIOHandler.Write(cmdLogin);

    // ProtVer
    fV := fServerVer;
    fIOHandler.Write( fV );

    // User name
    SendStr( UserName );

    // Empty (Password)
    SendStr( '' );

    // Not used
    fV := 0;
    fTCPClient.Socket.Write(fV);

    // Not used
    fV := 0;
    fTCPClient.Socket.Write(fV);

    // Not used
    fB := 0;
    fTCPClient.Socket.Write(fB);

    // Not used
    fB := 0;
    fTCPClient.Socket.Write(fB);

    // Not used
    fB := 0;
    fTCPClient.Socket.Write(fB);

    AddLog('<<<'#9+GetCmdName(cmdLogin));
  end;
end;

procedure TClient.AddLog(str: string);
begin
  fLog := str;
  Synchronize(DoLog);
end;

function TClient.CalckPith(X, Y, Z: Extended): Extended;
begin
  Result :=
    ArcTan2(
      sqrt( Power(X - Position.X, 2) +
            Power(Z - Position.Z, 2)),
            Y - Position.Y) * (180 / Pi) - 90;
end;

function TClient.CalckYaw(X, Z: Extended): Extended;
begin
  Result := 360 - ArcTan2(X - Position.X, Z - Position.Z) * (180 / Pi);
end;

procedure TClient.SendStr(str: string);
var
  w: Word;
begin
  // Len
  w := Length(str);
  fTCPClient.Socket.Write(w);

  // Data
  fTCPClient.Socket.Write(str, SysUtils.TEncoding.BigEndianUnicode);
end;

procedure TClient.Digging(Pos:TAbsPos; Status, Face: Byte);
var
  fV:Integer;
  fB:Byte;
begin
  try
    // Cmd
    fTCPClient.Socket.Write(cmdPlayerDigging);

    // Status
    fTCPClient.Socket.Write(Status);

    // X
    fV := Pos.X;
    fTCPClient.Socket.Write(fV);

    // Y
    fB := Pos.Y;
    fTCPClient.Socket.Write(fB);

    // Z
    fV := Pos.Z;
    fTCPClient.Socket.Write(fV);

    // Face
    fTCPClient.Socket.Write(Face);
  except
  end;
end;

procedure TClient.Place(Pos:TAbsPos; Direction, SubX, SubY, SubZ: Byte);
var
{$IFDEF SHOW_SERVERCMD_ALL}
  str: string;
{$ENDIF}
  fV:Integer;
  fB:Byte;
begin
  // == Get active slot ==
  try
    // Cmd
    fTCPClient.Socket.Write(cmdPlayerBlockPlacement);

    // X
    fV := Pos.X;
    fTCPClient.Socket.Write( fV );

    // Y
    fB := Pos.Y;
    fTCPClient.Socket.Write( fB );

    // Z
    fV := Pos.Z;
    fTCPClient.Socket.Write( fV );

    // Direction
    fTCPClient.Socket.Write(Direction);

{$IFDEF SHOW_SERVERCMD_ALL}
    str :=
      IntToHex(cmdPlayerBlockPlacement, 2)+ ',' +
      IntToHex(LongWord(Pos.X), 8) + ',' +
      IntToHex(Pos.Y, 2) + ',' +
      IntToHex(LongWord(Pos.Z), 8) + ',' +
      IntToHex(Direction, 2);
{$ENDIF}

    // Slot
    {$IFDEF SHOW_SERVERCMD_ALL}
      str := str +
    {$ENDIF}
    WriteSlotData( ActiveSlot );

    case fServerVer of
      // 1.3
      39..MaxByte:begin
        // Cursor pos
        // X
        fTCPClient.Socket.Write(SubX);

        // Y
        fTCPClient.Socket.Write(SubY);

        // Z
        fTCPClient.Socket.Write(SubZ);
      end;
    end;

{$IFDEF SHOW_SERVERCMD_ALL}
    AddLog(str + '|' + IntToHex(SubX, 2) + ',' + IntToHex(SubY, 2) + ',' + IntToHex(SubZ, 2));
{$ENDIF}
  except
  end;
end;

function TClient.ClickWindow(WId: Byte; Slot: Word; MB: TMButton; Shift: Boolean):Integer;
var
{$IFDEF SHOW_SERVERCMD_ALL}
  str: string;
{$ENDIF}
  fWnd, fInvWnd:IWindow;
  fSlot:ISlot;
begin
  result := -1;

  //# Patch - old version
  case MB of
    mbShift, mbMidle:
      if fServerVer < 47 then
        exit;
  end;

  // Get window
  if not Windows.TryGetValue(WId, fWnd) then exit;

  // Get slot
  fSlot := fWnd.GetSlot( Slot );

  fTransId := fActionNum;

  fClbInv := nil;
  if Cursor.BlockId <> -1 then begin
    fClbFrom := Cursor;
    fClbTo := fSlot;

    if (WId <> 0) and ( Slot > fWnd.WCount ) then begin
      if not Windows.TryGetValue(0, fInvWnd) then exit;
      fClbInv := fInvWnd.GetSlot( Slot - fWnd.WCount + 9 );
    end;
  end
  else begin
    fClbFrom := fSlot;
    fClbTo := Cursor;
  end;

  if fClbFrom.BlockId = -1 then exit;
  if fClbFrom.Count = 0 then exit;

  if MB = mbRight then
    if Cursor.BlockId <> -1 then
      fClbCount := 1
    else
      fClbCount := fClbFrom.Count div 2
  else
    fClbCount := fClbFrom.Count;

  //---- Send CMD ----
  try
    // Cmd
    fTCPClient.Socket.Write(cmdClickWindow);

    // Window ID
    fTCPClient.Socket.Write(WId);

    // Slot
    fTCPClient.Socket.Write(Slot);

    // Mouse button
    fTCPClient.Socket.Write(Byte(MB));

    // Action number
    fTCPClient.Socket.Write(fActionNum);

    result := fActionNum;
    fActionNum := Word(fActionNum+1);

    // Shift
    fTCPClient.Socket.Write(Byte(Shift));

    // Slot
    {$IFDEF SHOW_SERVERCMD_ALL}
      str :=
    {$ENDIF}
      WriteSlotData( fSlot );

  {$IFDEF SHOW_SERVERCMD_ALL}
    AddLog(
      IntToHex(cmdClickWindow, 2)+','+
      IntToHex(WId, 2)+','+
      IntToHex(Slot, 4)+','+
      IntToHex(Byte(MB), 2)+','+
      IntToHex(fActionNum, 4)+','+
      IntToHex(Byte(Shift), 2)+
      str
    );
  {$ENDIF}
  except
  end;
end;

procedure TClient.CloseWindow(WId: Byte);
begin
  try
    // Cmd
    fTCPClient.Socket.Write(cmdCloseWindow);

    // WId
    fTCPClient.Socket.Write(WId);
  except
  end;

  //@@@
  if Assigned(fOnCloseWindow) then
    fOnCloseWindow( WId );
end;

procedure TClient.CreateInventoryAction(Slot:Word; SlotData:ISlot);
begin
  try
    // Cmd
    fTCPClient.Socket.Write(cmdCreativeInventoryAction);

    // Slot Id
    fTCPClient.Socket.Write(Slot);

    // Slot
    WriteSlotData( SlotData );
  except
  end;
end;

procedure TClient.Disconect;
begin
  fReconect.Enabled := false;
  DoDisconect;

  fWork := False;
end;

procedure TClient.DoDisconect;
begin
  fKeepAlive.Enabled := false;
  fVelocity.Enabled := false;

  try
    if fTCPClient.Connected then
      fTCPClient.Disconnect;
  except
  end;

  fIOHandler := nil;
end;

function TClient.IsConnected: Boolean;
begin
  Result := fTCPClient.Connected;
end;

procedure TClient.LookAt( Pos:TPos );
begin
  Yaw := CalckYaw(Pos.X, Pos.Z);
  Pitch := CalckPith(Pos.X, Pos.Y, Pos.Z);

  // AddLog( FloatToStr(UserEntity.Pitch) );

  PlayerLook(Yaw, Pitch, Jamp);
end;

procedure TClient.LookAtEntity(EID: LongWord);
var
  fEntity: IEntity;
begin
  if Entitys.TryGetValue(EID, fEntity) then
    LookAt( fEntity.Pos );
end;

procedure TClient.PlayerJamp(fJamp: Boolean);
var
  fB: Byte;
begin
  // Set to values
  Jamp := fJamp;

  //----------------
  try
    // Cmd
    fTCPClient.Socket.Write(cmdPlayer);

    // On graund
    if Jamp then
      fB := 0
    else
      fB := 1;

    fTCPClient.Socket.Write(fB);
  except
  end;
end;

procedure TClient.Animation(Num:Byte);
begin
  try
    // Cmd
    fTCPClient.Socket.Write(cmdAnimation);

    // EID
    fTCPClient.Socket.Write( UserId );

    // Animation
    fTCPClient.Socket.Write(Num);
  except
  end;
end;

procedure TClient.PlayerLook(fYaw, fPitch: Single; fJamp: Boolean);
var
  fB: Byte;
  fDW: LongWord;
begin
  // Set to values
  Yaw := fYaw;
  Pitch := fPitch;
  Jamp := fJamp;

  //-----
  try
    // Cmd
    fTCPClient.Socket.Write(cmdPlayerLook);

    // Yaw
    fDW := PLongWord(@fYaw)^;
    fTCPClient.Socket.Write(fDW);

    // Pitch
    fDW := PLongWord(@fPitch)^;
    fTCPClient.Socket.Write(fDW);

    // On graund
    if fJamp then
      fB := 0
    else
      fB := 1;

    fTCPClient.Socket.Write(fB);
  except
  end;
end;

procedure TClient.HeldItemChange(Slot: SmallInt);
begin
  ActiveShield := Slot;

  //---- Send ----
  try
    // Cmd
    fTCPClient.Socket.Write(cmdHeldItemChange);

    // Slot
    fTCPClient.Socket.Write(Slot);
  except
  end;
end;

procedure TClient.DoKeepAlive(Sender: TObject);
var
  dw: LongWord;
begin
  if Self.Terminated then exit;
  if fTCPClient = nil then exit;
  if not fTCPClient.Connected then exit;

  // Keep alive
  fTCPClient.Socket.Write(cmdKeepAlive);

  // Id
  dw := 0;
  fTCPClient.Socket.Write(dw);

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('<<<'#9 + GetCmdName(cmdKeepAlive));
{$ENDIF}
end;

procedure TClient.DoLog;
begin
  if Assigned(fLogMsg) then
    fLogMsg(fLog);
end;

function TClient.GetSteck:string;
var
  i:Integer;
begin
  result := '';

  for i := 0 to fDebugCmdSteck.Count-1 do begin
    if result <> '' then Result := result + ', ';
    result := result + IntToHex(fDebugCmdSteck.Items[i], 2);
  end;
end;

procedure TClient.DoReconnect(Sender: TObject);
begin
  if not fWork then exit;

  DoConnect( fServerVer );
end;

procedure TClient.DoStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
begin
  AddLog('!!! ' + AStatusText);

  case AStatus of
    hsConnected:begin
      AddLog('----------------------');
      AddLog('Connected: ' + Host + ':' + IntToStr(Port));

      Session := '';

      if Assigned(fOnChangeConnection) then
        fOnChangeConnection(Self);
    end;

    hsDisconnected:begin
      if Assigned(fOnChangeConnection) then
        fOnChangeConnection(Self);
    end;
  end;
end;

procedure TClient.DoVelocity(Sender: TObject);
var
  fEntityPair: TEntityPair;
  fPos, fVelocity:TPos;
begin
  fLock.Enter;
  try
    // Entys
    for fEntityPair in Entitys do begin
      fPos := fEntityPair.Value.Pos;
      fVelocity := fEntityPair.Value.Velocity;

      if fVelocity.X <> 0 then
        fPos.X := fPos.X + fVelocity.X;

      if fVelocity.Y <> 0 then
        fPos.Y := fPos.X + fVelocity.Y;

      if fVelocity.Z <> 0 then
        fPos.Z := fPos.X + fVelocity.Z;

      // Test Range
      if fPos.Y < 0 then fPos.Y := 0;
      if fPos.Y > cMaxY then fPos.Y := cMaxY;

      //@@@ - Test Range

      fEntityPair.Value.Pos := fPos;
      fEntityPair.Value.Velocity := fVelocity;
    end;

  finally
    fLock.Leave;
  end;
end;

procedure TClient.Execute;
var
  fCmd: Byte;
begin
  while not Terminated do begin
    try
      try
        if not fTCPClient.Connected then begin
          Sleep(500);
          Continue;
        end;
      except
        fTCPClient.Disconnect;
      end;

      if fIOHandler = nil then
        Continue;

      fCmd := fIOHandler.ReadByte;
      if Terminated then
        Continue;

      fDebugCmdSteck.Add( fCmd );

      case fCmd of
        cmdKeepAlive:
          c00_KeepAlive();

        cmdLogin:
          c01_Login();

        cmdHandshake:
          c02_Handshake();

        cmdChatMessage:
          c03_ChatMessage();

        cmdTimeUpdate:
          c04_TimeUpdate();

        cmdEntityEquipment:
          c05_EntityEquipment();

        cmdSpawnPosition:
          c06_SpawnPosition();

        cmdUpdateHealth:
          c08_UpdateHealth();

        cmdRespawn:
          c09_Respawn();

        cmdPlayerPosition_Look:
          c0D_PlayerPosition_Look();

        cmdHeldItemChange:
          c10_HeldItemChange();

        cmdUseBed:
          c11_UseBed();

        cmdAnimation:
          c12_Animation();

        cmdSpawnNamedEntity:
          c14_SpawnNamedEntity();

        cmdSpawnDroppedItem:
          c15_SpawnDroppedItem();

        cmdCollectItem:
          c16_CollectItem();

        cmdSpawnObjectVehicle:
          c17_SpawnObject_Vehicle();

        cmdSpawnMob:
          c18_SpawnMob();

        cmdSpawnPainting:
          c19_SpawnPainting();

        cmdSpawnExperienceOrb:
          c1A_SpawnExperienceOrb();

        cmdEntityVelocity:
          c1C_EntityVelocity();

        cmdDestroyEntity:
          c1D_DestroyEntity();

        cmdEntity:
          c1E_Entity();

        cmdEntityRelativeMove:
          c1F_EntityRelativeMove();

        cmdEntityLook:
          c20_EntityLook();

        cmdEntityLook_RelativeMove:
          c21_EntityLook_RelativeMove();

        cmdEntityTeleport:
          c22_EntityTeleport();

        cmdEntityHeadLook:
          c23_EntityHeadLook();

        cmdEntityStatus:
          c26_EntityStatus();

        cmdAttachEntity:
          c27_AttachEntity();

        cmdEntityMetadata:
          c28_EntityMetadata();

        cmdEntityEffect:
          c29_EntityEffect();

        cmdRemoveEntityEffect:
          c2A_RemoveEntityEffect();

        cmdSetExperience:
          c2B_SetExperience();

        cmdEntityProperties:
          c2C_EntityProperties();

        cmdMapColumnAllocation:
          c32_MapColumnAllocation();

        cmdMapChunks:
          c33_MapChunks();

        cmdMultiBlockChange:
          c34_MultiBlockChange();

        cmdBlockChange:
          c35_BlockChange();

        cmdBlockAction:
          c36_BlockAction();

        cmdBlockBreakAnimation:
          c37_BlockBreakAnimation();

        cmdMapChunkBulk:
          c38_MapChunkBulk();

        cmdExplosion:
          c3C_Explosion();

        cmdSoundParticleEffect:
          c3D_SoundParticleEffect();

        cmdNamedSoundEffect:
          c3E_NamedSoundEffect;

        cmdChangeGameState:
          c46_ChangeGameState();

        cmdThunderbolt:
          c47_Thunderbolt();

        cmdOpenWindow:
          c64_OpenWindow();

        cmdCloseWindow:
          c65_CloseWindow();

        cmdSetSlot:
          c67_SetSlot();

        cmdSetWindowItems:
          c68_SetWindowItems();

        cmdUpdateWindowProperty:
          c69_UpdateWindowProperty();

        cmdConfirmTransaction:
          c6A_ConfirmTransaction();

        cmdCreativeInventoryAction:
          c6B_CreativeInventoryAction();

        cmdUpdateSign:
          c82_UpdateSign();

        cmdItemData:
          c83_ItemData();

        cmdUpdateTileEntity:
          c84_UpdateTileEntity();

        cmdIncrementStatistic:
          cC8_IncrementStatistic();

        cmdPlayerListItem:
          cC9_PlayerListItem();

        cmdPlayerAbilities:
          cCA_PlayerAbilities();

        cmdTabComplete:
          cCB_TabComplete();

        cmdCreateScoreboard:
          cCE_CreateScoreboard();

        cmdUpdateScore:
          cCF_UpdateScore();

        cmdDisplayScoreboard:
          cD0_DisplayScoreboard();

        cmdTeams:
          cD1_Teams();

        cmdPluginMessage:
          cFA_PluginMessage();

        cmdEncryptionKeyRequest:
          cFD_EncryptionKeyRequest();

        cmdDisconnectKick:
          cFF_DisconnectKick();

        else
          raise Exception.Create( '#Invalid command :' + GetSteck() );

      end;

      while fDebugCmdSteck.Count > 9 do
        fDebugCmdSteck.Delete(0);

    except
      on E: Exception do begin
        AddLog(E.Message);

        DoDisconect;
      end;
    end;
  end;

  fIOHandler := nil;
end;

function TClient.GetActiveSlot: ISlot;
var
  fWnd: IWindow;
begin
  if Windows.TryGetValue(0, fWnd) then
    result := fWnd.GetSlot( 36 + ActiveShield )

  else
    result := nil;
end;

procedure TClient.ReadBuffer(Buf: Pointer; BufSize: Integer);
var
  fBytes: TBytes;
begin
  fIOHandler.ReadBytes(fBytes, BufSize);
  try
    Move(fBytes[0], Buf^, BufSize);
  except
    fIOHandler := fIOHandler;
  end;
end;

procedure TClient.ReadMetaData(Entity: IEntity);
var
  fB, fIndex, fTY: Byte;
  fW: Word;
  fDW: LongWord;
  fInt: Integer;
  // fFloat:Single;
  fStr: string;
  fStrs: TStringList;
  // fDW:LongWord;
  fSlot: ISlot;
begin
  fStrs := TStringList.Create;
  try
    fB := fIOHandler.ReadByte;

    while fB <> 127 do begin
      fIndex := fB and $1F;
      fTY := fB shr 5;

      case fTY of
        // Byte
        0:
          begin
            fB := fIOHandler.ReadByte;

            Entity.Meta[ fIndex ] := fB;

            fStrs.Add(IntToStr(fIndex) + ':0:' + IntToStr(fB));
          end;
        // Short
        1:
          begin
            fW := fIOHandler.ReadWord;

            Entity.Meta[ fIndex ] := fW;

            fStrs.Add(IntToStr(fIndex) + ':1:' + IntToStr(fW));
          end;
        // Int
        2:
          begin
            fInt := fIOHandler.ReadLongInt();

            Entity.Meta[ fIndex ] := fInt;

            fStrs.Add(IntToStr(fIndex) + ':2:' + IntToStr(fInt));
          end;
        // Float
        3:
          begin
            fDW := fIOHandler.ReadLongWord;
            // fFloat := fIOHandler.ReadSmallInt;

            Entity.Meta[ fIndex ] := fDW;

            fStrs.Add(IntToStr(fIndex) + ':3:' + IntToStr(fDW));
          end;
        // String
        4:
          begin
            fStr := ReadString();

            Entity.Meta[ fIndex ] := fStr;

            fStrs.Add(IntToStr(fIndex) + ':4:' + fStr);
          end;
        // Slot
        5:
          begin
            fSlot := nil;

            if Entity <> nil then
              fSlot := Entity.Slots[0];

            case fServerVer of
              39..MaxByte:
                ReadSlotData( fSlot );

              else begin
                // Block Id
                fSlot.BlockId := fIOHandler.ReadWord();

                // Count
                fSlot.Count := fIOHandler.ReadByte();

                // Meta / Demage
                fSlot.Damage := fIOHandler.ReadWord();
              end;
            end;

            Entity.Meta[ fIndex ] := fSlot;

            fStrs.Add(IntToStr(fIndex) + ':5:' + fStr);
          end;
        // ?
        6:
          begin
            fDW := fIOHandler.ReadLongWord;
            fStr := IntToStr(fDW) + ',';

            fDW := fIOHandler.ReadLongWord;
            fStr := fStr + IntToStr(fDW) + ',';

            fDW := fIOHandler.ReadLongWord;
            fStr := fStr + IntToStr(fDW);

            //@@@ Entity.Meta[ fIndex ] := ;

            fStrs.Add(IntToStr(fIndex) + ':6:' + fStr);
          end;

        else
          raise Exception.Create('Error format: ReadMetaData() :'+GetSteck());
      end;

      // metadata[index] = (ty, val)
      fB := fIOHandler.ReadByte;
    end;

  finally
    fStrs.Free
  end;
end;

function TClient.ReadSlotData(Slot: ISlot): string;

  {function CanEnchant(value:SmallInt):boolean;
  begin
    case value of
      $100..$103,
      $105,
      $10B..$117,
      $11B..$11E,
      $122..$126,
      $12A..$13D,
      $15A,
      $167:
        Result := true;
      else
        Result := false;
    end;
  end;}

var
  fItmId: SmallInt;
  fItmCount: Byte;
  fSubData: Word;
  fSize: SmallInt;

  fBuff:TBytes;
  //fStrm:TMemoryStream;
  //fDecomp:TDecompressionStream;
  //fDecomp:TGZDecompressionStream;
begin
  if Slot <> nil then
    Slot.Empty;

  // Item id
  fItmId := SmallInt(fIOHandler.ReadWord());

  Result := '|' + IntToHex(Word(fItmId), 4);

  if fItmId = -1 then exit;

  // Count
  fItmCount := fIOHandler.ReadByte();

  // damage/block metadata
  fSubData := fIOHandler.ReadWord();

  if Slot <> nil then begin
    Slot.BlockId := fItmId;
    Slot.Count := fItmCount;
    Slot.Damage := fSubData;
  end;

  Result := Result +','+
    IntToHex(fItmCount, 2) +','+
    IntToHex(fSubData, 4);

  // NTB
  fSize := fIOHandler.ReadSmallInt();
  if fSize <> -1 then begin
    fIOHandler.ReadBytes(fBuff, fSize);

    (*
    fStrm := TMemoryStream.Create;
    try
      fIOHandler.ReadStream( fStrm, fSize );

      fStrm.Position := 0;
      {fDecomp := TDecompressionStream.Create( fStrm );
      try
        fDecomp.ReadBuffer( fBuff, fDecomp.Size );
      finally
        fDecomp.Free;
      end;}

      fDecomp := TGZDecompressionStream.Create( fStrm );
      try
        fDecomp.ReadBuffer( fBuff, fDecomp.Size );
      finally
        fDecomp.Free;
      end;

    finally
      fStrm.Free;
    end;
*)
    if Slot <> nil then
      Slot.Params := fBuff;
  end;
end;

function TClient.WriteSlotData(Slot: ISlot): string;
var
  fItmId: SmallInt;
  fItmCount: Byte;
  fSubData: Word;
  fSize: SmallInt;
begin
  // None
  if Slot = nil then begin
    fItmId := -1;
    fTCPClient.Socket.Write(fItmId);

    Result := ' | ' + IntToHex(Word(fItmId), 4);
  end
  // Slot
  else begin
    fItmId := Slot.BlockId;
    fTCPClient.Socket.Write(fItmId);

    Result := ' | ' + IntToHex(Word(fItmId), 4);

    if Slot.BlockId <> -1 then begin
      // Count
      fItmCount := Slot.Count;
      fTCPClient.Socket.Write(fItmCount);

      // damage/block metadata
      fSubData := 0;
      fTCPClient.Socket.Write(fSubData);

      // NTB
      fSize := 0; //Length(Slot.NTB);

      Result := Result + ',' + IntToHex(fItmCount, 2) + // Count
        ',' + IntToHex(fSubData, 4); // Damage/block metadata

      if fSize = 0 then begin
        // Size
        fSize := -1;
        fTCPClient.Socket.Write(fSize);

        Result := Result + ',' + IntToHex(Word(fSize), 4);
      end
      else begin
        // Size
        fTCPClient.Socket.Write(fSize);

        // Data
        fTCPClient.Socket.Write(Slot.Params);

        Result := Result + ',' + IntToHex(Word(fSize), 4) + ',...';
      end;

    end;
  end;
end;

function TClient.ReadString(IOHandler: TIdIOHandler = nil): string;
var
  fLen: Word;
begin
  try
    if IOHandler = nil then
      IOHandler := fTCPClient.IOHandler;

    fLen := IOHandler.ReadWord();
    Result := IOHandler.ReadString(fLen * 2, SysUtils.TEncoding.BigEndianUnicode);
  except
    Result := '-Error-';
  end;
end;

procedure TClient.SendChatMsg(str: string);
begin
  try
    // Cmd
    fTCPClient.Socket.Write(cmdChatMessage);

    // Data
    SendStr(str);
  except
  end;
end;

procedure TClient.ClientSettings(Locale:string; Distance:Byte; ChatFlags, Difficulty:Byte; ShowCape:boolean);
var
  fB:Byte;
begin
  if fServerVer < 39 then
    raise Exception.Create('#Invalid command in this version :' + GetSteck() );

  try
    // Cmd
    fTCPClient.Socket.Write(cmdClientSettings);

    // Locale
    SendStr(Locale);

    // View distance
    fTCPClient.Socket.Write( Distance );

    // Chat flags
    fTCPClient.Socket.Write( ChatFlags );

    // Difficulty
    fTCPClient.Socket.Write( Difficulty );

    // Show Cape
    if fServerVer >= 47 then begin
      if ShowCape then
        fB := 1
      else
        fB := 0;

      fTCPClient.Socket.Write( fB );
    end;

  except
  end;
end;

procedure TClient.Respawn();
var
  b: Byte;
begin
  case fServerVer of
    // 1.3
    39..MaxByte:
      try
        // Cmd
        fTCPClient.Socket.Write(cmdClientStatuses);

        // Init
        b := 1;
        fTCPClient.Socket.Write(b);
      except
      end;

    // 1.2
    28..38:
      try
        // Cmd
        fTCPClient.Socket.Write(cmdRespawn);

        // Dimension
        fTCPClient.Socket.Write( Dimension );

        // Difficulty
        fTCPClient.Socket.Write( Difficulty );

        // CreateMode
        b := GameMode;
        fTCPClient.Socket.Write( b );

        // WorldHeight
        fTCPClient.Socket.Write( WorldHeight );

        // Level type
        SendStr( LevelType );
      except
      end;

    else
      raise Exception.Create( '#Invalid command version to send' );
  end;
end;

procedure TClient.PlayerPosition(X, Y, Z, fStance: Double; fJamp: Boolean);
var
  fV: Int64;
  fB: Byte;
begin
  // === Operate ===
  fLock.Enter;
  try
    // Set to values
    Position.X := X;
    Position.Y := Y;
    Position.Z := Z;

    Stance := fStance;
    Jamp := fJamp;
  finally
    fLock.Leave;
  end;

  try
    // Cmd
    fTCPClient.Socket.Write(cmdPlayerPosition);

    // X
    fV := PInt64(@X)^;
    fTCPClient.Socket.Write(fV);

    // Y
    fV := PInt64(@Y)^;
    fTCPClient.Socket.Write(fV);

    // Stance
    fV := PInt64(@fStance)^;
    fTCPClient.Socket.Write(fV);

    // Z
    fV := PInt64(@Z)^;
    fTCPClient.Socket.Write(fV);

    // On graund
    if fJamp then
      fB := 0
    else
      fB := 1;

    fTCPClient.Socket.Write(fB);
  except
  end;
end;

procedure TClient.PlayerPositionLook(X, Y, Z, fStance: Double; fYaw, fPitch: Single; fJamp: Boolean);
var
  fV: Int64;
  fDW: LongWord;
  fB: Byte;
begin
  // === Operate ===
  fLock.Enter;
  try
    // Set to values
    Position.X := X;
    Position.Y := Y;
    Position.Z := Z;

    Stance := fStance;
    Yaw := fYaw;
    Pitch := fPitch;
    Jamp := fJamp;
  finally
    fLock.Leave;
  end;

  try
    // Cmd
    fTCPClient.Socket.Write(cmdPlayerPosition_Look);

    // X
    fV := PInt64(@X)^;
    fTCPClient.Socket.Write(fV);

    // Y
    fV := PInt64(@Y)^;
    fTCPClient.Socket.Write(fV);

    // Stance
    fV := PInt64(@fStance)^;
    fTCPClient.Socket.Write(fV);

    // Z
    fV := PInt64(@Z)^;
    fTCPClient.Socket.Write(fV);

    // Yaw
    fDW := PLongWord(@fYaw)^;
    fTCPClient.Socket.Write(fDW);

    // Pitch
    fDW := PLongWord(@fPitch)^;
    fTCPClient.Socket.Write(fDW);

    // On graund
    if fJamp then
      fB := 0
    else
      fB := 1;

    fTCPClient.Socket.Write(fB);
  except
  end;
end;

procedure TClient.EntyAction(EID:LongWord; Action:Byte; Unknown:LongWord);
begin
  try
    // Cmd
    fTCPClient.Socket.Write(cmdEntityAction);

    // Action
    fTCPClient.Socket.Write(Action);

    // Leash
    if fServerVer >= 62 then
      fTCPClient.Socket.Write( Unknown );
  except
  end;
end;

procedure TClient.c00_KeepAlive;
begin
  // AID
  fIOHandler.ReadLongInt();

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdKeepAlive));
{$ENDIF}
end;

procedure TClient.c01_Login;
var
  fPlayer: IPlayer;
begin
  fLock.Enter;
  try
    // User Id
    UserId := fIOHandler.ReadLongInt();

    case fServerVer of
      // 1.3 -
      39..MaxByte:begin
        // Level type
        LevelType := ReadString();

        // Game mode
        GameMode := fIOHandler.ReadByte();

        // Dimension
        Dimension := fIOHandler.ReadByte();
      end;
      // 1.2.0 - 1.2.5
      28..38:begin
        // Not used
        ReadString();

        // Level type
        LevelType := ReadString();

        // Game mode
        GameMode := fIOHandler.ReadLongInt();

        // Dimension
        Dimension := fIOHandler.ReadLongInt();
      end;
      else
        raise Exception.Create('@@@');
    end;

    // Difficulty
    Difficulty := fIOHandler.ReadByte;

    // Not used
    { fB := } fIOHandler.ReadByte;

    // Max players
    MaxPlayers := fIOHandler.ReadByte;

    // === Operate ===
    if not Players.TryGetValue(UserName, fPlayer) then begin
      fPlayer := TPlayer.Create;
      Players.Add(UserName, fPlayer);
    end;

    fPlayer.Name := UserName;
    fPlayer.EID  := UserId;
  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
    AddLog('#' + GetCmdName(cmdLogin) + ': Ok');
{$ENDIF}

  fKeepAlive.Enabled := True;
  fVelocity.Enabled := True;
end;

procedure TClient.c02_Handshake();
begin
  if fServerVer >= 39 then
    raise Exception.Create('#Invalid command in this version :' + GetSteck() );

  // Connection Hash
  Session := ReadString();

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdHandshake) {$IFDEF SHOW_SERVERCMD_ALL}+' : '+Session{$ENDIF});
{$ENDIF}
end;

procedure TClient.c03_ChatMessage;
var
  str, sub, fType, fFrom, fText, fMark: string;
  i, fLevel:Integer;
  fJSON, fUsing, fValue:TlkJSONbase;
  fTask:ITask;
  fTaskEventChat:ITaskEventChat;
begin
  str := ReadString();

  if fServerVer >= 67 then begin
    fJSON := TlkJSON.ParseText( str );
    try
      // Type
      fType := fJSON.Field['translate'].Value;

      fUsing := fJSON.Field['using'];

      // From
      fFrom := fUsing.Child[0].Value;

      fValue := fUsing.Child[1];

      // Text
      if fValue.Count = 0 then
        fText := fValue.Value

      else
        fText := GenerateReadableText( fValue, fLevel );

    finally
      fJSON.Free;
    end;
  end
  else begin
    fType := 'chat.type.announcement';
    fFrom := '';
    fText := str;

    // Cut special
    while true do begin
      i := Pos('§', fText);
      if i = 0 then break;

      fText := Copy(fText, 1, i-1) + Copy(fText, i+2, Length(fText));
    end;

    fMark := Copy(fText, 1, 1);
    // Server
    if fMark = '[' then begin
      fType := 'chat.type.admin';
      fFrom := ExtractWord(1, fText, ['[',']']);

      // In []
      if ExtractWord(2, fFrom, [':']) <> '' then begin
        sub := fFrom;

        fFrom := ExtractWord(1, sub, [':', '"']);

        // End text
        fText := trim( Copy(fText, Pos(']', fText)+1, Length(fText)) );

        // Text in service
        fText := trim( Copy(sub, Pos(':', sub)+1, Length(sub)) ) + trim(' ' +fText);
      end
      else
        fText := trim( Copy(fText, Pos(']', fText)+1, Length(fText)) );
    end
    // User
    else if fMark = '<' then begin
      fType := 'chat.type.announcement';
      fFrom := ExtractWord(1, fText, ['<','>']);
      fText := trim( Copy(fText, Pos('>', fText)+1, Length(fText)) );
    end;

    // Whispers
    if trim( lowercase( ExtractWord(2, fText, [' ']) ) ) = 'whispers' then begin
      fType := 'commands.message.display.incoming';
      fFrom := ExtractWord(1, fText, [' ']);
      fText := trim( Copy(fText, WordPosition(3, fText, [' ']), Length(fText)) );

      //# patch 1.5
      if Copy(fText, 1, 7) = 'to you:' then
        fText := Trim( Copy(fText, 8, Length(fText)) );
    end;
  end;

  // Log event
  AddLog('#' + GetCmdName(cmdChatMessage) + ': ' + fType+ '|'+fFrom+'|'+fText);

  // Tasks event
  for i := 0 to fTasks.Count-1 do begin
    fTask := fTasks.Items[i];

    if fTask.QueryInterface( ITaskEventChat, fTaskEventChat ) = S_OK then
      fTaskEventChat.ChatMessage( fType, fFrom, fText );
  end;
end;

procedure TClient.c04_TimeUpdate;
begin
  fLock.Enter;
  try
    Age := 0;

    case fServerVer of
      // 1.4.1
      47..MaxByte:begin
        // Age of the world
        Age := fIOHandler.ReadInt64();

        // Time of Day
        Time := fIOHandler.ReadInt64();
      end;
      else begin
        // Time of Day
        Time := fIOHandler.ReadInt64();
      end;
    end;

  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdTimeUpdate) + ': ' + IntToStr(Age) + '/' + IntToStr(Time));
{$ENDIF}
end;

procedure TClient.c05_EntityEquipment;
var
  fEId: LongWord;
  fSlotInd: SmallInt;
  fEntity: IEntity;
  fSlot: ISlot;
begin
  // EId
  fEId := fIOHandler.ReadLongWord();

  // Slot
  fSlotInd := fIOHandler.ReadSmallInt();
  case fSlotInd of
    0..4:;
    else
      raise Exception.Create('@@@');
  end;

  // === Operate ===
  fLock.Enter;
  try
    // Not user
    if not Entitys.TryGetValue(fEId, fEntity) then begin
      fEntity := TEntity.Create;
      Entitys.Add( fEId, fEntity );
    end;

    fSlot := fEntity.Slots[fSlotInd];

    case fServerVer of
      // 1.3
      39..maxByte:
        ReadSlotData(fSlot)

      else begin
        fSlot.BlockId := fIOHandler.ReadSmallInt();
        fSlot.Count := 1;
        fSlot.Damage := fIOHandler.ReadWord();
      end;
    end;

  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdEntityEquipment) + ':' + IntToHex(fEId, 8) + ' : ' + IntToStr(fSlotInd));
{$ENDIF}
end;

procedure TClient.c06_SpawnPosition;
begin
  fLock.Enter;
  try
    // X
    SpawnPosition.X := fIOHandler.ReadLongInt();

    // Y
    SpawnPosition.Y := fIOHandler.ReadLongInt();

    // Z
    SpawnPosition.Z := fIOHandler.ReadLongInt();
  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdSpawnPosition));
{$ENDIF}
end;

procedure TClient.c08_UpdateHealth;
var
  fDW:LongWord;
  i:Integer;
  fTask:ITask;
  fTaskUpdateHealth:ITaskUpdateHealth;
begin
  fLock.Enter;
  try
    // Health
    if fServerVer >= 62 then begin
      fDW := fIOHandler.ReadLongWord();
      Health := PSingle( @fDW )^;
    end
    else
      Health := fIOHandler.ReadSmallInt();

    // Food
    Food := fIOHandler.ReadSmallInt();

    // FoodSaturation
    fDW := fIOHandler.ReadLongWord();
    FoodSaturation := PSingle( @fDW )^;

  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdUpdateHealth));
{$ENDIF}

  // Tasks event
  for i := 0 to fTasks.Count-1 do begin
    fTask := fTasks.Items[i];

    if fTask.QueryInterface(ITaskUpdateHealth, fTaskUpdateHealth ) = S_OK then
      fTaskUpdateHealth.UpdateHealth();
  end;
end;

procedure TClient.c09_Respawn;
begin
  fLock.Enter;
  try
    // Dimension
    Dimension := fIOHandler.ReadLongInt();

    // Difficulty
    Difficulty := fIOHandler.ReadByte();

    // CreateMode
    GameMode := fIOHandler.ReadByte();

    // WorldHeight
    WorldHeight := fIOHandler.ReadWord();

    // Level type
    LevelType := ReadString();
  finally
    fLock.Leave;
  end;

  // === Operate ===
  AddLog('#' + GetCmdName(cmdRespawn));
end;

procedure TClient.c0D_PlayerPosition_Look;
var
  fX, fY, fZ, fStance, fYaw, fPitch: Int64;
begin
  fLock.Enter;
  try

    // X
    fX := fIOHandler.ReadInt64();
    Position.X := PDouble( @fX )^;

    // Stance
    fStance := fIOHandler.ReadInt64();
    Stance  := PDouble( @fStance )^;

    // Y
    fY := fIOHandler.ReadInt64();
    Position.Y := PDouble( @fY )^;

    // Z
    fZ := fIOHandler.ReadInt64();
    Position.Z := PDouble( @fZ )^;

    // Yaw
    fYaw := fIOHandler.ReadLongWord();
    Yaw := PSingle( @fYaw )^;

    // Pitch
    fPitch := fIOHandler.ReadLongWord();
    Pitch := PSingle( @fPitch )^;

    // OnGround
    Jamp := fIOHandler.ReadByte <> 1;

    // #Patch first pos
    if fFirstPos then  begin
      Jamp := false;

      PlayerPositionLook(
        Position.X, Position.Y, Position.Z,
        Stance, Yaw, Pitch, Jamp );

      if Assigned(fOnChangePosition) then
        fOnChangePosition(Self);
    end;

  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdPlayerPosition_Look));
{$ENDIF}
end;

procedure TClient.c10_HeldItemChange();
begin
  fLock.Enter;
  try
    ActiveShield := fIOHandler.ReadSmallInt();
  finally
    fLock.Leave;
  end;

  //@@@ - Send Event
end;

procedure TClient.c11_UseBed;
var
  fEId: LongWord;
  fEntity: IEntity;
  fPos:TPos;
  str:string;
begin
  fLock.Enter;
  try
    // EId
    fEId := fIOHandler.ReadLongWord();

    // Find
    if not Entitys.TryGetValue(fEId, fEntity) then begin
      fEntity := TEntity.Create;
      Entitys.Add( fEId, fEntity );
    end;

    // Reserv
    fIOHandler.ReadByte();

    // X
    fPos.X := fIOHandler.ReadLongInt() / cRelativeMovementDiv;

    // Y
    fPos.Y := fIOHandler.ReadByte();

    // Z
    fPos.Z := fIOHandler.ReadLongInt() / cRelativeMovementDiv;

    fEntity.Pos := fPos;

  finally
    flock.Leave;
  end;

  str := '#' + GetCmdName(cmdUseBed) + ' : ' + IntToHex(fEId, 8);

// {$IFDEF SHOW_SERVERCMD_ALL}
  AddLog(str);
// {$ENDIF}

  //@@@
  SendChatMsg('Не могу спать. Очень много дел.');
end;

procedure TClient.c12_Animation;
//var
//  fEId: LongWord;
//  fAnimation: Byte;
//  fEntity: TEntity;
//  str: string;
begin
  // === Read data ===
  // EId
  {fEId :=} fIOHandler.ReadLongWord();

  // Animation
  {fAnimation :=} fIOHandler.ReadByte();

  // === Operate ===
{  fLock.Enter;
  try
    // Find
    fEntity := fUserEntity.Entitys.GetEnty(fEId);
    if fEntity = nil then
      fEntity := fUserEntity.Entitys.AddEnty(fEId);

    fEntity.Animation := fAnimation;
  finally
    fLock.Leave;
  end;}

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog( '#' + GetCmdName(cmdAnimation) + #9'Animation' );
{$ENDIF}
end;

procedure TClient.c14_SpawnNamedEntity;
var
  fEId: LongWord;
  fEntity: IEntity;
  fPos:TPos;

  fUserName: string;
  fPlayer: IPlayer;

  i:Integer;
  fTask:ITask;
  fTaskEventEntity:ITaskEventEntity;
begin
  fLock.Enter;
  try
    // EId
    fEId := fIOHandler.ReadLongWord();

    //--- Entity ---
    if not Entitys.TryGetValue(fEId, fEntity) then begin
      fEntity := TEntity.Create;
      Entitys.Add(fEId, fEntity);
    end;

    fEntity.EType := etPlayer;

    // Palyer name
    fUserName := ReadString();
    fEntity.Title := fUserName;

    // X
    fPos.X := fIOHandler.ReadLongInt() / cRelativeMovementDiv;

    // Y
    fPos.Y := fIOHandler.ReadLongInt() / cRelativeMovementDiv;

    // Z
    fPos.Z := fIOHandler.ReadLongInt() / cRelativeMovementDiv;

    fEntity.Pos := fPos;

    // Yaw
    fEntity.Yaw := fIOHandler.ReadByte() * 360 div 256;

    // Pitch
    fEntity.Pitch := fIOHandler.ReadByte();

    // Current Item
    ActiveShield := fIOHandler.ReadSmallInt();

    //--- MetaData ---
    case fServerVer of
      39..MaxByte:
        ReadMetaData(fEntity);
    end;

    // User
    if not Players.TryGetValue(fUserName, fPlayer) then begin
      fPlayer := TPlayer.Create;
      Players.Add(fUserName, fPlayer);
    end;

    fPlayer.EID := fEId;
    fPlayer.Name := fUserName;

  finally
    fLock.Leave;
  end;

  // Tasks event
  for i := 0 to fTasks.Count-1 do begin
    fTask := fTasks.Items[i];

    if fTask.QueryInterface(ITaskEventEntity, fTaskEventEntity ) = S_OK then
      fTaskEventEntity.SpawnEntity( fEntity );
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdSpawnNamedEntity) + ' : ' + IntToHex(fEId, 8));
{$ENDIF}
end;

procedure TClient.c15_SpawnDroppedItem;
var
  fEId: Integer;
  fEntity: IEntity;
  fSlot: ISlot;
  fPos:TPos;

  i:Integer;
  fTask:ITask;
  fTaskEventEntity:ITaskEventEntity;
begin
  if fServerVer > 50 then
    raise Exception.Create('#Old command :' + IntToHex(cmdSpawnDroppedItem, 2));

  // EId
  fEId := fIOHandler.ReadLongWord();

  fLock.Enter;
  try
    //--- Entity ---
    if not Entitys.TryGetValue(fEId, fEntity) then begin
      fEntity := TEntity.Create;
      Entitys.Add(fEId, fEntity);
    end;

    fEntity.EType := etObjectVehicle;
    fEntity.SubType := cDroppedItem;

    fSlot := fEntity.Slots[0];

    // Slot
    if fServerVer >= 47 then
      ReadSlotData(fSlot)

    else begin
      // Block id
      fSlot.BlockId := SmallInt(fIOHandler.ReadWord());

      // Count
      fSlot.Count := fIOHandler.ReadByte();

      // Damage/Data
      fSlot.Damage := fIOHandler.ReadWord();
    end;

    // X
    fPos.X := fIOHandler.ReadLongInt() / cRelativeMovementDiv;

    // Y
    fPos.Y := fIOHandler.ReadLongInt() / cRelativeMovementDiv;

    // Z
    fPos.Z := fIOHandler.ReadLongInt() / cRelativeMovementDiv;

    fEntity.Pos := fPos;

    // Rotation
    fEntity.Yaw := fIOHandler.ReadByte();

    // Pitch
    fEntity.Pitch := fIOHandler.ReadByte();

    // Roll
    fEntity.Roll := fIOHandler.ReadByte();
  finally
    fLock.Leave;
  end;

  // Tasks event
  for i := 0 to fTasks.Count-1 do begin
    fTask := fTasks.Items[i];

    if fTask.QueryInterface(ITaskEventEntity, fTaskEventEntity ) = S_OK then
      fTaskEventEntity.SpawnEntity( fEntity );
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdSpawnDroppedItem) + ': ' + IntToHex(fEId, 8));
{$ENDIF}
end;

procedure TClient.c16_CollectItem;
begin
  // !!! Only for animation

  // CollectedEID
  fIOHandler.ReadLongWord();

  // CollectorEID
  fIOHandler.ReadLongWord();

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdCollectItem));
{$ENDIF}
end;

procedure TClient.c17_SpawnObject_Vehicle;
var
  fEId: LongWord;
  fEntity: IEntity;
  fPos:TPos;
  fFId: Integer;

  i:Integer;
  fTask:ITask;
  fTaskEventEntity:ITaskEventEntity;
begin
  fLock.Enter;
  try
    // EID
    fEId := fIOHandler.ReadLongWord();

    //--- Entity ---
    if not Entitys.TryGetValue(fEId, fEntity) then begin
      fEntity := TEntity.Create;
      Entitys.Add(fEId, fEntity);
    end;
    fEntity.EType := etObjectVehicle;

    // OType
    fEntity.SubType := fIOHandler.ReadByte();

    // X
    fPos.X := fIOHandler.ReadLongInt() / cRelativeMovementDiv;

    // Y
    fPos.y := fIOHandler.ReadLongInt() / cRelativeMovementDiv;

    // Z
    fPos.z := fIOHandler.ReadLongInt() / cRelativeMovementDiv;

    fEntity.Pos := fPos;

    if fServerVer >= 50 then begin
      // Yaw
      fEntity.Yaw :=fIOHandler.ReadByte() * 360 div 256;

      // Pitch
      fEntity.Pitch := fIOHandler.ReadByte();
    end;

    // FID
    fFId := fIOHandler.ReadLongInt();

    // The speed of the objec
    if fFId <> 0 then begin
      fIOHandler.ReadWord(); // X
      fIOHandler.ReadWord(); // Y
      fIOHandler.ReadWord(); // z
    end;

    case fFId of
      // Falling Objects
      70: raise Exception.Create('@@@ Falling Objects');
      // Item frames
      71: raise Exception.Create('@@@ Item frames');
    end;

    // @@@ Fireball

  finally
    fLock.Leave;
  end;

  // Tasks event
  for i := 0 to fTasks.Count-1 do begin
    fTask := fTasks.Items[i];

    if fTask.QueryInterface(ITaskEventEntity, fTaskEventEntity ) = S_OK then
      fTaskEventEntity.SpawnEntity( fEntity );
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdSpawnObjectVehicle));
{$ENDIF}
end;

procedure TClient.c18_SpawnMob;
var
  fEId: LongWord;
  fEntity: IEntity;
  fPos, fVelocity:TPos;

  i:Integer;
  fTask:ITask;
  fTaskEventEntity:ITaskEventEntity;
begin
  fLock.Enter;
  try
    // EId
    fEId := fIOHandler.ReadLongWord();

    //--- Entity ---
    if not Entitys.TryGetValue(fEId, fEntity) then begin
      fEntity := TEntity.Create;
      Entitys.Add(fEId, fEntity);
    end;
    fEntity.EType := etMob;

    // MType
    fEntity.SubType := fIOHandler.ReadByte();

    // X, Y, Z
    fPos.X := fIOHandler.ReadLongInt() / cRelativeMovementDiv;
    fPos.Y := fIOHandler.ReadLongInt() / cRelativeMovementDiv;
    fPos.Z := fIOHandler.ReadLongInt() / cRelativeMovementDiv;
    fEntity.Pos := fPos;

    // Yaw
    fEntity.Yaw := fIOHandler.ReadByte() * 360 div 256;

    // Pitch
    fEntity.Pitch := fIOHandler.ReadByte();

    case fServerVer of
      // 1.3
      39..MaxByte:begin
        // HeadYaw
        fEntity.HeadYaw := fIOHandler.ReadByte();

        // Velocity
        fVelocity.Z := fIOHandler.ReadSmallInt() / 32000;
        fVelocity.X := fIOHandler.ReadSmallInt() / 32000;
        fVelocity.Y := fIOHandler.ReadSmallInt() / 32000;
        fEntity.Velocity := fVelocity;
      end;
      // 1.2
      28..38:begin
        // HeadYaw
        fEntity.HeadYaw := fIOHandler.ReadByte();
      end;
      // 1.1
      else
        raise Exception.Create('@@@');
    end;

    // Meta data
    ReadMetaData( fEntity ); // @@@ Meta

  finally
    fLock.Leave;
  end;

  // Tasks event
  for i := 0 to fTasks.Count-1 do begin
    fTask := fTasks.Items[i];

    if fTask.QueryInterface(ITaskEventEntity, fTaskEventEntity ) = S_OK then
      fTaskEventEntity.SpawnEntity( fEntity );
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdSpawnMob) + ':' + IntToHex(fEId, 8));
{$ENDIF}
end;

procedure TClient.c19_SpawnPainting;
var
  fEId: LongWord;
  fEntity: IEntity;
  fPos:TPos;

  i:Integer;
  fTask:ITask;
  fTaskEventEntity:ITaskEventEntity;
begin
  fLock.Enter;
  try
    // EID
    fEId := fIOHandler.ReadLongWord();

    if not Entitys.TryGetValue(fEId, fEntity) then begin
      fEntity := TEntity.Create;
      Entitys.Add(fEId, fEntity);
    end;
    fEntity.EType := etPainting;

    // Title
    fEntity.Title := ReadString();

    // X
    fPos.X := fIOHandler.ReadLongInt() / cRelativeMovementDiv;

    // Y
    fPos.Y := fIOHandler.ReadLongInt() / cRelativeMovementDiv;

    // Z
    fPos.Z := fIOHandler.ReadLongInt() / cRelativeMovementDiv;

    fEntity.Pos := fPos;

    // Direction
    fEntity.HeadYaw := fIOHandler.ReadLongInt();

  finally
    fLock.Leave;
  end;

  // Tasks event
  for i := 0 to fTasks.Count-1 do begin
    fTask := fTasks.Items[i];

    if fTask.QueryInterface(ITaskEventEntity, fTaskEventEntity ) = S_OK then
      fTaskEventEntity.SpawnEntity( fEntity );
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdSpawnPainting));
{$ENDIF}
end;

procedure TClient.c1A_SpawnExperienceOrb;
var
  fEId: Integer;
  fEntity: IEntity;
  fPos:TPos;

  i:Integer;
  fTask:ITask;
  fTaskEventEntity:ITaskEventEntity;
begin
  fLock.Enter;
  try

    // EId
    fEId := fIOHandler.ReadLongWord();

    if not Entitys.TryGetValue(fEId, fEntity) then begin
      fEntity := TEntity.Create;
      Entitys.Add(fEId, fEntity);
    end;
    fEntity.EType := etExperienceOrb;
    fEntity.SubType := 0;

    // X
    fPos.X := fIOHandler.ReadLongInt() / cRelativeMovementDiv;

    // Y
    fPos.Y := fIOHandler.ReadLongInt() / cRelativeMovementDiv;

    // Z
    fPos.Z := fIOHandler.ReadLongInt() / cRelativeMovementDiv;

    fEntity.Pos := fPos;

    // Count
    fEntity.Count := fIOHandler.ReadSmallInt();
  finally
    fLock.Leave;
  end;

  // Tasks event
  for i := 0 to fTasks.Count-1 do begin
    fTask := fTasks.Items[i];

    if fTask.QueryInterface(ITaskEventEntity, fTaskEventEntity ) = S_OK then
      fTaskEventEntity.SpawnEntity( fEntity );
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdSpawnExperienceOrb));
{$ENDIF}
end;

procedure TClient.c1C_EntityVelocity;
var
  fEId: LongWord;
  fEntity: IEntity;
  fVelocity:TPos;
begin
  fLock.Enter;
  try

    // === Read data ===
    // EId
    fEId := fIOHandler.ReadLongWord();

    if not Entitys.TryGetValue(fEId, fEntity) then begin
      fEntity := TEntity.Create;
      Entitys.Add( fEId, fEntity );
    end;

    // X, Y, Z
    fVelocity.X := fIOHandler.ReadSmallInt() / 32000;
    fVelocity.Y := fIOHandler.ReadSmallInt() / 32000;
    fVelocity.Z := fIOHandler.ReadSmallInt() / 32000;
    fEntity.Velocity := fVelocity;

  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdEntityVelocity) + ':' + IntToHex(fEId, 8));
{$ENDIF}
end;

procedure TClient.c1D_DestroyEntity;

  procedure RemoveEID();
  var
    fEId: LongWord;

    fTask:ITask;
    fTaskEventEntity:ITaskEventEntity;
    fEntity:IEntity;

    j:Integer;
  begin
    // EID
    fEId := fIOHandler.ReadLongWord();

    if not Entitys.TryGetValue(fEId, fEntity) then exit;

    // Tasks event
    for j := 0 to fTasks.Count-1 do begin
      fTask := fTasks.Items[j];

      if fTask.QueryInterface(ITaskEventEntity, fTaskEventEntity ) = S_OK then
        fTaskEventEntity.DestroyEntity( fEntity );
    end;

    // === Operate ===
    Entitys.Remove( fEId );
  end;

var
  i: Integer;
  fCount: Byte;
begin
  fLock.Enter;
  try
    case fServerVer of
      // 1.3 -
      39..MaxByte:begin
        // Count
        fCount := fIOHandler.ReadByte();

        for i := 0 to Integer(fCount)-1 do
           RemoveEID();
      end;

      // 1.2.0 - 1.2.5
      28..38:
        RemoveEID();

      else
        raise Exception.Create('@@@');
    end;

  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdDestroyEntity));
{$ENDIF}
end;

procedure TClient.c1E_Entity;
var
  fEId: LongWord;
  fEntity: IEntity;
begin
  // === Read ===
  // EID
  fEId := fIOHandler.ReadLongWord();

  // === Operate ===
  fLock.Enter;
  try

    if not Entitys.TryGetValue(fEId, fEntity) then begin
      fEntity := TEntity.Create;
      Entitys.Add( fEId, fEntity );
    end;

  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog( '#' + GetCmdName(cmdEntity) );
{$ENDIF}
end;

procedure TClient.c1F_EntityRelativeMove;
var
  fEId: LongWord;
  fX, fY, fZ: ShortInt;
  fEntity: IEntity;
  fPos:TPos;
begin
  fLock.Enter;
  try

    // EID
    fEId := fIOHandler.ReadLongWord();

    if not Entitys.TryGetValue(fEId, fEntity) then begin
      fEntity := TEntity.Create;
      Entitys.Add( fEId, fEntity );
    end;

    fEntity.Velocity := ToPos(0,0,0);

    fX := ShortInt(fIOHandler.ReadByte());
    fY := ShortInt(fIOHandler.ReadByte());
    fZ := ShortInt(fIOHandler.ReadByte());

    fPos := fEntity.Pos;
    fPos.X := fPos.X + (fX / cRelativeMovementDiv);
    fPos.Y := fPos.Y + (fY / cRelativeMovementDiv);
    fPos.Z := fPos.Z + (fZ / cRelativeMovementDiv);
    fEntity.Pos := fPos;

  finally
    fLock.Leave;
  end;

  {$IFDEF SHOW_SERVERCMD_ALL}
    AddLog( '#' + GetCmdName(cmdEntityRelativeMove) + ': ' + IntToHex(fEId, 8) );
  {$ENDIF}
end;

procedure TClient.c20_EntityLook;
var
  fEId: LongWord;
  fEntity: IEntity;
begin
  fLock.Enter;
  try

    // EID
    fEId := fIOHandler.ReadLongWord();

    if not Entitys.TryGetValue(fEId, fEntity) then begin
      fEntity := TEntity.Create;
      Entitys.Add( fEId, fEntity );
    end;

    // Yaw
    fEntity.Yaw := fIOHandler.ReadByte() * 360 / 255;

    // Pitch
    fEntity.Pitch := fIOHandler.ReadByte;

  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdEntityLook) + ': ' + IntToHex(fEId, 8));
{$ENDIF}
end;

procedure TClient.c21_EntityLook_RelativeMove;
var
  fEId: LongWord;
  fX, fY, fZ: ShortInt;
  fEntity: IEntity;
  fPos:TPos;
begin
  fLock.Enter;
  try
    // EID
    fEId := fIOHandler.ReadLongWord();

    if not Entitys.TryGetValue(fEId, fEntity) then begin
      fEntity := TEntity.Create;
      Entitys.Add( fEId, fEntity );
    end;

    fEntity.Velocity := ToPos(0,0,0);

    // X, Y, Z
    fX := ShortInt(fIOHandler.ReadByte());
    fY := ShortInt(fIOHandler.ReadByte());
    fZ := ShortInt(fIOHandler.ReadByte());

    fPos := fEntity.Pos;
    fPos.X := fPos.X + (fX / cRelativeMovementDiv);
    fPos.Y := fPos.Y + (fY / cRelativeMovementDiv);
    fPos.Z := fPos.Z + (fZ / cRelativeMovementDiv);
    fEntity.Pos := fPos;

    // Yaw
    fEntity.Yaw := fIOHandler.ReadByte * 360 div 256;

    // Pitch
    fEntity.Pitch := fIOHandler.ReadByte;

  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdEntityLook_RelativeMove) + ': ' + IntToHex(fEId, 8));
{$ENDIF}
end;

procedure TClient.c22_EntityTeleport;
var
  fEId: LongWord;
  fEntity: IEntity;
  fPos:TPos;
begin
  fLock.Enter;
  try

    // EID
    fEId := fIOHandler.ReadLongWord();

    if not Entitys.TryGetValue(fEId, fEntity) then begin
      fEntity := TEntity.Create;
      Entitys.Add( fEId, fEntity );
    end;

    fEntity.Velocity := ToPos(0,0,0);

    // X
    fPos.X := fIOHandler.ReadLongInt() / cRelativeMovementDiv;

    // Y
    fPos.Y := fIOHandler.ReadLongInt() / cRelativeMovementDiv;

    // Z
    fPos.Z := fIOHandler.ReadLongInt() / cRelativeMovementDiv;

    fEntity.Pos := fPos;

    // Yaw
    fEntity.Yaw := fIOHandler.ReadByte * 360 div 256;

    // Pitch
    fEntity.Pitch := fIOHandler.ReadByte;

  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdEntityTeleport) + ': ' + IntToHex(fEId, 8));
{$ENDIF}
end;

procedure TClient.c23_EntityHeadLook;
var
  fEId: LongWord;
  fEntity: IEntity;
begin
  fLock.Enter;
  try

    // EID
    fEId := fIOHandler.ReadLongWord();

    if not Entitys.TryGetValue(fEId, fEntity) then begin
      fEntity := TEntity.Create;
      Entitys.Add( fEId, fEntity );
    end;

    // Yaw
    fEntity.Yaw := fIOHandler.ReadByte() * 360 / 255;

  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdEntityHeadLook) + ': ' + IntToHex(fEId, 8));
{$ENDIF}
end;

procedure TClient.c26_EntityStatus;
var
  fEId: LongWord;
  fEntity: IEntity;
begin
  fLock.Enter;
  try

    // Entity ID
    fEId := fIOHandler.ReadLongWord();

    if not Entitys.TryGetValue(fEId, fEntity) then begin
      fEntity := TEntity.Create;
      Entitys.Add( fEId, fEntity );
    end;

    // Status
    fEntity.LastStatus := fIOHandler.ReadByte();

  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdEntityStatus) + ': ' + IntToHex(fEId, 8));
{$ENDIF}
end;

procedure TClient.c27_AttachEntity;
var
  fEId: LongWord;
  fEntity: IEntity;
begin
  fLock.Enter;
  try
    // Entity ID
    fEId := fIOHandler.ReadLongWord();

    if not Entitys.TryGetValue(fEId, fEntity) then begin
      fEntity := TEntity.Create;
      Entitys.Add( fEId, fEntity );
    end;

    // Vehicle ID
    fEntity.AttachVehile := fIOHandler.ReadLongWord();

    // Leashe
    if fServerVer >= 62 then
      fEntity.Leashe := fIOHandler.ReadByte <> 0;

  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdAttachEntity) + ': ' + IntToHex(fEId, 8));
{$ENDIF}
end;

procedure TClient.c28_EntityMetadata;
var
  fEId: LongWord;
  fEntity: IEntity;
begin
  fLock.Enter;
  try

    // Entity ID
    fEId := fIOHandler.ReadLongWord();

    if not Entitys.TryGetValue(fEId, fEntity) then begin
      fEntity := TEntity.Create;
      Entitys.Add( fEId, fEntity );
    end;

    // Meta
    ReadMetaData( fEntity );

  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdEntityMetadata) + ':' + IntToHex(fEId, 8));
{$ENDIF}
end;

procedure TClient.c29_EntityEffect;
var
  fEId: LongWord;
  fEntity: IEntity;
  fEffect: Byte;
begin
  fLock.Enter;
  try
    // Entity ID
    fEId := fIOHandler.ReadLongWord();

    if not Entitys.TryGetValue(fEId, fEntity) then begin
      fEntity := TEntity.Create;
      Entitys.Add( fEId, fEntity );
    end;

    // Effect
    fEffect := fIOHandler.ReadByte;

    fEntity.SetEffect( fEffect );

    // Ampliffer
    fIOHandler.ReadByte;

    // Duration
    fIOHandler.ReadSmallInt;

  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog( '#' + GetCmdName(cmdEntityEffect) + ' : ' + IntToStr(fEffect) );
{$ENDIF}
end;

procedure TClient.c2A_RemoveEntityEffect;
var
  fEId: LongWord;
  fEntity: IEntity;
  fEffect: Byte;
begin
  fLock.Enter;
  try

    // Entity ID
    fEId := fIOHandler.ReadLongWord();

    if not Entitys.TryGetValue(fEId, fEntity) then begin
      fEntity := TEntity.Create;
      Entitys.Add( fEId, fEntity );
    end;

    // Effect
    fEffect := fIOHandler.ReadByte;

    fEntity.UnSetEffect( fEffect );

  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog( '#' + GetCmdName(cmdRemoveEntityEffect) + ' : ' + IntToStr(fEffect) );
{$ENDIF}
end;

procedure TClient.c2B_SetExperience;
var
  fExperienceBar: LongWord;
begin
  fLock.Enter;
  try
    // ExperienceBar
    fExperienceBar := fIOHandler.ReadLongWord();
    ExperienceBar := PSingle(@fExperienceBar)^;

    // Level
    Level := fIOHandler.ReadSmallInt();

    // TotalExperience
    TotalExperience := fIOHandler.ReadSmallInt();
  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdSetExperience));
{$ENDIF}
end;

procedure TClient.c2C_EntityProperties();
var
  fEId {, fDW}: LongWord;
  fEntity: IEntity;
  fCount, i: Integer;
  fKey:string;
begin
  if fServerVer < 67 then
    raise Exception.Create('#Invalid command in this version :' + GetSteck() );

  fLock.Enter;
  try
    // Entity ID
    fEId := fIOHandler.ReadLongWord();

    if not Entitys.TryGetValue(fEId, fEntity) then begin
      fEntity := TEntity.Create;
      Entitys.Add( fEId, fEntity );
    end;

    // Count
    fCount := fIOHandler.ReadLongInt();

    for i := 0 to fCount-1 do begin
      // Key
      fKey := ReadString();

      // val1
      {fDW :=} fIOHandler.ReadLongWord();

      // Cal2
      {fDW :=} fIOHandler.ReadLongWord();
    end;

  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog( '#' + GetCmdName(cmdEntityProperties) );
{$ENDIF}
end;

procedure TClient.c32_MapColumnAllocation();
begin
  if fServerVer >= 39 then
    raise Exception.Create('#Old command :' + IntToHex(cmdMapColumnAllocation, 2));

  // X
  fIOHandler.ReadLongInt();

  // Z
  fIOHandler.ReadLongInt();

  // Mode
  fIOHandler.ReadByte();

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdMapColumnAllocation));
{$ENDIF}
end;

procedure TClient.c33_MapChunks;
var
  fX, fZ, fCompressedSize: Integer;
  // fGround_upContinuous:Boolean;
  fPrimaryBitMap { , fAddBitMap } : Word;
  fChunk: TChunk;
  fStrm: TMemoryStream;
  fDecomp: TDecompressionStream;

  i: Integer;
  fTask:ITask;
  fTaskChangeBlocks:ITaskChangeBlocks;
begin
  // X
  fX := fIOHandler.ReadLongInt();

  // Z
  fZ := fIOHandler.ReadLongInt();

  // Ground-up Continuous
  { fGround_upContinuous := } fIOHandler.ReadByte() { <> 0 };

  // Primary BitMap
  fPrimaryBitMap := fIOHandler.ReadWord();

  // Add BitMap
  { fAddBitMap := } fIOHandler.ReadWord();

  // Compressed Size
  fCompressedSize := fIOHandler.ReadLongInt();

  case fServerVer of
    // 1.3
    39..MaxByte:;
    // 1.2
    28..38:begin
      // Unused int
      fIOHandler.ReadLongInt();
    end;
  end;

  // Chunk
  fChunk := Chunks.Chunk(fX, fZ);
  if fChunk = nil then
    fChunk := Chunks.Init(fX, fZ);

  // Array
  fStrm := TMemoryStream.Create;
  fLock.Enter; //###
  try
    fIOHandler.ReadStream(fStrm, fCompressedSize);
    fStrm.Position := 0;

    try
      fDecomp := TDecompressionStream.Create(fStrm);
      try
        // Data
        for i := 0 to 15 do begin
          // If the bitmask indicates this chunk has been sent...
          if (fPrimaryBitMap and (1 shl i)) = 0 then
            Continue;

          fDecomp.ReadBuffer(fChunk.Data[i * cBlockSize], cBlockSize);
        end;

        // Meta
        for i := 0 to 15 do begin
          // If the bitmask indicates this chunk has been sent...
          if (fPrimaryBitMap and (1 shl i)) = 0 then
            Continue;

          fDecomp.ReadBuffer(fChunk.Meta[i * cMetaDataSize], cMetaDataSize);
        end;

        { // Light
          fDecomp.Seek( cLightDataSize, soCurrent );

          // Sky light
          fDecomp.Seek( cSkyLightDataSize, soCurrent );

          // Added map
          if (fAddBitMap and (1 shl i)) <> 0 then
          fDecomp.Seek( cAddDataSize, soCurrent );

          // Read biom
          if fGround_upContinuous then
          fDecomp.Seek( cBiomeSize, soCurrent ); }

      finally
        fDecomp.Free;
      end;

    except
      raise Exception.Create('Error decompress buffer - '+GetCmdName(cmdMapChunks)+' : '+GetSteck());
    end;

  finally
    fStrm.Free;
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdMapChunks) + ' X:' + IntToStr(fX) + ' Z:' +
    IntToStr(fZ));
{$ENDIF}

  // Tasks event
  for i := 0 to fTasks.Count-1 do begin
    fTask := fTasks.Items[i];

    if fTask.QueryInterface(ITaskChangeBlocks, fTaskChangeBlocks ) = S_OK then
      fTaskChangeBlocks.BlockChangeMulti(fX, fZ);
  end;
end;

procedure TClient.c34_MultiBlockChange;
var
  fX, fZ, fSize, fPos: Integer;
  fRecordCount: SmallInt;
  fBytes: TBytes;
  fChunk: TChunk;
  i, j: Integer;
  fAPos:TAbsPos;

  fChX, fChY, fChZ, fBlockId, fBlockMeta: Byte;

  fTask:ITask;
  fTaskChangeBlocks:ITaskChangeBlocks;
begin
  // X
  fX := fIOHandler.ReadLongInt();

  // Z
  fZ := fIOHandler.ReadLongInt();

  // Record Count
  fRecordCount := fIOHandler.ReadSmallInt;

  // Data seize
  fSize := fIOHandler.ReadLongInt();

  // Data
  fIOHandler.ReadBytes(fBytes, fSize);

  fLock.Enter;
  try
    fChunk := Chunks.Chunk(fX, fZ);
    if fChunk = nil then
      fChunk := Chunks.Init(fX, fZ);

    fPos := 0;
    for i := 0 to fRecordCount - 1 do begin
      if fPos + 4 > fSize then begin
        AddLog('E:' + GetCmdName(cmdMultiBlockChange) + ' : 2');
        exit;
      end;

      fChX := fBytes[fPos] shr 4;
      fChZ := fBytes[fPos] and $0F;
      Inc(fPos);

      fChY := fBytes[fPos];
      Inc(fPos);

      fBlockId := fBytes[fPos] shl 4;
      Inc(fPos);
      fBlockId := fBlockId or (fBytes[fPos] shr 4);

      fBlockMeta := fBytes[fPos] and $0F;
      Inc(fPos);

      fAPos := AbsPos(fChX, fChY, fChZ);

      fChunk.SetBlockChunk(fAPos, fBlockId, fBlockMeta);

      // Tasks event
      for j := 0 to fTasks.Count-1 do begin
        fTask := fTasks.Items[j];

        if fTask.QueryInterface(ITaskChangeBlocks, fTaskChangeBlocks ) = S_OK then
          fTaskChangeBlocks.BlockChange( fAPos );
      end;
    end;
  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdMultiBlockChange));
{$ENDIF}
end;

procedure TClient.c35_BlockChange;
var
  fAPos:TAbsPos;
  fBlockMeta: Byte;
  fBlockType: Word;

  i:Integer;
  fTask:ITask;
  fTaskChangeBlocks:ITaskChangeBlocks;
begin
  // X
  fAPos.X := fIOHandler.ReadLongInt();

  // Y
  fAPos.Y := fIOHandler.ReadByte();

  // Z
  fAPos.Z := fIOHandler.ReadLongInt();

  // Type
  case fServerVer of
    // 1.3
    39..MaxByte:
      fBlockType := fIOHandler.ReadSmallInt();
    // 1.2.5
    else
      fBlockType := fIOHandler.ReadByte();
  end;

  // Meta
  fBlockMeta := fIOHandler.ReadByte();

  // === Operate ===
  fLock.Enter;
  try
    Chunks.SetBlock(fAPos, fBlockType, fBlockMeta);
  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdBlockChange) +
    ' X:' + IntToStr(fAPos.X) +
    ' Z:' + IntToStr(fAPos.Z) +
    ' Y:' + IntToStr(fAPos.Y) +
    ' T:' + IntTohex(fBlockType,2) +
    ' M:' + IntTohex(fBlockMeta,2)
  );
{$ENDIF}

  // Tasks event
  for i := 0 to fTasks.Count-1 do begin
    fTask := fTasks.Items[i];

    if fTask.QueryInterface( ITaskChangeBlocks, fTaskChangeBlocks ) = S_OK then
      fTaskChangeBlocks.BlockChange( fAPos );
  end;
end;

procedure TClient.c36_BlockAction;
begin
  // X
  fIOHandler.ReadLongInt();

  // Y
  fIOHandler.ReadWord();

  // Z
  fIOHandler.ReadLongInt();

  // Byte1
  fIOHandler.ReadByte();

  // Byte2
  fIOHandler.ReadByte();

  case fServerVer of
    39..MaxByte:begin
      // Block ID
      fIOHandler.ReadWord();
    end;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdBlockAction));
{$ENDIF}
end;

procedure TClient.c37_BlockBreakAnimation;
{ var
  fEId:LongWord;
  fX, fY, fZ:Integer;
  fStage:Byte; }
begin
  if fServerVer < 39 then
    raise Exception.Create('#Invalid command in this version :' + GetSteck() );

  // Entity ID
  { fEId := } fIOHandler.ReadLongWord();

  // X
  { fX := } fIOHandler.ReadLongInt();

  // Y
  { fY := } fIOHandler.ReadLongInt();

  // Z
  { fZ := } fIOHandler.ReadLongInt();

  // Stage
  { fStage := } fIOHandler.ReadByte();

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdBlockBreakAnimation));
{$ENDIF}
end;

procedure TClient.c38_MapChunkBulk;
var
  Count: SmallInt;
  Length, i, j, fPos, fDecompSize: Integer;
  fX, fZ: Integer;
  fPrimaryBitMap, fAddBitMap: Word;
  fStrm: TMemoryStream;
  fDecomp: TDecompressionStream;
  fChunk: TChunk;
  fBytes: TBytes;

  fTask:ITask;
  fTaskChangeBlocks:ITaskChangeBlocks;
begin
  if fServerVer < 39 then
    raise Exception.Create('#Invalid command in this version :' + GetSteck() );

  // Chunk Count
  Count := fIOHandler.ReadSmallInt();

  // Chunk data length
  Length := fIOHandler.ReadLongInt();

  // Sky light sent
  if fServerVer >= 51 then
    fIOHandler.ReadByte();

  // Data
  fLock.Enter;
  fStrm := TMemoryStream.Create;
  try
    fIOHandler.ReadStream(fStrm, Length);

    fStrm.Position := 0;
    fDecomp := TDecompressionStream.Create(fStrm);
    try
      try
        fDecompSize := fDecomp.Size;
        SetLength(fBytes, fDecompSize);
        fDecomp.ReadBuffer(fBytes[0], fDecompSize);
      finally
        fDecomp.Free;
      end;
    except
      AddLog('@@@@@@ Error decompres Map Chunk Bulk');
      exit;
    end;

    fPos := 0;

    // Meta information
    for i := 0 to Count - 1 do begin

      // X
      fX := fIOHandler.ReadLongInt();

      // Z
      fZ := fIOHandler.ReadLongInt();

      // Primary BitMap
      fPrimaryBitMap := fIOHandler.ReadWord();

      // Add BitMap
      fAddBitMap := fIOHandler.ReadWord();
      if fAddBitMap <> 0 then
        raise Exception.Create('@@@');

      // Init
      fChunk := Chunks.Chunk(fX, fZ);
      if fChunk = nil then
        fChunk := Chunks.Init(fX, fZ);

      // Data
      for j := 0 to 15 do begin
        // If the bitmask indicates this chunk has been sent...
        if (fPrimaryBitMap and (1 shl j)) = 0 then
          Continue;

        Move(fBytes[fPos], fChunk.Data[j * cBlockSize], cBlockSize);
        Inc(fPos, cBlockSize);
      end;

      // Meta
      for j := 0 to 15 do begin
        // If the bitmask indicates this chunk has been sent...
        if (fPrimaryBitMap and (1 shl j)) = 0 then
          Continue;

        Move(fBytes[fPos], fChunk.Meta[j * cMetaDataSize], cMetaDataSize);
        Inc(fPos, cMetaDataSize);
      end;

      // Light
      for j := 0 to 15 do begin
        // If the bitmask indicates this chunk has been sent...
        if (fPrimaryBitMap and (1 shl j)) = 0 then
          Continue;

        Inc(fPos, cLightDataSize);
      end;

      // Sky light
      for j := 0 to 15 do begin
        // If the bitmask indicates this chunk has been sent...
        if (fPrimaryBitMap and (1 shl j)) = 0 then
          Continue;

        Inc(fPos, cSkyLightDataSize);
      end;

      // Biom
      Inc(fPos, cBiomeSize);

      //=== Chanks ===
      // Tasks event
      for j := 0 to fTasks.Count-1 do begin
        fTask := fTasks.Items[j];

        try
          if fTask.QueryInterface( ITaskChangeBlocks, fTaskChangeBlocks ) = S_OK then
            fTaskChangeBlocks.BlockChangeMulti( fX, fZ );
        except
          fTask.Name;
        end;
      end;
    end;

  finally
    fStrm.Free;
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdMapChunkBulk));
{$ENDIF}
end;

procedure TClient.c3C_Explosion;
var
  fV:Int64;
//  fDW:LongWord;

  fPos:TPos;
  aPos, bPos:TAbsPos;

  lX,lY,lZ:ShortInt;

//  fRadius: Single;
  i, j, fCount: Integer;

{  fData2: TData;
  fBytes: TBytes;
  fSize: Integer;}

  fTask:ITask;
  fTaskChangeBlocks:ITaskChangeBlocks;
  fList:TList<TAbsPos>;
begin
  fList := TList<TAbsPos>.Create;
  try
    // X
    fV := fIOHandler.ReadInt64();
    fPos.X := PDouble( @fV )^;

    // Y
    fV := fIOHandler.ReadInt64();
    fPos.Y := PDouble( @fV )^;

    // Z
    fV := fIOHandler.ReadInt64();
    fPos.Z := PDouble( @fV )^;

    // Radius
    {fDW :=} fIOHandler.ReadLongWord();
    //fRadius := PSingle( @fDW )^;

    // Count
    fCount := fIOHandler.ReadLongInt();

    aPos := PosToAbsPos( fPos );

    // Records
    for i := 0 to fCount-1 do begin
      lx := ShortInt( fIOHandler.ReadByte() );
      ly := ShortInt( fIOHandler.ReadByte() );
      lz := ShortInt( fIOHandler.ReadByte() );

      bPos.X := aPos.X + lx;
      bPos.Y := aPos.Y + ly;
      bPos.Z := aPos.Z + lz;

      Chunks.SetBlock( bPos, btAir, 0 );

      fList.Add( bPos );
    end;

    // Player Motion
    //@@@
    fIOHandler.ReadLongWord();
    fIOHandler.ReadLongWord();
    fIOHandler.ReadLongWord();

    AddLog('#' + GetCmdName(cmdExplosion));

    // Tasks event
    for i := 0 to fList.Count-1 do
      for j := 0 to fTasks.Count-1 do begin
        fTask := fTasks.Items[j];

        if fTask.QueryInterface(ITaskChangeBlocks, fTaskChangeBlocks ) = S_OK then
          fTaskChangeBlocks.BlockChange( fList.Items[i] );
      end;

  finally
    fList.Free;
  end;
end;

procedure TClient.c3D_SoundParticleEffect;
{ var
  EffectId:Integer;
  X:Integer;
  Y:byte;
  Z:Integer;
  Data:Integer;
  NoVolDec:byte; }
begin
  // Entity ID
  { EffectId := } fIOHandler.ReadLongWord();

  // X
  { X := } fIOHandler.ReadLongInt();

  // Y
  { Y := } fIOHandler.ReadByte();

  // Z
  { Z := } fIOHandler.ReadLongInt();

  // Data
  { Data := } fIOHandler.ReadLongInt();

  // No Volume Decrease
  if fServerVer >= 47 then
    { NoVolDec := } fIOHandler.ReadByte();

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdSoundParticleEffect));
{$ENDIF}
end;

procedure TClient.c3E_NamedSoundEffect;
{ var
  str:string;
  fX, fY, fZ:Integer;
  fVolume:LongWord; // Folat
  fPitch:byte; }
begin
  if fServerVer < 39 then
    raise Exception.Create('#Invalid command in this version :' + GetSteck() );

  // Sound name
  { str := } ReadString();

  // X
  { fX := } fIOHandler.ReadLongInt();

  // Y
  { fY := } fIOHandler.ReadLongInt();

  // Z
  { fZ := } fIOHandler.ReadLongInt();

  // Volume
  { fVolume := } fIOHandler.ReadLongWord();

  // Pitch
  { fPitch := } fIOHandler.ReadByte();

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdNamedSoundEffect));
{$ENDIF}
end;

procedure TClient.c46_ChangeGameState;
var
  fReason: Byte;
  str: string;
begin
  fLock.Enter;
  try

    // Reason
    fReason := fIOHandler.ReadByte();

    // Game mode
    GameMode := fIOHandler.ReadByte();

  finally
    fLock.Leave;
  end;

  case fReason of
    0:
      str := 'Invalid Bed';
    1:
      str := 'Begin raining';
    2:
      str := 'End raining';
    3:
      str := 'Change game mode';
    4:
      str := 'Enter credits';
    else
      str := '???';
  end;

  AddLog('#' + GetCmdName(cmdChangeGameState) + ':' + str);
end;

procedure TClient.c47_Thunderbolt;
type
  TData = packed record
    EID: LongWord;
    Unknown: ByteBool;
    X: Integer;
    Y: Integer;
    Z: Integer;
  end;

var
  fData: TData;
begin
  // Data
  ReadBuffer(@fData, SizeOf(fData));

  // / cRelativeMovementDiv

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdThunderbolt));
{$ENDIF}
end;

procedure TClient.c64_OpenWindow;

  function IFFnc(Op:boolean; W1, W2:Integer):Integer;
  begin
    if Op then
      Result := W1
    else
      Result := W2;
  end;

var
  fWId, fWCount, fCount: Byte;
  fWType: Integer;
  str: string;
  fWnd: IWindow;

  i:Integer;
  fTask:ITask;
  fTaskEnentWindow:ITaskEnentWindow;
begin
  fLock.Enter;
  try
    // Window ID
    fWId := fIOHandler.ReadByte();

    // Window type
    fWType := fIOHandler.ReadByte();

    // Window title
    str := ReadString();

    // Number of Slots
    fWCount := fIOHandler.ReadByte();

    // Use provided window title
    if fServerVer >= 52 then begin
      fIOHandler.ReadByte(); //@@@
    end;

    // Get wind
    if not Windows.TryGetValue(fWId, fWnd) then begin
      if fWId = 0 then
        fCount := fWCount
      else
        fCount := fWCount + 37;
      fWnd := TWindow.Create(fWCount, fCount, str, fWType);
      Windows.Add(fWId, fWnd);
    end;
  finally
    fLock.Leave;
  end;

  if Assigned(fOnOpenWindow) then
    fOnOpenWindow(fWId);

  {$IFDEF SHOW_SERVERCMD_ALL}
    AddLog('#' + GetCmdName(cmdOpenWindow) + ': ' + str);
  {$ENDIF}

  // Tasks event
  for i := 0 to fTasks.Count-1 do begin
    fTask := fTasks.Items[i];

    if fTask.QueryInterface( ITaskEnentWindow, fTaskEnentWindow ) = S_OK then
      fTaskEnentWindow.OpenWindow( fWId );
  end;
end;

procedure TClient.c65_CloseWindow;
var
  fWId: Byte;

  i:Integer;
  fTask:ITask;
  fTaskEnentWindow:ITaskEnentWindow;
begin
  // Window ID
  fWId := fIOHandler.ReadByte();

  // === Operate ===
  if Assigned(fOnCloseWindow) then
    fOnCloseWindow(fWId);

  fLock.Enter;
  try
    Windows.Remove(fWId);
  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdCloseWindow));
{$ENDIF}

  // Tasks event
  for i := 0 to fTasks.Count-1 do begin
    fTask := fTasks.Items[i];

    if fTask.QueryInterface( ITaskEnentWindow, fTaskEnentWindow ) = S_OK then
      fTaskEnentWindow.CloseWindow( fWId );
  end;
end;

procedure TClient.c67_SetSlot();
var
  fWId: Byte;
  fSlotInd: SmallInt;

  fWnd: IWindow;
  fSlot: ISlot;
{$IFDEF SHOW_SERVERCMD_ALL}
  str: string;
{$ENDIF}
begin
  // Window ID
  fWId := fIOHandler.ReadByte();

  // Slot
  fSlotInd := fIOHandler.ReadSmallInt();

  // === Operate ===
  fLock.Enter;
  try
    if fWId = 255 then
      fSlot := Cursor

    else begin
      // Get wnd
      if not Windows.TryGetValue(fWId, fWnd) then begin
        if fWId <> 0 then
          raise Exception.Create('Error Message');

        fWnd := TWindow.Create(45, 45, 'Inventary', -1);
        Windows.Add(fWId, fWnd);
      end;

      // Get slot
      fSlot := fWnd.GetSlot( fSlotInd );
    end;

    // Slot data
    {$IFDEF SHOW_SERVERCMD_ALL}
      str :=
    {$ENDIF}
    ReadSlotData(fSlot);

  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  str := '#' + GetCmdName(cmdSetSlot) + '  WID:' + IntToStr(fWId) + ', Slot:' + IntToStr(fSlotInd)+' '+str;
  AddLog(str);
{$ENDIF}
end;

procedure TClient.c68_SetWindowItems;
var
  i, fCount: SmallInt;
  fWId: Byte;
  fWnd: IWindow;
  fSlot:ISlot;
begin
  // Window ID
  fWId := fIOHandler.ReadByte();

  // Count
  fCount := SmallInt(fIOHandler.ReadWord());

  // === Operate ===
  fLock.Enter;
  try
    // Get wind
    if not Windows.TryGetValue(fWId, fWnd) then begin
      if fWId <> 0 then
        raise Exception.Create('Error Message');

      fWnd := TWindow.Create(45, 45, 'Inventary', -1);
      Windows.Add(fWId, fWnd);
    end;

    // Slot data
    for i := 0 to fCount - 1 do begin
      fSlot := fWnd.GetSlot( i );
      ReadSlotData( fSlot );
    end;

  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdSetWindowItems) + ' WID:' + IntToStr(fWId) +' Cnt:' + IntToStr(fCount));
{$ENDIF}
end;

procedure TClient.c69_UpdateWindowProperty;
type
  TData = packed record
    WId: Byte;
    Prop: SmallInt;
    Value: SmallInt;
  end;

var
  fData: TData;
begin
  // Data
  ReadBuffer(@fData, SizeOf(fData));

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdUpdateWindowProperty));
{$ENDIF}
end;

procedure TClient.c6A_ConfirmTransaction;
var
  fWId: Byte;
  ActionNumber: Word;
  Accepted: Byte;

  i:Integer;
  fTask:ITask;
  fTaskEnentWindow:ITaskEnentWindow;
begin
  // Window ID
  fWId := fIOHandler.ReadByte();

  // Data
  ActionNumber := fIOHandler.ReadWord();

  // Accept
  Accepted := fIOHandler.ReadByte();

//{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdConfirmTransaction) +
    '; WId: ' + IntToStr(fWId) +
    '; ActNum:' + IntToStr(ActionNumber) +
    '; Accept:' + IntToStr(Accepted));
//{$ENDIF}

  // --- Send to server ---
  // Cmd
  fTCPClient.Socket.Write(cmdConfirmTransaction);

  // WId
  fTCPClient.Socket.Write(fWId);

  // Data
  fTCPClient.Socket.Write(ActionNumber);

  // Accept
  fTCPClient.Socket.Write(Accepted);

  // --- Event confirm ---
  fLock.Enter;
  try
    if (ActionNumber = fTransId) and (Accepted <> 0) then begin

      fClbTo.Put( fClbFrom, fClbCount );

      if fClbInv <> nil then
        fClbInv.Put( fClbTo, fClbCount );

      fClbFrom.Count := fClbFrom.Count - fClbCount;

      if fClbFrom.Count = 0 then
        fClbFrom.Empty;
    end;
  finally
    fLock.Leave;
  end;

  // Tasks event
  for i := 0 to fTasks.Count-1 do begin
    fTask := fTasks.Items[i];

    if fTask.QueryInterface( ITaskEnentWindow, fTaskEnentWindow ) = S_OK then
      fTaskEnentWindow.ConfirmTransaction( fWId, ActionNumber, Accepted <> 0 );
  end;
end;

procedure TClient.c6B_CreativeInventoryAction;
var
  fSlotInd:SmallInt;
  fWnd: IWindow;
  fSlot: ISlot;
begin
  fLock.Enter;
  try
    // Get wnd
    if not Windows.TryGetValue(0, fWnd) then begin
      fWnd := TWindow.Create(45, 45, 'Inventary', -1);
      Windows.Add(0, fWnd);
    end;

    // Slot
    fSlotInd := fIOHandler.ReadSmallInt();

    // Get slot
    fSlot := fWnd.GetSlot( fSlotInd );

    // Slot
    ReadSlotData( fSlot );

  finally
    fLock.Leave;
  end;

  AddLog('#' + GetCmdName(cmdCreativeInventoryAction));
end;

procedure TClient.c82_UpdateSign;
{ var
  fX:Integer;
  fY:SmallInt;
  fZ:Integer; }
begin
  // X
  { fX := } fIOHandler.ReadLongInt();

  // Y
  { fY := } fIOHandler.ReadSmallInt();

  // Z
  { fZ := } fIOHandler.ReadLongInt();

  // Text1
  ReadString();

  // Text2
  ReadString();

  // Text3
  ReadString();

  // Text4
  ReadString();

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdUpdateSign));
{$ENDIF}
end;

procedure TClient.c83_ItemData;
var
  fBuf: TBytes;
  { fItemType:SmallInt;
    fItemId:SmallInt; }
  Len: Integer;
begin
  // Item Type
  { fItemType := } fIOHandler.ReadSmallInt();

  // Item ID
  { fItemId := } fIOHandler.ReadSmallInt();

  // Text len
  if fServerVer >= 49 then
    Len := fIOHandler.ReadSmallInt()
  else
    Len := fIOHandler.ReadByte();

  // Text
  fIOHandler.ReadBytes(fBuf, Len);

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdItemData));
{$ENDIF}
end;

procedure TClient.c84_UpdateTileEntity;
var
//  fX, fZ: Integer;
//  fY: SmallInt;
//  fAction: Byte;
  fLength: SmallInt;
  fStrm: TMemoryStream;
//  str: string;
begin
  // X
  {fX :=} fIOHandler.ReadLongInt();

  // Y
  {fY :=} fIOHandler.ReadSmallInt();

  // Z
  {fZ :=} fIOHandler.ReadLongInt();

  // Action
  {fAction :=} fIOHandler.ReadByte();

  // Length
  fLength := fIOHandler.ReadSmallInt();

  // Array
  if fLength <> 0 then begin
    fStrm := TMemoryStream.Create;
    try
      fIOHandler.ReadStream(fStrm, fLength);

      // @@@
    finally
      fStrm.Free;
    end;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog( GetCmdName(cmdUpdateTileEntity) );
{$ENDIF}
end;

procedure TClient.cC8_IncrementStatistic;
// var
// StatisticId:Integer;
// Amount:Byte;
begin
  // StatisticId
  fIOHandler.ReadLongInt();

  // Amount
  fIOHandler.ReadByte();

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdIncrementStatistic));
{$ENDIF}
end;

procedure TClient.cC9_PlayerListItem;
var
  fUserName: string;
  fOnline: Boolean;
  fPing: Word;
  fPlayer: IPlayer;
begin
  // === Read ===
  // Player name
  fUserName := ReadString();

  // Online
  fOnline := fIOHandler.ReadByte() <> 0;

  // Ping
  fPing := fIOHandler.ReadWord();

  // === Operate ===
  fLock.Enter;
  try
    if not Players.TryGetValue(fUserName, fPlayer) then
      fPlayer := nil;

    // Add
    if fOnline then begin
      // New
      if fPlayer = nil then begin
        fPlayer := TPlayer.Create;
        Players.Add(fUserName, fPlayer);
      end;

      fPlayer.Name := fUserName;
      fPlayer.Ping := fPing;
    end
    // Delete
    else if fPlayer <> nil then
      Players.Remove(fUserName);

  finally
    fLock.Leave;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdPlayerListItem));
{$ENDIF}
end;

procedure TClient.cCA_PlayerAbilities;
begin
  case fServerVer of
    // 13w16a
    62..MaxByte:begin
      // Flags
      fIOHandler.ReadByte();

      // Flying speed
      fIOHandler.ReadLongWord();
      //@@@ - Float

      // Walking speed
      fIOHandler.ReadLongWord();
      //@@@ - Float
    end;
    // 1.3 - 1.5
    39..61:begin
      // Flags
      fIOHandler.ReadByte();

      // Flying speed
      fIOHandler.ReadByte();

      // Walking speed
      fIOHandler.ReadByte();
    end;
    // 1.2
    28..38:begin
      // Invulnerability,
      fIOHandler.ReadByte();

      // IsFlying
      fIOHandler.ReadByte();

      // CanFly
      fIOHandler.ReadByte();

      // InstantDestroy
      fIOHandler.ReadByte();
    end;
    else
      raise Exception.Create('#Invalid command in this version :' + GetSteck() );
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdPlayerAbilities));
{$ENDIF}
end;

procedure TClient.cCB_TabComplete();
begin
  if fServerVer < 39 then
    raise Exception.Create('#Invalid command in this version :' + GetSteck() );

  // String
  ReadString();

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdTabComplete));
{$ENDIF}
end;

procedure TClient.cCE_CreateScoreboard;
begin
  if fServerVer < 52 then
    raise Exception.Create('#Invalid command in this version :' + GetSteck() );

  // Scoreboard Name
  ReadString();

  // Scoreboard Display Text
  ReadString();

  // Create/Remove
  fIOHandler.ReadByte();

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdCreateScoreboard));
{$ENDIF}
end;

procedure TClient.cCF_UpdateScore;
begin
  if fServerVer < 52 then
    raise Exception.Create('#Invalid command in this version :' + GetSteck() );

  // Item Name
  ReadString();

  // Update/Remove
  fIOHandler.ReadByte();

  // Score Name
  ReadString();

  // Value
  fIOHandler.ReadLongInt();

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdUpdateScore));
{$ENDIF}
end;

procedure TClient.cD0_DisplayScoreboard;
{$IFDEF SHOW_SERVERCMD_ALL}
var
  str:string;
{$ENDIF}
begin
  if fServerVer < 52 then
    raise Exception.Create('#Invalid command in this version :' + GetSteck() );

  // Position
  fIOHandler.ReadByte();

  // Score Name
  {$IFDEF SHOW_SERVERCMD_ALL}
    str :=
  {$ENDIF}
  ReadString();

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdDisplayScoreboard)+' : '+str);
{$ENDIF}
end;

procedure TClient.cD1_Teams;
var
  fMode:Byte;
  fCnt, i:Integer;
begin
  if fServerVer < 52 then
    raise Exception.Create('#Invalid command in this version :' + GetSteck() );

  // Team Name
  ReadString();

  // Mode
  fMode := fIOHandler.ReadByte();

  case fMode of
    0,2:begin
      // Team Display Name
      ReadString();

      // Team Prefix
      ReadString();

      // Team Suffix
      ReadString();

      // Friendly fire
      fIOHandler.ReadByte();
    end;
  end;

  case fMode of
    0,2,4:begin
      // Player count
      fCnt := fIOHandler.ReadWord();

      // Player array
      for i := 0 to fCnt-1 do
        ReadString();
    end;
  end;

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdTeams));
{$ENDIF}
end;

procedure TClient.cFA_PluginMessage;
var
  fLen: Word;
  fBytes: TBytes;
begin
  // Channel
  ReadString();

  // Length
  fLen := fIOHandler.ReadWord();

  // Data
  fIOHandler.ReadBytes(fBytes, fLen);

  AddLog('#' + GetCmdName(cmdPluginMessage));
end;

procedure TClient.cFD_EncryptionKeyRequest;

{$IFDEF MSCrypt}
  {
    RSA: HCRYPTPROV;
    MyKey: HCRYPTKEY;

    // Open seq
    if not CryptAcquireContext(@RSA, 'myKey', nil, PROV_RSA_FULL, CRYPT_NEWKEYSET) then
    raise Exception.Create('CryptAcquireContext');

    // Generate key pair
    if not CryptGenKey(RSA, CALG_RSA_KEYX, RSA1024BIT_KEY or CRYPT_EXPORTABLE, @MyKey) then
    raise Exception.Create('CryptGenKey'); }

  { if not CryptImportKey(RSA, fPublicKey, fPublicKeyLength, 0, 0, @HPair) then
    raise Exception.Create('CryptAcquireContext'); }
{$ENDIF}

{$IFDEF OpenSSL}
  //========= OpenSSL =====================
var
  rsa: pRSA;

  function GetError(ErrMsg:pBIO):string;
  var
    buff: array [0..1023] of AnsiChar;
  begin
    BIO_reset(ErrMsg);
    BIO_read(ErrMsg, @buff, 1024);
    result := string(buff);
  end;

  function Seq_Init():boolean;
  begin
    rsa := nil;

    result := true;
  end;

  procedure Seq_Final();
  begin
    if rsa <> nil then RSA_free(rsa);
  end;

  procedure Seq_InportPublicKey();
  var
    keyfile: pBIO;
  begin
    keyfile := BIO_new(BIO_s_mem());

    pKey := nil;
    PEM_read_bio_RSAPublicKey(keyfile, nil, nil, );
  end;

  procedure Seq_GenerateKey();
  {var
    ErrMsg: pBIO;
  }
  begin
    {  ErrMsg := nil;

     rsa := RSA_generate_key(1024, RSA_F4, nil, ErrMsg);
     if rsa = nil then
       raise Exception.Create( GetError(ErrMsg) );}
  end;
{$ENDIF}

var
  ServerId: string;
  fPublicKeyLength, fSharedKeyLength, fVerifyTokenLength: SmallInt;
  fPublicKey, fSharedKey, fVerifyToken: TBytes;
  i:Integer;

  b: Byte;
begin
  if fServerVer < 39 then
    raise Exception.Create('#Invalid command in this version :' + GetSteck() );

  // Generate our shared secret
  fSharedKeyLength := 16;
  SetLength(fSharedKey, fSharedKeyLength);

  for i := 0 to fSharedKeyLength-1 do
    fSharedKey[i] := Random(256);

  // Server Id
  ServerId := ReadString();

  // Public key length
  fPublicKeyLength := fIOHandler.ReadSmallInt();

  // Public key
  fIOHandler.ReadBytes(fPublicKey, fPublicKeyLength);

  // Verify Token Length
  fVerifyTokenLength := fIOHandler.ReadSmallInt();

  // Verify token
  fIOHandler.ReadBytes(fVerifyToken, fVerifyTokenLength);

  // Premium
  if (ServerId <> '-') and (ServerId <> '+') then
    raise Exception.Create('Not ended :'+GetSteck());

  // --------------------------------------------------------------------------
  {$IFDEF OpenSSL}
    Seq_Init();
    try
      Seq_InportPublicKey();

//      Seq_GenerateKey();
    finally
      Seq_Final();
    end;
  {$ENDIF}

  // HASH = mcHexDigest()

  { // Cmd
    fTCPClient.Socket.Write(cmdEncryptionKeyResponse);

    // Shared secret length
    fTCPClient.Socket.Write(fSharedKeyLength);

    // Shared secret
    fTCPClient.Socket.Write(fSharedKey);

    // Verify token length
    fTCPClient.Socket.Write(fVerifyTokenLength);

    // Verify token response
    fTCPClient.Socket.Write(fVerifyToken); }

   {fSSL := TIdSSLIOHandlerSocketOpenSSL.Create(fTCPClient);
   fSSL.SSLContext.
   fTCPClient.IOHandler := fSSL;
   fSSL.SSLOptions.Method:= sslvTLSv1;
   fSSL.StartSSL;}

  // === ClientStatuses ===

  // Cmd
  fTCPClient.Socket.Write(cmdClientStatuses);

  // Init
  b := 0;
  fTCPClient.Socket.Write(b);

{$IFDEF SHOW_SERVERCMD_ALL}
  AddLog('#' + GetCmdName(cmdEncryptionKeyRequest));
{$ENDIF}
end;

procedure TClient.cFF_DisconnectKick;
begin
  // Reson
  AddLog('#' + GetCmdName(cmdDisconnectKick) + ': ' + ReadString());
end;

{ TClientInt }

constructor TClientInt.Create(Client: TClient);
begin
  fClient := Client;

  fAdmins := TStringList.Create;
  fAdmins.Text := LowerCase(
    StrUtils.ReplaceStr( GetParam( 'options', 'admins' ), ',', #13#10 )
  );
end;

destructor TClientInt.Destroy;
begin
  fAdmins.Free;

  inherited;
end;

function TClientInt.Health: Single;
begin
  result := fClient.Health;
end;

procedure TClientInt.HeldItemChange(Slot: SmallInt);
begin
  fCLient.HeldItemChange( Slot );
end;

function TClientInt.Food: Integer;
begin
  result := fClient.Food;
end;

function TClientInt.FoodSaturation: Single;
begin
  Result := fClient.FoodSaturation;
end;

function TClientInt.CalckPith(X, Y, Z: Extended): Extended;
begin
  result := fClient.CalckPith(X, Y, Z);
end;

function TClientInt.CalckYaw(X, Z: Extended): Extended;
begin
  result := fClient.CalckYaw(X, Z);
end;

function TClientInt.ClickWindow(WId: Byte; Slot: Word; MB: TMButton; Shift: Boolean):Integer;
begin
  result := fClient.ClickWindow( WId, Slot, MB, Shift );
end;

procedure TClientInt.CloseWindow(WId: Byte);
begin
  fClient.CloseWindow( WId );
end;

procedure TClientInt.AddLog(str: string);
begin
  if Assigned(fLogMsg) then
    fLogMsg( str );
end;

procedure TClientInt.SendEvent(Name, Data:string);
begin
  fClient.fTasks.SendEvent( Name, Data );
end;

function TClientInt.GetPlayer(Title:string):IPlayer;
begin
  if not fClient.Players.TryGetValue(Title, result) then
    result := nil;
end;

function TClientInt.GetEntity( EID:LongWord ):IEntity;
begin
  if not fClient.Entitys.TryGetValue( EID, result ) then
    result := nil;
end;

function TClientInt.GetNearEntity(Pos:TPos; EType: TEntityType; SubType:Byte; MaxDistance:Extended; var Distance: Extended): IEntity;
var
  fEPair:TEntityPair;
  fDistance:Extended;
begin
  result := nil;

  fClient.fLock.Enter;
  try
    Distance := MaxDistance+1;

    for fEPair in fClient.Entitys do begin
      if fEPair.Value.EType <> EType then continue;
      if fEpair.Value.SubType <> SubType then continue;

      fDistance := GetDistance( Pos, fEPair.Value.Pos );
      if fDistance > MaxDistance then Continue;

      if fDistance < Distance then begin
        Distance := fDistance;
        result := fEPair.Value;
      end;
    end;

  finally
    fClient.fLock.Leave;
  end;
end;

procedure TClientInt.GetNearEntitys( Pos:TPos; MaxDistance:Extended; List:TList<IEntity> );
var
  fEPair:TEntityPair;
  fDistance:Extended;
begin
  fClient.fLock.Enter;
  try

    for fEPair in fClient.Entitys do begin

      fDistance := GetDistance( Pos, fEPair.Value.Pos );
      if fDistance > MaxDistance then Continue;

      List.Add( fEPair.Value );
    end;

  finally
    fClient.fLock.Leave;
  end;
end;

procedure TClientInt.LookAt(Pos: TPos);
begin
  if not fClient.IsConnected then Exit;

  fClient.LookAt( Pos );
end;

procedure TClientInt.Animation(Num:Byte);
begin
  fClient.Animation( Num );
end;

procedure TClientInt.Digging(Pos:TAbsPos; Status, Face: Byte);
begin
  fClient.Digging( Pos, Status, Face );
end;

procedure TClientInt.Place(Pos: TAbsPos; Direction, SubX, SubY, SubZ: Byte);
begin
  fClient.Place( Pos, Direction, SubX, SubY, SubZ );
end;

procedure TClientInt.PlayerPosition(X, Y, Z, Stance: Double; Jamp: Boolean);
begin
  fClient.PlayerPosition( X, Y, Z, Stance, Jamp );
end;

procedure TClientInt.PlayerPositionLook(X, Y, Z, Stance: Double; Yaw, Pitch: Single; Jamp: Boolean);
begin
  fClient.PlayerPositionLook(X, Y, Z, Stance, Yaw, Pitch, Jamp);
end;

procedure TClientInt.SendChatMsg(msg: string);
begin
  fClient.SendChatMsg( msg );
end;

function TClientInt.GetParam(Sesion, Ident: string): string;
begin
  result := '';
  if fClient.fIni = nil then exit;
  result := fClient.fIni.ReadString(Sesion, Ident, '')
end;

procedure TClientInt.SetParam(Sesion, Ident, Value: string);
begin
  if fClient.fIni = nil then exit;
  fClient.fIni.WriteString(Sesion, Ident, Value);
end;

procedure TClientInt.DelParam(Sesion, Ident: string);
begin
  if fClient.fIni = nil then exit;
  fClient.fIni.DeleteKey( Sesion, Ident );
end;

function TClientInt.GetPos: TPos;
begin
  result := fClient.Position;
end;

function TClientInt.GetYaw:Extended;
begin
  result := fCLient.Yaw;
end;

function TClientInt.GetUserGroup(UName: string): TUserGroup;
begin
  if fAdmins.IndexOf( LowerCase(UName) ) = -1 then
    result := ugNone
  else
    Result := ugAdmin;
end;

function TClientInt.GetWindow(WId: byte): IWindow;
begin
  if not fClient.Windows.TryGetValue(WId, result) then
    result := nil;
end;

function TClientInt.GetBlock(Pos: TAbsPos; var BlockId: Integer; var Meta: Byte): Boolean;
begin
  result := fClient.Chunks.GetBlock( Pos, BlockId, Meta )
end;

function TClientInt.GetBlockInfo(BlockId:Integer):IBlockInfo;
begin
  result := BloksInfos.GetInfo( BlockId );
end;

initialization
  {$IFDEF OpenSSL}
    OpenSSL_add_all_algorithms;
    OpenSSL_add_all_ciphers;
    OpenSSL_add_all_digests;
    ERR_load_crypto_strings;
  {$ENDIF}

end.
