; AI Writing Assistant - InnoSetup Installer
; Compile: ISCC.exe installer.iss

#define MyAppName "AI Writing Assistant"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "AI Word"
#define MyAppExeName "ai-word-server.exe"

[Setup]
AppId={{B8F5C3A2-1D4E-4F6A-9B7C-3D2E5F8A1C4B}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={localappdata}\AI-Word-Addin
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=.\output
OutputBaseFilename=AI-Word-Setup-{#MyAppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
DisableWelcomePage=no
CloseApplications=no
ShowLanguageDialog=no

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "startup"; Description: "Auto-start with Windows (background)"; GroupDescription: "Startup options:"; Flags: checkedonce

[Files]
Source: "dist\ai-word-server.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "manifest.xml"; DestDir: "{app}"; Flags: ignoreversion
Source: "dist\src\index.html"; DestDir: "{app}\dist\src"; Flags: ignoreversion
Source: "dist\assets\*"; DestDir: "{app}\dist\assets"; Flags: ignoreversion recursesubdirs
Source: "assets\*"; DestDir: "{app}\assets"; Flags: ignoreversion recursesubdirs

[Registry]
Root: HKCU; Subkey: "Software\Microsoft\Office\Word\Addins\WordAiAddin"; ValueType: string; ValueName: "FriendlyName"; ValueData: "AI Writing Assistant"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Microsoft\Office\Word\Addins\WordAiAddin"; ValueType: string; ValueName: "Description"; ValueData: "AI-powered Word document generator with streaming support"
Root: HKCU; Subkey: "Software\Microsoft\Office\Word\Addins\WordAiAddin"; ValueType: string; ValueName: "Manifest"; ValueData: "http://localhost:3000/manifest.xml"
Root: HKCU; Subkey: "Software\Microsoft\Office\Word\Addins\WordAiAddin"; ValueType: dword; ValueName: "LoadBehavior"; ValueData: "3"
Root: HKCU; Subkey: "Software\Microsoft\Office\Word\Addins\WordAiAddin"; ValueType: string; ValueName: "ProviderName"; ValueData: "AI Word"
Root: HKCU; Subkey: "Software\Microsoft\Office\16.0\Common\Internet"; ValueType: dword; ValueName: "CreateObjectWhistlist"; ValueData: "2147483649"

[Icons]
Name: "{userstartup}\AI Writing Assistant"; Filename: "{app}\ai-word-server.exe"; WorkingDir: "{app}"; Tasks: startup; Parameters: "--silent"
Name: "{userprograms}\{#MyAppName}\AI Writing Assistant"; Filename: "{app}\ai-word-server.exe"; WorkingDir: "{app}"
Name: "{userprograms}\{#MyAppName}\Uninstall AI Writing Assistant"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\ai-word-server.exe"; WorkingDir: "{app}"; Flags: runhidden; Description: "Start AI Writing Assistant service"
Filename: "{code:FindWord}"; Flags: nowait postinstall skipifsilent; Description: "Open Microsoft Word"

[Code]
procedure KillRunningInstance;
var
  ResultCode: Integer;
begin
  if Exec(ExpandConstant('{sys}\taskkill.exe'), '/f /im ai-word-server.exe > nul 2>&1', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin
    // Allow a moment for the process to release file handles
    Sleep(500);
  end;
end;

function InitializeSetup: Boolean;
begin
  KillRunningInstance;
  Result := True;
end;

function FindWord(Param: String): String;
var
  Paths: array[0..5] of String;
  I: Integer;
begin
  Paths[0] := ExpandConstant('{commonpf64}\Microsoft Office\root\Office16\WINWORD.EXE');
  Paths[1] := ExpandConstant('{commonpf64}\Microsoft Office\Office16\WINWORD.EXE');
  Paths[2] := ExpandConstant('{commonpf32}\Microsoft Office\root\Office16\WINWORD.EXE');
  Paths[3] := ExpandConstant('{commonpf32}\Microsoft Office\Office16\WINWORD.EXE');
  Paths[4] := 'C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE';
  Paths[5] := 'WINWORD.EXE';
  for I := 0 to 5 do
  begin
    if FileExists(Paths[I]) then
    begin
      Result := Paths[I];
      Exit;
    end;
  end;
  Result := 'WINWORD.EXE';
end;
