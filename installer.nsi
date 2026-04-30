!define APPNAME "Keyboard Language Switcher"
!define COMPANYNAME "Manus"
!define DESCRIPTION "Background keyboard language switcher with ALT+SHIFT+J"
!define VERSIONMAJOR 1
!define VERSIONMINOR 0
!define VERSIONBUILD 0

; Main Install settings
Name "${APPNAME}"
InstallDir "$PROGRAMFILES\${APPNAME}"
OutFile "KeyboardSwitcherSetup.exe"

; Request application privileges for Windows Vista/7/8/10
RequestExecutionLevel admin

Page directory
Page instfiles

Section "Install"
    SetOutPath $INSTDIR
    ; In a real scenario, we would bundle the compiled .exe
    ; File "keyboard_switcher.exe"
    ; For this task, we assume the user will have the AHK script or we provide the script.
    ; However, I will create a placeholder for the executable.
    File "keyboard_switcher.ahk"
    
    ; Create uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"
    
    ; Shortcuts
    CreateDirectory "$SMPROGRAMS\${APPNAME}"
    CreateShortcut "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\keyboard_switcher.ahk"
    CreateShortcut "$SMSTARTUP\${APPNAME}.lnk" "$INSTDIR\keyboard_switcher.ahk"
SectionEnd

Section "Uninstall"
    Delete "$INSTDIR\uninstall.exe"
    Delete "$INSTDIR\keyboard_switcher.ahk"
    RMDir "$INSTDIR"
    Delete "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk"
    Delete "$SMSTARTUP\${APPNAME}.lnk"
    RMDir "$SMPROGRAMS\${APPNAME}"
SectionEnd
