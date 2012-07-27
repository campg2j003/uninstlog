;uninstlog.nsh
/*
Adapted by GaryC from code from http://nsis.sourceforge.net/Uninstall_only_installed_files by Afrow UK with modifications by others, taken 8/3/11.

Version 0.0.2
Last modified 7/27/2012

Modifications:

7/27/12 by GaryC: Added display of time stamps in modified file messaage.
7/25/12 by GaryC: Updated documentation.
Added version number.
Deleted commented out section marked "was before sections" at end of file.
7/24/12 Previous saved to HG rev 2.
7/23/12 by GaryC: Fixed typos.
Macro AddItemAlways added sometime earlier, probably before or around 8/15/11.
8/15/11 by GaryC: Added note about AddItem needing to be called before the command it applies to.
8/15/11 by GaryC:
Added file existence checks in more macros.  Added check of $UninstLogAlwaysLog to macros that write files.
Added note about not working before SetCompressor /SOLID LZMA.
8/15/11 Initial modifications from WIKI code by GaryC:
In UninstallLog changed SetOutPath so that it doesn't log the path if it already exists.
In WriteRegDWORD changed WriteRegStr to WriteRegDWORD.
Converted uninstallLog to check file date and size of selected files and offer to not uninstall if files have been changed.
Made uninstall code into a function, moved to end of header.  
Moved close and delete of log file to right after it has been read.  This allows the INSTDIR to be removed.
Made section -openlogfile into macro UNINSTLOG_OPENINSTALL.
Added macro UNINSTLOG_CLOSEINSTALL to close log file, don't think it was done in original code.
Added !ifndef INSTALLLOGINCLUDED around header file contents.
In the uninstall section registry key removal code changed UNINSTALLPATH to REG_UNINSTALL_PATH.  Added !ifdefs so that if this or REG_APP_PATH are not defined, code for deleting the respective registry paths is not executed.
Made open install code into a function with macro that calls it.
Changed all macros so that they don't try to write if the log file is closed.  You can now disable logging by not calling INSTALLOPEN.
Added initialization call for ${UnStrTok}. Added define UNINSTLOGDEBUG.
Commented out section to open uninstall log.
Added variable $UninstLogAlwaysLog to log files even if they already exist.
Added documentation and example script.

Documentation:

This header file supports the ability to uninstall only the installed files.

It expects the following defines:
REG_ROOT, REG_APP_PATH, and REG_UNINSTALL_pATH.  If either of the latter two are undefined these registry keys won't be deleted even if they appear in the log file.


To use:
!include this file at the top of your scrip.
(Note: it gets an error if it is before "SetCompressor /SOLID LZMA": "Error: can't change compressor after data already got compressed or header already changed!".)
Define REG_ROOT, and REG_APP_PATH and/or REG_UNINSTALL_PATH if you want to use the ${WriteRegStr} or ${WriteRegDWORD}.
Start and end each install section like this:
section "Install section"
!insertmacro UNINSTLOG_OPENINSTALL
;Install section code
!insertmacro UNINSTLOG_CLOSEINSTALL
sectionend

When the log is closed the commands will be executed but not logged.

If you want the $INSTDIR to be removed automatically, you need to place 
${AddItemAlways} "$INSTDIR"
after you initially open the log.  This is because the $INSTDIR is already created at the time INSTLOG_OPENINSTALL is called, so it won't automatically be logged.  UNINSTLOG_OPENINSTALL does not automatically log it so that you don't add a directory automatically if you close and reopen a new install block.  (Automatically writing $INSTDIR on open makes a messy log but it might be okay since there are still files in the directory.)  If you run the installer again to add additional files, it will again write the $INSTDIR to the log.

In your uninstall section do:
!insertmacro UNINSTLOG_UNINSTALL
Note that this will push one entry on the stack for every entry in the log.

The following commands are provided, most of them simple forms of the similar NSIS commands:
${AddItem} Path --  adds a file or directory when the provided commands won't do the job.  Does not add the item if it exists, so you need to call this before the command that creates it.
${AddItemAlways} -- Like AddItem but adds item even if it exists.
${File} Path FileName -- path is path on source machine, must be empty or end with backspash.
${CreateShortcut} FilePath FilePointer Pamameters Icon IconIndex -- create shortcut FilePath that links to FilePointer.
${CopyFiles} source Dest - use full paths.
${Rename} Source Dest - use full paths.
${CreateDirectory} Path
${SetOutPath} Path
${WriteUninstaller} Path -- should use a fully-qualified path to make the logged value right.
${WriteRegStr} Root path Key Value-- path is the subkey, must be the value of either ${rEG_APP_PATH} or ${REG_UNINSTALL_PATH), which must be defined prior to use.
${WriteRegDWORD} -- see ${WriteRegStr}
${AddItemDated} -- same as AddItem but includes the date/time and size of the installed file so that the uninstaller can detect if files are modified.
${FileDated} -- same as ItemDated for the ${File} command.

Uses the following additional defines:
UninstLog -- name of the log file, defaults to uninstall.log.  You can define this just before calling UNINSTLOG_OPENINSTALL and UNINSTLOG_UNINSTALL to change the name of the log file.  You could even create separate logs.  You would then need to do more than one UNINSTLOG_UNINSTALL for each log file.  The name will stay defined until you change it.
UNINSTLOGDSEP -- separator used to separate file path and date-size for ${FileDated} and $ItemDated} macros (|)
INSTLOGDEBUG -- Activates debugging messages if defined.

and variables:
$UninstLog -- handle of log file, empty if log closed.  When the log is closed commands are executed but not logged.
$UninstLogAlwaysLog -- Normally a file is not logged if it exists on the target system.  You can cause files to always be logged even if they exist by setting the variable $UninstLogAlwaysLog to nonempty:
section "something"
;...
StrCpy $UninstLogAlwaysLog 1
${File} "" "MyFile.txt" ; will be logged even if it exists.
${FileDated} "" "AnotherFile" ;so will this one.
StrCpy $UninstLogAlwaysLog "" ; turn it off
${File} "" "filexxx" ; won't be logged if it exists.
;...
sectionend

Note that this header uses strfunc.nsh function ${UnStrTok}.  If you also include strfunc.nsh and use ${UnstrTok} after this file you can check to see if it has been initialized by:
!ifndef UnStrTokINCLUDED
${UnStrTok}
!endif

(This was discovered by inspection in v1.09.)

A note about wildcards.  Although you can use wildcards in ${File}, ${Rename}, and ${CopyFiles}, it could be dangerous and is not recommended unless you are sure you know what you are doing.  Suppose you do ${File} "*.txt" where the source directory has a few text files, but the directory into which they are installed already contains text files.  The value written to the log will be "*.txt", and this will cause the uninstaller to uninstall all of the .txt files in the folder, including the ones that were already installed.  You can't use wildcards at all with ${FileDated}, although there is no check for this.  (I need a way to run FindFirst/FindNext on the source system to do this.)

The project for which I modified this header file uses ${AddItem}, ${AddItemAlways}, ${AddItemDated}, ${File}, ${FileDated}, ${CreateDirectory}, ${CreateShortcut}, ${SetOutPath}, and ${WriteUninstaller}.  I have retained the other commands but I have not tested them much.

Bugs/enhancements:

Issue with ${AddItemDated}: If ${AddItemDated} follows the command that creates its file then it won't log unless UninstLogAlwaysLog is on.  If it precedes the command, the date-size stamp will be empty because it doesn't exist yet.  It was not modified to always log regardless of the value of $UninstLogAlwaysLog to make it clear that it is set.

Issue with ${WriteReg...} macros: For these macros to work REG_APP_PATH and REG_UNINSTALL_pATH must be defined, and these are the only registry paths that can be written.  This means that you must define these and use them in the path of any ${WriteReg...} calls to make them be deleted.  If there were an installed file with the same name as these values that was installed but had been deleted before the uninstall, it could cause these keys to be deleted from the registry unintentionally.  (I presume that's why the uninstaller code checks for these values before removing them-- otherwise any file in the log that doesn't exist on the system when uninstalled would be interpreted as a registry key to delete.)

To do: make all macros, variables, and !defines defined by this header start with "UninstLog" to avoid name collisions with other header files.

Example:
!include "uninstlog.nsh"
!define REG_ROOT "HKLM"
!define REG_UNINSTALL_PATH "Software\Microsoft\Windows\CurrentVersion\Uninstall\testuninstlog"
installdir "$PROGRAMFILES\testuninstlog"
OutFile "testuninstlog.exe"
Name "Test Uninstlog.nsh"
RequestExecutionLevel user
ShowInstDetails show
ShowUninstDetails show

ComponentText "This demonstrates the uninstlog.nsh header file which provides logging of installed files.  File uninstlog.nsh has a date stamp.  There is a shortcut on the desktop to uninstall this test."
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
${CreateShortcut} "$DESKTOP\Uninstall testuninstlog.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
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

*/

