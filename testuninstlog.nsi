/*
7/24/12 Added section to test ${File} with wildcards.
9/9/17  Adde section to test messages for localization.
9/13/17 Replaced sections.nsh with strfunc.nsh, per report that sections.nsh isn't in standard NSIS install.
9/16/17  Added test for LOGGING_DumpLog.
9/16/17 This is the Unicode version.
*/

Unicode true
LoadLanguageFile "${NSISDIR}\Contrib\Language files\English.nlf"
LoadLanguageFile "${NSISDIR}\Contrib\Language files\Spanish.nlf"
LoadLanguageFile "${NSISDIR}\Contrib\Language files\German.nlf"
LoadLanguageFile "${NSISDIR}\Contrib\Language files\Finnish.nlf"
LoadLanguageFile "${NSISDIR}\Contrib\Language files\French.nlf"
;LangStrings
!include "uninstlog_enu.nsh"
!include "uninstlog_esn.nsh"
!include "uninstlog_deu.nsh"
!include "uninstlog_fin.nsh"
!include "uninstlog_fra.nsh"
!include "uninstlog.nsh"
!include "logging.nsh"
!define REG_ROOT "HKLM"
!define REG_UNINSTALL_PATH "Software\Microsoft\Windows\CurrentVersion\Uninstall\testuninstlog"
!define SHORTCUTNAME "Uninstall testuninstlog_unicode"
installdir "$LOCALAPPDATA\testuninstlog_unicode"
OutFile "testuninstlog_unicode.exe"
Name "Test Uninstlog.nsh (Unicode)"
RequestExecutionLevel user
ShowInstDetails show
ShowUninstDetails show

ComponentText "This demonstrates the uninstlog.nsh header file which provides logging of installed files.  File uninstlog.nsh has a date stamp.  The shortcut ${SHORTCUTNAME} on the desktop will uninstall this test.  This is a Unicode installer."
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
File /oname=something.nsh "${NSISDIR}\include\strfunc.nsh"
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

!macro TestLangString Name ShouldBe
  MessageBox MB_OK "Testing ${Name}$\r$\nEnglish:$\r$\n${ShouldBe}$\r$\nTranslation:$\r$\n$(${Name})"
!MacroEnd
!define TestLangString "!insertmacro TestLangString"

section /O "Test messages"
  ;test Unin stLogMissing
  StrCpy $0 "abc.txt"
  ${TestLangString} UninstLogMissing "$0 not found!$\r$\nUninstallation cannot proceed!"
  ;Displays a files timestamp and size.  $1 = timestamp, $2 = size in bytes.
  StrCpy $1 "20170909140507"
  StrCpy $2 "123"
  ${TestLangString} UninstLogShowDateSize "$1 UTC $2 bytes"
  StrCpy $R3 $(UninstLogShowDateSize)
  StrCpy $1 "20170909140509"
  StrCpy $2 "234"
  StrCpy $R4 $(UninstLogShowDateSize)
  StrCpy $R0 $0
  ${TestLangString} UninstLogModified "File $R0 has been modified since it was installed.  Do you want to delete it and all other modified files?$\r$\nOriginal: $R3$\r$\nCurrent: $R4"
sectionend

section /O "Test dumplog"
DetailPrint "Testing dumplog."
push "$INSTDIR\installer.log"
call LOGGING_DumpLog
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

Function .onInit

	;Language selection dialog

	Push ""
	Push ${LANG_ENGLISH}
	Push English
	;Push ${LANG_DUTCH}
	;Push Dutch
	Push ${LANG_FRENCH}
	Push French
	Push ${LANG_GERMAN}
	Push German
	;Push ${LANG_KOREAN}
	;Push Korean
	;Push ${LANG_RUSSIAN}
	;Push Russian
	Push ${LANG_SPANISH}
	Push Spanish
	;Push ${LANG_SWEDISH}
	;Push Swedish
	;Push ${LANG_TRADCHINESE}
	;Push "Traditional Chinese"
	;Push ${LANG_SIMPCHINESE}
	;Push "Simplified Chinese"
	;Push ${LANG_SLOVAK}
	;Push Slovak
	Push ${LANG_FINNISH}
	Push Finnish
	Push A ; A means auto count languages
	       ; for the auto count to work the first empty push (Push "") must remain
	LangDLL::LangDialog "Installer Language" "Please select the language of the installer"

	Pop $LANGUAGE
	StrCmp $LANGUAGE "cancel" 0 +2
		Abort
FunctionEnd
