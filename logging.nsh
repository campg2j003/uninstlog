!IfNDef LOGGING_INCLUDED
  !Define LOGGING_INCLUDED
  
/*
Logging: log to a file.

Last Updated: 2017-09-16

*/

!Include "WinMessages.nsh" ;for LVM_FIRST


;-----
;Store DetailPrint entries from functions run before DetailPrint works.
VAR DetailPrintStoreFileName ;name of temp file
Var DetailPrintStoreHandle ;file handle

!macro StoreDetailPrintInit
  ;Call this in .OnInit.
  GetTempFileName $DetailPrintStoreFileName ;creates a file
  FileOpen $DetailPrintStoreHandle $DetailPrintStoreFileName "w"
!MacroEnd ;StoreDetailPrintInit
!Define StoreDetailPrintInit "!InsertMacro StoreDetailPrintInit"

;To print the accumulated messages, invoke ${DetailPrintStored}.
!macro StoreDetailPrint msg
  ;Add msg followed by a newline to the cache.
  FileWrite $DetailPrintStoreHandle "${msg}$\r$\n"
!MacroEnd ; StoreDetailPrint
!Define StoreDetailPrint "!insertMacro StoreDetailPrint"

!macro DetailPrintStored
  ;DetailPrints the cached messages and clears the cache.
  Push $0
  FileClose $DetailPrintStoreHandle
  FileOpen $DetailPrintStoreHandle $DetailPrintStoreFileName "r"
  ${If} $DetailPrintStoreHandle <> 0
  ${Do}
    FileRead $DetailPrintStoreHandle $0
    ${If} ${Errors}
      ${ExitDo}
    ${EndIf}
    StrCpy $0 $0 -2 ;remove CRLF
    DetailPrint $0
  ${Loop}
  FileClose $DetailPrintStoreHandle
  Delete $DetailPrintStoreFileName
  StrCpy $DetailPrintStoreFileName ""
  StrCpy $DetailPrintStoreHandle 0
  ${EndIf} ;opened file
  Pop $0
!MacroEnd ;DetailPrintStored
!Define DetailPrintStored "!InsertMacro DetailPrintStored"

!macro LOGGING_defineifndef switches name rest
  ;Usage: !{LOGGING_defineifndef} /math defname "val1 + val2"
  ;If there are no switches then specify "".  If there are more than switch enclose them in quotes.
  !ifndef ${name}
    !define ${switches} ${name} ${rest}
  !EndIf
!MacroEnd
!define LOGGING_defineifndef "!InsertMacro LOGGING_defineifndef"

;-----
;!define /ifndef LVM_FIRST           0x1000
${LOGGING_defineifndef} /math LVM_GETITEMCOUNT "${LVM_FIRST} + 4"
${LOGGING_defineifndef} /math LVM_GETITEMTEXTA "${LVM_FIRST} + 45"
;We don't need these, but include them so if we're using a list view we can just test the first one and assume they're all there.
${LOGGING_defineifndef} "/math " LVM_GETITEMTEXTW "${LVM_FIRST} + 115"
${LOGGING_defineifndef} "" LVM_GETUNICODEFORMAT "0x2006"
${LOGGING_defineifndef} "/math " LVM_GETITEMSTATE "${LVM_FIRST} + 44"
${LOGGING_defineifndef} "/math " LVM_SETITEMSTATE "${LVM_FIRST} + 43"
${LOGGING_defineifndef} "/math " LVM_GETITEMA "${LVM_FIRST} + 5"
${LOGGING_defineifndef} "/math " LVM_GETITEMW "${LVM_FIRST} + 75"
${LOGGING_defineifndef} "/math " LVM_SETITEMA "${LVM_FIRST} + 6"
${LOGGING_defineifndef} "/math " LVM_INSERTITEMA "${LVM_FIRST} + 7"
${LOGGING_defineifndef} "/math " LVM_INSERTITEMW "${LVM_FIRST} + 77"
${LOGGING_defineifndef} "/math " LVM_INSERTCOLUMNA "${LVM_FIRST} + 27"
${LOGGING_defineifndef} "/math " LVM_INSERTCOLUMNW "${LVM_FIRST} + 97"
${LOGGING_defineifndef} "/math " LVM_GETEXTENDEDLISTVIEWSTYLE "${LVM_FIRST} + 55"
${LOGGING_defineifndef} "/math " LVM_SETEXTENDEDLISTVIEWSTYLE "${LVM_FIRST} + 54 ; wparam is mask, lparam is style, returns old style"

