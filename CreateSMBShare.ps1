<#
In Summery
This PowerShell script is designed to set up a SMB share on a Windows server. It begins by creating the share using
the New-SmbShare cmdlet, which allows for easy sharing of files and directories across a network. Next, it sets network
rules to allow network discovery and file and printer sharing using netsh advfirewall and Set-NetFirewallRule cmdlets. 
The script also sets services to start automatically using the Set-Service cmdlet, and disables SMB signing in the 
registry using the Set-ItemProperty cmdlet. Finally, it starts necessary services for network discovery and file and 
printer sharing using the Start-Service cmdlet. Overall, this script automates the process of setting up an SMB share, 
ensuring that all necessary network rules and services are properly configured for optimal functionality.#>

# Create an SMB share
$shareName = "ShareName"
$sharePath = "C:\SharePath"
New-SmbShare -Name $shareName -Path $sharePath -FullAccess "Everyone"

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
