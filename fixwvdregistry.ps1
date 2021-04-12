#read WVD registry
$sxsstackver = (Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\RDInfraAgent\SxsStack).CurrentVersion

#Read terminalserverinfo
$subkeys = (Get-ChildItem -Path 'Registry::\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations').Name
$listofsxs = $subkeys -match 'rdp-sxs'

#Check if sxs exists
if (($listofsxs).count -gt 0){
    #backing up registry
    $date = get-date -Format 'MMddyyyy_hhmmss'
    $filename = "c:\windows\temp\sxsregsave_$date.reg"
    Invoke-Command  {reg export 'HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations' $filename}
}

#Remove sxs keys
foreach ($subkey in $listofsxs){
    Remove-Item -Path "Registry::\$subkey" -Recurse -Force
}
#run enable sxs script
$scriptPath = "C:\fixwvd\enablesxsstackrc.ps1"
$argumentList = $sxsstackver
Invoke-Expression "$scriptPath $argumentList"

#Add windows 10 fix key
New-ItemProperty "HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\$sxsstackver" -Name "fReverseConnectMode" -Value 1 -PropertyType "DWord"

write-host "You need to reboot to take effect" -ForegroundColor Red
Restart-Computer -force
