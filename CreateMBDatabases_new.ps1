<#
.SYNOPSIS
This is a sample script to create mailbox databases.

.DESCRIPTION
This script Imports the CSV file and reads the list of databases and
servers.  Each line in the CSV file provides the information required to
create and configure the database.
The script must be run from within the Exchange Shell.

The header line of the CSV file contains the following:
		Name,Server,DBFilePath,LogFolderPath,DeletedItemRetention,GC,OAB,
		RetainDeletedItemsUntilBackup,IndexEnabled,CircularLoggingEnabled,
		ProhibitSendReceiveQuota,ProhibitSendQuota,IssueWarningQuota,AllowFileRestore,
		BackgroundDatabaseMaintenance,IsExcludedFromProvisioning,IsSuspendedFromProvisioning,
		MailboxRetention,MountAtStartup,EventHistoryRetentionPeriod,AutoDagExcludeFromMonitoring,
		CalendarLoggingQuota,IsExcludedFromInitialProvisioning,DataMoveReplicationConstraint,
		RecoverableItemsQuota,RecoverableItemsWarningQuota,DataMoveReplicationConstraint

.NOTES
The specified Mailbox server must not already host a copy of the specified
mailbox database.

The database path used by the specified database must also be available on
the specified Mailbox server, because all copies of a database must use the
same path.

Please note: The setting for Circular Logging is ignored in this script.  The
	MailboxDatabases.csv file is also used by the script to create database copies.
	The Circular Logging choice is enforced in that script.
	
	If you're adding the second copy of a database (for example, adding the
first passive copy of the database), circular logging must not be enabled
for the specified mailbox database. If circular logging is enabled, you must
first disable it.

After the mailbox database copy has been added, circular logging can be
enabled.

After enabling circular logging for a replicated mailbox database,
continuous replication circular logging (CRCL) is used instead of JET
circular logging.

If you're adding the third or subsequent copy of a database, CRCL can remain
enabled.

Definitions:
Name = "DB1"
The name of the database to create

Server = "Server 1"
The host name of the computer on which the database should be
created

DBFilePath = """E:\EXCHANGEDATABASES\DB1\DB1.db\DB1.edb"""
The path and file name of the database

