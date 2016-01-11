/*
Spanish messages for uninstlog.nsh V0.1.0 (updated 1/10/2016)
Translation of file uninstlog_enu.nsh last updated 1/10/16.
This file last updated 1/10/16.
Translated by .
*/

!ifndef __UNINSTLOG_ESN_INCLUDED
  !define __UNINSTLOG_ESN_INCLUDED
  
;Uninstall log file missing, $0 is file name.
LangString UninstLogMissing ${LANG_SPANISH} "$0 not found!$\r$\nUninstallation cannot proceed!"

;$R0 = file name, $R3 = log entry file stamp, $R4 = current file stamp.  File stamp is produced by  LangString UninstLogShowDateSize.
LangString UninstLogModified ${LANG_SPANISH} "File $R0 has been modified since it was installed.  Do you want to delete it?$\r$\nOriginal: $R3$\r$\nCurrent: $R4"

;Displays a files timestamp and size.  $1 = timestamp, $2 = size in bytes.
LangString UninstLogShowDateSize ${LANG_SPANISH} "$1 UTC $2 bytes"

!endif ;__UNINSTLOG_ESN_INCLUDED
