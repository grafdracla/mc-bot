unit uWork_Feller;

interface

uses
  Classes,
  SyncObjs,

  uPlugins;

type
  TWFState = (wfsNone, wfsWalkEnd, wfsWalkError, wfsOpenWind, wfsClickWnd, wfsDiggEnd, wfsDiggError);

  TWork_Feller = class(TInterfacedObject,
    ITask,
    ITaskEventChat,
    ITaskEnentWindow)
  private
    fClient:IClient;
    fThread:TThread;
    fState:string;

    fWindowId:Byte;
    fTransId:Integer;

    fEventState:TWFState;
    fEvent:TSimpleEvent;

    procedure DoEndWork;
    procedure StopThread;
  public
    constructor Create(Client:IClient);
    destructor Destroy; override;

    function GetInfo:string;

    function Name:string;
    function GetState:string;
    procedure Event(Name, Data:string);

    // Chat
    procedure ChatMessage(msg:string);

    // Window
    procedure OpenWindow(WID:Byte);
    procedure CloseWindow(WID:Byte);
    procedure ConfirmTransaction(WID:Byte; TransId:Word; Accept:boolean);
  end;

implementation

uses
  Generics.Collections,
  StrUtils,
  SysUtils,

  qStrUtils,
  qSysUtils,

  mcConsts,
  mcTypes,

  aA,
  aTestBlock,
  uPick,
  uIBase;

const
  cMaxTime = INFINITE;

const
  cChest_Aix = 27+2;
  cRadius = 10;

  cRangeDown = 5;
  cRangeUp = 6;

  cMinDestBlock = 6;

type
  TWork_Feller_thread = class(TThread)
  private
    fParent:TWork_Feller;
    fSkipBloks:TList<Integer>;
    fIgnoreBloks:TList<TAbsPos>;

    function WalkTo(data:string):boolean;
    function DiggTo(data:string):boolean;

    function OpenChest(Pos:TAbsPos):boolean;
    function WndClick(WId, Ind:Integer):Boolean;

    procedure TestBlock(Pos: TAbsPos; var Fly: Boolean; var Passability: Extended);
    function CheckBlock(Pos: TAbsPos):Boolean;
  public
    constructor Create(Parent:TWork_Feller);
    destructor Destroy; override;

    procedure Execute; override;
  end;

{ TWork_Feller }

constructor TWork_Feller.Create(Client: IClient);
begin
  fClient := Client;

  fThread := nil;
  fState := '-';

  fWindowId := 0;
  fTransId := -1;

  fEventState := wfsNone;
  fEvent := TSimpleEvent.Create;
end;

destructor TWork_Feller.Destroy;
begin
  StopThread;

  fEvent.Free;

  inherited;
end;

function TWork_Feller.GetInfo: string;
begin
  Result := '{'+
    '"name":"work.feller",'+
    '"dependence":["cmd.walk"],'+
    '"events":['+
      '"cmd.walk.end", "cmd.walk.error", '+
      '"cmd.digg.end", "cmd.digg.error", '+
      '"state"]'+
  '}';
end;

function TWork_Feller.Name: string;
begin
  result := 'work.feller';
end;

function TWork_Feller.GetState: string;
begin
  result := fState;
end;

procedure TWork_Feller.DoEndWork;
begin
  fClient.SendEvent('state', 'idle');
  fThread := nil;
end;

procedure TWork_Feller.Event(Name, Data: string);
begin
  // Change state
  if Name = 'state' then begin
    if data = 'work.feller' then begin
    
      // Start therd
      if fThread = nil then
        fThread := TWork_Feller_thread.Create( self );
        
    end
    else
      if fThread <> nil then
        StopThread;
  end
  
  // Events
  else if fThread <> nil then begin

    // Walk end
    if Name = 'cmd.walk.end' then begin
      fEventState := wfsWalkEnd;
      fEvent.SetEvent;
    end
    // Walk error
    else if Name = 'cmd.walk.error' then begin
      fEventState := wfsWalkError;
      fEvent.SetEvent;
    end
    // Digg end
    else if Name = 'cmd.digg.end' then begin
      fEventState := wfsDiggEnd;
      fEvent.SetEvent;
    end
    // Digg error
    else if Name = 'cmd.digg.error' then begin
      fEventState := wfsDiggError;
      fEvent.SetEvent;
    end;
  end;
end;

procedure TWork_Feller.OpenWindow(WID: Byte);
begin
  fEventState := wfsOpenWind;
  fWindowId := WID;

  fEvent.SetEvent;
end;

procedure TWork_Feller.StopThread;
begin
  if fThread = nil then Exit;

  fThread.Terminate;
    
  fEventState := wfsNone;
  fEvent.SetEvent;

  fThread := nil;