LogFolderPath = """E:\EXCHANGEDATABASES\DB1\DB1.log\"""
The path of the log directory

GC or GC2 = Use the FQDN in the CSV file of your preferred GC.

IMPORTANT
Calendar logging quota is 20% of dumpster quota.

.PARAMETER DBFile
Specifies the name of the CSV file.  The parameter is optional and  defaults
to "MailboxDatabases.csv" in the current directory if no parameter is
provided.

The path of the DBFile should be enclosed in quotes if it contains
embedded spaces.

.EXAMPLE
./CreateMBDatabases.ps1 -DBFile "D:\MailboxDatabases.csv"
Runs the CreateMBDatabases command and imports the database information from
the file MailboxDatabases.csv in the root directory of the D: drive.
#>

Param (
[Parameter(Position = 0)][String]$DBFile = "MailboxDatabases.csv"
)
$ForegroundNormal = "Green"
$ForeGroundError = "Red"
$Version = "2.2"
$DataVersion = "2.1"
$Ver = "VersionNumber"
<#
==========================================================================
CreateMBDatabases.ps1
Exchange 2013

THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
PARTICULAR PURPOSE.GOSTEELERS.

==========================================================================
#>

#######Functions######

# Input the amount of time you want to sleep
Function Sleep_Progress {
Param($SleepTime)

# Loop Number of seconds you want to sleep
For ($i=0;$i -le $SleepTime;$i++){
$timeleft = ($SleepTime - $i);
# Progress bar showing progress of the sleep
Write-Progress "Sleeping" "$Timeleft More Seconds" -PercentComplete (($i/$SleepTime)*100);
If ($i -lt $SleepTime){Sleep 1}
}
}

Function Monitor_Mount {
Param ([String]$DBtoMonitor)
$GC = $MBDB.GC
# Check if it is mounted if not sleep 60 seconds then try again
$Trys = 0

Write-Host "`nAttempting to mount $DBtoMonitor using the $GC domain controller" -ForegroundColor $ForeGroundNormal
try
{
Mount-Database -Identity $DBtoMonitor -DomainController $GC -ErrorAction Stop
}
catch
{
Write-Host "$DBtoMonitor did not mount. Retrying $MaxTrys mount attempts...`n" -ForegroundColor $ForeGroundNormal
While (($Trys -lt $MaxTrys) -and ((Get-Mailboxdatabase $DBtoMonitor -status).Mounted -ne $True)){

Mount-Database -Identity $DBtoMonitor -DomainController $GC
Write-Host "$DBtoMonitor did not mount. Sleeping...`n" -ForegroundColor $ForeGroundError
Sleep_Progress 60
$Trys++
}
}
If ($Trys -eq $MaxTrys) {
Write-Host "Failed to mount $DBtoMonitor`n" -ForegroundColor $ForeGroundError
}
}

# ##############################################
#                 START SCRIPT
# ##############################################
[Int]$MaxTrys = 5
Write-host ""
If (Test-Path "$DBFile") {
Start-Transcript
Write-Host "CreateMDDatabases script version $Version" -ForegroundColor $ForeGroundNormal
Write-Host "CreateMDDatabases data version $DataVersion" -ForegroundColor $ForeGroundNormal
Write-Host "Attempting to read CSV file: $DBFile" -ForegroundColor $ForegroundNormal
[Array]$MBDBs = Import-CSV $DBFile
$i=0
If ($DataVersion -eq $MBDBs[0].Server) {
Foreach ($MBDB in $MBDBs) {
If ($Ver -ne $MBDB.Name) {
$Name = $MBDB.Name
$Server = $MBDB.Server
$DBFilePath = $MBDB.EDBFilePath
$LogFolderPath = $MBDB.LogFolderPath
$PFDatabase = $MBDB.PFDatabase
$DeletedItemRetention = $MBDB.DeletedItemRetention
$GC = $MBDB.GC
$OAB = $MBDB.OAB
[bool]$RDIUB = [System.Convert]::ToBoolean($MBDB.RetainDeletedItemsUntilBackup)
[bool]$IE = [System.Convert]::ToBoolean($MBDB.IndexEnabled)
#				[bool]$CLE = [System.Convert]::ToBoolean($MBDB.CircularLoggingEnabled)
$CLQ = $MBDB.CalendarLoggingQuota
$PSRQ = $MBDB.ProhibitSendReceiveQuota
$PSQ = $MBDB.ProhibitSendQuota
$IWQ = $MBDB.IssueWarningQuota
[bool]$AFR = [System.Convert]::ToBoolean($MBDB.AllowFileRestore)
[bool]$BDM = [System.Convert]::ToBoolean($MBDB.BackgroundDatabaseMaintenance)
$DMRC = $MBDB.DataMoveReplicationConstraint
[bool]$IEFP = [System.Convert]::ToBoolean($MBDB.IsExcludedFromProvisioning)
[bool]$IEFIP = [System.Convert]::ToBoolean($MBDB.IsExcludedFromInitialProvisioning)
[bool]$ISFP = [System.Convert]::ToBoolean($MBDB.IsSuspendedFromProvisioning)
[bool]$ADEFM = [System.Convert]::ToBoolean($MBDB.AutoDagExcludeFromMonitoring)
$MR = $MBDB.MailboxRetention
[bool]$MAS = [System.Convert]::ToBoolean($MBDB.MountAtStartup)
$EHRP =$MBDB.EventHistoryRetentionPeriod

Write-Progress -activity "Creating databases..." -status $Name -percentComplete (($i / $MBDBs.Count)  * 100)

Set-ADServerSettings –PreferredServer "$GC"
Write-Host "`nAdding a new database $Name...." -ForegroundColor $ForegroundNormal
Write-Host "`nNew-MailboxDatabase -Name $Name -Server $Server -EdbFilePath $DBFilePath -LogFolderPath $LogFolderPath -DomainController $GC" -ForegroundColor $ForegroundNormal
New-MailboxDatabase -Name $Name -Server $Server -EdbFilePath "$DBFilePath" -LogFolderPath "$LogFolderPath" -DomainController $GC

Write-Host "`nSetting database properties of database $Name..." -ForegroundColor $ForegroundNormal
Write-Host "`nSet-MailboxDatabase -Identity $Name  -AutoDagExcludeFromMonitoring $ADEFM -CalendarLoggingQuota $CLQ -DeletedItemRetention $DeletedItemRetention -DomainController $GC -OfflineAddressBook $OAB -RetainDeletedItemsUntilBackupp $RDIUB  -IndexEnabled $IE -ProhibitSendReceiveQuota $PSRQ -ProhibitSendQuota $PSQ -IssueWarningQuota $IWQ -AllowFileRestore $AFR -BackgroundDatabaseMaintenance $BDM -IsExcludedFromInitialProvisioning $IEFIP -IsExcludedFromProvisioning $IEFP -IsSuspendedFromProvisioning $ISFP -MailboxRetention $MR -MountAtStartup $MAS -EventHistoryRetentionPeriod $EHRP -DataMoveReplicationConstraint $DMRC " -ForegroundColor $ForegroundNormal
#                Set-MailboxDatabase -Identity $Name  -AutoDagExcludeFromMonitoring $ADEFM  CircularLoggingEnabled $CLE -CalendarLoggingQuota $CLQ -DeletedItemRetention $DeletedItemRetention -DomainController $GC -OfflineAddressBook "$OAB" -RetainDeletedItemsUntilBackup $RDIUB  -IndexEnabled $IE -ProhibitSendReceiveQuota $PSRQ -ProhibitSendQuota $PSQ -IssueWarningQuota $IWQ -AllowFileRestore $AFR -BackgroundDatabaseMaintenance $BDM -IsExcludedFromInitialProvisioning $IEFIP -IsExcludedFromProvisioning $IEFP -IsSuspendedFromProvisioning $ISFP -MailboxRetention $MR -MountAtStartup $MAS -EventHistoryRetentionPeriod $EHRP -DataMoveReplicationConstraint $DMRC
Set-MailboxDatabase -Identity $Name  -AutoDagExcludeFromMonitoring $ADEFM  -CalendarLoggingQuota $CLQ -DeletedItemRetention $DeletedItemRetention -DomainController $GC -OfflineAddressBook "$OAB" -RetainDeletedItemsUntilBackup $RDIUB  -IndexEnabled $IE -ProhibitSendReceiveQuota $PSRQ -ProhibitSendQuota $PSQ -IssueWarningQuota $IWQ -AllowFileRestore $AFR -BackgroundDatabaseMaintenance $BDM -IsExcludedFromInitialProvisioning $IEFIP -IsExcludedFromProvisioning $IEFP -IsSuspendedFromProvisioning $ISFP -MailboxRetention $MR -MountAtStartup $MAS -EventHistoryRetentionPeriod $EHRP -DataMoveReplicationConstraint $DMRC

Write-Host "`nDone with database $Name..." -ForegroundColor $ForegroundNormal
}
$i++;
}
$i=0;
Foreach ($MBDB in $MBDBs) {
If ($Ver -ne $MBDB.Name)
{
$Name = $MBDB.Name
$GC = $MBDB.GC
Write-Progress -activity "Mounting databases..." -status $Name -percentComplete (($i / $MBDBs.Count)  * 100)
Set-ADServerSettings –PreferredServer "$GC"
Monitor_Mount -DBToMonitor $Name
}
$i++;
}
}
Else {
Write-Host "`nMismatch between script data version ($DataVersion) and $DBFile data version (" $MBDBs[0].Server ")" -ForegroundColor $ForeGroundError
Stop-Transcript
Exit 2
}
Stop-Transcript
}
Else {
Write-Host "`nCannot find CSV file: $DBFile.  Exiting on keystroke..." -ForegroundColor $ForeGroundError
$Host.UI.RawUI.ReadKey() | Out-Null
Exit 3
}
