# Prompt user for hostnames
$hostnames = Read-Host "Enter comma-separated hostnames (e.g., server1,server2,server3)"
$servers = $hostnames -split ',' | ForEach-Object { $_.Trim() }

# Function to collect system info
function Get-SystemInfo {
    param (
        [string]$ComputerName
    )

    Write-Host "`nGathering info for $ComputerName..." -ForegroundColor Cyan

    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $ComputerName
        $cpu = Get-CimInstance -ClassName Win32_Processor -ComputerName $ComputerName
        $mem = Get-CimInstance -ClassName Win32_PhysicalMemory -ComputerName $ComputerName
        $disk = Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $ComputerName -Filter "DriveType=3"
        $net = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -ComputerName $ComputerName | Where-Object { $_.IPEnabled }

        [PSCustomObject]@{
            ComputerName     = $ComputerName
            OSVersion        = $os.Caption
            OSBuild          = $os.BuildNumber
            TotalRAMGB       = "{0:N2}" -f ($mem.Capacity | Measure-Object -Sum).Sum / 1GB
            CPU              = $cpu.Name
            DiskInfo         = $disk | Select-Object DeviceID, @{Name="FreeGB";Expression={"{0:N2}" -f ($_.FreeSpace / 1GB)}}, @{Name="SizeGB";Expression={"{0:N2}" -f ($_.Size / 1GB)}}
            IPAddresses      = $net.IPAddress -join ', '
            MACAddresses     = $net.MACAddress -join ', '
        }
    }
    catch {
        Write-Warning "Failed to connect to $ComputerName`: $($_.Exception.Message)"
    }
}

# Loop through each server and collect info
$results = foreach ($server in $servers) {
    Get-SystemInfo -ComputerName $server
}

# Display results
$results | Format-List