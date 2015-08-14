<#
.SYNOPSIS
Example Script to Create a DAG based on inputs from the Exchange Server Mailbox
Role Calculator

.DESCRIPTION
Imports a csv file and creates a DAG.  Sets specific DAG parameters. Input for
DAG parameters is based on a VBA input page from the Exchange Mailbox Role
Calculator.

This script was tested with Exchange Server 2013 RTM and Office 2013.

.NOTES
When creating a DAG, you need to specify a valid computer name for the DAG no
longer than 15 characters that's unique within the Active Directory forest. In
addition, each DAG is configured with a witness server and witness directory.
The witness server and its directory are used only for quorum purposes where
there's an even number of members in the DAG. You don't need to create the
witness directory in advance. Exchange automatically creates and secures the
directory for you on the witness server. The directory shouldn't be used for any
purpose other than for the DAG witness server.

The requirements for the witness server are as follows:

The witness server can't be a member of the DAG.

The witness server must be in the same Active Directory forest as the DAG.

The witness server must be running the Windows Server 2012,
Windows Server 2008 R2, Windows Server 2008, Windows Server 2003 R2, or
Windows Server 2003 operating system.

A single server can serve as a witness for multiple DAGs; however, each DAG
requires its own witness directory.

We recommend that you use a Client Access server running on Microsoft Exchange
Server 2013 in the Active Directory site containing the DAG. This allows the
witness server and directory to remain under the control of an Exchange
administrator.

The following combinations of options and behaviors are available:

You can specify only a name for the DAG. In this scenario, the task searches for
a Client Access server in the local Active Directory site that doesn't have the
Mailbox server role installed, and it automatically creates the default
directory and share on that server and uses that Client Access server as the
witness server.

You can specify a name for the DAG, the witness server that you want to use, and
the directory you want created and shared on the witness server.

You can specify a name for the DAG and the witness server that you want to use.
In this scenario, the task creates the default directory on the specified
witness server.

You can specify a name for the DAG and specify the directory you want created
and shared on the witness server. In this scenario, the task searches for a
Client Access server in the local Active Directory site that doesn't have the
Mailbox server role installed, and it automatically creates the specified
directory on that server, shares the directory, and uses that Client Access
server as the witness server.

!!!!!IMPORTANT!!!!!
If the witness server you specify isn't an Exchange 2013 server, you must add
the Exchange Trusted Subsystem universal security group (USG) to the local
Administrators group on the witness server. 

!!!!!Warning!!!!!
If the witness server is a directory server, you must add the Exchange
Trusted Subsystem USG to the Builtin\Administrators group.

These security permissions are necessary to ensure that Exchange can create a
directory and share on the witness server as needed.  

In addition to providing a name for the DAG, one or more IP addresses must also
be assigned to the DAG. You can assign static IP addresses to the DAG by using
the DatabaseAvailabilityGroupIpAddresses parameter. If you omit this parameter,
the task attempts to use Dynamic Host Configuration Protocol (DHCP) to obtain
the necessary IP addresses.

DatabaseAvailabilityGroupIpAddresses  =  192.168.100.50/24,192.168.200.50/24
The DatabaseAvailabilityGroupIpAddresses parameter specifies one or more static
IP addresses to the DAG when a Mailbox server is added to a DAG. If you omit the
DatabaseAvailabilityGroupIpAddresses parameter when creating a DAG, the system
attempts to lease one or more IP addresses from a DHCP server in your
organization to assign to the DAG. Setting the
DatabaseAvailabilityGroupIpAddresses parameter to a value of 0.0.0.0 configures
the DAG to use DHCP
 
AutoDagDatabasesRootFolderPath =  specifies the directory containing the
database mount points 
when using the AutoReseed feature of the DAG. 
AutoReseed uses a default path of C:\ExchangeDatabases.

AutoDagVolumesRootFolderPath =  specifies the volume containing the mount points
for all disks, 
INCLUDING spare disks, when using the AutoReseed feature of the DAG. 

AutoReseed uses a default path of C:\ExchangeVolumes.

AutoDagDatabaseCopiesPerVolume=The AutoDagDatabaseCopiesPerVolume parameter is
used to specify the configured number of database copies per volume. This
parameter is used only with the AutoReseed feature of the DAG.

ManualDagNetworkConfiguration=  specifies whether DAG networks should be
automatically configured. If this parameter is set to False, DAG networks are
automatically configured. If this parameter is set to True, you must manually
configure DAG networks

.PARAMETER ServerFile
	Specifies the name of the CSV file.  The parameter is optional and  defaults
	to "DAGInfo.csv" in the current directory if no parameter is provided.

	The path of the ServerFile should be enclosed in quotes if it contains
	embedded spaces.

.PARAMETER NewDAG
	Specifies the name of the DAG to create.  If NewDAG is not specified as an
	argument then the script will prompt for the name of a DAG to create.