!ifndef UNINSTALLLOGINCLUDED
!define UNINSTALLLOGINCLUDED
!define UNINSTLOGDEBUG
!include "strfunc.nsh"
!include "filefunc.nsh"
;--------------------------------
; Configure UnInstall log to only remove what is installed
;-------------------------------- 
;The symbol that separates the date-size stamp from the file name.
!define UNINSTLOGDSEP |
Var UninstLog ; handle of log file
Var UninstLogAlwaysLog ;If nonempty, FileDated logs the file even if it exists.
;Ex:
;StrCpy $UninstLogAlwaysLog 1
;${FileDated} "" "something"
;StrCpy $UninstLogAlwaysLog "" ;turn it back off.
 
  ;Uninstall log file missing.
    LangString UninstLogMissing ${LANG_ENGLISH} "${UninstLog} not found!$\r$\nUninstallation cannot proceed!"
    LangString UninstLogModified ${LANG_ENGLISH} "File $R0 has been modified since it was installed.  Do you want to delete it?$\r$\nOriginal: $R3$\r$\nCurrent: $R4"
    LangString UninstLogShowDateSize ${LANG_ENGLISH} "$1 UTC $2 bytes"

;We need to make sure these functions haven't already been initialized outside this header.  Not documented, found by inspection.
;!ifndef StrTokINCLUDED
;${StrTok}
;!endif
!ifndef UnStrTokINCLUDED
${UnStrTok}
!endif

