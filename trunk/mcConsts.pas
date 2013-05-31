unit mcConsts;

interface

const
  // http://mc.kev009.com/Protocol

  // Name
  // Code
  // Server to Client
  // Client to server
  // Version
  // Note

  cmdKeepAlive            = $00;        //  S C
  cmdLogin                = $01;        //  S C
  cmdHandshake            = $02;        //  S C
  cmdChatMessage          = $03;        //  S C
  cmdTimeUpdate           = $04;        //  S
  cmdEntityEquipment      = $05;        //  S
  cmdSpawnPosition        = $06;        //  S
  cmdUseEntity            = $07;        //    C
  cmdUpdateHealth         = $08;        //  S
  cmdRespawn              = $09;        //  S C
  cmdPlayer               = $0A;        //    C
  cmdPlayerPosition       = $0B;        //    C
  cmdPlayerLook           = $0C;        //    C
  cmdPlayerPosition_Look  = $0D;        //  S C
  cmdPlayerDigging        = $0E;        //    C
  cmdPlayerBlockPlacement = $0F;        //    C
  cmdHeldItemChange       = $10;        //    C
  cmdUseBed               = $11;        //  S
  cmdAnimation            = $12;        //  S C
  cmdEntityAction         = $13;        //    C         ???
  cmdSpawnNamedEntity     = $14;        //  S
  cmdSpawnDroppedItem     = $15;        //  S   -51
  cmdCollectItem          = $16;        //  S           Only for animation
  cmdSpawnObjectVehicle   = $17;        //  S
  cmdSpawnMob             = $18;        //  S
  cmdSpawnPainting        = $19;        //  S
  cmdSpawnExperienceOrb   = $1A;        //  S
  cmdSteerVehicle         = $1B;        //    C
  cmdEntityVelocity       = $1C;        //  S
  cmdDestroyEntity        = $1D;        //  S
  cmdEntity               = $1E;        //  S
  cmdEntityRelativeMove   = $1F;        //  S
  cmdEntityLook           = $20;        //  S
  cmdEntityLook_RelativeMove = $21;     //  S
  cmdEntityTeleport       = $22;        //  S
  cmdEntityHeadLook       = $23;        //  S
  cmdEntityStatus         = $26;        //  S
  cmdAttachEntity         = $27;        //  S
  cmdEntityMetadata       = $28;        //  S
  cmdEntityEffect         = $29;        //  S
  cmdRemoveEntityEffect   = $2A;        //  S
  cmdSetExperience        = $2B;        //  S
  cmdEntityProperties     = $2C;        //  S
  cmdMapColumnAllocation  = $32;        //  S   -39     No nide
  cmdMapChunks            = $33;        //  S
  cmdMultiBlockChange     = $34;        //  S
  cmdBlockChange          = $35;        //  S
  cmdBlockAction          = $36;        //  S
  cmdBlockBreakAnimation  = $37;        //  S   39      No nide
  cmdMapChunkBulk         = $38;        //  S   39
  cmdExplosion            = $3C;        //  S
  cmdSoundParticleEffect  = $3D;        //  S           No nide
  cmdNamedSoundEffect     = $3E;        //  S   39      No nide
  cmdChangeGameState      = $46;        //  S
  cmdThunderbolt          = $47;        //  S           No nide
  cmdOpenWindow           = $64;        //  S
  cmdCloseWindow          = $65;        //  S C
  cmdClickWindow          = $66;        //    C
  cmdSetSlot              = $67;        //  S
  cmdSetWindowItems       = $68;        //  S           No nide
  cmdUpdateWindowProperty = $69;        //  S
  cmdConfirmTransaction   = $6A;        //  S C
  cmdCreativeInventoryAction = $6B;     //  S C
  // Enchant Item (0x6C)                //    C
  cmdUpdateSign           = $82;        //  S C         Not ended
  cmdItemData             = $83;        //  S           Not ended
  cmdUpdateTileEntity     = $84;        //  S           Not ended
  cmdIncrementStatistic   = $C8;        //  S           No nide
  cmdPlayerListItem       = $C9;        //  S
  cmdPlayerAbilities      = $CA;        //  S C         Not ended
  cmdTabComplete          = $CB;        //  S C 39      No nide
  cmdClientSettings       = $CC;        //    C 39
  cmdClientStatuses       = $CD;        //    C 39
  cmdCreateScoreboard     = $CE;        //  S   13w04a
  cmdUpdateScore          = $CF;        //  S   13w04a
  cmdDisplayScoreboard    = $D0;        //  S   13w04a
  cmdTeams                = $D1;        //  S   13w05a
  cmdPluginMessage        = $FA;        //  S C         No nide
  cmdEncryptionKeyResponse = $FC;       //    C 39
  cmdEncryptionKeyRequest = $FD;        //  S   39
  cmdServerListPing       = $FE;        //    C         Send byte - receive $FF
  cmdDisconnectKick       = $FF;        //  S C

  cMaxY                   = 255;
  cBlockInCube            = 16;

  cGM_Survival            = 0;
  cGM_Creative            = 1;
  cGM_Adventure           = 2;

  cTickInDay              = 24000;

  cRelativeMovementDiv    = 32;

  btNone                  = -1;
  btAir                   = $00;
  btWood                  = $11;
  btLeaves                = $12;
  btTorch                 = $32;
  btWoodenStairs          = $35;
  btChest                 = $36;
  btWoodenDoor            = $40;
  btLadders               = $41;
  btCobblestoneStairs     = $43;
  btWallMounted           = $44;
  btLever                 = $45;
  btIronDoor              = $47;
  btRedstoneTorch_Off     = $4B;
  btRedstoneTorch_On      = $4C;
  btStoneButton           = $4D;
  btSnow                  = $4E;
  btVines                 = $6A;
  btBrickStairs           = $6C;
  btStoneBrickStairs      = $5D;
  btNetherBrickStairs     = $72;
  btSandstoneStairs       = $80;
  btWoodenButton          = $8F;