.EXAMPLE
	./CreateDAG.ps1 -ServerFile "D:\DAGInfo.csv" -NewDAG "DAG1"
	Runs the CreateDAG script, imports the DAG information from the file
	DAGInfo.csv in the root directory of the D: drive, and creates the DAG1 DAG.
#>

Param (
	[Parameter(Position = 0)][String]$ServerFile = "DAGInfo.csv",
	[Parameter()][String]$NewDAG
)
###############################################################################
#	CreateDAG.ps1
#
#	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
#	KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
#	IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
#	PARTICULAR PURPOSE.SIXTIMESUPERBOWLCHAMPIONS.BLUEBULLSRULE
#
#	Description: Scripted creation of Exchange DAGs.
#
###############################################################################

$ForegroundNormal = "Green"
$ForeGroundError = "Red"
$ForeGroundWarn = "Yellow"
$Version = "2.3"
$DataVersion = "2.3"

# Function to sleep the process
Function CountDown($waitMinutes)	{
	$StartTime = Get-Date
	$EndTime = $StartTime.AddMinutes($WaitMinutes)
	$TimeSpan = New-Timespan $StartTime $EndTime

	Write-Host "Sleeping for $WaitMinutes minutes`n"

	While ($TimeSpan -gt 0)	{
		$TimeSpan = New-Timespan $(Get-Date) $EndTime
		Write-Host "`r".Padright(40," ") -NoNewline
		Write-Host $([string]::Format("`rTime Remaining: {0:d2}:{1:d2}", `
			#$TimeSpan.Hours, `
			$TimeSpan.Minutes,`
			$TimeSpan.Seconds)) -NoNewline -ForegroundColor $ForeGroundWarn
		Sleep $WaitMinutes
	}
}

# ##############################################
#			  START SCRIPT
# ##############################################

Write-Host ""
If (Test-Path "$ServerFile") {
	Start-Transcript
	Write-Host "CreateDAG script version: $Version" -ForegroundColor $ForeGroundNormal
	Write-Host "CreateDG schema version: $DataVersion" -ForegroundColor $ForeGroundNormal
	$Found = $False
	If ($NewDAG -eq "") {
		$NewDAG = Read-Host "Enter the name of the DAG you want to create?"
	}
	$DAGInfoFile = Import-csv $ServerFile
	If ($DataVersion -eq $DAGInfoFile[0].DagIps){
		Foreach ($DAG in $DAGInfoFile) {
			If (($DAG.DagName.ToUpper() -eq $NewDAG.ToUpper()) -and (-not $Found)) {
			    $Found = $True
				[Array]$Servers = $DAG.Site1Servers.split(",")
				[Array]$Servers2 = $DAG.Site2Servers.split(",")
				$DAGName = $DAG.DagName.ToUpper()
				$DAGIps = $DAG.DagIps.Split(",")
				If ($DAG.DagMapiNetwork -ne $null)
				{
				   $DAGNetwork1 = $DAG.DagMapiNetwork.Split(",")
				   $DAGNetwork2 = $DAG.DagReplNetwork.Split(",")
				   $DAGNetwork3 = $DAG.DagEbnNetwork.Split(",")				
				   $DAGNetwork1Name = $DAG.DagMapiNetworkName
				   $DAGNetwork2Name = $DAG.DagReplNetworkName
				   $DAGNetwork3Name = $DAG.DagEbnNetworkName
				}
				$WitnessServer = $Dag.WitnessServer
				$AltWitnessDirectory = $DAG.AltWitnessDir
				$AltWitnessServer = $DAG.AltWitnessServer
				$WitnessDirectory = $DAG.WitnessDir
				$DAGTest = Get-DatabaseAvailabilityGroup $DAGName -ErrorAction SilentlyContinue 
				$Dom = [system.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()
				$GC = $DAG.GC
				$GC2 = $DAG.GC2
				$MAD1 = [int]$DAG.MaximumActiveDatabasesSite1
				$MAD2 = [int]$DAG.MaximumActiveDatabasesSite2
				$DAC=$DAG.DACMODE
				$ADVRFP=$DAG.AutoDAGVolumesRootFolderPath
				$ADDRFP=$DAG.AutoDAGDatabasesRootFolderPath
				$ADDCPV= [int]$DAG.AutoDAGDatabaseCopiesPerVolume
				[bool]$QMDNC = [System.Convert]::ToBoolean($DAG.ManualDagnetworkConfiguration)
				[bool]$RLME = [System.Convert]::ToBoolean($DAG.ReplayLagManagerEnabled)
				$NE=$DAG.NetworkEncryption
				$NC=$DAG.NetworkCompression
				$RP= [Uint16]$DAG.ReplicationPort
					[Bool]$LogIsolation = [System.Convert]::ToBoolean($DAG.LogIsolation)
				If ($DAGTest) {
				    Write-Host "The database availability group, $DAGName, already exists.  Exiting on keystroke..." -ForegroundColor $ForegroundError
				    $Host.UI.RawUI.ReadKey() | Out-Null
				    Exit
				}
				Else {
				    Write-Host "`nCreating a new Database Availability Group named $DAGNAME" -ForegroundColor $ForegroundNormal
				    New-DatabaseAvailabilityGroup -Name $DAGName -WitnessServer $WitnessServer -WitnessDirectory $WitnessDirectory -DatabaseAvailabilityGroupIPAddresses $DAGIPs -DomainController $GC 
				   
				    If ($GC2.toupper() -ne "NOT USED") {
					   While ((Get-DatabaseAvailabilityGroup -Identity $DAGName -Domaincontroller $GC -ErrorAction SilentlyContinue).Identity -ne (Get-DatabaseAvailabilityGroup -Identity $DAGName -DomainController $GC2 -ErrorAction SilentlyContinue).Identity) {
						  Write-Host "Waiting for Domain Controllers $GC and $GC2 to get in sync before continuing" -ForegroundColor $ForegroundNormal
						  Countdown 5
					   }
						Write-Host "`nAdding DAG members in Site 1" -ForegroundColor $ForegroundNormal
						$Servers | ForEach-Object {
							Set-MailboxServer $_ -MaximumActiveDatabases  $MAD1
							Add-DatabaseAvailabilityGroupServer -Identity $DAGName -MailboxServer $_
						}
						
						Write-Host "`nAdding DAG members in Site 2" -ForegroundColor $ForegroundNormal
						$Servers2 | ForEach-Object {
							Set-MailboxServer $_ -MaximumActiveDatabases  $MAD2
							Add-DatabaseAvailabilityGroupServer -Identity $DAGName -MailboxServer $_
						}
						
						Write-Host "`nWaiting for Domain Controllers $GC and $GC2 to get in sync before continuing" -ForegroundColor $ForegroundNormal
						Countdown 5			  
					}
				    Else {
						Write-Host "`nAdding DAG members" -ForegroundColor $ForegroundNormal
						$Servers | ForEach-Object {
						Set-MailboxServer $_ -MaximumActiveDatabases  $MAD1
						Add-DatabaseAvailabilityGroupServer -Identity $DAGName -MailboxServer $_
						}
				    }
					
				    Write-Host "`nSetting DAC Mode" -ForegroundColor $ForegroundNormal
				    Set-DatabaseAvailabilityGroup -Identity $DAGName -DatacenterActivationMode $DAC  
				    Write-Host "`nSetting Alternate Witness" -ForegroundColor $ForegroundNormal
				    Set-DatabaseAvailabilityGroup -Identity $DAGName  -AlternateWitnessServer $AltWitnessServer -AlternateWitnessDirectory $AltWitnessDirectory
						If ($LogIsolation) {
							Write-Host "`nAuto Reseed not configured because Log Isolation is enabled" -ForegroundColor $ForegroundNormal
						}
						Else {
							Write-Host "`nSetting Auto Reseed Parameters" -ForegroundColor $ForegroundNormal
					    Set-DatabaseAvailabilityGroup -Identity $DAGName  -AutoDagVolumesRootFolderPath $ADVRFP -AutoDagDatabasesRootFolderPath $ADDRFP  -AutoDagDatabaseCopiesPerVolume $ADDCPV
						}
				    Write-Host "`nSetting Your Manual Dag Network Configurations setting to $QMDNC" -ForegroundColor $ForegroundNormal
				    Set-DatabaseAvailabilityGroup -Identity $DAGName -ManualDagNetworkConfiguration $QMDNC		
				    Write-Host "`nSetting Additional Parameters for Network Compression and Network Encryption" -ForegroundColor $ForegroundNormal
				    Set-DatabaseAvailabilityGroup -Identity $DAGName  -NetworkCompression $NC -NetworkEncryption $NE
				    Write-Host "`nSetting Additional Parameters for Replay Lag Manager and Replication Port Number" -ForegroundColor $ForegroundNormal
				    Set-DatabaseAvailabilityGroup -Identity $DAGName  -ReplayLagManagerEnabled $RLME -ReplicationPort $RP
				}
			}
		}
		If ($Found) 
		{
			Write-Host "`nThe Create DAG script completed, please check for errors." -ForegroundColor $ForegroundNormal
			Get-DatabaseAvailabilityGroup -Id $NewDAG -Status | FL
		}
		Else 
		{
			Write-Host "Cannot find $NewDAG in file $ServerFile.  Exiting on keystroke..." -ForegroundColor $ForeGroundError
			$Host.UI.RawUI.ReadKey() | Out-Null
			Stop-Transcript
			Exit 1
		}
	}
	Else {
Write-Host "Mismatch between script schema version ($DataVersion) and $ServerFile schema version (" $DAGInfoFile[0].DagIps ")" -ForegroundColor $ForeGroundError
		Stop-Transcript
		Exit 2
	}
}
Else {
	Write-Host "Cannot find CSV file: $ServerFile.  Exiting on keystroke..." -ForegroundColor $ForeGroundError
	$Host.UI.RawUI.ReadKey() | Out-Null
	Stop-Transcript
	Exit 3
}
Stop-Transcript

