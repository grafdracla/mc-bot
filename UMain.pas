unit UMain;

interface

//{$DEFINE OpenGL}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.Buttons, Vcl.Samples.Spin, Vcl.Grids, Vcl.Menus,
  IniFiles,

  Generics.Collections,

  IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdIOHandler,

  mcTypes,

  {$IFDEF OpenGL}
    uRender_OpenGL,
  {$ELSE}
    uRender_25D,
  {$ENDIF}

  uConnection,
  uPlugins,
  uRenderUtils,

  uPlayer, uTasks, IdLogBase, IdLogFile, IdIntercept,
  IdInterceptSimLog;

const
  WM_USEREVENT  = WM_USER + $100;

type
  TMain = class(TForm)
    BConnect: TButton;
    PControl: TPanel;
    PConrol: TPanel;
    EText: TEdit;
    BDo: TButton;
    CbScroll: TCheckBox;
    Timer: TTimer;
    Panel2: TPanel;
    MState: TMemo;
    CbJamp: TCheckBox;
    EYaw: TEdit;
    EPitch: TEdit;
    EX: TEdit;
    EY: TEdit;
    EZ: TEdit;
    EStance: TEdit;
    BBGet: TBitBtn;
    BPosLook: TButton;
    SBUp: TSpeedButton;
    SBLeft: TSpeedButton;
    SBRight: TSpeedButton;
    SBDown: TSpeedButton;
    PCMain: TPageControl;
    TSLog: TTabSheet;
    Mlines: TMemo;
    TSMap: TTabSheet;
    PLogCtrl: TPanel;
    BRespawn: TButton;
    BLookAt: TButton;
    SBY: TSpinButton;
    LVUsers: TListView;
    SBCHangeShield: TSpeedButton;
    EActiveSlot: TEdit;
    tsTSTasks: TTabSheet;
    lvTVTasks: TListView;
    btnBGoto: TButton;
    BInventory: TButton;
    btnUp: TSpeedButton;
    btnDown: TSpeedButton;
    BAnimation: TButton;
    EAnimation: TEdit;
    Panel1: TPanel;
    BSendEvent: TButton;
    BFeller: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure BConnectClick(Sender: TObject);
    procedure BDoClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure BBGetClick(Sender: TObject);
    procedure BMoveClick(Sender: TObject);
    procedure SBMoveClick(Sender: TObject);
    procedure SBMapUpdateClick(Sender: TObject);
    procedure ETextKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SBCHangeShieldClick(Sender: TObject);
    procedure BRespawnClick(Sender: TObject);
    procedure BLookAtClick(Sender: TObject);
    procedure SBYUpClick(Sender: TObject);
    procedure SBYDownClick(Sender: TObject);
    procedure BInventoryClick(Sender: TObject);
    procedure btnBGotoClick(Sender: TObject);
    procedure BAnimationClick(Sender: TObject);
    procedure BSendEventClick(Sender: TObject);
    procedure BFellerClick(Sender: TObject);
  private
    fRender:IRender;

    fHost: string;
    fPort: Integer;
    fUser: string;

    fConfig: TIniFile;

    fPath: TPath;

    procedure DoTerminate(Sender: TObject);
    procedure DoChangeConnection(Sender: TObject);
    procedure DoChangePosition(Sender: TObject);
    procedure DoOpenWind(WID: Byte);
    procedure DoCloseWind(WID: Byte);

    function  GetCursorPos:TPos;
    procedure SetCursorPos(Pos:TPos);

    procedure WMUserEvent(var Msg: TMessage); message WM_USEREVENT;
  public
    fClient: TClient;
    fTasks:TTasks;

    procedure AddLog(str: string);
  end;

var
  Main: TMain;

implementation

uses
  SyncObjs,
  math,
  Types,

  qSysUtils,
  aA,

  mcConsts,
  uEntity,
  uChunk,
  uIBase,
  uPick,
  uWind,
  dWindow,

  uSys_Login,

  uCmd_Walk,
  uCmd_Digg,
  uCmd_Points,

  uIdle_Gravitation,
  uIdle_LookAtPlayers,
  uIdle_GetDropItems,

  uWork_GoWithMe,
  uWork_Goto,
  uWork_Feller,

  uNeed_Eat;

{$R *.dfm}

procedure TMain.FormCreate(Sender: TObject);
var
  fini: TIniFile;
  iClient:TClientInt;
  fDir: String;
  fSes:TStringList;

  fCmd_Walk:TCmd_Walk;
  i: Integer;

  fRenderParams:TRenderParams;
