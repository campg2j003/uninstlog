/*
English messages for uninstlog.nsh V0.1.0 (updated 1/10/2016)
This file last updated 1/10/16.
*/

;Uninstall log file missing, $0 is file name.
LangString UninstLogMissing ${LANG_ENGLISH} "$0 not found!$\r$\nUninstallation cannot proceed!"

;$R0 = file name, $R3 = log entry file stamp, $R4 = current file stamp.  File stamp is produced by  LangString UninstLogShowDateSize.
LangString UninstLogModified ${LANG_ENGLISH} "File $R0 has been modified since it was installed.  Do you want to delete it?$\r$\nOriginal: $R3$\r$\nCurrent: $R4"

;Displays a files timestamp and size.  $1 = timestamp, $2 = size in bytes.
LangString UninstLogShowDateSize ${LANG_ENGLISH} "$1 UTC $2 bytes"
