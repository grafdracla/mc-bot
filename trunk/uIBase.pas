unit uIBase;

interface

uses
  Classes, Generics.Collections,
  IniFiles,

  uPlugins;

type
  TBlockInfo = class(TInterfacedObject, IBlockInfo)
  private
    fBId:Integer;
    fBType:TBType;
    fTitle:String;
    fDemage:Extended;
    fResistance:Extended;
    fStackable:Integer;
    fColor:LongWord;
    fHeight:Extended;
    fHint:string;

    fTools:TList<Integer>;
    fCraft:TList;
  public
    constructor Create;
    destructor Destroy; override;

    function BlockId:Integer;
    function BlockType:TBType;
    function Solid:Boolean;
    function Title:String;
    function Demage:Extended;
    function Resistance:Extended;
    function Stackable:Integer;
    function Height(Meta:Byte):Extended;

    function GetToolCount:Integer;
    function GetTool(Ind:Integer):Integer;

    // For debug
    function Color:LongWord;
    function Hint:string;
    function TypeName:string;
  end;

  TBloksInfos = class
  private
    fItems:TDictionary<Integer, IBlockInfo>;
  public
    constructor Create;
    destructor Destroy; override;

    function GetInfo(BlockId:Integer):IBlockInfo;

    procedure LoadData(INI:TIniFile);
  end;

  TMobInfo = class(TInterfacedObject, IMobInfo)
  private
    fType:TMType;
    fTitle:string;
  public
    constructor Create;
    destructor Destroy; override;

    function MType:TMType;
    function Title:string;
  end;

  TObjInfo = class(TInterfacedObject, IObjInfo)
  private
    fTitle:string;
  public
    constructor Create;

    function Title:string;
  end;

  TEntityInfos = class
  private
    fMobs:TDictionary<Integer, IMobInfo>;
    fObjs:TDictionary<Integer, IObjInfo>;
  public
    constructor Create;
    destructor Destroy; override;

    function GetMobInfo(Id:Integer):IMobInfo;
    function GetObjInfo(Id:Integer):IObjInfo;

    procedure LoadData(INI:TIniFile);
  end;

var
  BloksInfos:TBloksInfos;
  EntityInfos:TEntityInfos;

implementation

uses
  SysUtils, UIConsts, Graphics,

  qSysUtils,
  qStrUtils,

  mcConsts;

{ TBloksInfos }

constructor TBloksInfos.Create;
begin
  fItems := TDictionary<Integer, IBlockInfo>.Create;
end;

destructor TBloksInfos.Destroy;
begin
  fItems.Free;

  inherited;
end;

function TBloksInfos.GetInfo(BlockId: Integer): IBlockInfo;
begin
  if not fItems.TryGetValue(BlockId, result) then
    result := nil;
end;

procedure TBloksInfos.LoadData(INI: TIniFile);
var fSession:TStringList;
    fValues:TStringList;
    i, j, k, fKey, fNVal:Integer;
    fEVal:Extended;
    fSesion, fValName, fVal, sub:string;
    fBlock:TBlockInfo;
