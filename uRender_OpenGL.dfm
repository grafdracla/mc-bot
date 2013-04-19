object Render_OpenGL: TRender_OpenGL
  Left = 0
  Top = 0
  Width = 320
  Height = 240
  TabOrder = 0
  OnResize = FrameResize
  object RefreshMap: TTimer
    OnTimer = RefreshMapTimer
    Left = 16
    Top = 16
  end
end
