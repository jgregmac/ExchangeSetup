#Disable-NetAdapterChecksumOffload -Name nic1 -IpIPv4
# Better set in: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters Reg_DWORD DisableTaskOffload=0x00000001
# Also: netsh int ip set global TaskOffload=disabled
# (we are now setting the registry value in group policy, so no need to script this.)
