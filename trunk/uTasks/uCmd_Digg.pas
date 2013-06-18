unit uCmd_Digg;

interface

uses
  ExtCtrls,

  mcTypes,
  uPlugins;

type
  TCmd_Digg = class(TInterfacedObject, ITask, ITaskChangeBlocks)
  private
    fClient:IClient;
    fWork:boolean;

    fFace:Byte;
    fAPos:TPos;

    // 0 - None
    // 1 - Start
    // 2 - Animation
    // 3 - Stop

    fState:Integer;
    fAnimateCount:Integer;

    fLastTime:LongWord;
    fTime:TTimer;

    procedure Stop;
    procedure DoDigg(Sender:TObject);
  public
    constructor Create(Client:IClient);
    destructor Destroy; override;

    function GetInfo:string;

    function Name:string;
    function GetState:string;

    function Help:string;

    procedure Event(Name, Data:string);

    // Block Change
    procedure BlockChange( Pos:TAbsPos );
    procedure BlockChangeMulti( X,Y:Integer );
  end;

implementation

uses
  Windows,
  SysUtils,
  Math,
  uLkJSON,

  qStrUtils,
  qSysUtils,

  uPick;

const
  cAnimationCnt = 5;
  cMaxDistance = 6;

  cTimeOutBlockChange = 1000;

{ TCmd_Digg }

constructor TCmd_Digg.Create(Client: IClient);
begin
  fClient := Client;

  fWork := true;

  fState := 0;
  fAnimateCount := 0;

  fFace := 0;
  fAPos := ToPos(0,0,0);

  fTime := TTimer.Create(nil);
  fTime.Interval := 500; //@@@
  fTime.Enabled := false;
  fTime.OnTimer := DoDigg;
end;

destructor TCmd_Digg.Destroy;
begin
  fTime.Free;

  inherited;
end;

function TCmd_Digg.GetInfo: string;
begin
  Result := '{'+
    '"name":"cmd.digg",'+
    '"events":["cmd.digg.set","cmd.digg.work","cmd.digg.abort"]'+
  '}';
end;

function TCmd_Digg.Name: string;
begin
  result := 'cmd.digg';
end;

function TCmd_Digg.GetState: string;
begin
  if fWork then
    if fTime.Enabled then
      case fState of
        1: result := 'Start';
        2: result := 'Digg';
        3: result := 'Stop';
        4: result := 'Wait block digg';
        else
          result := '-';
      end
    else
      result := '-'
  else
    result := '';
end;

function TCmd_Digg.Help: string;
begin
  result := '';
end;

procedure TCmd_Digg.Event(Name, Data: string);
var
  fJSON:TlkJSONBase;
  val:string;
begin
  // Set destanation
  if Name = 'cmd.digg.set' then begin
    fJSON := TlkJSON.ParseText( Data );
    try
      fAPos.X := 0;
      fAPos.Y := 0;
      fAPos.Z := 0;

      // Coord
      if fJSON.Field['point'] <> nil then begin
        val := fJSON.Field['point'].Value;

        fAPos.X := StrToFloat( ExtractWord(1, val, [';']) );
        fAPos.Y := StrToFloat( ExtractWord(2, val, [';']) );
        fAPos.Z := StrToFloat( ExtractWord(3, val, [';']) );
      end;

      fState := 1;
      fTime.Enabled := true;

    finally
      fJSON.Free;
    end;
  end
  //Set work
  else if Name = 'cmd.digg.work' then begin
    fWork := Data = 'on';
  end
  // Abort
  else if Name = 'cmd.digg.abort' then
    Stop();

end;

procedure TCmd_Digg.Stop;
begin
  fState := 0;
  fTime.Enabled := false;
end;

procedure TCmd_Digg.DoDigg(Sender: TObject);
begin
  case fState of
    // Digg
    1:begin
      //--- Dest ---
      if GetDistance( fClient.Pos, fAPos ) > cMaxDistance then begin
        Stop();

        fClient.SendEvent('cmd.digg.error','To far');

        {$IFDEF ADEBUG}
          fClient.AddLog('% Place not found');
        {$ENDIF}

        exit;
      end;

      fFace := Pick( fClient.Pos, fAPos );

      // @@@ Test block

      // @@@ Test block path

      //--- Look at ---
      fClient.LookAt( fAPos );

      //--- Digg ---
      fClient.Digging( PosToAbsPos(fAPos), 0, fFace);
      fState := 2;
      fAnimateCount := cAnimationCnt;
    end;
    // Animation
    2:begin
      fClient.Animation( 1 );

      Dec(fAnimateCount);
      if fAnimateCount <= 0 then
        fState := 3;
    end;
    // Stop Digg
    3:begin
      fLastTime := GetTickCount();
      fState := 4;

      fClient.Digging( PosToAbsPos(fAPos), 2, fFace);
    end;
    // Wait change block
    4:begin

      // Timeout error
      if GetTickDiff(fLastTime, GetTickCount()) > cTimeOutBlockChange then begin
        Stop();

        fClient.SendEvent('cmd.digg.error','Timeout digg block');
      end;
    end;

    else
      Stop();

  end;
end;

procedure TCmd_Digg.BlockChange(Pos: TAbsPos);
begin
  if fState = 0 then exit;
  if not CompareAbsPos( PosToAbsPos(fAPos), Pos) then exit;

  Stop();
  fClient.SendEvent('cmd.digg.end','');
end;

procedure TCmd_Digg.BlockChangeMulti(X, Y: Integer);
begin
  //
end;

end.
