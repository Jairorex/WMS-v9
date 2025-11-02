; ========================================
; Script de Instalación InnoSetup
; WMS Escasan - Sistema de Gestión de Almacén
; ========================================

#define MyAppName "WMS Escasan"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Escasan"
#define MyAppURL "http://www.escasan.com"
#define MyAppExeName "WMS Escasan.url"

[Setup]
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=LICENCIA.txt
InfoBeforeFile=INFO.txt
OutputDir=installer
OutputBaseFilename=WMS-Escasan-Setup-v{#MyAppVersion}
SetupIconFile=icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1; Check: not IsAdminInstallMode

[Files]
Source: "backend\*"; DestDir: "{app}\backend"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "node_modules\*,vendor\*,storage\framework\cache\*,storage\framework\sessions\*,storage\framework\views\*,storage\logs\*.log,.git\*"
Source: "frontend\*"; DestDir: "{app}\frontend"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "node_modules\*,dist\*,.git\*"
Source: "database\*"; DestDir: "{app}\database"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "scripts\*"; DestDir: "{app}\scripts"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "docs\*"; DestDir: "{app}\docs"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "README.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "LICENCIA.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "INFO.txt"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "http://localhost:5174"; IconFileName: "{app}\frontend\public\favicon.ico"
Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "http://localhost:5174"; IconFileName: "{app}\frontend\public\favicon.ico"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "http://localhost:5174"; IconFileName: "{app}\frontend\public\favicon.ico"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\scripts\instalar.bat"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: shellexec postinstall skipifsilent

[Code]
procedure InitializeWizard;
begin
  WizardForm.LicenseLabel.Visible := False;
  WizardForm.LicenseAcceptedRadio.Checked := True;
end;

function InitializeSetup(): Boolean;
var
  ErrorCode: Integer;
begin
  Result := True;
  
  // Verificar requisitos
  if not RegKeyExists(HKEY_LOCAL_MACHINE, 'SOFTWARE\PHP') then
  begin
    if MsgBox('PHP no está instalado. ¿Desea descargar PHP 8.1+?', mbConfirmation, MB_YESNO) = IDYES then
    begin
      ShellExec('open', 'https://windows.php.net/download/', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
    end;
    Result := True; // Continuar instalación aunque falte PHP
  end;
  
  if not RegKeyExists(HKEY_LOCAL_MACHINE, 'SOFTWARE\Node.js') then
  begin
    if MsgBox('Node.js no está instalado. ¿Desea descargar Node.js 18+?', mbConfirmation, MB_YESNO) = IDYES then
    begin
      ShellExec('open', 'https://nodejs.org/', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
    end;
    Result := True; // Continuar instalación aunque falte Node.js
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
begin
  if CurStep = ssPostInstall then
  begin
    // Ejecutar script de instalación automática
    if FileExists(ExpandConstant('{app}\scripts\instalar.bat')) then
    begin
      if MsgBox('¿Desea ejecutar la configuración automática ahora?', mbConfirmation, MB_YESNO) = IDYES then
      begin
        Exec(ExpandConstant('{app}\scripts\instalar.bat'), '', '', SW_SHOWNORMAL, ewWaitUntilTerminated, ResultCode);
      end;
    end;
  end;
end;

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
