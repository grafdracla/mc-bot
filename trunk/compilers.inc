{$DEFINE BORLAND}

{ Set FreePascal to Delphi mode }
{$IFDEF FPC}
  {$MODE DELPHI}
  {$ASMMODE Intel}
  {$UNDEF BORLAND}
  {$DEFINE CPUASM}
   // FPC defines CPU32, CPU64 and Unix automatically
{$ENDIF}

{$IFDEF BORLAND}
  {$IFDEF LINUX}
    {$DEFINE KYLIX}
  {$ENDIF LINUX}
  {$IFNDEF CLR}
    {$DEFINE CPU386}  // For Borland compilers select the x86 compat assembler by default
    {$DEFINE CPU32}   // Assume Borland compilers are 32-bit (rather than 64-bit)
    {$DEFINE CPUASM}
  {$ENDIF ~CLR}
{$ENDIF BORLAND}

{$IFDEF BORLAND}
  {$IFDEF KYLIX}
    {$I kylix.inc} // FPC incompatible stuff
  {$ELSE ~KYLIX}

    {$DEFINE UNKNOWN_COMPILER_VERSION}

    {$IFDEF VER80}
      {$DEFINE COMPILER1}
      {$DEFINE DELPHI1}
      {$DEFINE DELPHICOMPILER1}
      {$DEFINE RTL80_UP}
      {$UNDEF UNKNOWN_COMPILER_VERSION}
    {$ENDIF}

    {$IFDEF VER90}
      {$DEFINE COMPILER2}
      {$DEFINE DELPHI2}
      {$DEFINE DELPHICOMPILER2}
      {$DEFINE RTL90_UP}
      {$UNDEF UNKNOWN_COMPILER_VERSION}
    {$ENDIF}

    {$IFDEF VER93}
      {$DEFINE COMPILER2}
      {$DEFINE BCB1}
      {$DEFINE BCB}
      {$DEFINE RTL93_UP}
      {$UNDEF UNKNOWN_COMPILER_VERSION}
    {$ENDIF}

    {$IFDEF VER100}
      {$DEFINE COMPILER3}
      {$DEFINE DELPHI3}
      {$DEFINE DELPHICOMPILER3}
      {$DEFINE RTL100_UP}
      {$UNDEF UNKNOWN_COMPILER_VERSION}
    {$ENDIF}

    {$IFDEF VER110}
      {$DEFINE COMPILER35}
      {$DEFINE BCB3}
      {$DEFINE BCB}
      {$DEFINE RTL110_UP}
      {$UNDEF UNKNOWN_COMPILER_VERSION}
    {$ENDIF}

    {$IFDEF VER120}
      {$DEFINE COMPILER4}
      {$DEFINE DELPHI4}
      {$DEFINE DELPHICOMPILER4}
      {$DEFINE RTL120_UP}
      {$UNDEF UNKNOWN_COMPILER_VERSION}
    {$ENDIF}

    {$IFDEF VER125}
      {$DEFINE COMPILER4}
      {$DEFINE BCB4}
      {$DEFINE BCB}
      {$DEFINE RTL125_UP}
      {$UNDEF UNKNOWN_COMPILER_VERSION}
    {$ENDIF}

    {$IFDEF VER130}
      {$DEFINE COMPILER5}
      {$IFDEF BCB}
        {$DEFINE BCB5}
      {$ELSE}
        {$DEFINE DELPHI5}
        {$DEFINE DELPHICOMPILER5}
      {$ENDIF}
      {$DEFINE RTL130_UP}
      {$UNDEF UNKNOWN_COMPILER_VERSION}
    {$ENDIF}

    {$IFDEF VER140}
      {$DEFINE COMPILER6}
      {$IFDEF BCB}
        {$DEFINE BCB6}
      {$ELSE}
        {$DEFINE DELPHI6}
        {$DEFINE DELPHICOMPILER6}
      {$ENDIF}
      {$DEFINE RTL140_UP}
      {$UNDEF UNKNOWN_COMPILER_VERSION}
    {$ENDIF}

    {$IFDEF VER150}
      {$DEFINE COMPILER7}
      {$DEFINE DELPHI7}
      {$DEFINE DELPHICOMPILER7}
      {$DEFINE RTL150_UP}
      {$UNDEF UNKNOWN_COMPILER_VERSION}
    {$ENDIF}

    {$IFDEF VER160}
      {$DEFINE BDS2}
      {$DEFINE BDS}
      {$IFDEF CLR}
        {$DEFINE CLR10}
      {$ENDIF CLR}
      {$DEFINE COMPILER8}
      {$DEFINE DELPHI8}
      {$DEFINE DELPHICOMPILER8}
      {$DEFINE RTL160_UP}
      {$UNDEF UNKNOWN_COMPILER_VERSION}
    {$ENDIF}

    {$IFDEF VER170}
      {$DEFINE BDS3}
      {$DEFINE BDS}
      {$IFDEF CLR}
        {$DEFINE CLR11}
      {$ENDIF CLR}
      {$DEFINE COMPILER9}
      {$DEFINE DELPHI9}
      {$DEFINE DELPHI2005} // synonym to DELPHI9
      {$DEFINE DELPHICOMPILER9}
      {$DEFINE RTL170_UP}
      {$UNDEF UNKNOWN_COMPILER_VERSION}
    {$ENDIF}

    {$IFDEF VER180}
      {$DEFINE BDS}
      {$IFDEF CLR}
        {$DEFINE CLR11}
      {$ENDIF CLR}
      {$IFDEF VER185}
        {$DEFINE BDS5}
        {$DEFINE COMPILER11}
        {$IFDEF BCB}
          {$DEFINE BCB11}
        {$ELSE}
          {$DEFINE DELPHI11}
          {$DEFINE DELPHI2007} // synonym to DELPHI11
          {$DEFINE DELPHICOMPILER11}
        {$ENDIF}
        {$DEFINE RTL185_UP}
      {$ELSE ~~VER185}
        {$DEFINE BDS4}
        {$DEFINE COMPILER10}
        {$IFDEF BCB}
          {$DEFINE BCB10}
        {$ELSE}
          {$DEFINE DELPHI10}
          {$DEFINE DELPHI2006} // synonym to DELPHI10
          {$DEFINE DELPHICOMPILER10}
        {$ENDIF}
        {$DEFINE RTL180_UP}
      {$ENDIF ~VER185}
      {$UNDEF UNKNOWN_COMPILER_VERSION}
    {$ENDIF}

    {$IFDEF VER190} // Delphi 2007 for .NET
      {$DEFINE BDS}
      {$DEFINE BDS5}
      {$IFDEF CLR}
        {$DEFINE CLR20}
      {$ENDIF CLR}
      {$DEFINE COMPILER11}
      {$DEFINE DELPHI11}
      {$DEFINE DELPHI2007} // synonym to DELPHI11
      {$DEFINE DELPHICOMPILER11}
      {$DEFINE RTL190_UP}
      {$UNDEF UNKNOWN_COMPILER_VERSION}
    {$ENDIF VER190}

    {$IFDEF VER200} // RAD Studio 2009
      {$DEFINE BDS}
      {$DEFINE BDS6}
      {$IFDEF CLR}
        {$DEFINE CLR20}
      {$ENDIF CLR}
      {$DEFINE COMPILER12}
      {$IFDEF BCB}
        {$DEFINE BCB12}
      {$ELSE}
        {$DEFINE DELPHI12}
        {$DEFINE DELPHI2009} // synonym to DELPHI12
        {$DEFINE DELPHICOMPILER12}
      {$ENDIF BCB}
      {$IFDEF CLR}
        {$DEFINE RTL190_UP}
      {$ELSE}
        {$DEFINE RTL200_UP}
      {$ENDIF}
      {$UNDEF UNKNOWN_COMPILER_VERSION}
    {$ENDIF VER200}

    {$IFDEF VER210} // RAD Studio 2010
      {$DEFINE BDS}
      {$DEFINE BDS7}
      {$DEFINE COMPILER14}
      {$IFDEF BCB}
        {$DEFINE BCB14}
      {$ELSE}
        {$DEFINE DELPHI14}
        {$DEFINE DELPHI2010} // synonym to DELPHI14
        {$DEFINE DELPHICOMPILER14}
      {$ENDIF BCB}
      {$DEFINE RTL210_UP}
      {$UNDEF UNKNOWN_COMPILER_VERSION}
    {$ENDIF VER210}

    {$IFDEF UNKNOWN_COMPILER_VERSION} // adjust for newer version (always use latest version)
      {$DEFINE BDS}
      {$DEFINE BDS7}
      {$DEFINE COMPILER14}
      {$IFDEF BCB}
        {$DEFINE BCB14}
      {$ELSE}
        {$DEFINE DELPHI14}
        {$DEFINE DELPHI2010} // synonym to DELPHI14
        {$DEFINE DELPHICOMPILER14}
      {$ENDIF BCB}
      {$DEFINE RTL210_UP}
      {$UNDEF UNKNOWN_COMPILER_VERSION}
    {$ENDIF}

  {$ENDIF ~KYLIX}

  {$IFDEF BCB}
    {$DEFINE CPPBUILDER}
    {$DEFINE BCBCOMPILER}
  {$ELSE ~BCB}
    {$DEFINE DELPHI}
    {$DEFINE DELPHICOMPILER}
  {$ENDIF ~BCB}