begin
  Randomize();

  fDir := ExtractFilePath(ParamStr(0));

  fConfig := TIniFile.Create(fDir + 'config.ini');

  {$IFDEF OpenGL}
    fRender := TRender_OpenGL.Create(TSMap);
  {$ELSE}
    fRender := TRender_25D.Create(TSMap);
  {$ENDIF}

  fHost := fConfig.ReadString('server', 'host', '');
  fPort := fConfig.ReadInteger('server', 'port', 25565);
  fUser := fConfig.ReadString('server', 'user', '');
//    fPassword := fConfig.ReadString('server', 'password', '');

  fini := TIniFile.Create(fDir + 'bloks.ini');
  try
    BloksInfos.LoadData(fini);
  finally
    fini.Free;
  end;

  fini := TIniFile.Create(fDir + 'enttitys.ini');
  try
    EntityInfos.LoadData(fini);
  finally
    fini.Free;
  end;

  fPath := nil;

  // Client
  fClient := TClient.Create;
  fClient.OnLog := AddLog;
  fClient.OnTerminate := DoTerminate;
  fClient.OnChangeConnection := DoChangeConnection;
  fClient.OnChangePosition := DoChangePosition;
  fClient.OnOpenWindow := DoOpenWind;
  fClient.OnCloseWindow := DoCloseWind;

  fClient.Host := fHost;
  fClient.Port := fPort;
  fClient.UserName := fUser;

  fClient.fIni := fConfig;

  iClient := TClientInt.Create(fClient);
  iClient.OnLogMsg := AddLog;

  // Init render
  fRenderParams.Client := iClient;
  fRenderParams.GetCursorPos := GetCursorPos;
  fRenderParams.SetCursorPos := SetCursorPos;
  fRender.Init( fRenderParams );

  // Tasks
  fTasks := TTasks.Create( );
  fTasks.OnLogMsg := AddLog;

  fClient.fTasks := fTasks;

  fTasks.Add( TSys_Login.Create(iClient) );

  // Idle
  fTasks.Add( TIdle_Gravitation.Create(iClient) );
  fTasks.Add( TIdle_LookAtPlayer.Create(iClient) );

  // Pasive
  fTasks.Add( TPasive_GetDropItems.Create(iClient) );

  // Cmd
  fCmd_Walk := TCmd_Walk.Create(iClient);
  fPath := fCmd_Walk.Path;
  fTasks.Add( fCmd_Walk );

  fTasks.Add( TCmd_Digg.Create(iClient) );

  fTasks.Add( TCmd_Points.Create(iClient) );

  // Work
  fTasks.Add( TWork_Goto.Create(iClient) );
  fTasks.Add( TWork_GoWithMe.Create(iClient) );
  fTasks.Add( TWork_Feller.Create(iClient) );

  // Need
  fTasks.Add( TNeed_eat.Create(iClient) );

  // Off tasks
  fSes := TStringList.Create;
  try
    fConfig.ReadSection('tasks', fSes);

    for i := 0 to fSes.Count-1 do
      if fConfig.ReadString('tasks', fSes.Strings[i], 'on') = 'off' then
        fTasks.Remove( fSes.Strings[i] );
  finally
    fSes.Free;
  end;

  fTasks.SendEvent('state', 'idle');
end;

procedure TMain.FormDestroy(Sender: TObject);
begin
  if Assigned(fClient) then
    fClient.Terminate;

  fTasks.Free;

  fConfig.Free;

  fRender := nil;
end;

function TMain.GetCursorPos(): TPos;
begin
  result.X := StrToFloat(EX.Text);
  result.Y := StrToFloat(EY.Text);
  result.Z := StrToFloat(EZ.Text);
end;

procedure TMain.SetCursorPos(Pos:TPos);
begin
  EX.Text := FloatToStr( Pos.X );
  EY.Text := FloatToStr( Pos.Y );
  EZ.Text := FloatToStr( Pos.Z );
end;

procedure TMain.BConnectClick(Sender: TObject);
var
  fServVer:Byte;
begin
  if not fClient.IsConnected then begin
    fServVer := fConfig.ReadInteger( 'server', 'ver', 0 );

    fClient.Connect( fServVer );
  end
  else
    fClient.Disconect;
end;

procedure TMain.AddLog(str: string);
begin
  if not CbScroll.Checked then
    exit;

  Mlines.Lines.Add(str);
  // Mlines.ScaleBy(Mlines.Lines.Count, 0);

  SendMessage(Mlines.Handle, EM_LINESCROLL, 0, Mlines.Lines.Count);
end;

