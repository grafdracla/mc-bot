unit uRender_OpenGL;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,

  uRenderUtils, uPlugins,

  dglOpenGL, Vcl.ExtCtrls;

type
  TRender_OpenGL = class(TFrame, IRender)
    RefreshMap: TTimer;
    procedure FrameResize(Sender: TObject);
    procedure RefreshMapTimer(Sender: TObject);
  private
    dc: HDC;
    hrc: HGLRC;

    procedure SetupGL;
  public
    constructor Create(AOwner: TWinControl);
    destructor Destroy; override;

    procedure Init( RenderParams:TRenderParams );
    procedure Active(Val: Boolean);

    procedure DoUpdate;
    procedure UpdatePos;
  end;

implementation

{uses
  Glaux;}

{$R *.dfm}

const
  NearClipping = 0.1;
  FarClipping  = 200;

{ TRender_OpenGL }

constructor TRender_OpenGL.Create(AOwner: TWinControl);
begin
  inherited Create(AOwner);

  Parent := AOwner;
  Align := alClient;

  dc := 0;
end;

destructor TRender_OpenGL.Destroy;
begin
  DeactivateRenderingContext;
  DestroyRenderingContext(hrc);
  ReleaseDC(Handle, dc);

  inherited;
end;

procedure TRender_OpenGL.Init( RenderParams:TRenderParams );
begin
  // Get context
  dc := GetDC( Handle );

  if not InitOpenGl then
    Application.Terminate;

  hrc := CreateRenderingContext( dc, [opDoubleBuffered], 32, 24, 0,0,0,0);

  ActivateRenderingContext(dc, hrc);

  SetupGL;
end;

procedure TRender_OpenGL.FrameResize(Sender: TObject);
begin
  if dc = 0 then exit;

  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(45.0, ClientWidth/ClientHeight, NearClipping, FarClipping);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;

  DoUpdate;
end;

procedure TRender_OpenGL.SetupGL;
begin
  if dc = 0 then exit;

  glClearColor(0.3, 0.4, 0.7, 0);
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_CULL_FACE);
end;

procedure TRender_OpenGL.Active(Val: Boolean);
begin
  if Val then begin
    RefreshMap.Enabled := True; //CBUpdate.Checked
    DoUpdate;
  end
  else
    RefreshMap.Enabled := False;
end;

procedure TRender_OpenGL.UpdatePos;
begin
  //@@@
end;

procedure TRender_OpenGL.RefreshMapTimer(Sender: TObject);
begin
  if RefreshMap.Tag <> 0 then exit;

  RefreshMap.Tag := 1;
  try
    DoUpdate;
  finally
    RefreshMap.Tag := 0;
  end;
end;

procedure TRender_OpenGL.DoUpdate;
begin
  if dc = 0 then exit;

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glViewport(0,0, Self.ClientWidth, Self.ClientHeight );
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(45.0, Self.ClientWidth/Self.ClientHeight, NearClipping, FarClipping);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;

  glTranslatef(0,0,-3);

  glBegin(GL_QUADS);
    glColor3f(1,0,0);
//    auxSolidBox(4, 4, 1);

{    glColor3f(1,0,0);  glVertex3f(-1,-1,0);
    glColor3f(0,1,0);  glVertex3f(1,-1,0);
    glColor3f(0,0,1);  glVertex3f(1,1,0);
    glColor3f(1,1,0);  glVertex3f(-1,1,0);}
  glEnd;

  SwapBuffers(dc);
end;

end.
