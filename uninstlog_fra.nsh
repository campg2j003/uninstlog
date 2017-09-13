/*
French messages for uninstlog.nsh V0.1.3 (updated 2017-09-13)
Translation of file uninstlog_enu.nsh last updated 2016-09-21.
This file last updated 2017-09-08.
*/

!ifndef __UNINSTLOG_FRA_INCLUDED
  !define __UNINSTLOG_FRA_INCLUDED
;Uninstall log file missing, $0 is file name.
LangString UninstLogMissing ${LANG_FRENCH} "$0 pas trouvé!$\r$\nLa désinstallation ne peut pas continuer!"

;$R0 = file name, $R3 = log entry file stamp, $R4 = current file stamp.  File stamp is produced by  LangString UninstLogShowDateSize.
LangString UninstLogModified ${LANG_FRENCH} "Le fichier $R0 a été modifié depuis qu'il a été installé.  Voulez-vous le supprimer et tous les autres fichiers modifiés?$\r$\nOriginal: $R3$\r$\nActuel: $R4"

;Displays a files timestamp and size.  $1 = timestamp, $2 = size in bytes.
LangString UninstLogShowDateSize ${LANG_FRENCH} "$1 UTC $2 octets"

!EndIf ;__UNINSTLOG_FRA_INCLUDED
