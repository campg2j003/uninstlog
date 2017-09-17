/*
German messages for uninstlog.nsh V0.1.3 (updated 2017-09-13)
Translation of file uninstlog_enu.nsh last updated 2016-09-21.
This file last updated 2017-08-26.
Translated by Michael Vogt.
*/

!ifndef __UNINSTLOG_DEU_INCLUDED
  !define __UNINSTLOG_DEU_INCLUDED
;Uninstall log file missing, $0 is file name.
LangString UninstLogMissing ${LANG_GERMAN} "$0 nicht gefunden!$\r$\nDeinstallation kann nicht fortgesetzt werden!"

;$R0 = file name, $R3 = log entry file stamp, $R4 = current file stamp.  File stamp is produced by  LangString UninstLogShowDateSize.
LangString UninstLogModified ${LANG_GERMAN} "Die Datei $R0 wurde  seit der Installation verändert.  Möchten Sie diese Datei und alle anderen modifizierten Dateien des Skript Pakets entfernen?$\r$\nOriginal: $R3$\r$\nAktuell: $R4"

;Displays a files timestamp and size.  $1 = timestamp, $2 = size in bytes.
LangString UninstLogShowDateSize ${LANG_GERMAN} "$1 UTC $2 bytes"

!EndIf ;__UNINSTLOG_DEU_INCLUDED
