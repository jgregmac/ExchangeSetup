<#
    Disable-IPv4Checksum script - 
    Actively disables the "IPv4 Checksum Offload" value on all Intel or Broadcom adapters.
#>

#Display name for the property that we want to disable:
[string]$offloadProp = "IPv4 Checksum Offload"

#Collect all of the Broadcom and Intel adapters on this system:
$nics = @()
$nics = Get-NetAdapter | ? {$_.InterfaceDescription -match 'Intel|Broadcom'}

if ($nics.count -eq 0) {
    write-host "No Broadcom or Intel adapters present on this system."
    Exit
}

foreach ($nic in $nics) {
    write-host Adapter Name: $nic.Name Index: $nic.ifIndex Description: $nic.ifDesc
    #[string]$ipOffloadPath = $nic.PSPath + '\' + $offloadProp
    $nicProp = $nic | Get-NetAdapterAdvancedProperty -DisplayName $offloadProp -ErrorAction SilentlyContinue
    if ($nicProp -ne $null) {
        write-host '  IPv4 Checksum Offload value is present...' -ForegroundColor Gray
        if ($nicProp.RegistryValue -ne 0) {
            write-host '    Value is non-zero. setting.' -ForegroundColor Cyan
            $nic | Set-NetAdapterAdvancedProperty -DisplayName $offloadProp -DisplayValue 'Disabled'
        } else {
            write-host '    Value is already set to "Disabled"' -ForegroundColor Gray
        }
    } else {
        write-host '    Value is not available on this adapter.  Skipping...' -ForegroundColor Yellow
    }
}

# granualValues is an array of all possible network adapter offload values.  We are only using the first one.
# leaving this code block in case we want to disable all offload capabilities in the future.
<#$granularValues = @(
    '*IPChecksumOffloadIPv4',
    '*TCPChecksumOffloadIPv4',
    '*TCPChecksumOffloadIPv6',
    '*UDPChecksumOffloadIPv4',
    '*UDPChecksumOffloadIPv6',
    '*LsoV1IPv4',
    '*LsoV2IPv4',
    '*LsoV2IPv6',
    '*IPsecOffloadV1IPv4',
    '*IPsecOffloadV2',
    '*IPsecOffloadV2IPv4'
)
#>

#Registry key that holds configurable properties for all network adapters.  Not used with this script,
#but useful to know about for script action verification.
#[string]$nicsPath = 'HKLM:\System\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}'
#Registry property that we wish to set to zero:
#[string]$offloadProp = '*IPChecksumOffloadIPv4'