procedure TMain.BDoClick(Sender: TObject);
begin
  fClient.SendChatMsg(EText.Text);

  EText.Text := '';
end;

procedure TMain.BAnimationClick(Sender: TObject);
var
  fN:Integer;
begin
  if not isNum(EAnimation.Text, fN) then exit;

  fClient.Animation( fN );
end;

procedure TMain.BBGetClick(Sender: TObject);
begin
  if not EX.Focused then
    EX.Text := FloatToStr(fClient.Position.X);

  if not EY.Focused then
    EY.Text := FloatToStr(fClient.Position.Y);

  if not EZ.Focused then
    EZ.Text := FloatToStr(fClient.Position.Z);

  if not EStance.Focused then
    EStance.Text := FloatToStr(fClient.Stance);

  if not EYaw.Focused then
    EYaw.Text := FloatToStr(fClient.Yaw);

  if not EPitch.Focused then
    EPitch.Text := FloatToStr(fClient.Pitch);

  if not CbJamp.Focused then
    CbJamp.Checked := fClient.jamp;
end;

procedure TMain.BMoveClick(Sender: TObject);
var
  fX, fY, fZ, fStance: Extended;
  fYaw, fPitch: Extended;
begin
  fX := StrToFloat(EX.Text);
  fY := StrToFloat(EY.Text);
  fZ := StrToFloat(EZ.Text);
  fStance := StrToFloat(EStance.Text);

  fYaw := StrToFloat(EYaw.Text);
  fPitch := StrToFloat(EPitch.Text);

  fClient.PlayerPositionLook(fX, fY, fZ, fStance, fYaw, fPitch, CbJamp.Checked);

  fRender.DoUpdate;
end;

procedure TMain.BLookAtClick(Sender: TObject);
var
  fPos:TPos;
begin
  fPos.X := StrToFloat(EX.Text);
  fPos.Y := StrToFloat(EY.Text);
  fPos.Z := StrToFloat(EZ.Text);

  fClient.LookAt( fPos );

  fRender.DoUpdate;
end;

procedure TMain.BRespawnClick(Sender: TObject);
begin
  fClient.Respawn;
end;

procedure TMain.DoChangeConnection(Sender: TObject);
begin
  if fClient.IsConnected then
    BConnect.Caption := 'Disconnect'

  else
    BConnect.Caption := 'Connect';
end;

procedure TMain.DoTerminate(Sender: TObject);
begin
  BConnect.Caption := 'Terminate';
end;

procedure TMain.DoChangePosition(Sender: TObject);
begin
  PostMessage(Handle, WM_USEREVENT, 2, 0);
end;

procedure TMain.DoOpenWind(WID: Byte);
begin
  PostMessage(Handle, WM_USEREVENT, 0, WID);
end;

procedure TMain.DoCloseWind(WID: Byte);
begin
  PostMessage(Handle, WM_USEREVENT, 1, WID);
end;

procedure TMain.ETextKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    BDoClick(Sender);
end;

procedure TMain.SBMoveClick(Sender: TObject);
const
  cStep = 0.5;
var
  fX, fY, fZ, fStance: Extended;
begin
  fX := fClient.Position.X;
  fY := fClient.Position.Y;
  fZ := fClient.Position.Z;

  case TControl(Sender).Tag of
    0:
      fZ := fZ - cStep;
    1:
      fZ := fZ + cStep;
    2:
      fX := fX - cStep;
    3:
      fX := fX + cStep;
    4:
      fY := fY + cStep;
    5:
      fY := fY - cStep;
  end;
  fStance := fY + cStance;

  fClient.PlayerPosition(fX, fY, fZ, fStance, CbJamp.Checked);

  fRender.DoUpdate;

  BBGetClick(Sender);
end;

procedure TMain.TimerTimer(Sender: TObject);

  function GetTime(Val: Integer): string;
  var
    fTime: TDateTime;
  begin
    fTime := fClient.Time / cTickInDay;

    // Hour
    result := IntToStr(Round(fTime)) + '  ' + TimeToStr(fTime);
  end;

var
  i: Integer;
  fPlayerPair:TPair<string, IPlayer>;
  fPlayer:IPlayer;
  itm:TListItem;
  fTask:ITask;
