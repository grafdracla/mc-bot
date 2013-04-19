unit aTestBlock;

interface

uses
  Generics.Collections,
  uPlugins;

  procedure DefTestBlock(Client:ICLient; Pos: TAbsPos; AirBloks:TList<Integer>; var Fly: Boolean; var Passability: Extended);

implementation

uses
  Math,

  mcConsts,
  mcTypes;

procedure DefTestBlock(Client:ICLient; Pos: TAbsPos; AirBloks:TList<Integer>; var Fly: Boolean; var Passability: Extended);
var
  f0_BId, f1_BId, fG_BId:Integer;
  f0_BMeta, f1_BMeta, fG_BMeta:Byte;
  f0_BInfo, f1_BInfo, fG_BInfo: IBlockInfo;
begin
  Passability := 0;
  Fly := false;

  // === 0 ===
  if not Client.GetBlock(Pos, f0_BId, f0_BMeta) then exit;

  // Skip bloks
  if (AirBloks <> nil) and ( AirBloks.IndexOf(f0_BId) <> -1) then begin
    Passability := 1;
  end
  else begin
    f0_BInfo := Client.GetBlockInfo( f0_BId );
    if f0_BInfo = nil then exit;

    case f0_BInfo.BlockType of
      btBlock, btPlant:
        // Not walk @@@
        if f0_BInfo.Height(f0_BMeta) = 1 then begin
          Passability := 0;
          exit;
        end
        else
          Passability := 1;

      // @@@ - Set valid
      btFluid:
        begin
          Passability := 0;
          exit;
        end;

      else
        Passability := 1;
    end;
  end;

  // === 1 ===
  if not Client.GetBlock( AbsPos(Pos.X, Pos.Y + 1, Pos.Z), f1_BId, f1_BMeta) then exit;

  // Skip bloks
  if (AirBloks <> nil) and ( AirBloks.IndexOf(f1_BId) <> -1) then begin
    Passability := Min(1, Passability);
  end
  else begin
    f1_BInfo := Client.GetBlockInfo( f1_BId );
    if f1_BInfo = nil then exit;

    case f1_BInfo.BlockType of
      btBlock, btPlant:
        // Not walk @@@
        if f1_BInfo.Height(f1_BMeta) = 1 then begin
          Passability := 0;
          exit;
        end
        else
          Passability := Min(1, Passability);

      // @@@ - Set valid
      btFluid:
        begin
          Passability := 0;
          exit;
        end;

      else
        Passability := Min(1, Passability);
    end;
  end;

  // === G ===
  if not Client.GetBlock( AbsPos(Pos.X, Pos.Y -1, Pos.Z), fG_BId, fG_BMeta) then exit;

  case f0_BId of
    btLadders:;

    else begin
      fG_BInfo := Client.GetBlockInfo( fG_BId );
      if fG_BInfo = nil then exit;

      case fG_BInfo.BlockType of
        btBlock, btPlant:
          if fG_BInfo.Height(fG_BMeta) = 0 then
            Fly := true;

        // @@@ - Set valid
        btFluid:
          Fly := true;

        else
          Fly := true;
      end;
    end;
  end;
end;

end.