{$ENDIF BORLAND}


{------------------------------------------------------------------------------}
{ DELPHIX_UP from DELPHIX mappings                                             }
{------------------------------------------------------------------------------}

{$IFDEF DELPHI14} {$DEFINE DELPHI14_UP} {$ENDIF}
{$IFDEF DELPHI12} {$DEFINE DELPHI12_UP} {$ENDIF}
{$IFDEF DELPHI11} {$DEFINE DELPHI11_UP} {$ENDIF}
{$IFDEF DELPHI10} {$DEFINE DELPHI10_UP} {$ENDIF}
{$IFDEF DELPHI9}  {$DEFINE DELPHI9_UP}  {$ENDIF}
{$IFDEF DELPHI8}  {$DEFINE DELPHI8_UP}  {$ENDIF}
{$IFDEF DELPHI7}  {$DEFINE DELPHI7_UP}  {$ENDIF}
{$IFDEF DELPHI6}  {$DEFINE DELPHI6_UP}  {$ENDIF}
{$IFDEF DELPHI5}  {$DEFINE DELPHI5_UP}  {$ENDIF}
{$IFDEF DELPHI4}  {$DEFINE DELPHI4_UP}  {$ENDIF}
{$IFDEF DELPHI3}  {$DEFINE DELPHI3_UP}  {$ENDIF}
{$IFDEF DELPHI2}  {$DEFINE DELPHI2_UP}  {$ENDIF}
{$IFDEF DELPHI1}  {$DEFINE DELPHI1_UP}  {$ENDIF}

