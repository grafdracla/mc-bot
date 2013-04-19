unit uRenderUtils;

interface

uses
  uPlugins;

type
  TGetCursorPos = function :TPos of object;
  TSetCursorPos = procedure (Pos:TPos) of object;

  TRenderParams = record
    Client:IClient;

    GetCursorPos:TGetCursorPos;
    SetCursorPos:TSetCursorPos;
  end;

  IRender = interface
    ['{432A6E8F-A796-4F95-A9AE-C29A8A0A4ECF}']

    procedure Init( RenderParams:TRenderParams );
    procedure DoUpdate;

    procedure Active(Val: Boolean);
    procedure UpdatePos;
  end;

implementation

end.
