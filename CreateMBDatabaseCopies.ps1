<#
.SYNOPSIS
This is a sample script to add mailbox database copies.

.DESCRIPTION
	This script Imports the CSV file and reads the list of databases and
	servers.  Each line in the CSV file provides the information required to
	create and configure the database copy. The script must be run from within
	the Exchange Shell.  Script does not seed the database.
	
	Tested on Exchange Server 2013 RTM. CSV files created with Office 2013.
	
	The header line of the CSV file contains the following: (Example)
		Name,Server, ActivationPreference,ReplayLagTime,TruncationLagTime,GC,GC2
		DB003,SERVER1,2,00:15:00,00:30:00,SITE1DC,SITE2DC
		DB011,SERVER2,2,00:15:00,00:30:00,SITE1DC,SITE2DC

.NOTES
	The specified Mailbox server must be in the same database availability group
		(DAG), and the DAG must have quorum and be healthy.
	The specified Mailbox server must not already host a copy of the specified
		mailbox database.
	The database path used by the specified database must also be available on
		the specified Mailbox server, because all copies of a database must use
		the same path.
	If you're adding the second copy of a database (for example, adding the
		first passive copy of the database), circular logging must not be
		enabled for the specified mailbox database. If circular logging is
		enabled, you must first disable it. 
	After the mailbox database copy has been added, circular logging can be
		enabled. 	
	After enabling circular logging for a replicated mailbox database,
		continuous replication circular logging (CRCL) is used instead of JET
		circular logging.
	If you're adding the third or subsequent copy of a database, CRCL can remain
		enabled.
	After running the Add-MailboxDatabaseCopy cmdlet, the new copy remains in a
		Suspended state if the SeedingPostponed parameter is specified. 
	When the database copy status is set to Suspended, the SuspendMessage is set
		to "Replication is suspended for database copy '{0}' because database
		needs to be seeded.
		
Definitions:
		Name = "DB1"
			The name of the database copy to create
		
		Server = "Server 1"
			The host name of the computer on which the database should be
			created
			
		ActivationPreference = "2"
			The ActivationPreference parameter value is used as part of Active
			Manager's best copy selection process and to redistribute active
			mailbox databases throughout the DAG when using the
			RedistributeActiveDatabases.ps1 script. The value for the activation
			preference is a number equal to or greater than 1, where 1 is at the
			top of the preference order. The preference number can't be larger
			than the number of copies of the mailbox database.
			
		ReplayLagTime=  00.00:00:00
			The ReplayLagTime parameter specifies the amount of time that the
			Microsoft Exchange Replication service waits before replaying log
			files that have been copied to the database copy. To specify a
			value, enter it as a time span: dd.hh:mm:ss where d = days,
			h = hours, m = minutes, and s = seconds. The maximum allowable
			setting for this value is 14 days. The minimum allowable setting is
			0 seconds, and setting this value to 0 seconds eliminates any delay
			in log replay activity.
			
			For example, to specify a 14-day replay lag period, enter
			14.00:00:00. The default value is 00.00:00:00, which specifies that
			there's no replay lag.

		TruncationLagTime= 00.00:00:00
			The TruncationLagTime parameter specifies the amount of time that
			the Microsoft Exchange Replication service waits before truncating
			log files that have replayed into a copy of the database.
			The time period begins after the log has been successfully replayed
			into the copy of the database. To specify a value, enter it as a
			time span: dd.hh:mm:ss where d = days, h = hours, m = minutes, and
			s = seconds. The maximum allowable setting for this value is 14
			days. The minimum allowable setting is 0 seconds, and setting this
			value to 0 seconds eliminates any delay in log truncation activity.
			
			For example, to specify a 14-day truncation lag period, enter
			14.00:00:00. The default value is 00.00:00:00, which specifies that
			there's no truncation lag.
		GC or GC2 = Use the FQDN in the CSV file of your preferred GC.

.PARAMETER DBCopyFile
	Specifies the name of the CSV file.  The parameter is optional and  defaults
	to "MailboxDatabaseCopies.csv" in the current directory if no parameter is
	provided.

	The path of the DBCopyFile should be enclosed in quotes if it contains
	embedded spaces.

.EXAMPLE
	./CreateMBDatabaseCopies.ps1 -DBFile "D:\MailboxDatabaseCopies.csv"
	Runs the CreateMBDatabases command and imports the database copy information
	from the file MailboxDatabases.csv in the root directory of the D: drive.
