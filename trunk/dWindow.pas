unit dWindow;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.Grids, Vcl.ExtCtrls, Vcl.StdCtrls,

  uWind, uPlugins, Vcl.Menus;

type
  TfWindow = class(TForm)
    Trefresh: TTimer;
    PCursor: TPanel;
    LCursor: TLabel;
    SGInventary: TStringGrid;
    PMWindow: TPopupMenu;
    Inventoryaction1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TrefreshTimer(Sender: TObject);
    procedure SGInventaryMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SGInventaryDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure Inventoryaction1Click(Sender: TObject);
  private
    fWnd:IWindow;
    fWId:Integer;

    function GetItemInfo( Slot:ISlot ):string;
    procedure RefreshTable;
  public
    procedure Execute(WID:Integer);
  end;

var
  fWindow: TfWindow;

implementation

uses
  System.UITypes,
  uIBase,
  mcConsts,

  qSysUtils,

  UMain;

{$R *.dfm}

{ TfWindow }

procedure TfWindow.FormCreate(Sender: TObject);
begin
  fWnd := nil;
  fWId := -1;
end;

procedure TfWindow.FormShow(Sender: TObject);
begin
  Trefresh.Enabled := true;
end;

procedure TfWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Trefresh.Enabled := false;
  fWId := -1;
end;

procedure TfWindow.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CloseWindow( fWId );
end;

procedure TfWindow.TrefreshTimer(Sender: TObject);
begin
  RefreshTable;

  // Cursor
  LCursor.Caption := GetItemInfo( Main.fClient.Cursor );
end;

function TfWindow.GetItemInfo(Slot: ISlot): string;
var
  fBlockInfo:IBlockInfo;
begin
  result := '';

  if (Slot <> nil) and (Slot.BlockId <> -1) then begin
    // Block Id
    fBlockInfo := BloksInfos.GetInfo(Slot.BlockId);
    if fBlockInfo <> nil then
      result := result + fBlockInfo.Title
    else
      result := result + IntToHex(Slot.BlockId, 3);

    result := result + '  '+
      // Count
      '('+IntToStr(Slot.Count)+')  '+
      // Damage
      '['+IntToStr(Slot.Damage)+']';
  end;
end;

procedure TfWindow.Inventoryaction1Click(Sender: TObject);
var
  str:string;
  fSlot:ISlot;
  fBlockid:Integer;
begin
  if Main.fClient.GameMode <> cGM_Creative then
    MessageDlg('Only on Creative game mode', mtWarning, [mbOk], 0);

  if fWId <> 0 then begin
    MessageDlg('Only in inventory', mtError, [mbOk], 0);
    exit;
  end;

  if SGInventary.Row < SGInventary.RowCount-9 then begin
    MessageDlg('Only in action cell', mtError, [mbOk], 0);
    exit;
  end;

  if not InputQuery('Inventory action', 'Block id:', str) then exit;

  if not IsNum('$'+str, fBlockid) then begin
    MessageDlg('Error format', mtError, [mbOk], 0);
    exit;
  end;

  fSlot := TSlot.Create;
  try
    fSlot.BlockId := fBlockId;
    fSlot.Count := 1;

    Main.fClient.CreateInventoryAction( SGInventary.Row, fSlot );
  finally
    fSlot := nil;
  end;
end;

procedure TfWindow.RefreshTable;

  procedure UpdateItem(SG:TStringGrid; Row:Integer; Slot:ISlot);
  var
    str:string;
  begin
    str := IntToStr(Row)+'  '+GetItemInfo(Slot);
    SG.Cells[0, Row] := str;
  end;

var
  i:Integer;
begin
  // Window items
  for i := 0 to fWnd.Count-1 do
    UpdateItem( SGInventary, i, fWnd.GetSlot( i ) );
end;

procedure TfWindow.Execute(WID: Integer);
begin
  fWnd := nil;
  fWId := WID;

  // Window
  if not Main.fClient.Windows.TryGetValue( WID, fWnd ) then
    raise Exception.Create( 'Window not found: '+IntToStr(WID) );

  Caption := fWnd.GetTitle;
  SGInventary.RowCount := fWnd.Count;

  RefreshTable;
  Show;
end;

procedure TfWindow.SGInventaryMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  fMB: TMButton;
  fSlotInd:Integer;
  fCol, fRow:Integer;
begin
  TStringGrid(Sender).MouseToCell(X, Y, fCol, fRow);

  if fRow = -1 then exit;
  if fCol = -1 then exit;
  
  TStringGrid(Sender).Row := fRow;

  fSlotInd := fRow;
  if fSlotInd = -1 then exit;

  case Button of
    TMouseButton.mbLeft:
      fMB := mbLeft;

    TMouseButton.mbRight:
      fMB := mbRight;

    TMouseButton.mbMiddle:
      fMB := mbMidle;

    else
      Exit;
  end;

  Main.fClient.ClickWindow( fWId, fSlotInd, fMB, ssShift in Shift );
end;

procedure TfWindow.SGInventaryDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  str:string;
  fRc:Integer;
begin
  fRC := SGInventary.RowCount;

  SGInventary.Canvas.Brush.Color := SGInventary.Color;

  // Special
  if ARow >= fRc-36 then
    SGInventary.Canvas.Brush.Color := $00FFFFB0;

  // Action
  if ARow >= fRc-9 then
    SGInventary.Canvas.Brush.Color := $00BFFFFF;

  // Active shield
  if ARow =  fRc-9 + Main.fClient.ActiveShield then
    SGInventary.Canvas.Pen.Color := clBlack
  else
    SGInventary.Canvas.Pen.Color := SGInventary.Canvas.Brush.Color;

  str := SGInventary.Cells[ ACol, ARow ];

  SGInventary.Canvas.Rectangle( Rect ); //  FillRect

  Rect.Offset(2, 0);
  DrawText( SGInventary.Canvas.Handle, PWideChar(Str), Length(Str), Rect, DT_VCENTER or DT_SINGLELINE );
end;

end.