;AddItem macro-- Writes an item to the log, for times when you need options the macros don't support.
  !macro AddItem Path
    StrCmp $UninstLogAlwaysLog "" 0 +2 ; if nonempty, don't check existence.
    IfFileExists "${Path}" +3 ;if it exists we don't log it.
    StrCmp $UninstLog "" +2
    FileWrite $UninstLog "${Path}$\r$\n"
  !macroend
 
;AddItemAlways - Like AddItem but turns on $UninstLogAlwaysLog and restores it afterwards.
!macro AddItemAlways Path
push $UninstLogAlwaysLog
StrCpy $UninstLogAlwaysLog "1"
!insertmacro AddItem ${Path}
pop $UninstLogAlwaysLog
!macroend

;AddItemDated macro.  like AddItem but allows you to add date and size information to the entry so the uninstaller can tell if the file has been modified.
  ;Writes path with date-size appended.  path must exist.
  !macro AddItemDated Path
    StrCmp $UninstLogAlwaysLog "" 0 +2 ; if nonempty, don't check existence.
    IfFileExists "${Path}" +9 ;if it exists we don't log it.
    StrCmp $UninstLog "" +8 ;bail if uninstall log closed
    push $0
    push $1
    strCpy $0 ${Path}
    call UninstLogMakeDateSize
    FileWrite $UninstLog "${Path}${UNINSTLOGDSEP}$1$\r$\n"
    pop $1
    pop $0
  !macroend

;Consider ItemDated2 macro that would receive path Date (string containing YYYYMMDDhhmmss) size (string containing number of bytes in decimal).