// -X        -Z
//    W     N
//       /\
//       \/
//    S     E
//  Z         X

{  bpinEast                = $01;
  bpinWest                = $02;
  bpinSouth               = $03;
  bpinNorth               = $04;
  bpinFloor               = $05;

  bpincSouth              = $01;
  bpincWest               = $02;
  bpincNorth              = $04;
  bpincEast               = $08;}

  cStance = 1.62;

  cWalkPointInterval = 200;

  function GetCmdName(Cmd:Byte):string;
  function CanEnchant(Id:SmallInt):Boolean;

implementation

uses
  SysUtils;

function GetCmdName(Cmd:Byte):string;
begin
  case Cmd of
    cmdKeepAlive:
      result := 'KeepAlive';

    cmdLogin:
      result := 'Login';

    cmdHandshake:
      result := 'Handshake';

    cmdChatMessage:
      result := 'Chat Message';

    cmdTimeUpdate:
      result := 'Time Update';

    cmdEntityEquipment:
      result := 'Entity Equipment';

    cmdSpawnPosition:
      result := 'Spawn Position';

    cmdUseEntity:
      result := 'Use Entity';

    cmdUpdateHealth:
      result := 'Update Health';

    cmdRespawn:
      result := 'Respawn';

    cmdPlayerPosition:
      result := 'Player Position';

    cmdPlayerPosition_Look:
      result := 'Player Position&Look';

    cmdPlayerBlockPlacement:
      result := 'Player block placement';

    cmdUseBed:
      result := 'Use Bed';

    cmdAnimation:
      result := 'Animation';

    cmdEntityAction:
      result := 'Entity Action';

    cmdSpawnNamedEntity:
      result := 'Spawn Named Entity';

    cmdCollectItem:
      result := 'Collect Item';

    cmdSpawnDroppedItem:
      result := 'Spawn Dropped Item';

    cmdSpawnObjectVehicle:
      result := 'Spawn Object Vehicle';

    cmdSpawnMob:
      result := 'Spawn Mob';

    cmdSpawnPainting:
      result := 'Spawn Painting';

    cmdSpawnExperienceOrb:
      result := 'Spawn Experience Orb';

    cmdEntityVelocity:
      result := 'Entity Velocity';

    cmdDestroyEntity:
      result := 'Destroy Entity';

    cmdEntity:
      result := 'Entity';

    cmdEntityRelativeMove:
      result := 'EntityRelativeMove';

    cmdEntityLook:
      result := 'Entity Look';

    cmdEntityLook_RelativeMove:
      result := 'Entity Look and Relative Move';

    cmdEntityTeleport:
      result := 'Entity Teleport';

    cmdEntityHeadLook:
      result := 'Entity Head Look';

    cmdEntityStatus:
      result := 'Entity Status';

    cmdAttachEntity:
      result := 'Attach Entity';

    cmdEntityMetadata:
      result := 'Entity Metadata';

    cmdEntityEffect:
      result := 'Entity Effect';

    cmdRemoveEntityEffect:
      result := 'Remove Entity Effect';

    cmdSetExperience:
      result := 'Set Experience';

    cmdEntityProperties:
      result := 'Entity Properties';

    cmdMapColumnAllocation:
      result := 'Map Column Allocation';

    cmdMapChunks:
      result := 'Map Chunks';

    cmdMultiBlockChange:
      result := 'Multi Block Change';

    cmdBlockChange:
      result := 'Block Change';

    cmdBlockAction:
      result := 'Block Action';

    cmdBlockBreakAnimation:
      result := 'Block Brea kAnimation';

    cmdMapChunkBulk:
      result := 'Map Chunk Bulk';

    cmdExplosion:
      result := 'Explosion';

    cmdSoundParticleEffect:
      result := 'Sound Particle Effect';

    cmdNamedSoundEffect:
      result := 'Named Sound Effect';

    cmdChangeGameState:
      result := 'Change Game State';

    cmdThunderbolt:
      result := 'Thunderbolt';

    cmdOpenWindow:
      result := 'Open Window';

    cmdCloseWindow:
      result := 'Close Window';

    cmdSetSlot:
      Result := 'Set Slot';

    cmdSetWindowItems:
      result := 'Set Window Items';

    cmdUpdateWindowProperty:
      result := 'Update Window Property';

    cmdConfirmTransaction:
      result := 'Confirm Transaction';

    cmdCreativeInventoryAction:
      result := 'Creative Inventory Action';

    cmdUpdateSign:
      result := 'Update Sign';

    cmdItemData:
      result := 'Item Data';

    cmdUpdateTileEntity:
      result := 'Update Tile Entity';

    cmdIncrementStatistic:
      result := 'Increment Statistic';

    cmdPlayerListItem:
      result := 'Player List Item';

    cmdPlayerAbilities:
      result := 'Player Abilities';

    cmdTabComplete:
      result := 'Tab Complete';

    cmdCreateScoreboard:
      result := 'Create Scoreboard';

    cmdUpdateScore:
      result := 'Update Score';

    cmdDisplayScoreboard:
      result := 'Display Scoreboard';

    cmdTeams:
      result := 'Teams';

    cmdPluginMessage:
      result := 'Plugin Message';

    cmdEncryptionKeyRequest:
      result := 'Encryption Key Request';

    cmdDisconnectKick:
      result := 'Disconnect/Kick';

    else
      result := '?:'+IntToHex(Cmd, 2);
  end;
end;

function CanEnchant(Id:SmallInt):Boolean;
begin
  case Id of
     256..259,
     267..279,
     283..286,
     290..294,
     298..317,
     261, 359, 346:
       Result := True;
     else
       Result := false;
  end;
end;

end.
