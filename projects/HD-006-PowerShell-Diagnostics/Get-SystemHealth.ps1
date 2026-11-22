# HD-006: Windows System Health Diagnostics
# Purpose: Collect read-only system information.
# Compatible with Windows PowerShell 5.1.

$ErrorActionPreference = "Stop"

# 1. Operating system information
$OS = Get-CimInstance Win32_OperatingSystem

$Uptime = (Get-Date) - $OS.LastBootUpTime

# 2. Memory information
$TotalMemory = [math]::Round(
    $OS.TotalVisibleMemorySize / 1MB, 2
)

$FreeMemory = [math]::Round(
    $OS.FreePhysicalMemory / 1MB, 2
)

# 3. Disk information
$Disks = @(
    Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
    ForEach-Object {
        [PSCustomObject]@{
            Drive = $_.DeviceID
            TotalGiB = [math]::Round($_.Size / 1GB, 2)
            FreeGiB = [math]::Round($_.FreeSpace / 1GB, 2)
        }
    }
)

# 4. Windows service information
$ServiceNames = @("Spooler", "wuauserv", "BITS")

$Services = @(
    foreach ($Name in $ServiceNames) {
        $Service = Get-Service -Name $Name -ErrorAction SilentlyContinue

        [PSCustomObject]@{
            Name = $Name
            Status = if ($null -eq $Service) {
                "NotFound"
            }
            else {
                $Service.Status.ToString()
            }
        }
    }
)

# 5. Build diagnostic report
$Report = [PSCustomObject]@{
    CollectedAt = (Get-Date).ToString("o")
    OperatingSystem = $OS.Caption
    UptimeHours = [math]::Round($Uptime.TotalHours, 2)
    TotalMemoryGiB = $TotalMemory
    FreeMemoryGiB = $FreeMemory
    Disks = $Disks
    Services = $Services
}

# 6. Save report with error handling

$ReportFolder = Join-Path $PSScriptRoot "reports"
$ReportPath = Join-Path $ReportFolder "SystemHealth.json"

try {

    # Create the output directory
    New-Item -ItemType Directory -Path $ReportFolder -Force -ErrorAction Stop |
        Out-Null

    # Validate basic system information
    if ($Report.TotalMemoryGiB -le 0) {
        throw "Invalid total memory value."
    }

    if (@($Report.Disks).Count -eq 0) {
        throw "No fixed disks were detected."
    }

    # Convert the report to JSON
    $Json = $Report | ConvertTo-Json -Depth 4 -ErrorAction Stop

    # Save the report
    $Json | Set-Content -LiteralPath $ReportPath -Encoding UTF8 -ErrorAction Stop

    # Verify that the saved JSON can be read
    $SavedReport = Get-Content -LiteralPath $ReportPath -Raw -ErrorAction Stop |
        ConvertFrom-Json -ErrorAction Stop

    if ([string]::IsNullOrWhiteSpace($SavedReport.OperatingSystem)) {
        throw "Saved report is missing operating system information."
    }

    Write-Output "SUCCESS: System health report generated."
    Write-Output "Report saved to: $ReportPath"

}
catch {

    Write-Error "FAILED: $($_.Exception.Message)"

    exit 1
}