;File macro
  ;Filepath is path on machine generating installer, must be empty or terminated with backslash.
  ;Use regular file command and AddItem macro for anything more exhotic.
  !macro File FilePath FileName
    StrCmp $UninstLogAlwaysLog "" 0 +2 ; if nonempty, don't check existence.
     IfFileExists "$OUTDIR\${FileName}" +3
     StrCmp $UninstLog "" +2
     ;detailprint "File: checking existence of $OUTDIR\${FileName}, $$UninstLog=$UninstLog" ; debug
     ;IfFileExists "$OUTDIR\${FileName}" +4 ; debug
     ;StrCmp $UninstLog "" +3 ; debug
     ;detailprint "File: logging $OUTDIR\${FileName} to $UninstLog"
     FileWrite $UninstLog "$OUTDIR\${FileName}$\r$\n"
     ;detailprint "File: executing File for ${FilePath}${FileName}"
     File "${FilePath}${FileName}"
  !macroend
 
;FileDated macro
  ;If $UninstLogAlwaysLog is nonempty, this will log the entry even if it exists on the target machine, which means it will be removed when uninstalled.  Otherwise it will not be logged if it exists.
  !macro FileDated FilePath FileName
    push $0
    push $1
    push $2
    StrCpy $2 ""
    StrCmp $UninstLogAlwaysLog "" 0 +2 ; if nonempty, don't check existence.
    IfFileExists "$OUTDIR\${FileName}" +3 ;if it exists we don't log it.
      strCmp $UninstLog "" +2 ; if log file not opened don't log
        strCpy $2 1 ;set flag to log file
    File "${FilePath}${FileName}"
    StrCmp $2 "" +4 ;skip logging
      StrCpy $0 "$OUTDIR\${FileName}" ;file on target system is here
      call UninstLogMakeDateSize
      ;Write something like Outdir\filename|201108041600005234
      FileWrite $UninstLog "$0${UNINSTLOGDSEP}$1$\r$\n"
    pop $2
    pop $1
    pop $0
  !macroend

  ;$0 - (in) file path (if it is a path it is so on the source system)
  ;$1 - (out) date-size yyyymmddhhmmsssize.
  ; We use a macro so we can get an install and uninstall version.  Prefix is either "" or "un."
  !macro UninstLogInsertMakeDateSize prefix
  function ${prefix}UninstLogMakeDateSize
     push $R0
     push $R1
     push $R2
     push $R3
     push $R4
     push $R5
     push $R6
     push $R7
     push $R8
     ${GetTime} "$0" "MS" $R0 $R1 $R2 $R3 $R4 $R5 $R6
     ; Get file size.
     FileOpen $R8 "$0" r
     FileSeek $R8 0 END $R7
     FileClose $R8
     ;return something like 201108041600005234 in $1
     StrCpy $1 "$R2$R1$R0$R4$R5$R6$R7"
     pop $R8
     pop $R7
     pop $R6
     pop $R5
     pop $R4
     pop $R3
     pop $R2
     pop $R1
     pop $R0
  functionend
  !macroend
  !insertmacro UninstLogInsertMakeDateSize ""
  !insertmacro UninstLogInsertMakeDateSize "un."

  ; Produce a string containing display of a stamp returned by UninstLogMakeDateSize.
  ; Input and output values are on the stack.
  function un.UninstLogShowDateSize
    exch $0
    push $1
    push $2
    strcpy $1 $0 14 ; copy the time part
    strcpy $2 $0 "" 14 ; copy the size (everything after the time)
    strcpy $0 "$(UninstLogShowDateSize)"
    pop $2
    pop $1
    exch $0
  functionend
  

