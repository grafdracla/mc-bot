// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
program mcBot;

uses
  Vcl.Forms,
  uEntity in 'uEntity.pas',
  uChunk in 'uChunk.pas',
  uIBase in 'uIBase.pas',
  uWind in 'uWind.pas',
  aA in 'aA.pas',
  uGrapsh in 'uGrapsh.pas',
  uPick in 'uPick.pas',
  mcTypes in 'mcTypes.pas',
  mcConsts in 'mcConsts.pas',
  UMain in 'UMain.pas' {Main},
  dWindow in 'dWindow.pas' {fWindow},
  uTasks in 'uTasks.pas',
  uIdle_LookAtPlayers in 'uTasks\uIdle_LookAtPlayers.pas',
  uCmd_Walk in 'uTasks\uCmd_Walk.pas',
  uIdle_GetDropItems in 'uTasks\uIdle_GetDropItems.pas',
  uConnection in 'uConnection.pas',
  uPlugins in 'uPlugins.pas',
  uSys_Login in 'uTasks\uSys_Login.pas',
  uWork_GoWithMe in 'uTasks\uWork_GoWithMe.pas',
  uWork_Goto in 'uTasks\uWork_Goto.pas',
  uPlayer in 'uPlayer.pas',
  uIdle_Gravitation in 'uTasks\uIdle_Gravitation.pas' {$R *.res},
  uCmd_Points in 'uTasks\uCmd_Points.pas',
  uNeed_Eat in 'uTasks\uNeed_Eat.pas',
  uWork_Feller in 'uTasks\uWork_Feller.pas',
  uCmd_Digg in 'uTasks\uCmd_Digg.pas',
  uRenderUtils in 'uRenderUtils.pas',
  aTestBlock in 'aTestBlock.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.CreateForm(TfWindow, fWindow);
  Application.Run;
end.