{------------------------------------------------------------------------------}
{ DELPHIX_UP from DELPHIX_UP mappings                                          }
{------------------------------------------------------------------------------}

{$IFDEF DELPHI14_UP}
  {$DEFINE DELPHI2010_UP} // synonym to DELPHI14_UP
  {$DEFINE DELPHI12_UP}
{$ENDIF}

{$IFDEF DELPHI12_UP}
  {$DEFINE DELPHI2009_UP} // synonym to DELPHI12_UP
  {$DEFINE DELPHI11_UP}
{$ENDIF}

{$IFDEF DELPHI11_UP}
  {$DEFINE DELPHI2007_UP} // synonym to DELPHI11_UP
  {$DEFINE DELPHI10_UP}
{$ENDIF}

{$IFDEF DELPHI10_UP}
  {$DEFINE DELPHI2006_UP} // synonym to DELPHI10_UP
  {$DEFINE DELPHI9_UP}
{$ENDIF}

{$IFDEF DELPHI9_UP}
  {$DEFINE DELPHI2005_UP} // synonym to DELPHI9_UP
  {$DEFINE DELPHI8_UP}
{$ENDIF}

{$IFDEF DELPHI8_UP} {$DEFINE DELPHI7_UP} {$ENDIF}
{$IFDEF DELPHI7_UP} {$DEFINE DELPHI6_UP} {$ENDIF}
{$IFDEF DELPHI6_UP} {$DEFINE DELPHI5_UP} {$ENDIF}
{$IFDEF DELPHI5_UP} {$DEFINE DELPHI4_UP} {$ENDIF}
{$IFDEF DELPHI4_UP} {$DEFINE DELPHI3_UP} {$ENDIF}
{$IFDEF DELPHI3_UP} {$DEFINE DELPHI2_UP} {$ENDIF}
{$IFDEF DELPHI2_UP} {$DEFINE DELPHI1_UP} {$ENDIF}