;CreateShortcut macro
  !macro CreateShortcut FilePath FilePointer Parameters Icon IconIndex
    !ifdef UNINSTLOGDEBUG ; debug
    StrCpy $0 "doesn't"
    IfFileExists "${FilePath}" 0 +2
    StrCpy $0 "does"
    DetailPrint 'CreateShortcut: Checking existence of ${FilePath} which $0 exist.' ; debug
    !endif ; debug
    StrCmp $UninstLogAlwaysLog "" 0 +2 ; if nonempty, don't check existence.
    IfFileExists "${FilePath}" +3 ;if it exists we don't log it.
    StrCmp $UninstLog "" +2
      FileWrite $UninstLog "${FilePath}$\r$\n"
    CreateShortcut "${FilePath}" "${FilePointer}" "${Parameters}" "${Icon}" "${IconIndex}"
  !macroend
 
;Copy files macro
  !macro CopyFiles SourcePath DestPath
    StrCmp $UninstLogAlwaysLog "" 0 +2 ; if nonempty, don't check existence.
    IfFileExists "${DestPath}" +3
      StrCmp $UninstLog "" +2
        FileWrite $UninstLog "${DestPath}$\r$\n"
    CopyFiles "${SourcePath}" "${DestPath}"
  !macroend
 
;Rename macro
  !macro Rename SourcePath DestPath
    StrCmp $UninstLogAlwaysLog "" 0 +2 ; if nonempty, don't check existence.
    IfFileExists "${DestPath}" +3
      StrCmp $UninstLog "" +2
        FileWrite $UninstLog "${DestPath}$\r$\n"
    Rename "${SourcePath}" "${DestPath}"
  !macroend
 
;CreateDirectory macro
  !macro CreateDirectory Path
    StrCmp $UninstLogAlwaysLog "" 0 +2 ; if nonempty, don't check existence.
    IfFileExists "${Path}\*.*" +3 ;if it exists we don't log it.
    StrCmp $UninstLog "" +2
      FileWrite $UninstLog "${Path}$\r$\n"
    CreateDirectory "${Path}"
  !macroend
 
/*
;SetOutPath macro
; WARNING: If Path already exists the uninstaller will delete it.--GaryC
  !macro SetOutPath Path
    SetOutPath "${Path}"
    StrCmp $UninstLog "" +2
      FileWrite $UninstLog "${Path}$\r$\n"
  !macroend
*/
 
;SetOutPath macro
;Modified to not log Path if it already exists.--GaryC
;If you use this macro, the path you specify will be removed by the uninstaller if it does not already exist!
  !macro SetOutPath Path
    StrCmp $UninstLogAlwaysLog "" 0 +2 ; if nonempty, don't check existence.
    IfFileExists "${Path}\*.*" +3
      StrCmp $UninstLog "" +2
        FileWrite $UninstLog "${Path}$\r$\n"
    SetOutPath "${Path}"
  !macroend
 
;WriteUninstaller macro
  !macro WriteUninstaller Path
    StrCmp $UninstLogAlwaysLog "" 0 +2 ; if nonempty, don't check existence.
    IfFileExists "${Path}" +3 ;if it exists we don't log it.
    StrCmp $UninstLog "" +2
      FileWrite $UninstLog "${Path}$\r$\n"
    WriteUninstaller "${Path}"
  !macroend

;WriteRegStr macro
  !macro WriteRegStr RegRoot UnInstallPath Key Value
    StrCmp $UninstLog "" +2
      FileWrite $UninstLog "${RegRoot} ${UnInstallPath}$\r$\n"
    WriteRegStr "${RegRoot}" "${UnInstallPath}" "${Key}" "${Value}"
  !macroend
 
 
;WriteRegDWORD macro
;WARNING: This writes spaces between items while WriteRegStr does not.--GaryC
  !macro WriteRegDWORD RegRoot UnInstallPath Key Value
    StrCmp $UninstLog "" +2
      FileWrite $UninstLog "${RegRoot} ${UnInstallPath}$\r$\n"
    ;WriteRegStr "${RegRoot}" "${UnInstallPath}" "${Key}" "${Value}"
    WriteRegDWord "${RegRoot}" "${UnInstallPath}" "${Key}" "${Value}"
  !macroend

