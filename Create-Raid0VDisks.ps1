# Configures a RAID 0 array for each drive on the adapter in Slot 3 (which matches our PERC H830 cards)
# Requires: 
#   - RACADM.exe (From Dell OM DRAC Tools or OM Managed Endpoint (OMSA))
#   - OM Managed Endpoint software.
#   - Adapter with drives in "Ready" or "JBOD" state on a PERC in Slot 3.

Set-PSDebug -Strict

$pdisks = & racadm storage get pdisks | ? {$_ -match 'Slot\.3-1'}

[int32]$i = 0
foreach ($disk in $pdisks) {
    & racadm Storage "createvd:RAID.Slot.3-1" "-rl r0" "-name VDisk$i" "-wp wb" "-rp ara" "-dcp disabled" "-ss 256k" "-pdkey:$disk"
    $i++
}

[string]$out = & racadm jobqueue create "RAID.Slot.3-1" "--realtime"
# Look at $out to find the JID of the job that got created.
# Capture this to $jid.  I can't do this right now because I deleted my jobs.  Boo!
[string]$jid = $out | ? {$_ -match 'JID ='} | % {$_.split('=') | select -last 1} | % {$_.trim()}

$done = $false
do {
    Start-Sleep -Seconds 10
    $out = & racadm jobqueue view "-i $jid"
    $out | Out-Host
    if ($out -match '\[100\]') {
        $done = $true
    } else {
        $out = "Job not complete.  Sleeping for 10 seconds and then trying again..."
        $out | out-host
    }
} until ($done)
$out = "Partitioning operations have ended.  Verify, because this script is too stupid to do that for you."
$out | Out-Host