{------------------------------------------------------------------------------}
{ BCBX_UP from BCBX mappings                                                   }
{------------------------------------------------------------------------------}

{$IFDEF BCB14} {$DEFINE BCB14_UP} {$ENDIF}
{$IFDEF BCB12} {$DEFINE BCB12_UP} {$ENDIF}
{$IFDEF BCB11} {$DEFINE BCB11_UP} {$ENDIF}
{$IFDEF BCB10} {$DEFINE BCB10_UP} {$ENDIF}
{$IFDEF BCB6}  {$DEFINE BCB6_UP}  {$ENDIF}
{$IFDEF BCB5}  {$DEFINE BCB5_UP}  {$ENDIF}
{$IFDEF BCB4}  {$DEFINE BCB4_UP}  {$ENDIF}
{$IFDEF BCB3}  {$DEFINE BCB3_UP}  {$ENDIF}
{$IFDEF BCB1}  {$DEFINE BCB1_UP}  {$ENDIF}

{------------------------------------------------------------------------------}
{ BCBX_UP from BCBX_UP mappings                                                }
{------------------------------------------------------------------------------}

{$IFDEF BCB14_UP} {$DEFINE BCB12_UP} {$ENDIF}
{$IFDEF BCB12_UP} {$DEFINE BCB11_UP} {$ENDIF}
{$IFDEF BCB11_UP} {$DEFINE BCB10_UP} {$ENDIF}
{$IFDEF BCB10_UP} {$DEFINE BCB6_UP}  {$ENDIF}
{$IFDEF BCB6_UP}  {$DEFINE BCB5_UP}  {$ENDIF}
{$IFDEF BCB5_UP}  {$DEFINE BCB4_UP}  {$ENDIF}
{$IFDEF BCB4_UP}  {$DEFINE BCB3_UP}  {$ENDIF}
{$IFDEF BCB3_UP}  {$DEFINE BCB1_UP}  {$ENDIF}

{------------------------------------------------------------------------------}
{ BDSX_UP from BDSX mappings                                                   }
{------------------------------------------------------------------------------}

{$IFDEF BDS7} {$DEFINE BDS7_UP} {$ENDIF}
{$IFDEF BDS6} {$DEFINE BDS6_UP} {$ENDIF}
{$IFDEF BDS5} {$DEFINE BDS5_UP} {$ENDIF}
{$IFDEF BDS4} {$DEFINE BDS4_UP} {$ENDIF}
{$IFDEF BDS3} {$DEFINE BDS3_UP} {$ENDIF}
{$IFDEF BDS2} {$DEFINE BDS2_UP} {$ENDIF}

{------------------------------------------------------------------------------}
{ BDSX_UP from BDSX_UP mappings                                                }
{------------------------------------------------------------------------------}

{$IFDEF BDS7_UP} {$DEFINE BDS6_UP} {$ENDIF}
{$IFDEF BDS6_UP} {$DEFINE BDS5_UP} {$ENDIF}
{$IFDEF BDS5_UP} {$DEFINE BDS4_UP} {$ENDIF}
{$IFDEF BDS4_UP} {$DEFINE BDS3_UP} {$ENDIF}
{$IFDEF BDS3_UP} {$DEFINE BDS2_UP} {$ENDIF}