end;

procedure TWork_Feller.CloseWindow(WID: Byte);
begin
  //
end;

procedure TWork_Feller.ConfirmTransaction(WID:Byte; TransId:Word; Accept:boolean);
begin
  if fTransId = TransId then begin
    if Accept then
      fEventState := wfsClickWnd
    else
      fEventState := wfsNone;
    fEvent.SetEvent;
  end;
end;

procedure TWork_Feller.ChatMessage(msg: string);
var
  fUser, fCmd:string;
begin
  // Test whispers
  if lowercase( ExtractWord(2, msg, [' ']) ) <> 'whispers' then exit;

  // Test user
  fUser := ExtractWord(1, msg, [' ']);
  case fClient.GetUserGroup(fUser) of
    ugAdmin:;
    else
      exit;
  end;

  // Patch 1.5
  if ExtractWord(3, msg, [' ']) = 'to' then
    msg := trim( lowercase( Copy(msg, WordPosition(2, msg, [':']), Length(msg)) ) )

  else
    msg := trim( lowercase( Copy(msg, WordPosition(3, msg, [' ']), Length(msg)) ) );

  // Test command
  fCmd := lowercase( ExtractWord(1, msg, [' ']) );
  if fCmd <> 'work' then exit;

  fCmd := lowercase( ExtractWord(2, msg, [' ']) );
  if fCmd <> 'feller' then exit;

  if fThread <> nil then exit;

  //==== Start work ====
  fClient.SendEvent('state', 'work.feller');  
end;

{ TWork_Feller_thread }

constructor TWork_Feller_thread.Create(Parent:TWork_Feller);
begin
  inherited Create(false);

  fParent := Parent;
  FreeOnTerminate := true;

  fSkipBloks := TList<Integer>.Create;
  fSkipBloks.Add( btWood );
  fSkipBloks.Add( btLeaves );

  fIgnoreBloks := TList<TAbsPos>.Create;
end;

destructor TWork_Feller_thread.Destroy;
begin
  fSkipBloks.Free;
  fIgnoreBloks.Free;
end;

function TWork_Feller_thread.WalkTo(data: string):boolean;
begin
  result := false;

  fParent.fEventState := wfsNone;
  fParent.fEvent.ResetEvent;

  fParent.fClient.SendEvent('cmd.walk.set', data);

  // Wait end walk
  if fParent.fEvent.WaitFor(cMaxTime) <> wrSignaled then
    exit;

  result := fParent.fEventState = wfsWalkEnd;
end;

function TWork_Feller_thread.DiggTo(data:string):boolean;
begin
  result := false;

  fParent.fEventState := wfsNone;
  fParent.fEvent.ResetEvent;

  fParent.fClient.SendEvent('cmd.digg.set', data);

  // Wait end walk
  if fParent.fEvent.WaitFor(cMaxTime) <> wrSignaled then
    exit;

  result := fParent.fEventState = wfsDiggEnd;
end;

function TWork_Feller_thread.OpenChest(Pos: TAbsPos): boolean;
begin
  result := false;

  fParent.fEventState := wfsNone;
  fParent.fEvent.ResetEvent;

  fParent.fClient.Place( Pos, 0, 0, 0, 0);

  // Wait end walk
  if fParent.fEvent.WaitFor(cMaxTime) <> wrSignaled then
    exit;

  result := fParent.fEventState = wfsOpenWind;
end;

function TWork_Feller_thread.WndClick(WId, Ind:Integer):Boolean;
begin
  result := true;

  fParent.fEventState := wfsNone;
  fParent.fEvent.ResetEvent;

  // Click
  fParent.fTransId := fParent.fClient.ClickWindow( WId, Ind, mbLeft, false );
  if fParent.fTransId = -1 then exit;

  // Wait
  if fParent.fEvent.WaitFor(2000) <> wrSignaled then exit;

  result := fParent.fEventState = wfsClickWnd;
end;

procedure TWork_Feller_thread.TestBlock(Pos: TAbsPos; var Fly: Boolean; var Passability: Extended);
begin
  DefTestBlock( fParent.fClient, Pos, fSkipBloks, Fly, Passability );
end;

function TWork_Feller_thread.CheckBlock(Pos: TAbsPos):Boolean;
var
  fBlockId:Integer;
  fBlockMetta:Byte;
begin
  // Check ignore
  if fIgnoreBloks.IndexOf(Pos) <> -1 then begin
    result := false;
    exit;
  end;

  // Get block info
  result := fParent.fClient.GetBlock(Pos, fBlockId, fBlockMetta);

  // Test block
  if result then
    result := fBlockId = btWood;
