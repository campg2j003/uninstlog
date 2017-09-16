/*
English messages for uninstlog.nsh V0.1.3 (updated 2017-09-13)
This file last updated 2016-09-21.
*/

!ifndef __UNINSTLOG_ENU_INCLUDED
  !define __UNINSTLOG_ENU_INCLUDED
;Uninstall log file missing, $0 is file name.
LangString UninstLogMissing ${LANG_ENGLISH} "$0 not found!$\r$\nUninstallation cannot proceed!"

;$R0 = file name, $R3 = log entry file stamp, $R4 = current file stamp.  File stamp is produced by  LangString UninstLogShowDateSize.
LangString UninstLogModified ${LANG_ENGLISH} "File $R0 has been modified since it was installed.  Do you want to delete it and all other modified files?$\r$\nOriginal: $R3$\r$\nCurrent: $R4"

;Displays a files timestamp and size.  $1 = timestamp, $2 = size in bytes.
LangString UninstLogShowDateSize ${LANG_ENGLISH} "$1 UTC $2 bytes"

!EndIf ;__UNINSTLOG_ENU_INCLUDED