begin
  fSession := TStringList.Create;
  fValues  := TStringList.Create;
  try
    Ini.ReadSections(fSession);

    for i := 0 to fSession.Count-1 do begin
      fSesion := fSession.Strings[i];

      if not isNum('$'+fSesion, fKey) then continue;

      if fItems.ContainsKey(fKey) then
        raise Exception.Create('Block ID ready has');

      fBlock := TBlockInfo.Create;
      fItems.Add(fKey, fBlock);

      fBlock.fBId := fKey;

      fValues.Clear;
      Ini.ReadSection(fSesion, fValues);

      for j := 0 to fValues.Count-1 do begin
        fValName := LowerCase( fValues.Strings[j] );

        // Types
        if fValName = 'type' then begin
          fVal := INI.ReadString(fSesion, fValName, '');

          for k := 1 to WordCount(fVal, [';']) do begin
            sub := LowerCase( Trim( ExtractWord(k, fVal, [';']) ) );

            if sub = 'solid block' then begin
              // fBlock.fSolid := true;
              // fBlock.fHeight := 1;
              continue;
            end;

            if sub = 'non-solid' then begin
              fBlock.fBType := btBlock;
              //fBlock.fSolid := false;
              fBlock.fHeight := 0;
            end
            else if sub = 'block' then begin
              fBlock.fBType := btBlock;
              //fBlock.fSolid := true;
            end
            else if sub = 'technical' then begin
              fBlock.fBType := btBlock;
              //fBlock.fSolid := true;
            end
            else if sub = 'fluid' then begin
              fBlock.fBType := btFluid;
              //fBlock.fSolid := true;
            end
            else if sub = 'item' then begin
              fBlock.fBType := btItem;
              //fBlock.fSolid  := false;
              fBlock.fHeight := 0;
            end
            else if sub = 'plant' then begin
              fBlock.fBType := btPlant;
              //fBlock.fSolid := false;
              fBlock.fHeight := 0;
            end
            else if sub = 'ingredient' then begin
              fBlock.fBType := btIngredient;
              //fBlock.fSolid  := false;
              fBlock.fHeight := 0;
            end
            else if sub = 'raw materials' then begin
              fBlock.fBType := btRawMaterials;
              //fBlock.fSolid  := false;
              fBlock.fHeight := 0;
            end
            else if sub = 'tools' then begin
              fBlock.fBType := btTool;
              //fBlock.fSolid  := false;
              fBlock.fHeight := 0;
            end
            else if sub = 'weapons' then begin
              fBlock.fBType := btWeapons;
              //fBlock.fSolid  := false;
              fBlock.fHeight := 0;
            end
            else if sub = 'armor' then begin
              fBlock.fBType := btArmor;
              //fBlock.fSolid  := false;
              fBlock.fHeight := 0;
            end
            else if sub = 'food' then begin
              fBlock.fBType := btFood;
              //fBlock.fSolid  := false;
              fBlock.fHeight := 0;
            end

            else
              raise Exception.Create('Invalid type: '+sub);
          end;
        end
        // Title
        else if fValName = 'title' then
          fBlock.fTitle := INI.ReadString(fSesion, fValName, '')

        // Demage
        else if fValName = 'demage' then begin
          fVal := INI.ReadString(fSesion, fValName, '0');

          if isFLoat(fVal, fEVal) then
            fBlock.fDemage := fEVal;
        end

        // Resistance
        else if fValName = 'resistance' then begin
          fVal := INI.ReadString(fSesion, fValName, '0');

          if isFLoat(fVal, fEVal) then
            fBlock.fResistance := fEVal;
        end

        // Height
        else if fValName = 'height' then begin
          fVal := INI.ReadString(fSesion, fValName, '0');

          if isFLoat(fVal, fEVal) then
            fBlock.fHeight := fEVal;
        end

        // Stackable
        else if fValName = 'stackable' then
          fBlock.fStackable := INI.ReadInteger(fSesion, fValName, 0)

        // Color
        else if fValName = 'color' then begin
          fVal := INI.ReadString(fSesion, fValName, 'clNone');

          if Copy(fVal, 1, 1) = '#' then begin

            if IsNum('$'+Copy(fVal,6,2)+Copy(fVal,4,2)+Copy(fVal,2,2), fNVal) then
              fBlock.fColor := fNVal

          end
          else
            fBlock.fColor := StringToColor(fVal);
        end

        // Tools
        else if fValName = 'tool' then begin
          fVal := INI.ReadString(fSesion, fValName, '');

          for k := 1 to WordCount(fVal, [',']) do
            if isNum( '$'+ExtractWord(k, fVal, [',']), fNVal ) then
              fBlock.fTools.Add( fNVal );
        end

        // Hint
        else if fValName = 'hint' then begin
          fVal := INI.ReadString(fSesion, fValName, '');

          fBlock.fHint := ReplaceStr(fVal, '/n', #13#10);
        end;

      end;
    end;

  finally
    fSession.Free;
    fValues.Free;
  end;
end;

{ TBlockInfo }

constructor TBlockInfo.Create;
begin
  fBId           := btNone;
  fBType         := btBlock;
  //fSolid         := true;
  fTitle         := '';
  fDemage        := 0;
  fResistance    := -1;
  fTools         := TList<Integer>.Create;
  fStackable     := 0;
  fCraft         := TList.Create;
  fColor         := clNone;
  fHeight        := 1;
  fHint          := '';
end;

destructor TBlockInfo.Destroy;
begin
  fTools.Free;
  fCraft.Free;

  inherited;
end;

function TBlockInfo.GetTool(Ind: Integer): Integer;
begin
  if Ind >= fTools.Count then
    result := -1
  else
    result := fTools.Items[Ind];
end;

function TBlockInfo.GetToolCount: Integer;
begin
  result := fTools.Count;
end;

function TBlockInfo.BlockId:Integer;
begin
  result := fBId;
end;

function TBlockInfo.BlockType: TBType;
begin
  result := fBType;
end;

function TBlockInfo.Solid: Boolean;
begin
  result := fHeight = 1;
end;

function TBlockInfo.Title: String;
begin
  Result := fTitle;
end;

function TBlockInfo.Demage: Extended;
begin
  result := fDemage;
end;

function TBlockInfo.Resistance: Extended;
begin
  result := fResistance;
end;

function TBlockInfo.Stackable: Integer;
begin
  result := fStackable;
end;

function TBlockInfo.Height(Meta:Byte): Extended;
begin
  case fBId of
    btSnow:
      result := 1 * (Meta and $7) / 8;
    else
      result := fHeight;
  end;
end;

function TBlockInfo.Color: LongWord;
begin
  result := fColor;
end;

function TBlockInfo.Hint: string;
begin
  result := fHint;
end;

function TBlockInfo.TypeName: string;
begin
  Result := '';

  case fBType of
    btBlock:
      result := 'Block';

    btFluid:
      result := 'Fluid';

    btItem:
      result := 'Item';

    btPlant:
      result := 'Plant';

    btIngredient:
      result := 'Ingredient';

    btRawMaterials:
      result := 'Raw Materials';

    btTool:
      result := 'Tool';

    btWeapons:
      result := 'Weapons';

    btArmor:
      result := 'Armor';

    btFood:
      result := 'Food';

    else
      Result := '???';
  end;

  if Solid then
    result := result + '; Solid block';
end;

{ TEntityInfo }

constructor TMobInfo.Create;
begin
  fType := etPassive;
  fTitle := '';
end;

destructor TMobInfo.Destroy;
begin
  inherited;
end;

function TMobInfo.MType: TMType;
begin
  result := fType;
end;

function TMobInfo.Title: string;
begin
  result := fTitle;
end;

{ TEntityInfos }

constructor TEntityInfos.Create;
begin
  fMobs := TDictionary<Integer, IMobInfo>.Create;
  fObjs := TDictionary<Integer, IObjInfo>.Create;
end;

destructor TEntityInfos.Destroy;
begin
  fMobs.Free;
  fObjs.Free;

  inherited;
end;

function TEntityInfos.GetMobInfo(Id: Integer): IMobInfo;
begin
  if not fMobs.TryGetValue(Id, result) then
    result := nil;
end;

function TEntityInfos.GetObjInfo(Id:Integer):IObjInfo;
begin
  if not fObjs.TryGetValue(Id, result) then
    result := nil;
end;

procedure TEntityInfos.LoadData(INI: TIniFile);
var
  fSession:TStringList;
  fValues:TStringList;
  i, j, fKey:Integer;
  fSesion, fSType, fValName, fVal:string;
  fMInfo:TMobInfo;
  fOInfo:TObjInfo;
begin
  fSession := TStringList.Create;
  fValues  := TStringList.Create;
  try
    Ini.ReadSections(fSession);

    for i := 0 to fSession.Count-1 do begin
      fSesion := fSession.Strings[i];

      fSType := ExtractWord(1, fSesion, ['_']);
      if not isNum( ExtractWord(2, fSesion, ['_']), fKey) then continue;

      // Object
      if fSType = 'ov' then begin

        if fObjs.ContainsKey(fKey) then
          raise Exception.Create('Obj ID ready has');

        fOInfo := TObjInfo.Create;
        fObjs.Add(fKey, fOInfo);

        fValues.Clear;
        Ini.ReadSection(fSesion, fValues);

        for j := 0 to fValues.Count-1 do begin
          fValName := LowerCase( fValues.Strings[j] );

          // Title
          if fValName = 'title' then
            fOInfo.fTitle := INI.ReadString(fSesion, fValName, '');
        end;
      end
      // Mob
      else if fSType = 'm' then begin

        if fMobs.ContainsKey(fKey) then
          raise Exception.Create('Mob ID ready has');

        fMInfo := TMobInfo.Create;
        fMobs.Add(fKey, fMInfo);

        fValues.Clear;
        Ini.ReadSection(fSesion, fValues);

        for j := 0 to fValues.Count-1 do begin
          fValName := LowerCase( fValues.Strings[j] );

          // Type
          if fValName = 'type' then begin
            fVal := INI.ReadString(fSesion, fValName, '');

            if fVal = 'neutral' then
              fMInfo.fType := etNeutral

            else if fVal = 'passive' then
              fMInfo.fType := etPassive

            else if fVal = 'hostile' then
              fMInfo.fType := etHostile

            else
              raise Exception.Create('Invalid type: '+fVal);
          end
          // Title
          else if fValName = 'title' then
            fMInfo.fTitle := INI.ReadString(fSesion, fValName, '');

        end;
      end;
    end;

  finally
    fSession.Free;
    fValues.Free;
  end;
end;

{ TObjInfo }

constructor TObjInfo.Create;
begin
  fTitle := '';
end;

function TObjInfo.Title: string;
begin
  result := fTitle;
end;

initialization
  BloksInfos := TBloksInfos.Create;
  EntityInfos := TEntityInfos.Create;

finalization
  BloksInfos.Free;
  BloksInfos := nil;

  EntityInfos.Free;
  EntityInfos := nil;

end.
