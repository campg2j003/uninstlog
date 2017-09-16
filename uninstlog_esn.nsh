/*
Spanish messages for uninstlog.nsh V0.1.3 (updated 2017-09-13)
Translation of file uninstlog_enu.nsh last updated 2016-09-21.
This file last updated 2016-09-21.
Translated by Fernando Gregoire.
*/

!ifndef __UNINSTLOG_ESN_INCLUDED
  !define __UNINSTLOG_ESN_INCLUDED
  
;Uninstall log file missing, $0 is file name.
LangString UninstLogMissing ${LANG_SPANISH} "Â¡No se encontrÃ³ $0!$\r$\nÂ¡La desinstalaciÃ³n no puede proseguir!"

;$R0 = file name, $R3 = log entry file stamp, $R4 = current file stamp.  File stamp is produced by  LangString UninstLogShowDateSize.
LangString UninstLogModified ${LANG_SPANISH} "El archivo $R0 se ha modificado desde que se instalÃ³. Â¿Desea eliminarlo?$\r$\nOriginal: $R3$\r$\nActual: $R4"

;Displays a files timestamp and size.  $1 = timestamp, $2 = size in bytes.
LangString UninstLogShowDateSize ${LANG_SPANISH} "$1 UTC, $2 bytes"

!endif ;__UNINSTLOG_ESN_INCLUDED