{------------------------------------------------------------------------------}
{ DELPHICOMPILERX_UP from DELPHICOMPILERX mappings                             }
{------------------------------------------------------------------------------}

{$IFDEF DELPHICOMPILER14} {$DEFINE DELPHICOMPILER14_UP} {$ENDIF}
{$IFDEF DELPHICOMPILER12} {$DEFINE DELPHICOMPILER12_UP} {$ENDIF}
{$IFDEF DELPHICOMPILER11} {$DEFINE DELPHICOMPILER11_UP} {$ENDIF}
{$IFDEF DELPHICOMPILER10} {$DEFINE DELPHICOMPILER10_UP} {$ENDIF}
{$IFDEF DELPHICOMPILER9}  {$DEFINE DELPHICOMPILER9_UP}  {$ENDIF}
{$IFDEF DELPHICOMPILER8}  {$DEFINE DELPHICOMPILER8_UP}  {$ENDIF}
{$IFDEF DELPHICOMPILER7}  {$DEFINE DELPHICOMPILER7_UP}  {$ENDIF}
{$IFDEF DELPHICOMPILER6}  {$DEFINE DELPHICOMPILER6_UP}  {$ENDIF}
{$IFDEF DELPHICOMPILER5}  {$DEFINE DELPHICOMPILER5_UP}  {$ENDIF}
{$IFDEF DELPHICOMPILER4}  {$DEFINE DELPHICOMPILER4_UP}  {$ENDIF}
{$IFDEF DELPHICOMPILER3}  {$DEFINE DELPHICOMPILER3_UP}  {$ENDIF}
{$IFDEF DELPHICOMPILER2}  {$DEFINE DELPHICOMPILER2_UP}  {$ENDIF}
{$IFDEF DELPHICOMPILER1}  {$DEFINE DELPHICOMPILER1_UP}  {$ENDIF}

{------------------------------------------------------------------------------}
{ DELPHICOMPILERX_UP from DELPHICOMPILERX_UP mappings                          }
{------------------------------------------------------------------------------}

{$IFDEF DELPHICOMPILER14_UP} {$DEFINE DELPHICOMPILER12_UP} {$ENDIF}
{$IFDEF DELPHICOMPILER12_UP} {$DEFINE DELPHICOMPILER11_UP} {$ENDIF}
{$IFDEF DELPHICOMPILER11_UP} {$DEFINE DELPHICOMPILER10_UP} {$ENDIF}
{$IFDEF DELPHICOMPILER10_UP} {$DEFINE DELPHICOMPILER9_UP}  {$ENDIF}
{$IFDEF DELPHICOMPILER9_UP}  {$DEFINE DELPHICOMPILER8_UP}  {$ENDIF}
{$IFDEF DELPHICOMPILER8_UP}  {$DEFINE DELPHICOMPILER7_UP}  {$ENDIF}
{$IFDEF DELPHICOMPILER8_UP}  {$DEFINE DELPHICOMPILER7_UP}  {$ENDIF}
{$IFDEF DELPHICOMPILER7_UP}  {$DEFINE DELPHICOMPILER6_UP}  {$ENDIF}
{$IFDEF DELPHICOMPILER6_UP}  {$DEFINE DELPHICOMPILER5_UP}  {$ENDIF}
{$IFDEF DELPHICOMPILER5_UP}  {$DEFINE DELPHICOMPILER4_UP}  {$ENDIF}
{$IFDEF DELPHICOMPILER4_UP}  {$DEFINE DELPHICOMPILER3_UP}  {$ENDIF}
{$IFDEF DELPHICOMPILER3_UP}  {$DEFINE DELPHICOMPILER2_UP}  {$ENDIF}
{$IFDEF DELPHICOMPILER2_UP}  {$DEFINE DELPHICOMPILER1_UP}  {$ENDIF}