end;

procedure TWork_Feller_thread.Execute;

  function GetPlace(Name:string; var Pos:TPos):boolean;
  var
    str:string;
  begin
    result := false;

    str := fParent.fClient.GetParam('points', Name);
    if not isFloat( ExtractWord(1, str, [';']), Pos.X ) then Exit;
    if not isFloat( ExtractWord(2, str, [';']), Pos.Y ) then Exit;
    if not isFloat( ExtractWord(3, str, [';']), Pos.Z ) then Exit;

    result := true;
  end;

  function DoFeller(Pos:TAbsPos):boolean;
  var
    fBId:Integer;
    fBMeta:Byte;

    str:string;
  begin
    result := false;

    // Test block
    if not fParent.fClient.GetBlock(Pos, fBId, fBMeta) then exit;

    case fBId of
      btWood:;
      btLeaves:;
      else begin
        result := true;
        exit;
      end;
    end;

    // Digg
    str := '{'+
      '"point":"'+
        FloatToStr(Pos.X)+';'+
        FloatToStr(Pos.Y)+';'+
        FloatToStr(Pos.Z)+'",'+
    '}';

    result := DiggTo( str );
  end;

var
  str:string;
  fChestPos, fForestPos:TPos;
  fPos, fBlockPos:TAbsPos;

  fDist:Extended;

  fTBlockPos:TAbsPos;
  fTFound:Boolean;

  fSlot:ISlot;
  fWnd:IWindow;
  i, fInd, fBlockId:Integer;
  fMeta:Byte;
  x, y, z:Integer;
  fHasWood, fNideWood:Integer;
  fBlockInfo:IBlockInfo;
  fTools:TList<Integer>;

  fBestAxe_Slot:Integer;
  fBestAxe_Ind:Integer;

  fPath: TPath;
  fPoint: TAbsPos;
begin
  try
    //=== Prepare ===
    fParent.fState := 'Get info';

    fIgnoreBloks.Clear;

    // Chest
    if not GetPlace('chest', fChestPos) then begin
      fParent.fState := 'Last, chest not found';
      exit;
    end;

    // Forest
    if not GetPlace('forest', fForestPos) then begin
      fParent.fState := 'Last, forest not found';
      exit;
    end;

(*
    //--- Goto chest ---
    if Terminated then Exit;
    fParent.fState := 'Goto chest';

    str := '{'+
        '"place":"chest",'+
        '"frange":"1"'+
      '}';

    if not WalkTo( str ) then begin
      fParent.fState := 'Last, Error goto chest';
      exit;
    end;

    //--- Open chest ---
    if Terminated then Exit;
    fParent.fState := 'Open chest';

    if not OpenChest( PosToAbsPos( fChestPos ) ) then Exit;

    Sleep(2000);

    //--- See wood count ---
    if Terminated then Exit;
    fParent.fState := 'Look at chest';

    // Get Wind
    fWnd := fParent.fClient.GetWindow( fParent.fWindowId );
    if fWnd = nil then exit;

    // Block info wood
    fBlockInfo := BloksInfos.GetInfo( btWood );
    if fBlockInfo = nil then Exit;

    // Calck work count
    fHasWood := 0;
    for i := 0 to fWnd.WCount-1 do begin
      fSlot := fWnd.GetSlot( i );
      if fSlot = nil then Continue;
      if fSlot.BlockId <> btWood then continue;

      fHasWood := fHasWood + fSlot.Count;
    end;

    // Look has Axe
    fTools := TList<Integer>.Create;
    try
      // Make list
      for i := 0 to fBlockInfo.GetToolCount-1 do
        fTools.Add( fBlockInfo.GetTool(i) );

      fBestAxe_Slot := -1;
      fBestAxe_Ind := -1;

      for i := 0 to fWnd.Count-1 do begin
        fSlot := fWnd.GetSlot( i );
        if fSlot = nil then Continue;

        fInd := fTools.IndexOf( fSlot.BlockId );
        if fInd = -1 then continue;

        if (fBestAxe_Slot = -1) or  // First
           (fInd < fBestAxe_Ind)    // Best
        then begin
          fBestAxe_Slot := i;
          fBestAxe_Ind := fTools.IndexOf( fSlot.BlockId );
        end;
      end;

      // Has aix
      if fBestAxe_Slot = -1 then begin
        fParent.fState := 'Last, Axe not found';
        exit;
      end;

      // Best Axe in chest
      if fBestAxe_Slot <> fWnd.WCount+cChest_Aix then begin

        if Terminated then Exit;

        // Click to slot 2
        if not WndClick( fParent.fWindowId, fWnd.WCount+cChest_Aix ) then begin
          fParent.fState := 'Last, Error click slot #1';
          exit;
        end;

        if Terminated then Exit;

        // Click to slot Best
        if not WndClick( fParent.fWindowId, fBestAxe_Slot ) then begin
          fParent.fState := 'Last, Error click slot #2';
          exit;
        end;

        if Terminated then Exit;

        // Click to slot 2
        if not WndClick( fParent.fWindowId, fWnd.WCount+cChest_Aix ) then begin
          fParent.fState := 'Last, Error click slot #3';
          exit;
        end;
      end;

      // Setect AXE
      fParent.fClient.HeldItemChange( 2 );

    finally
      fTools.Free;
    end;

    fParent.fClient.CloseWindow( fParent.fWindowId );

    fNideWood := 64*2 - fHasWood;
    if fNideWood < 0 then begin
      fParent.fState := 'Last, to many woods';
      exit;
    end;
*)

    //=== Goto forest ===
    if Terminated then Exit;
    fParent.fState := 'Goto forest';

    str := '{'+
        '"place":"forest",'+
        '"frange":"2"'+
      '}';

    if not WalkTo( str ) then begin
      fParent.fState := 'Last, Error goto forest';
      exit;
    end;

    //=== Cycle ===
    while not Terminated do begin

      // Find wood
      if Terminated then exit;
      fParent.fState := 'Find wood';

      fPos := PosToAbsPos( fParent.fClient.Pos );

      fTFound := ANerest( fPos, PosToAbsPos(fForestPos), CheckBlock, cRadius, cRangeUp, cRangeDown, fTBlockPos);

      // Forest is end
      if not fTFound then begin
        fParent.fState := 'Last, Forest is end';
        exit;
      end;

      //--- Goto wood block ---
      if Terminated then exit;
      fParent.fState := 'Goto wood point';

      str := '{'+
        '"point":"'+
          FloatToStr(fTBlockPos.X)+';'+
          FloatToStr(fTBlockPos.Y)+';'+
          FloatToStr(fTBlockPos.Z)+'",'+
