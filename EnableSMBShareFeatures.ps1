<#In Summary:
The script checks if a specified network share exists on a given server
by searching for the share name in the list of shared disk paths#>

Param(
    [string]$ShareName,
    [string]$ServerName
)

try {
    # Test if server is reachable
    if (!(Test-Connection -ComputerName $ServerName -Count 1 -Quiet)) {
        throw "Cannot reach server $ServerName"
    }

    # Get share information from server
    $Shares = Get-WmiObject -Class Win32_Share -ComputerName $ServerName -ErrorAction Stop

    # Check if the share exists
    if ($Shares | Where-Object {$_.Name -eq $ShareName}) {
        Write-Host "Share $ShareName found on server $ServerName"
        return 1
    } else {
        Write-Host "Share $ShareName not found on server $ServerName"
        return 0
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)"
    return -1
}