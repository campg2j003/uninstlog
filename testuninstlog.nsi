/*
7/24/12 Added section to test ${File} with wildcards.
*/

LoadLanguageFile "${NSISDIR}\Contrib\Language files\English.nlf"
LoadLanguageFile "${NSISDIR}\Contrib\Language files\Spanish.nlf"
!include "uninstlog.nsh"
!define REG_ROOT "HKLM"
!define REG_UNINSTALL_PATH "Software\Microsoft\Windows\CurrentVersion\Uninstall\testuninstlog"
!define SHORTCUTNAME "Uninstall testuninstlog"
installdir "$PROGRAMFILES\testuninstlog"
OutFile "testuninstlog.exe"
Name "Test Uninstlog.nsh"
RequestExecutionLevel user
ShowInstDetails show
ShowUninstDetails show

ComponentText "This demonstrates the uninstlog.nsh header file which provides logging of installed files.  File uninstlog.nsh has a date stamp.  The shortcut ${SHORTCUTNAME} on the desktop will uninstall this test."
page components
page Directory
page InstFiles

UninstPage uninstConfirm
UninstPage instfiles

section "-install"
!insertmacro UNINSTLOG_OPENINSTALL
${AddItemAlways} "$INSTDIR"
${SetOutPath} "$INSTDIR"
${FileDated} "" "uninstlog.nsh"
${File} "${NSISDIR}\Include\" "strfunc.nsh"
${CreateShortcut} "$DESKTOP\${SHORTCUTNAME}.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
${WriteUninstaller} "$INSTDIR\uninstall.exe"
${WriteRegStr} ${rEG_ROOT} "${REG_UNINSTALL_PaTH}" "UninstallString" "$INSTDIR\uninstall.exe"
!insertmacro UNINSTLOG_CLOSEINSTALL
sectionend

section /O "Optional stuff, copy and rename"
!insertmacro UNINSTLOG_OPENINSTALL
${CreateDirectory} "$INSTDIR\optional" ;will be logged
${SetOutPath} "$INSTDIR\optional" ;will not be logged because it already exists
${AddItem} "$OUTDIR\something.nsh"
File /oname=something.nsh "${NSISDIR}\include\sections.nsh"
${CopyFiles} "$OUTDIR\something.nsh" "$OUTDIR\somethingelse.nsh" ;will be logged, but...
${Rename} "$OUTDIR\somethingelse.nsh" "$OUTDIR\somethingelse.dat"
!insertmacro UNINSTLOG_CLOSEINSTALL
sectionend

section /O "Optional stuff 2, an additional log file"
!undef UNINSTLOG
!define UNINSTLOG "uninstall2.dat"
!insertmacro UNINSTLOG_OPENINSTALL
${SetOutPath} "$INSTDIR"
${File} "${NSISDIR}\" "makensis.exe"
!insertmacro UNINSTLOG_CLOSEINSTALL
!undef UNINSTLOG
sectionend

section /O "Demonstrate FileDated, update uninstlog.nsh"
;Back to first log.
!insertmacro UNINSTLOG_OPENINSTALL
${SetOutPath} "$INSTDIR"
sleep 1000
; Update uninstlog.nsh
fileopen $0 "uninstlog.nsh" a
filewrite $0 ";Appended by update test.$\r$\n"
fileclose $0
!insertmacro UNINSTLOG_CLOSEINSTALL
sectionend

section /O "Test wildcards"
!insertmacro UNINSTLOG_OPENINSTALL
${CreateDirectory} "$INSTDIR\wildcard" ;will be logged
${SetOutPath} "$INSTDIR\wildcard" ;will not be logged because it already exists
${File} "${NSISDIR}\include\" "*.nsh"
!insertmacro UNINSTLOG_CLOSEINSTALL
sectionend

section "uninstall"
; We have to do uninstall2.dat first because install.log removes $INSTDIR.
IfFileExists "$INSTDIR\uninstall2.dat" 0 NotInstall2
!undef UninstLog
!define UninstLog "uninstall2.dat"
!insertmacro UNINSTLOG_UNINSTALL
NotInstall2:
!undef UninstLog
!insertmacro UNINSTLOG_UNINSTALL
End:
sectionend
