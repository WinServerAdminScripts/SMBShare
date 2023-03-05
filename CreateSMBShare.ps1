# Set network rules to allow network discovery and file and printer sharing
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes
Set-NetFirewallRule -DisplayGroup "File And Printer Sharing" -Enabled True -Profile Any

# Set services to start automatically
$services = "upnphost", "FDResPub", "SSDPSRV"
Set-Service -Name $services -StartupType Automatic

# Disable SMB signing
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters'
$Name = 'requiresecuritysignature'
$Value = '0'
Try {
    Set-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -Force -ErrorAction Stop
}
Catch {
    Write-Error "Unable to set registry value: $($_.Exception.Message)"
}

# Start necessary services for network discovery and file and printer sharing
$servicesToStart = "upnphost", "SSDPSRV"
foreach ($service in $servicesToStart) {
    Try {
        Start-Service -Name $service -ErrorAction Stop
    }
    Catch {
        Write-Error "Unable to start service '$service': $($_.Exception.Message)"
    }
}
