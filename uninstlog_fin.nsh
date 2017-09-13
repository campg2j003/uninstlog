/*
Finish messages for uninstlog.nsh V0.1.3 (updated 2017-09-13)
Translation of file uninstlog_enu.nsh last updated 2016-09-21.
This file last updated 2017-09-08.
*/

!ifndef __UNINSTLOG_FIN_INCLUDED
  !define __UNINSTLOG_FIN_INCLUDED
;Uninstall log file missing, $0 is file name.
LangString UninstLogMissing ${LANG_FINNISH} "$0 ei löydetty!$\r$\nAsennuksen poistaminen ei onnistu!"

;$R0 = file name, $R3 = log entry file stamp, $R4 = current file stamp.  File stamp is produced by  LangString UninstLogShowDateSize.
LangString UninstLogModified ${LANG_FINNISH} "Tiedostoa $R0 on muutettu, koska se on asennettu.  Haluatko poistaa sen ja kaikki muut muokatut tiedostot?$\r$\nAlkuperäinen: $R3$\r$\nNykyinen: $R4"

;Displays a files timestamp and size.  $1 = timestamp, $2 = size in bytes.
LangString UninstLogShowDateSize ${LANG_FINNISH} "$1 UTC $2 tavua"

!EndIf ;__UNINSTLOG_ENU_INCLUDED