#>

Param (
	[Parameter(Position = 0)][String]$DBCopyFile = "MailboxDatabaseCopies.csv"
)
$ForegroundNormal = "Green"
$ForeGroundError = "Red"
$Version = "2.1"
$DataVersion = "2.1"

#==========================================================================
#        CreateMBDatabaseCopies.ps1
#        EXCHANGE SERVER 2013
#
#        THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
#        KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
#        IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
#        PARTICULAR PURPOSE.HEREWEGOSTEELERS.
#
#==========================================================================

# Function to sleep the process
Function Sleep_Progress {
    Param($SleepTime)
    # Loop Number of seconds you want to sleep
    For ($i=0;$i -le $SleepTime;$i++){
        $TimeLeft = ($SleepTime - $i);
        # Progress bar showing progress of the sleep
        Write-Progress "Sleeping" "$Timeleft More Seconds" -PercentComplete (($i/$SleepTime)*100);
        If ($i -lt $SleepTime){Sleep 1}
    }
}

# ##############################################
#                 START SCRIPT
# ##############################################
Start-Transcript
Write-host ""
If (Test-Path "$DBCopyFile") {
	Write-Host "CreateMBDatabaseCopies script version $Version" -ForegroundColor $ForeGroundNormal
	Write-Host "CreateMBDatabaseCopies data version $DataVersion" -ForegroundColor $ForeGroundNormal
	Write-Host "Attempting to read CSV file: $DBCopyFile" -ForegroundColor $ForegroundNormal
	[Array]$DBCopies = Import-CSV $DBCopyFile
	
	If ($DataVersion -eq $DBCopies[0].GC2) {
		ForEach ( $DBCopy in $DBCopies ) {
			If ($DBCopy.GC -ne "VersionNumber") {
			    $CopyName = $DBCopy.Name
			    $CopyServer = $DBCopy.Server
			    $CopyPreference = $DBCopy.ActivationPreference
			    $PrimaryADSiteCopyDC = $DBCopy.GC
			    $SecondaryADSiteCopyDC = $DBCopy.GC2
			    $ReplayLagTime=$DBCopy.ReplayLagTime
			    $TruncationLagTime=$DBCopy.TruncationLagTime

			    Write-Host "`nAdding a mailbox database copy for database $CopyName on server $CopyServer..." -ForegroundColor $ForeGroundNormal
			    Write-Host " `nAdd-MailboxDatabaseCopy -Identity $CopyName -SeedingPostponed -MailboxServer $CopyServer -ActivationPreference $CopyPreference -DomainController $PrimaryADSiteCopyDC -ReplayLagTime  $ReplayLagTime  -TruncationLagTime  $TruncationLagTime"
			    Add-MailboxDatabaseCopy -Identity $CopyName -SeedingPostponed -MailboxServer $CopyServer -ActivationPreference $CopyPreference -DomainController $PrimaryADSiteCopyDC -ReplayLagTime  $ReplayLagTime  -TruncationLagTime  $TruncationLagTime

			    If ($SecondaryADSiteCopyDC -ne ""){
			        While ((Get-MailboxDatabaseCopyStatus -Identity $CopyName\$CopyServer -DomainController $PrimaryADsiteCopyDC -ErrorAction SilentlyContinue).Identity -ne (Get-MailboxDatabaseCopyStatus -Identity $CopyName\$CopyServer -DomainController $SecondaryADSiteCopyDC -ErrorAction SilentlyContinue).Identity)
					{
			            Write-Host "`nWaiting for Domain Controllers to get in sync before continuing" -ForegroundColor $ForeGroundNormal
			            Sleep_Progress 300
			        }
			    }
			    Write-Host "`nFinished adding a mailbox database copy for database $CopyName on server $CopyServer" -ForegroundColor $ForeGroundNormal
			}
		}
	}
	Else {
		Write-Host "`nMismatch between script data version ($DataVersion) and $DBCopyFile data version (" $DBCopies[0].GC2 ")" -ForegroundColor $ForeGroundError
		Stop-Transcript
		Exit 2
	}
}
Else {
	Write-Host "Cannot find CSV file: $DBCopyFile.  Exiting on keystroke..." -ForegroundColor $ForeGroundError
	$Host.UI.RawUI.ReadKey() | Out-Null
	Exit 3
}
Stop-Transcript