;Defines for commands
  ;AddItem macro
    !define AddItem "!insertmacro AddItem"
 
  ;AddItemAlways macro
    !define AddItemAlways "!insertmacro AddItemAlways"
 
  ;AddItemDated macro
    !define AddItemDated "!insertmacro AddItemDated"
 
  ;File macro
    !define File "!insertmacro File"
 
  ;FileDated macro
    !define FileDated "!insertmacro FileDated"
 
  ;CreateShortcut macro
    !define CreateShortcut "!insertmacro CreateShortcut"
 
  ;Copy files macro
    !define CopyFiles "!insertmacro CopyFiles"
 
  ;Rename macro
    !define Rename "!insertmacro Rename"
 
  ;CreateDirectory macro
    !define CreateDirectory "!insertmacro CreateDirectory"
 
  ;SetOutPath macro
    !define SetOutPath "!insertmacro SetOutPath"
 
  ;WriteUninstaller macro
    !define WriteUninstaller "!insertmacro WriteUninstaller"
 
  ;WriteRegStr macro
    !define WriteRegStr "!insertmacro WriteRegStr"
 
  ;WriteRegDWORD macro
    !define WriteRegDWORD "!insertmacro WriteRegDWORD" 
 
  ;Need to invoke before items are logged.
  !macro UNINSTLOG_OPENINSTALL
    ;Set the name of the uninstall log
    !ifndef UninstLog
      ;Default value if not defined outside.
      !define UninstLog "uninstall.log"
    !endif
    !ifdef UNINSTLOGDEBUG
      !echo "Opening ${UninstLog} at line ${__LINE__}"
    !endif
    push $0
    StrCpy $0 "${UninstLog}"
    call __UninstLogOpenInstall
    pop $0
  !macroend
  ; $0 -- path/filename of uninstall log.
  function __UninstLogOpenInstall
    push !1
    StrCpy $1 "" ;should we log $INSTDIR?
    IfFileExists $INSTDIR +2
      StrCpy $1 1 ;Doesn't exist, log it.
    CreateDirectory "$INSTDIR"
    IfFileExists "$INSTDIR\$0" LogAppend
      !ifdef UNINSTLOGDEBUG
        detailprint "Opening $0"
      !endif
      FileOpen $UninstLog "$INSTDIR\$0" w
    GoTo Opened
    LogAppend:
      !ifdef UNINSTLOGDEBUG
        detailprint "Opening $0 for append"
      !endif
      SetFileAttributes "$INSTDIR\$0" NORMAL
      FileOpen $UninstLog "$INSTDIR\$0" a
      FileSeek $UninstLog 0 END
    Opened:
    IntCmp $1 0 End
      ${AddItem} "$INSTDIR"
    End:
    pop $1
  functionend ; __UninstLogOpenInstall

  ;Need to invoke at end of installation.
  !macro UNINSTLOG_CLOSEINSTALL
    FileClose $UninstLog
    StrCpy $UninstLog ""
  !ifdef UNINSTLOGDEBUG
    !echo "Closing install log at line ${__LINE__}"
    detailprint "Closing install log at line ${__LINE__}"
  !endif
  !macroend