//        '"frange":"6",'+
        '"type":"nearest"'+
      '}';

      if not WalkTo( str ) then begin
        fParent.fState := 'Last, Error goto wood block';
        exit;
      end;

      //--- Digg wood block ---
      if Terminated then exit;
      fParent.fState := 'Find digg path';

      fPath := TPath.Create;
      try
        // Get path to block
        fPos := PosToAbsPos( fParent.fClient.Pos );
        if not AFind( fPos, fTBlockPos, TestBlock, fPath, 6*6*10, 0 ) then begin
          // ignore point
          fIgnoreBloks.Add( fPos );
          continue;
        end;

        while fPath.Count <> 0 do begin
          if Terminated then exit;

          fParent.fState := 'Feller: '+IntToStr(fPath.Count);

          //--- Test point ---
          fPoint := fPath.First;

          {// Test position
          if GetDistance( PosToAbsPos(fParent.fClient.Pos), fPoint ) > 2 then begin
            fParent.fClient.AddLog('@ Walk error');
            break;
          end;}

          // Delete
          fPath.Delete(0);

          // Check error
          if fPath.Count = 0 then
            Continue;

          // Get next
          fPoint := fPath.First;

          //--- Test point 0 ---
          if Terminated then exit;

          if not DoFeller( fPoint ) then begin
            //raise Exception.Create('@@@');
          end;

          //--- Test point +1 ---
          if Terminated then exit;

          if not DoFeller( AbsPos(fPoint.X, fPoint.Y+1, fPoint.Z) ) then begin
            //raise Exception.Create('@@@');
          end;

          //--- Test point Top ---
          if Terminated then exit;

          if not DoFeller( AbsPos(fPoint.X, fPoint.Y+2, fPoint.Z) ) then begin
            //raise Exception.Create('@@@');
          end;

          //--- Test poing ground ---
          //@@@

          //--- Goto new point ---
          if GetDistance( PosToAbsPos(fParent.fClient.Pos), fTBlockPos ) > cMinDestBlock then begin
            if Terminated then exit;
            fParent.fState := 'Goto new filer point';

            str := '{'+
              '"point":"'+
                FloatToStr(fPoint.X)+';'+
                FloatToStr(fPoint.Y)+';'+
                FloatToStr(fPoint.Z)+'",'+
              '"frange":"4",'+
              '"type":"nearest"'+
            '}';

            if not WalkTo( str ) then begin
              fParent.fState := 'Last, Error goto wood block';
              exit;
            end;
          end;
        end;

      finally
        fPath.Free;
      end;
    end;

  finally
    Synchronize( fparent.DoEndWork );
  end;
end;

end.
