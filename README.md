===Documentation===
(for version 0.1.0 dated 1/9/2016)

This header file supports the ability to uninstall only the installed files.

It expects the following defines:
REG_ROOT, REG_APP_PATH, and REG_UNINSTALL_PATH.  If either of the latter two are undefined these registry keys won't be deleted even if they appear in the log file.


# To use:
* At the top of your scrip !include at least one langstring header file and uninstlog.nsh:
```
!include "uninstlog_enu.nsh"
!include "uninstlog.nsh"
```
(Note: it gets an error if it is included before "SetCompressor /SOLID LZMA": "Error: can't change compressor after data already got compressed or header already changed!".)
* Define REG_ROOT, and REG_APP_PATH and/or REG_UNINSTALL_PATH if you want to use ${WriteRegStr} or ${WriteRegDWORD}.
* Start and end each install section like this:
```
section "Install section"
!insertmacro UNINSTLOG_OPENINSTALL
;Install section code
!insertmacro UNINSTLOG_CLOSEINSTALL
sectionend
```
* Replace File instructions with the appropriate macros.

When the log is closed the commands will be executed but not logged.

If you want the $INSTDIR to be removed automatically, you need to place 
`${AddItemAlways} "$INSTDIR"`
after you initially open the log.  This is because the $INSTDIR is already created at the time INSTLOG_OPENINSTALL is called, so it won't automatically be logged.  UNINSTLOG_OPENINSTALL does not automatically log it so that you don't add a directory automatically if you close and reopen a new install block.  (Automatically writing $INSTDIR on open makes a messy log but it might be okay since there are still files in the directory.)  If you run the installer again to add additional files, it will again write the $INSTDIR to the log.

In your uninstall section do:

```
!insertmacro UNINSTLOG_UNINSTALL
```

Note that this will push one entry on the stack for every entry in the log.

# Macros
The following commands are provided, most of them simple forms of the similar NSIS commands:
* ${AddItem} Path --  adds a file or directory when the provided commands won't do the job.  Does not add the item if it exists, so you need to call this before the command that creates it.
* ${AddItemAlways} -- Like AddItem but adds item even if it exists.
* ${File} Path FileName -- path is path on source machine, must be empty or end with backslash.
* ${CreateShortcut} FilePath FilePointer Parameters Icon IconIndex -- create shortcut FilePath that links to FilePointer.
* ${CopyFiles} source Dest - use full paths.
* ${Rename} Source Dest - use full paths.
* ${CreateDirectory} Path
* ${SetOutPath} Path
* ${WriteUninstaller} Path -- should use a fully-qualified path to make the logged value right.
* ${WriteRegStr} Root path Key Value-- path is the subkey, must be the value of either ${rEG_APP_PATH} or ${REG_UNINSTALL_PATH), which must be defined prior to use.
* ${WriteRegDWORD} -- see ${WriteRegStr}
* ${AddItemDated} -- same as AddItem but includes the date/time and size of the installed file so that the uninstaller can detect if files are modified.
* ${FileDated} -- same as ItemDated for the ${File} command.


# Defines and variables
Uses the following additional defines:
* UninstLog -- name of the log file, defaults to uninstall.log.  You can define this just before calling UNINSTLOG_OPENINSTALL and UNINSTLOG_UNINSTALL to change the name of the log file.  You could even create separate logs.  You would then need to do more than one UNINSTLOG_UNINSTALL for each log file.  The name will stay defined until you change it.
* UNINSTLOGDSEP -- separator used to separate file path and date-size for ${FileDated} and $ItemDated} macros (|)
* INSTLOGDEBUG -- Activates debugging messages if defined.


and variables:
* $UninstLog -- handle of log file, empty if log closed.  When the log is closed commands are executed but not logged.
* $UninstLogAlwaysLog -- Normally a file is not logged if it exists on the target system.  You can cause files to always be logged even if they exist by setting the variable $UninstLogAlwaysLog to nonempty:
```
section "something"
;...
StrCpy $UninstLogAlwaysLog 1
${File} "" "MyFile.txt" ; will be logged even if it exists.
${FileDated} "" "AnotherFile" ;so will this one.
StrCpy $UninstLogAlwaysLog "" ; turn it off
${File} "" "filexxx" ; won't be logged if it exists.
;...
sectionend
```


Note that this header uses strfunc.nsh function ${UnStrTok}.  If you also include strfunc.nsh and use ${UnstrTok} after this file you can check to see if it has been initialized by:
```
!ifndef UnStrTokINCLUDED
${UnStrTok}
!endif
```

(This was discovered by inspection in strfunc.nsh v1.09.)

# A note about wildcards
Although you can use wildcards in ${File}, ${Rename}, and ${CopyFiles}, it could be dangerous and is not recommended unless you are sure you know what you are doing.  Suppose you do `${File} "*.txt"` where the source directory has a few text files, but the directory into which they are installed already contains text files.  The value written to the log will be "*.txt", and this will cause the uninstaller to uninstall all of the .txt files in the folder, including the ones that were already installed.  You can't use wildcards at all with ${FileDated}, although there is no check for this.  (I need a way to run FindFirst/FindNext on the source system to do this.  See above for an alternative.)

The project for which I modified this header file uses ${AddItem}, ${AddItemAlways}, ${AddItemDated}, ${File}, ${FileDated}, ${CreateDirectory}, ${CreateShortcut}, ${SetOutPath}, and ${WriteUninstaller}.  I have retained the other commands but I have not tested them much.

# Bugs/enhancements

* Issue with ${AddItemDated}: If ${AddItemDated} follows the command that creates its file then it won't log unless UninstLogAlwaysLog is on.  If it precedes the command, the date-size stamp will be empty because it doesn't exist yet.  It was not modified to always log regardless of the value of $UninstLogAlwaysLog to make it clear that it is set.
* Issue with ${WriteReg...} macros: For these macros to work REG_APP_PATH and REG_UNINSTALL_PATH must be defined, and these are the only registry paths that can be written.  This means that you must define these and use them in the path of any ${WriteReg...} calls to make them be deleted.  If there were an installed file with the same name as these values that was installed but had been deleted before the uninstall, it could cause these keys to be deleted from the registry unintentionally.  (I presume that's why the uninstaller code checks for these values before removing them-- otherwise any file in the log that doesn't exist on the system when uninstalled would be interpreted as a registry key to delete.)
* To do: make all macros, variables, and !defines defined by this header start with "UninstLog" to avoid name collisions with other header files.

# Messages
Note that starting in V0.1.0 the messages are in separate header files so that they can be localized:
* uninstlog_enu.nsh -- English messages.