; $0 -- name of uninstall log file.
function un.UninstLogUninstall
  ;Can't uninstall if uninstall log is missing!
  IfFileExists "$INSTDIR\$0" +3
    MessageBox MB_OK|MB_ICONSTOP "$(UninstLogMissing)"
      Abort
 
  Push $1
  Push $R0
  Push $R1
  Push $R2
  push $R3
  push $R4
  SetFileAttributes "$INSTDIR\$0" NORMAL
  FileOpen $UninstLog "$INSTDIR\$0" r

  ;Set $OUTDIR to something we aren't going to remove so we can delete $INSTDIR.  This works because all of the paths in the log are absolute.
  SetOutPath $PROGRAMFILES

  ;Read in the uninstall log and put it on the stack.
  StrCpy $R1 -1 ; line count
  GetLineCount:
    ClearErrors
    FileRead $UninstLog $R0
    IntOp $R1 $R1 + 1
    StrCpy $R0 $R0 -2 ; remove $|R$\N
    Push $R0   
    IfErrors 0 GetLineCount
 
  FileClose $UninstLog
  Delete "$INSTDIR\$0"
  Pop $R0
 
  !ifdef UNINSTLOGDEBUG
    DetailPrint "Read $R1 log entries" ; debug
  !endif
  LoopRead:
    StrCmp $R1 0 LoopDone
    Pop $R0 ; log entry
 
    IfFileExists "$R0\*.*" 0 NotDir
      !ifdef UNINSTLOGDEBUG ; debug
        DetailPrint "Attempting to remove directory $R0" ; debug
      !endif ; debug
      RMDir $R0  #is dir
      !ifdef UNINSTLOGDEBUG ; debug
        IfErrors 0 +2 ; debug
          DetailPrint "Error after trying to remove directory $0" ; debug
      !endif ; debug
      Goto LoopNext
    NotDir:
    ${UnStrTok} $R2 $R0 ${UNINSTLOGDSEP} 1 0 ; date/size, 2nd token
    ${UnStrTok} $R0 "$R0" ${UNINSTLOGDSEP} 0 0 ;remove date/size from path.
    !ifdef UNINSTLOGDEBUG
      DetailPrint "After separating time stamp, time stamp=$R2, file=$R0" ; debug
    !endif
    StrCmp $R2 "" NoDateSize ;Skip call if no timestamp
      push $0
      StrCpy $0 $R0
      Call un.UninstLogMakeDateSize
      pop $0
      ;$1 contains date + size from file, $R2 is same from log entry.
    NoDateSize:
    IfFileExists $R0 0 NotFile
      StrCmp $R2 "" NoDateSize2 ;If this log entry had no date-size, skip compare
      !ifdef UNINSTLOGDEBUG
        DetailPrint "UninstLog: file $0 has time stamp $1, entry stamp is $R2" ; debug
      !endif
      StrCmp $R2 $1 DateSizeMatch
      push $R2 ; log entry stamp
      call un.UninstLogShowDateSize
      pop $R3 ; display of log entry stamp
      push $1 ; current stamp
      call un.UninstLogShowDateSize
      pop $R4 ; current file stamp
        MessageBox MB_YESNO $(UninstLogModified) IDNO NoDelete
pop $2
pop $1
      DateSizeMatch:
      NoDateSize2:
      Delete $R0 #is file
      NoDelete:
      Goto LoopNext
    NotFile:
    !ifdef REG_APP_PATH
      StrCmp $R0 "${REG_ROOT} ${REG_APP_PATH}" 0 NotRegAppPath
        DeleteRegKey ${REG_ROOT} "${REG_APP_PATH}" #is Reg Element
        Goto LoopNext
      NotRegAppPath:
    !endif ; REG_APP_PATH
    !ifdef REG_UNINSTALL_PATH
      StrCmp $R0 "${REG_ROOT} ${REG_UNINSTALL_PATH}" 0 +2
        DeleteRegKey ${REG_ROOT} "${UNINSTALL_PATH}" #is Reg Element
    !endif ; REG_UNINSTALL_PATH 

    LoopNext:
    IntOp $R1 $R1 - 1
    Goto LoopRead
  LoopDone:
  pop $R4
pop $R3
  Pop $R2
  Pop $R1
  Pop $R0
  Pop $1
 
  ;Remove registry keys
    ;DeleteRegKey ${REG_ROOT} "${REG_APP_PATH}"
    ;DeleteRegKey ${REG_ROOT} "${REG_UNINSTALL_PATH}"
functionend
!macro UNINSTLOG_UNINSTALL
  !ifndef UninstLog
    ;Default value if not defined outside.
    !define UninstLog "uninstall.log"
  !endif
  push $0
  StrCpy $0 "${UninstLog}"
  call un.UninstLogUninstall
  pop $0
!macroend

;-- end header file addition

!endif ; UNINSTALLLOGINCLUDED

;--- end uninstalllog.nsh code