begin
  // Players
  fClient.Lock.Enter;
  try
    LVUsers.Items.BeginUpdate;
    try
      LVUsers.Items.Clear;

      // Update list
      for fPlayerPair in fClient.Players do begin
        fPlayer := fPlayerPair.Value;

        itm := LVUsers.Items.Add;
        Itm.Caption := fPlayer.Name;
        Itm.SubItems.Add( IntToHex( fPlayer.EID, 8) );
        Itm.SubItems.Add( IntToStr( fPlayer.Ping ) );
      end;

    finally
      LVUsers.Items.EndUpdate;
    end;

    // State
    MState.Lines.BeginUpdate;
    try
      MState.Lines.Clear;

      MState.Lines.Add('Time: ' + GetTime(fClient.Time));
      MState.Lines.Add('Entitys: ' + IntToStr(fClient.Entitys.Count));
      MState.Lines.Add('Chunks: ' + IntToStr(fClient.Chunks.Count) + '-' +
        IntToStr(fClient.Chunks.CountLoaded));

      MState.Lines.Add('X    : ' + FloatToStr(fClient.Position.X));
      MState.Lines.Add('Y    : ' + FloatToStr(fClient.Position.Y));
      MState.Lines.Add('Z    : ' + FloatToStr(fClient.Position.Z));

      MState.Lines.Add('Yaw  : ' + FloatToStr(fClient.Yaw));
      MState.Lines.Add('Pitch: ' + FloatToStr(fClient.Pitch));

      if fClient.jamp then
        MState.Lines.Add('Jamp : T')
      else
        MState.Lines.Add('Jamp : F');

      MState.Lines.Add('Health: ' + FloatToStr(fClient.Health));
      MState.Lines.Add('Food: ' + IntToStr(fClient.Food));
      MState.Lines.Add('Food Saturation: ' + FloatToStr(fClient.FoodSaturation));

      MState.Lines.Add('ExperienceBar: ' +
        FloatToStr(fClient.ExperienceBar));
      MState.Lines.Add('Level: ' + IntToStr(fClient.Level));
      MState.Lines.Add('TotalExperience: ' +
        IntToStr(fClient.TotalExperience));

    finally
      MState.Lines.EndUpdate;
    end;

    // Tasks
    lvTVTasks.Items.BeginUpdate;
    try
      for i := 0 to fTasks.Count-1 do begin
        fTask := fTasks.Items[i];

        // Append new
        if lvTVTasks.Items.Count <= i then
          lvTVTasks.Items.Add;

        // Get item
        itm := lvTVTasks.Items.Item[i];
        itm.Caption := fTask.Name;

        // State
        while itm.SubItems.Count < 1 do
          itm.SubItems.Add('');

        itm.SubItems.Strings[0] := fTask.GetState;
      end;

    finally
      lvTVTasks.Items.EndUpdate;
    end;

  finally
    fClient.Lock.Leave;
  end;
end;

procedure TMain.SBMapUpdateClick(Sender: TObject);
begin
  fRender.DoUpdate;
end;

procedure TMain.SBCHangeShieldClick(Sender: TObject);
var
  fSlot: SmallInt;
begin
  if not IsNum(EActiveSlot.Text, fSlot) then exit;
  fClient.HeldItemChange(fSlot);
end;

procedure TMain.SBYDownClick(Sender: TObject);
var
  fY: Extended;
begin
  fY := StrToFloat(EY.Text);
  fY := fY - 1;
  EY.Text := FloatToStr(fY);
end;

procedure TMain.SBYUpClick(Sender: TObject);
var
  fY: Extended;
begin
  fY := StrToFloat(EY.Text);
  fY := fY + 1;
  EY.Text := FloatToStr(fY);
end;

procedure TMain.BInventoryClick(Sender: TObject);
begin
  PostMessage(Handle, WM_USEREVENT, 0, 0);
end;

procedure TMain.WMUserEvent(var Msg: TMessage);
begin
  case Msg.WParam of
    0: fWindow.Execute(Msg.LParam);
    1: fWindow.Close;
    2:begin
      BBGetClick(self);

      fRender.UpdatePos;
    end;
  end;
end;

procedure TMain.btnBGotoClick(Sender: TObject);
var
  str:string;
begin
  str := '{'+
    '"point":"'+
      EX.Text+';'+
      EY.Text+';'+
      EZ.Text+
    '",'+
    '"type":"nearest"'+
  '}';

  fTasks.SendEvent('cmd.walk.set', str);
end;

procedure TMain.BSendEventClick(Sender: TObject);
var
  fName, fData:string;
begin
  if not InputQuery('Send event', 'Name', fName) then exit;
  if not InputQuery('Send event', 'Data', fData) then exit;

  fTasks.SendEvent( fName, fData );
end;

procedure TMain.BFellerClick(Sender: TObject);
begin
  fTasks.SendEvent( 'state', 'work.feller' );
end;

end.
