;uninstlog.nsh
/*
Adapted by GaryC from code from http://nsis.sourceforge.net/Uninstall_only_installed_files by Afrow UK with modifications by others, taken 8/3/11.

Version 0.1.1
Last modified 3/31/2016

Modifications:

*/

!ifndef UNINSTALLLOGINCLUDED
!define UNINSTALLLOGINCLUDED
!define UNINSTLOGDEBUG
!include "strfunc.nsh"
!include "filefunc.nsh"
!include "logging.nsh"
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

;We need to make sure these functions haven't already been initialized outside this header.  Not documented, found by inspection.
;!ifndef StrTokINCLUDED
;${StrTok}
;!endif
!ifndef UnStrTokINCLUDED
${UnStrTok}
!endif

;AddItem macro-- Writes an item to the log, for times when you need options the other macros don't support.
  ;path -- path of file on target system to be logged.
  !macro AddItem Path
    ${If} $UninstLogAlwaysLog != "" ; if nonempty, don't check existence.
    ${OrIfNot} ${FileExists} "${Path}";if it exists we don't log it.
      ${If} $UninstLog != ""
        FileWrite $UninstLog "${Path}$\r$\n"
      ${EndIf} ; if log opened
    ${EndIf} ; IfNot fileExists
  !macroend
 
;AddItemAlways - Like AddItem but turns on $UninstLogAlwaysLog and restores it afterwards.
!macro AddItemAlways Path
push $UninstLogAlwaysLog
StrCpy $UninstLogAlwaysLog "1"
!insertmacro AddItem ${Path}
pop $UninstLogAlwaysLog
!macroend

;AddItemDated macro.  like AddItem but allows you to add date and size information to the entry so the uninstaller can tell if the file has been modified.
  ;Writes path with date-size appended.  path references the target system and must exist.  Therefore this macro won't write an entry unless $UninstLogAlwaysLog is true.
  !macro AddItemDated Path
    ${If} $UninstLogAlwaysLog != "" ; if empty, don't log.
      ;IfFileExists "${Path}" 0 AddItemDatedEnd ;if it does not exist we don't log it.
      ${If} $UninstLog != "" ;bail if uninstall log closed
        push $0
        push $1
        strCpy $0 ${Path}
        call UninstLogMakeDateSize
        FileWrite $UninstLog "${Path}${UNINSTLOGDSEP}$1$\r$\n"
        pop $1
        pop $0
      ${EndIf} ; if log open
    ${EndIf} ; If always log
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

  ;$0 - (in) file path (if it is a path it is so on the target system)
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
  ;path: path to uninstaller.
  ;We always log this even if it exists because otherwise when installing over a previous install it doesn't get put in the log and $InstDir is not removed when uninstalled.
    ;${IfNot} ${FileExists} "${Path}" ;if it exists we don't log it.
    ${OrIf} $UninstLogAlwaysLog != "" ;unless $UninstLogAlwaysLog is true
      ${If} $UninstLog != "" ;log is open
	FileWrite $UninstLog "${Path}$\r$\n"
      ${EndIf} ;uninstlog open
    ;${EndIf} ;if does not exist or $UninstLogAlwaysLog
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
    ${Logging_DetailPrint} "Read $R1 log entries" ; debug
    
  !endif
  LoopRead:
    StrCmp $R1 0 LoopDone
    Pop $R0 ; log entry
 
    IfFileExists "$R0\*.*" 0 NotDir
      !ifdef UNINSTLOGDEBUG ; debug
        ${Logging_DetailPrint} "Attempting to remove directory $R0" ; debug
      !endif ; debug
      RMDir $R0  #is dir
      !ifdef UNINSTLOGDEBUG ; debug
        IfErrors 0 +2 ; debug
          ${Logging_DetailPrint} "Error after trying to remove directory $0" ; debug
      !endif ; debug
      Goto LoopNext
    NotDir:
    ${UnStrTok} $R2 $R0 ${UNINSTLOGDSEP} 1 0 ; date/size, 2nd token
    ${UnStrTok} $R0 "$R0" ${UNINSTLOGDSEP} 0 0 ;remove date/size from path.
    !ifdef UNINSTLOGDEBUG
      ${Logging_DetailPrint} "After separating time stamp, time stamp=$R2, file=$R0" ; debug
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
      ;!ifdef UNINSTLOGDEBUG
        ;${Logging_DetailPrint} "UninstLog: file $0 has time stamp $1, entry stamp is $R2" ; debug
      ;!endif
      ${If} $R2 != $1
	push $R2 ; log entry stamp
	call un.UninstLogShowDateSize
	pop $R3 ; display of log entry stamp
	push $1 ; current stamp
	call un.UninstLogShowDateSize
	pop $R4 ; current file stamp
        MessageBox MB_YESNO $(UninstLogModified) IDNO NoDelete
	pop $2
	pop $1
      ${EndIf} ;date/sizes do not match
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