;Adapted from winmessages.nsh from NSIS 3.02.1
!macro _LOGGING_DEFAW d
!ifdef NSIS_UNICODE
${LOGGING_defineifndef} "" ${d} "${${d}W}"
!else
${LOGGING_defineifndef} "" ${d} "${${d}A}"
!endif
!macroend
!define _LOGGING_DEFAW '!insertmacro _LOGGING_DEFAW '

${_LOGGING_DEFAW} LVM_GETITEMTEXT
${_LOGGING_DEFAW} LVM_GETITEM
${_LOGGING_DEFAW} LVM_SETITEM
${_LOGGING_DEFAW} LVM_INSERTITEM
${_LOGGING_DEFAW} LVM_INSERTCOLUMN

!macro LOGGING_DumpLog
  ;Dump log window to a file.  Does not work for silent installs.
  ;TOS is file path.
  Exch $5
  Push $0
  Push $1
  Push $2
  Push $3
  Push $4
  Push $6
  push $7 ; error description

  FindWindow $0 "#32770" "" $HWNDPARENT
  ;DetailPrint "DumpLog: $$HWNDPARENT=$HWNDPARENT, FindWindow found $0$\r$\n"
  StrCpy $7 "in FindWindow"
  IntCmp $0 0 error
  GetDlgItem $0 $0 1016
  ;DetailPrint "  GetDlgItem found $0$\r$\n"
  StrCpy $7 "in GetDlgItem"
  StrCmp $0 0 error
  ;delete $5
  ${IfNot} ${FileExists} $5
    FileOpen $5 $5 "w"
    StrCpy $7 "opening file"
    StrCmp $5 0 error
  ${Else}
    ;SetFileAttributes "$INSTDIR\$0" NORMAL
    FileOpen $5 $5 "a"
    StrCpy $7 "opening file for append"
    StrCmp $5 0 error
    FileSeek $5 0 END
  ${EndIf}
  SendMessage $0 ${LVM_GETITEMCOUNT} 0 0 $6
  StrCpy $7 "no items"
  IntCmp $6 0 error
  System::Alloc ${NSIS_MAX_STRLEN}
  Pop $3
  StrCpy $2 0
  System::Call "*(i, i, i, i, i, i, i, i, i) i \
      (0, 0, 0, 0, 0, r3, ${NSIS_MAX_STRLEN}) .r1"
  loop: StrCmp $2 $6 done
  !ifdef NSIS_UNICODE
  System::Call "User32::SendMessageW(i, i, i, i) i \
      ($0, ${LVM_GETITEMTEXT}, $2, r1)"
  !else
  System::Call "User32::SendMessageA(i, i, i, i) i \
      ($0, ${LVM_GETITEMTEXT}, $2, r1)"
  !EndIf
  System::Call "*$3(&t${NSIS_MAX_STRLEN} .r4)"
  FileWrite $5 "$4$\r$\n"
  IntOp $2 $2 + 1
  Goto loop
  done:
    FileClose $5
    System::Free $1
    System::Free $3
    Goto exit
  error:
    DetailPrint "DumpLog: error $7$\r$\n"
    ;MessageBox MB_OK "DumpLog: error $7"
  exit:
    Pop $7
    Pop $6
    Pop $4
    Pop $3
    Pop $2
    Pop $1
    Pop $0
    Pop $5
!MacroEnd ; LOGGING_DumpLog

Function LOGGING_DumpLog
  ;TOS is file path.
  !InsertMacro LOGGING_DumpLog
FunctionEnd ;LOGGING_DumpLog

Function un.LOGGING_DumpLog
  ;TOS is file path.
  !InsertMacro LOGGING_DumpLog
FunctionEnd ;un.LOGGING_DumpLog

!macro logging_DetailPrint msg
  DetailPrint "${msg}"
  ${StoreDetailPrint} "${msg}"
!MacroEnd ;logging_DetailPrint
!Define logging_DetailPrint "!InsertMacro logging_DetailPrint"

!macro logging_Write
  ;Write contents of DetailPrintStoreCache to log file.
  ;TOS=file name
  ;Note that this will not append to an existing file
  Exch $5
  FileClose $DetailPrintStoreHandle
  StrCpy $DetailPrintStoreHandle 0
  Delete $5 ;in case one exists
  Rename $DetailPrintStoreFileName $5
  StrCpy $DetailPrintStoreFileName ""
  Pop $5
!MacroEnd ;logging_Write
function logging_Write
  !InsertMacro logging_Write
  FunctionEnd ;logging_Write
function un.logging_Write
  !InsertMacro logging_Write
  FunctionEnd ;un.logging_Write

!EndIf ;LOGGING_INCLUDED
