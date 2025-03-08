# PowerShell Output Formatting That Doesn't Suck
# Practical Demo Script

#region Get Server Information
# Define a function that retrieves useful server information via CIM
function Get-ServerInfo {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string[]]$ComputerName = @("DC01", "SRV01", "SRV02")
    )
    
    begin {
        # Define a list to hold our server information
        $allServerInfo = @()
    }
    
    process {
        foreach ($computer in $ComputerName) {
            Write-Verbose "Gathering information from $computer..."
            
            try {
                # Test connection first
                $pingStatus = Test-Connection -ComputerName $computer -Count 1 -Quiet
                
                if ($pingStatus) {
                    # Get OS information
                    $os = Get-CimInstance -ComputerName $computer -ClassName Win32_OperatingSystem -ErrorAction Stop
                    
                    # Get computer system information
                    $computerSystem = Get-CimInstance -ComputerName $computer -ClassName Win32_ComputerSystem -ErrorAction Stop
                    
                    # Get processor information
                    $processor = Get-CimInstance -ComputerName $computer -ClassName Win32_Processor -ErrorAction Stop | Select-Object -First 1
                    
                    # Get logical disk information (C: drive)
                    $disk = Get-CimInstance -ComputerName $computer -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction Stop
                    
                    # Get network adapter configuration
                    $network = Get-CimInstance -ComputerName $computer -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled='True'" -ErrorAction Stop
                    
                    # Get service information
                    $runningServices = (Get-CimInstance -ComputerName $computer -ClassName Win32_Service -Filter "State='Running'" -ErrorAction Stop).Count
                    $stoppedServices = (Get-CimInstance -ComputerName $computer -ClassName Win32_Service -Filter "State='Stopped'" -ErrorAction Stop).Count
                    
                    # Calculate memory values
                    $totalMemory = [math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)
                    $freeMemory = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
                    $memoryUsedPercent = [math]::Round(($totalMemory - ($freeMemory/1024)) / $totalMemory * 100, 2)
                    
                    # Calculate disk space values
                    $totalDiskSpace = [math]::Round($disk.Size / 1GB, 2)
                    $freeDiskSpace = [math]::Round($disk.FreeSpace / 1GB, 2)
                    $diskUsedPercent = [math]::Round(($totalDiskSpace - $freeDiskSpace) / $totalDiskSpace * 100, 2)
                    
                    # Create server info object
                    $serverInfo = [PSCustomObject]@{
                        ServerName = $computer
                        Status = "Online"
                        OSName = $os.Caption
                        OSVersion = $os.Version
                        Manufacturer = $computerSystem.Manufacturer
                        Model = $computerSystem.Model
                        Processor = $processor.Name
                        LogicalCores = $processor.NumberOfLogicalProcessors
                        TotalMemoryGB = $totalMemory
                        FreeMemoryGB = [math]::Round($freeMemory/1024, 2)
                        MemoryUsedPercent = $memoryUsedPercent
                        TotalDiskGB = $totalDiskSpace
                        FreeDiskGB = $freeDiskSpace
                        DiskUsedPercent = $diskUsedPercent
                        IPAddress = ($network | Select-Object -First 1).IPAddress[0]
                        MACAddress = ($network | Select-Object -First 1).MACAddress
                        LastBootTime = $os.LastBootUpTime
                        UptimeDays = [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalDays, 2)
                        RunningServices = $runningServices
                        StoppedServices = $stoppedServices
                    }
                } else {
                    # Create offline server object
                    $serverInfo = [PSCustomObject]@{
                        ServerName = $computer
                        Status = "Offline"
                        OSName = "N/A"
                        OSVersion = "N/A"
                        Manufacturer = "N/A"
                        Model = "N/A"
                        Processor = "N/A"
                        LogicalCores = 0
                        TotalMemoryGB = 0
                        FreeMemoryGB = 0
                        MemoryUsedPercent = 0
                        TotalDiskGB = 0
                        FreeDiskGB = 0
                        DiskUsedPercent = 0
                        IPAddress = "N/A"
                        MACAddress = "N/A"
                        LastBootTime = $null
                        UptimeDays = 0
                        RunningServices = 0
                        StoppedServices = 0
                    }
                }
                
                # Add to collection
                $allServerInfo += $serverInfo
                
            } catch {
                Write-Warning "Error retrieving information from $computer`: $_"
                
                # Create error server object
                $serverInfo = [PSCustomObject]@{
                    ServerName = $computer
                    Status = "Error"
                    OSName = "Error"
                    OSVersion = "Error"
                    Manufacturer = "Error"
                    Model = "Error"
                    Processor = "Error"
                    LogicalCores = 0
                    TotalMemoryGB = 0
                    FreeMemoryGB = 0
                    MemoryUsedPercent = 0
                    TotalDiskGB = 0
                    FreeDiskGB = 0
                    DiskUsedPercent = 0
                    IPAddress = "Error"
                    MACAddress = "Error"
                    LastBootTime = $null
                    UptimeDays = 0
                    RunningServices = 0
                    StoppedServices = 0
                }
                
                # Add to collection
                $allServerInfo += $serverInfo
            }
        }
    }
    
    end {
        # Return the server information
        return $allServerInfo
    }
}
#endregion
Get-ServerInfo 

#region Demo Functions
# For demonstration purposes, let's create a function that simulates getting data
# This allows the demo to work without actual servers
function Get-DemoServerInfo {
    param (
        [string[]]$ComputerName = @("SRV01", "SRV02", "DC01")
    )
    
    $allServerInfo = @()
    
    foreach ($computer in $ComputerName) {
        # Randomize some values for the demo
        $status = Get-Random -InputObject @("Online", "Online", "Online", "Offline")
        $totalMemory = Get-Random -Minimum 8 -Maximum 64
        $freeMemory = Get-Random -Minimum 1 -Maximum ($totalMemory - 1)
        $memoryUsedPercent = [math]::Round(($totalMemory - $freeMemory) / $totalMemory * 100, 2)
        
        $totalDisk = Get-Random -Minimum 100 -Maximum 1000
        $freeDisk = Get-Random -Minimum 10 -Maximum ($totalDisk - 10)
        $diskUsedPercent = [math]::Round(($totalDisk - $freeDisk) / $totalDisk * 100, 2)
        
        $lastBootTime = (Get-Date).AddDays(-1 * (Get-Random -Minimum 1 -Maximum 60))
        $uptimeDays = [math]::Round(((Get-Date) - $lastBootTime).TotalDays, 2)
        
        $runningServices = Get-Random -Minimum 50 -Maximum 100
        $stoppedServices = Get-Random -Minimum 10 -Maximum 50
        
        $ipOctet3 = Get-Random -Minimum 0 -Maximum 255
        $ipOctet4 = Get-Random -Minimum 1 -Maximum 254
        
        $serverInfo = [PSCustomObject]@{
            ServerName = $computer
            Status = $status
            OSName = if ($computer -eq "DC01") { "Windows Server 2019 Datacenter" } else { "Windows Server 2022 Standard" }
            OSVersion = if ($computer -eq "DC01") { "10.0.17763" } else { "10.0.20348" }
            Manufacturer = Get-Random -InputObject @("Dell Inc.", "HP", "Lenovo")
            Model = "PowerEdge R740"
            Processor = "Intel(R) Xeon(R) CPU E5-2690 v4 @ 2.60GHz"
            LogicalCores = Get-Random -InputObject @(8, 16, 32)
            TotalMemoryGB = $totalMemory
            FreeMemoryGB = $freeMemory
            MemoryUsedPercent = $memoryUsedPercent
            TotalDiskGB = $totalDisk
            FreeDiskGB = $freeDisk
            DiskUsedPercent = $diskUsedPercent
            IPAddress = "192.168.$ipOctet3.$ipOctet4"
            MACAddress = (0..5 | ForEach-Object { [byte](Get-Random -Minimum 0 -Maximum 255) } | ForEach-Object { $_.ToString("X2") }) -join "-"
            LastBootTime = $lastBootTime
            UptimeDays = $uptimeDays
            RunningServices = $runningServices
            StoppedServices = $stoppedServices
        }
        
        $allServerInfo += $serverInfo
    }
    
    return $allServerInfo
}

# Demo 1: Basic Console Formatting
function Demo-ConsoleFormatting {
    Clear-Host
    Write-Host "DEMO 1: Basic Console Formatting" -ForegroundColor Cyan
    Write-Host "------------------------------" -ForegroundColor Cyan
    
    # Get server information
    $servers = Get-ServerInfo -ComputerName dc01,srv01,SRV02
    
    # Show default output (ugly)
    Write-Host "`nDefault Output (Ugly):" -ForegroundColor Yellow
    $servers
    
    # Show better formatted table with calculated properties
    Write-Host "`nBetter Formatted Table:" -ForegroundColor Yellow
    $servers | Format-Table -Property ServerName, Status, OSName,
        @{Name="Memory (GB)"; Expression={"$($_.FreeMemoryGB) / $($_.TotalMemoryGB)"}; Alignment="Right"},
        @{Name="Memory %"; Expression={$_.MemoryUsedPercent}; Alignment="Right"},
        @{Name="Disk (GB)"; Expression={"$($_.FreeDiskGB) / $($_.TotalDiskGB)"}; Alignment="Right"},
        @{Name="Disk %"; Expression={$_.DiskUsedPercent}; Alignment="Right"},
        @{Name="Uptime"; Expression={"$($_.UptimeDays) days"}; Alignment="Right"} -AutoSize
    
    # Show color-coded console output
    Write-Host "`nColor-Coded Console Output:" -ForegroundColor Yellow
    foreach ($server in $servers) {
        # Determine status color
        $statusColor = switch ($server.Status) {
            "Online" { "Green" }
            "Offline" { "Red" }
            default { "Yellow" }
        }
        
        # Determine resource warning colors
        $memoryColor = if ($server.MemoryUsedPercent -gt 90) { "Red" } 
                      elseif ($server.MemoryUsedPercent -gt 70) { "Yellow" }
                      else { "Green" }
                      
        $diskColor = if ($server.DiskUsedPercent -gt 90) { "Red" } 
                    elseif ($server.DiskUsedPercent -gt 70) { "Yellow" }
                    else { "Green" }
        
        # Output formatted server info
        Write-Host "Server: " -NoNewline
        Write-Host $server.ServerName -ForegroundColor Cyan -NoNewline
        Write-Host " [" -NoNewline
        Write-Host $server.Status -ForegroundColor $statusColor -NoNewline
        Write-Host "]" 
        
        Write-Host "  OS: $($server.OSName)"
        
        Write-Host "  Memory: " -NoNewline
        Write-Host "$($server.FreeMemoryGB) GB free of $($server.TotalMemoryGB) GB" -NoNewline
        Write-Host " ($($server.MemoryUsedPercent)% used)" -ForegroundColor $memoryColor
        
        Write-Host "  Disk: " -NoNewline
        Write-Host "$($server.FreeDiskGB) GB free of $($server.TotalDiskGB) GB" -NoNewline
        Write-Host " ($($server.DiskUsedPercent)% used)" -ForegroundColor $diskColor
        
        Write-Host "  Uptime: $($server.UptimeDays) days"
        Write-Host "  Services: $($server.RunningServices) running, $($server.StoppedServices) stopped"
        Write-Host "  Network: $($server.IPAddress) ($($server.MACAddress))"
        Write-Host ""
    }
}

Demo-ConsoleFormatting

# Demo 2: Exporting to CSV
function Demo-ExportCSV {
    Clear-Host
    Write-Host "DEMO 2: Exporting to CSV" -ForegroundColor Cyan
    Write-Host "---------------------" -ForegroundColor Cyan
    
    # Get server information
    $servers = Get-DemoServerInfo
    
    # Create a cleaned up version for export
    $exportData = $servers | Select-Object ServerName, Status, OSName, OSVersion, Manufacturer, Model,
        @{Name="TotalMemoryGB"; Expression={$_.TotalMemoryGB}},
        @{Name="FreeMemoryGB"; Expression={$_.FreeMemoryGB}},
        @{Name="MemoryUsedPercent"; Expression={$_.MemoryUsedPercent}},
        @{Name="TotalDiskGB"; Expression={$_.TotalDiskGB}},
        @{Name="FreeDiskGB"; Expression={$_.FreeDiskGB}},
        @{Name="DiskUsedPercent"; Expression={$_.DiskUsedPercent}},
        IPAddress, UptimeDays,
        @{Name="LastBootTimeUTC"; Expression={$_.LastBootTime.ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss")}},
        RunningServices, StoppedServices
    
    # Display what we're exporting
    Write-Host "`nData prepared for CSV export:" -ForegroundColor Yellow
    $exportData | Format-Table -AutoSize
    
    # Export to CSV
    $csvPath = "$PWD\ServerInventory.csv"
    $exportData | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
    
    Write-Host "`nExported to CSV: $csvPath" -ForegroundColor Green
    
    # Show the command to import this CSV back
    Write-Host "`nTo import this CSV later:" -ForegroundColor Yellow
    Write-Host 'Import-Csv -Path "$PWD\ServerInventory.csv"' -ForegroundColor Gray
}
Demo-ExportCSV

# Demo 3: Exporting to Excel with ImportExcel module
function Demo-ExportExcel {
    Clear-Host
    Write-Host "DEMO 3: Exporting to Excel with ImportExcel Module" -ForegroundColor Cyan
    Write-Host "--------------------------------------------" -ForegroundColor Cyan
    
    # Check if ImportExcel module is installed
    if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
        Write-Host "`nThe ImportExcel module is not installed. Here's the code that would run:" -ForegroundColor Yellow
        Write-Host @'
# Install the module if needed
Install-Module -Name ImportExcel -Scope CurrentUser -Force

# Get server information
$servers = Get-ServerInfo -ComputerName "SRV01", "SRV02", "DC01"

# Define the Excel path
$excelPath = "$PWD\ServerInventory.xlsx"

# Export to Excel with formatting
$servers | Export-Excel -Path $excelPath -WorksheetName "Server Inventory" -TableName "ServerInventory" -AutoSize -FreezeTopRow -BoldTopRow -AutoFilter -ConditionalText $(
    # Add conditional formatting
    New-ConditionalText -Text "Offline" -ConditionalTextColor Black -BackgroundColor Coral
    New-ConditionalText -Text "Error" -ConditionalTextColor Black -BackgroundColor Red
    
    # Memory usage condition
    New-ConditionalText -Range "K:K" -ConditionalType GreaterThan -Value 90 -ConditionalTextColor Black -BackgroundColor Red
    New-ConditionalText -Range "K:K" -ConditionalType GreaterThan -Value 70 -ConditionalTextColor Black -BackgroundColor Yellow
    
    # Disk usage condition
    New-ConditionalText -Range "N:N" -ConditionalType GreaterThan -Value 90 -ConditionalTextColor Black -BackgroundColor Red
    New-ConditionalText -Range "N:N" -ConditionalType GreaterThan -Value 70 -ConditionalTextColor Black -BackgroundColor Yellow
)

# Add a chart to the Excel workbook
$excel = $servers | Export-Excel -Path $excelPath -WorksheetName "Disk Usage" -PassThru
$diskSheet = $excel.Workbook.Worksheets["Disk Usage"]

# Create a new chart
$chart = $diskSheet.Drawings.AddChart("Disk Usage Chart", [OfficeOpenXml.Drawing.Chart.eChartType]::ColumnClustered)
$chart.Series.Add("A2:A4", "M2:M4")  # ServerName vs DiskUsedPercent
$chart.Title.Text = "Disk Usage Percentage by Server"
$chart.SetPosition(1, 0, 6, 0)
$chart.SetSize(600, 400)
$chart.YAxis.Title.Text = "Disk Usage (%)"
$chart.XAxis.Title.Text = "Server"

# Save the workbook
$excel.Save()
$excel.Dispose()

Write-Host "Exported to Excel: $excelPath" -ForegroundColor Green
'@ -ForegroundColor Gray
    } else {
        # Get server information
        $servers = Get-DemoServerInfo
        
        # Export to Excel
        $excelPath = "$PWD\ServerInventory.xlsx"
        
        Write-Host "`nExporting to Excel with formatting..." -ForegroundColor Yellow
        
        # Example code for ImportExcel - commented out to prevent running it in the demo
        <#
        $servers | Export-Excel -Path $excelPath -WorksheetName "Server Inventory" -TableName "ServerInventory" -AutoSize -FreezeTopRow -BoldTopRow -AutoFilter -ConditionalText $(
            # Add conditional formatting
            New-ConditionalText -Text "Offline" -ConditionalTextColor Black -BackgroundColor Coral
            New-ConditionalText -Text "Error" -ConditionalTextColor Black -BackgroundColor Red
            
            # Memory usage condition
            New-ConditionalText -Range "K:K" -ConditionalType GreaterThan -Value 90 -ConditionalTextColor Black -BackgroundColor Red
            New-ConditionalText -Range "K:K" -ConditionalType GreaterThan -Value 70 -ConditionalTextColor Black -BackgroundColor Yellow
            
            # Disk usage condition
            New-ConditionalText -Range "N:N" -ConditionalType GreaterThan -Value 90 -ConditionalTextColor Black -BackgroundColor Red
            New-ConditionalText -Range "N:N" -ConditionalType GreaterThan -Value 70 -ConditionalTextColor Black -BackgroundColor Yellow
        )
        #>
        
        Write-Host "`nExcel export would be saved to: $excelPath" -ForegroundColor Green
    }
}

Demo-ExportExcel
# Demo 4: HTML Report with External CSS
function Demo-HTMLReport {
    Clear-Host
    Write-Host "DEMO 4: HTML Report with External CSS" -ForegroundColor Cyan
    Write-Host "---------------------------------" -ForegroundColor Cyan
    
    # Get server information
    $servers = Get-DemoServerInfo
    
    # Define external CSS file path
    $cssPath = "$PWD\ServerReport.css"
    
    # Create CSS content
    $css = @"
body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    margin: 20px;
    background-color: #f8f9fa;
    color: #212529;
}

h1 {
    color: #0066cc;
    border-bottom: 2px solid #0066cc;
    padding-bottom: 5px;
}

h2 {
    color: #0066cc;
    margin-top: 20px;
}

.container {
    background-color: white;
    border-radius: 5px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    padding: 20px;
    margin-bottom: 20px;
}

.summary {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-bottom: 20px;
}

.summary-box {
    flex: 1;
    min-width: 200px;
    background-color: #e9ecef;
    border-left: 5px solid #0066cc;
    padding: 10px 15px;
    border-radius: 3px;
}

table {
    width: 100%;
    border-collapse: collapse;
    margin: 15px 0;
}

th {
    background-color: #0066cc;
    color: white;
    text-align: left;
    padding: 10px;
}

td {
    padding: 8px 10px;
    border-bottom: 1px solid #dee2e6;
}

tr:nth-child(even) {
    background-color: #f2f2f2;
}

tr:hover {
    background-color: #e9ecef;
}

.status-online {
    color: green;
    font-weight: bold;
}

.status-offline {
    color: red;
    font-weight: bold;
}

.status-error {
    color: orange;
    font-weight: bold;
}

.warning {
    background-color: #fff3cd;
    color: #856404;
}

.critical {
    background-color: #f8d7da;
    color: #721c24;
}

.footer {
    text-align: center;
    margin-top: 20px;
    font-size: 0.8em;
    color: #6c757d;
}

.timestamp {
    font-style: italic;
    color: #6c757d;
    text-align: right;
}
"@
    
    # Save CSS to file
    $css | Out-File -FilePath $cssPath -Encoding utf8
    
    # Create HTML content
    $onlineCount = ($servers | Where-Object { $_.Status -eq "Online" }).Count
    $offlineCount = ($servers | Where-Object { $_.Status -eq "Offline" }).Count
    $errorCount = ($servers | Where-Object { $_.Status -eq "Error" }).Count
    
    $highMemoryCount = ($servers | Where-Object { $_.MemoryUsedPercent -gt 70 }).Count
    $highDiskCount = ($servers | Where-Object { $_.DiskUsedPercent -gt 70 }).Count
    
    $avgMemoryUsage = [math]::Round(($servers | Measure-Object -Property MemoryUsedPercent -Average).Average, 2)
    $avgDiskUsage = [math]::Round(($servers | Measure-Object -Property DiskUsedPercent -Average).Average, 2)
    
    # Create table rows
    $serverRows = ""
    foreach ($server in $servers) {
        $statusClass = "status-$($server.Status.ToLower())"
        
        $memoryClass = if ($server.MemoryUsedPercent -gt 90) { "critical" } 
                       elseif ($server.MemoryUsedPercent -gt 70) { "warning" }
                       else { "" }
                       
        $diskClass = if ($server.DiskUsedPercent -gt 90) { "critical" } 
                     elseif ($server.DiskUsedPercent -gt 70) { "warning" }
                     else { "" }
        
        $serverRows += @"
<tr>
    <td>$($server.ServerName)</td>
    <td class="$statusClass">$($server.Status)</td>
    <td>$($server.OSName)</td>
    <td>$($server.Manufacturer) $($server.Model)</td>
    <td>$($server.IPAddress)</td>
    <td class="$memoryClass">$($server.FreeMemoryGB) / $($server.TotalMemoryGB) GB ($($server.MemoryUsedPercent)%)</td>
    <td class="$diskClass">$($server.FreeDiskGB) / $($server.TotalDiskGB) GB ($($server.DiskUsedPercent)%)</td>
    <td>$($server.UptimeDays) days</td>
</tr>
"@
    }
    
    # Build the complete HTML
    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Server Status Report</title>
    <link rel="stylesheet" href="ServerReport.css">
</head>
<body>
    <h1>Server Status Report</h1>
    <div class="timestamp">Generated on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</div>
    
    <div class="container">
        <h2>Summary</h2>
        <div class="summary">
            <div class="summary-box">
                <strong>Total Servers:</strong> $($servers.Count)<br>
                <strong>Online:</strong> $onlineCount<br>
                <strong>Offline:</strong> $offlineCount<br>
                <strong>Error:</strong> $errorCount
            </div>
            <div class="summary-box">
                <strong>Avg Memory Usage:</strong> $avgMemoryUsage%<br>
                <strong>Servers with High Memory:</strong> $highMemoryCount<br>
                <strong>Avg Disk Usage:</strong> $avgDiskUsage%<br>
                <strong>Servers with High Disk:</strong> $highDiskCount
            </div>
        </div>
        
        <h2>Server Details</h2>
        <table>
            <tr>
                <th>Server Name</th>
                <th>Status</th>
                <th>OS</th>
                <th>Hardware</th>
                <th>IP Address</th>
                <th>Memory Usage</th>
                <th>Disk Usage</th>
                <th>Uptime</th>
            </tr>
            $serverRows
        </table>
    </div>
    
    <div class="footer">
        Server Status Report | IT Department | For internal use only
    </div>
</body>
</html>
"@
    
    # Save HTML to file
    $htmlPath = "$PWD\ServerReport.html"
    $html | Out-File -FilePath $htmlPath -Encoding utf8
    
    Write-Host "`nHTML Report Generated:" -ForegroundColor Green
    Write-Host "HTML File: $htmlPath" -ForegroundColor Gray
    Write-Host "CSS File: $cssPath" -ForegroundColor Gray
    
    # Show how to open the report
    Write-Host "`nTo open the report in the default browser:" -ForegroundColor Yellow
    Write-Host "Invoke-Item `"$htmlPath`"" -ForegroundColor Gray
}

Demo-HTMLReport
# Demo 5: Converting to JSON
function Demo-ConvertToJSON {
    Clear-Host
    Write-Host "DEMO 5: Converting to JSON" -ForegroundColor Cyan
    Write-Host "------------------------" -ForegroundColor Cyan
    
    # Get server information
    $servers = Get-DemoServerInfo
    
    # Create a simplified version for JSON export
    $jsonData = $servers | ForEach-Object {
        [PSCustomObject]@{
            server_name = $_.ServerName
            status = $_.Status.ToLower()
            hardware = [PSCustomObject]@{
                manufacturer = $_.Manufacturer
                model = $_.Model
                processor = $_.Processor
                logical_cores = $_.LogicalCores
            }
            operating_system = [PSCustomObject]@{
                name = $_.OSName
                version = $_.OSVersion
            }
            resources = [PSCustomObject]@{
                memory = [PSCustomObject]@{
                    total_gb = $_.TotalMemoryGB
                    free_gb = $_.FreeMemoryGB
                    used_percent = $_.MemoryUsedPercent
                }
                disk = [PSCustomObject]@{
                    total_gb = $_.TotalDiskGB
                    free_gb = $_.FreeDiskGB
                    used_percent = $_.DiskUsedPercent
                }
            }
            network = [PSCustomObject]@{
                ip_address = $_.IPAddress
                mac_address = $_.MACAddress
            }
            uptime = [PSCustomObject]@{
                days = $_.UptimeDays
                last_boot = $_.LastBootTime.ToString("o")
            }
            services = [PSCustomObject]@{
                running = $_.RunningServices
                stopped = $_.StoppedServices
            }
        }
    }
    
    # Convert to JSON
    $json = $jsonData | ConvertTo-Json -Depth 5
    
    # Display JSON
    Write-Host "`nJSON Output:" -ForegroundColor Yellow
    Write-Host $json -ForegroundColor Gray
    
    # Save to file
    $jsonPath = "$PWD\ServerInventory.json"
    $json | Out-File -FilePath $jsonPath -Encoding utf8
    
    Write-Host "`nJSON saved to: $jsonPath" -ForegroundColor Green
    
    # Show how to use the JSON
    Write-Host "`nTo import this JSON later:" -ForegroundColor Yellow
    Write-Host "Get-Content -Path `"$jsonPath`" -Raw | ConvertFrom-Json" -ForegroundColor Gray
    
    # Show API integration example
    Write-Host "`nExample of API integration:" -ForegroundColor Yellow
    Write-Host @'
# Post the data to a monitoring API
$apiUrl = "https://monitoring.company.com/api/servers"
$headers = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer $apiToken"
}

# Send the server data
Invoke-RestMethod -Uri $apiUrl -Method Post -Body $json -Headers $headers -ContentType "application/json"

# You can also query data from an API and format it
$apiServers = Invoke-RestMethod -Uri "$apiUrl/list" -Method Get -Headers $headers
$apiServers | ConvertTo-Html -Property server_name,status,uptime.days -Fragment | 
    Out-File -FilePath "$PWD\APIServers.html"
'@ -ForegroundColor Gray
}

Demo-ConvertToJSON
# Demo 6: All-in-One Server Report with Multiple Outputs
function Demo-ServerReportAllInOne {
    Clear-Host
    Write-Host "DEMO 6: Complete Server Reporting Solution" -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    
    # Get server information
    Write-Host "`nGathering server information..." -ForegroundColor Yellow
    $servers = Get-DemoServerInfo
    
    # Create output directory if it doesn't exist
    $outputPath = "$PWD\ServerReports"
    if (-not (Test-Path -Path $outputPath)) {
        New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
    }
    
    # 1. Display console report with color coding
    Write-Host "`nGenerating color-coded console report..." -ForegroundColor Yellow
    foreach ($server in $servers) {
        # Determine status color
        $statusColor = switch ($server.Status) {
            "Online" { "Green" }
            "Offline" { "Red" }
            default { "Yellow" }
        }
        
        # Output formatted server info with color
        Write-Host ("=" * 50)
        Write-Host "SERVER: " -NoNewline
        Write-Host $server.ServerName -ForegroundColor Cyan -NoNewline
        Write-Host " [" -NoNewline
        Write-Host $server.Status -ForegroundColor $statusColor -NoNewline
        Write-Host "]"
        Write-Host ("=" * 50)
        
        if ($server.Status -ne "Online") {
            Write-Host "Server is not online. Skipping detailed stats.`n"
            continue
        }
        
        # Display server details
        Write-Host "OS:         $($server.OSName) ($($server.OSVersion))"
        Write-Host "Hardware:   $($server.Manufacturer) $($server.Model)"
        Write-Host "Processor:  $($server.Processor) ($($server.LogicalCores) cores)"
        
        # Memory section with color
        $memoryColor = if ($server.MemoryUsedPercent -gt 90) { "Red" } 
                      elseif ($server.MemoryUsedPercent -gt 70) { "Yellow" }
                      else { "Green" }
        Write-Host "Memory:     " -NoNewline
        Write-Host "$($server.FreeMemoryGB) GB free of $($server.TotalMemoryGB) GB" -NoNewline
        Write-Host " ($($server.MemoryUsedPercent)% used)" -ForegroundColor $memoryColor
        
        # Disk section with color
        $diskColor = if ($server.DiskUsedPercent -gt 90) { "Red" } 
                    elseif ($server.DiskUsedPercent -gt 70) { "Yellow" }
                    else { "Green" }
        Write-Host "Disk (C:):  " -NoNewline
        Write-Host "$($server.FreeDiskGB) GB free of $($server.TotalDiskGB) GB" -NoNewline
        Write-Host " ($($server.DiskUsedPercent)% used)" -ForegroundColor $diskColor
        
        # Network and services
        Write-Host "Network:    $($server.IPAddress) ($($server.MACAddress))"
        Write-Host "Uptime:     $($server.UptimeDays) days (boot: $($server.LastBootTime))"
        Write-Host "Services:   $($server.RunningServices) running, $($server.StoppedServices) stopped"
        Write-Host ""
    }
    
    # 2. Export to CSV
    Write-Host "`nExporting to CSV..." -ForegroundColor Yellow
    $csvPath = "$outputPath\ServerInventory.csv"
    $servers | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
    Write-Host "CSV exported to: $csvPath" -ForegroundColor Green
    
    # 3. Export to HTML
    Write-Host "`nGenerating HTML report..." -ForegroundColor Yellow
    
    # Create HTML Header with embedded CSS
    $htmlHeader = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Server Infrastructure Report</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 20px;
            background-color: #f8f9fa;
            color: #212529;
        }
        h1, h2, h3 {
            color: #0066cc;
        }
        h1 {
            border-bottom: 2px solid #0066cc;
            padding-bottom: 5px;
        }
        .section {
            background-color: white;
            border-radius: 5px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            padding: 20px;
            margin-bottom: 20px;
        }
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }
        .summary-box {
            background-color: #e9ecef;
            border-left: 5px solid #0066cc;
            padding: 10px 15px;
            border-radius: 3px;
        }
        .status-container {
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 15px;
        }
        .status-box {
            flex: 1;
            min-width: 120px;
            padding: 10px;
            border-radius: 5px;
            text-align: center;
        }
        .status-online {
            background-color: #d4edda;
            color: #155724;
        }
        .status-offline {
            background-color: #f8d7da;
            color: #721c24;
        }
        .status-warning {
            background-color: #fff3cd;
            color: #856404;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 15px 0;
        }
        th {
            background-color: #0066cc;
            color: white;
            text-align: left;
            padding: 10px;
        }
        td {
            padding: 8px 10px;
            border-bottom: 1px solid #dee2e6;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        tr:hover {
            background-color: #e9ecef;
        }
        .warning {
            background-color: #fff3cd;
        }
        .critical {
            background-color: #f8d7da;
        }
        .footer {
            text-align: center;
            margin-top: 20px;
            font-size: 0.8em;
            color: #6c757d;
        }
        .chart-container {
            max-width: 800px;
            margin: 0 auto;
            height: 300px;
            position: relative;
        }
        .bar {
            display: inline-block;
            width: 40px;
            margin: 0 10px;
            position: absolute;
            bottom: 40px;
            background-color: #0066cc;
            transition: height 0.5s ease;
        }
        .bar-label {
            position: absolute;
            bottom: 10px;
            text-align: center;
            width: 60px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .axis {
            position: absolute;
            bottom: 40px;
            left: 0;
            right: 0;
            height: 1px;
            background-color: #333;
        }
    </style>
</head>
<body>
    <h1>Server Infrastructure Report</h1>
    <p>Report generated on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")</p>
"@
    
    # Create summary section
    $onlineCount = ($servers | Where-Object { $_.Status -eq "Online" }).Count
    $offlineCount = ($servers | Where-Object { $_.Status -eq "Offline" }).Count
    $errorCount = ($servers | Where-Object { $_.Status -eq "Error" }).Count
    
    $htmlSummary = @"
    <div class="section">
        <h2>Executive Summary</h2>
        <div class="status-container">
            <div class="status-box status-online">
                <h3>$onlineCount</h3>
                <div>Online</div>
            </div>
            <div class="status-box status-offline">
                <h3>$offlineCount</h3>
                <div>Offline</div>
            </div>
            <div class="status-box status-warning">
                <h3>$errorCount</h3>
                <div>Error</div>
            </div>
        </div>
        
        <div class="summary-grid">
            <div class="summary-box">
                <strong>Total Servers:</strong> $($servers.Count)<br>
                <strong>Avg Memory Usage:</strong> $([math]::Round(($servers | Measure-Object -Property MemoryUsedPercent -Average).Average, 2))%<br>
                <strong>Avg Disk Usage:</strong> $([math]::Round(($servers | Measure-Object -Property DiskUsedPercent -Average).Average, 2))%
            </div>
            <div class="summary-box">
                <strong>High Memory Servers:</strong> $($servers | Where-Object { $_.MemoryUsedPercent -gt 70 }).Count<br>
                <strong>High Disk Usage Servers:</strong> $($servers | Where-Object { $_.DiskUsedPercent -gt 70 }).Count<br>
                <strong>Avg Uptime:</strong> $([math]::Round(($servers | Measure-Object -Property UptimeDays -Average).Average, 2)) days
            </div>
        </div>
    </div>
"@
    
    # Create disk usage chart (simple HTML/CSS chart)
    $chartHtml = @"
    <div class="section">
        <h2>Disk Usage Overview</h2>
        <div class="chart-container">
            <div class="axis"></div>
"@
    
    # Add bars for each server
    $barWidth = 60  # Width of each bar plus margin
    $i = 0
    foreach ($server in ($servers | Sort-Object -Property DiskUsedPercent -Descending)) {
        $barHeight = [math]::Max(10, $server.DiskUsedPercent * 2.5)  # Scale to make it visible (max 250px)
        $barColor = if ($server.DiskUsedPercent -gt 90) { "#dc3545" }
                   elseif ($server.DiskUsedPercent -gt 70) { "#ffc107" }
                   else { "#0066cc" }
                   
        $left = 30 + ($i * $barWidth)
        
        $chartHtml += @"
            <div class="bar" style="left: ${left}px; height: ${barHeight}px; background-color: $barColor;"></div>
            <div class="bar-label" style="left: ${left}px;">$($server.ServerName)<br>$($server.DiskUsedPercent)%</div>
"@
        $i++
    }
    
    $chartHtml += @"
        </div>
    </div>
"@
    
    # Create server details table
    $serverRows = ""
    foreach ($server in $servers) {
        $rowClass = if ($server.Status -ne "Online") { "critical" }
                   elseif ($server.DiskUsedPercent -gt 90 -or $server.MemoryUsedPercent -gt 90) { "critical" }
                   elseif ($server.DiskUsedPercent -gt 70 -or $server.MemoryUsedPercent -gt 70) { "warning" }
                   else { "" }
                   
        $serverRows += @"
        <tr class="$rowClass">
            <td>$($server.ServerName)</td>
            <td>$($server.Status)</td>
            <td>$($server.OSName)</td>
            <td>$($server.IPAddress)</td>
            <td>$($server.MemoryUsedPercent)%</td>
            <td>$($server.DiskUsedPercent)%</td>
            <td>$($server.UptimeDays) days</td>
        </tr>
"@
    }
    
    $htmlTable = @"
    <div class="section">
        <h2>Server Details</h2>
        <table>
            <tr>
                <th>Server Name</th>
                <th>Status</th>
                <th>Operating System</th>
                <th>IP Address</th>
                <th>Memory Usage</th>
                <th>Disk Usage</th>
                <th>Uptime</th>
            </tr>
            $serverRows
        </table>
    </div>
"@
    
    # Create HTML footer
    $htmlFooter = @"
    <div class="footer">
        Server Infrastructure Report | IT Department | Generated by PowerShell
    </div>
</body>
</html>
"@
    
    # Combine all HTML parts
    $fullHtml = $htmlHeader + $htmlSummary + $chartHtml + $htmlTable + $htmlFooter
    
    # Save HTML to file
    $htmlPath = "$outputPath\ServerReport.html"
    $fullHtml | Out-File -FilePath $htmlPath -Encoding utf8
    Write-Host "HTML report exported to: $htmlPath" -ForegroundColor Green
    
    # 4. Convert to JSON for API
    Write-Host "`nGenerating JSON for API..." -ForegroundColor Yellow
    
    # Create JSON structure
    $jsonData = @{
        report_metadata = @{
            report_name = "Server Infrastructure Status"
            generated_at = (Get-Date).ToString("o")
            server_count = $servers.Count
        }
        summary = @{
            status = @{
                online = $onlineCount
                offline = $offlineCount
                error = $errorCount
            }
            resources = @{
                avg_memory_usage = [math]::Round(($servers | Measure-Object -Property MemoryUsedPercent -Average).Average, 2)
                avg_disk_usage = [math]::Round(($servers | Measure-Object -Property DiskUsedPercent -Average).Average, 2)
                high_memory_count = ($servers | Where-Object { $_.MemoryUsedPercent -gt 70 }).Count
                high_disk_count = ($servers | Where-Object { $_.DiskUsedPercent -gt 70 }).Count
            }
        }
        servers = $servers | ForEach-Object {
            @{
                name = $_.ServerName
                status = $_.Status.ToLower()
                os = $_.OSName
                ip_address = $_.IPAddress
                resources = @{
                    memory = @{
                        total_gb = $_.TotalMemoryGB
                        free_gb = $_.FreeMemoryGB
                        used_percent = $_.MemoryUsedPercent
                    }
                    disk = @{
                        total_gb = $_.TotalDiskGB
                        free_gb = $_.FreeDiskGB
                        used_percent = $_.DiskUsedPercent
                    }
                }
                uptime_days = $_.UptimeDays
            }
        }
    }
    
    # Convert to JSON
    $json = $jsonData | ConvertTo-Json -Depth 5
    
    # Save to file
    $jsonPath = "$outputPath\ServerStatus.json"
    $json | Out-File -FilePath $jsonPath -Encoding utf8
    Write-Host "JSON exported to: $jsonPath" -ForegroundColor Green
    
    # Summary
    Write-Host "`nAll reports have been generated in: $outputPath" -ForegroundColor Green
    Write-Host "You can now view these reports and use them for various purposes." -ForegroundColor Yellow
}

Demo-ServerReportAllInOne



# Main menu function
function Show-FormattingMenu {
    Clear-Host
    Write-Host "PowerShell Output Formatting That Doesn't Suck" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host
    Write-Host "Choose a demo to run:" -ForegroundColor Yellow
    Write-Host "1. Basic Console Formatting (Format-Table tricks)" -ForegroundColor White
    Write-Host "2. Exporting to CSV" -ForegroundColor White
    Write-Host "3. Exporting to Excel (with ImportExcel module)" -ForegroundColor White
    Write-Host "4. HTML Report with External CSS" -ForegroundColor White
    Write-Host "5. Converting to JSON" -ForegroundColor White
    Write-Host "6. All-in-One Server Report Solution" -ForegroundColor White
    Write-Host "Q. Quit" -ForegroundColor White
    Write-Host
    Write-Host "Enter your choice (1-6 or Q):" -ForegroundColor Yellow
}

# Run the demo menu
function Start-FormattingDemo {
    do {
        Show-FormattingMenu
        $choice = Read-Host
        
        switch ($choice) {
            '1' { Demo-ConsoleFormatting; pause }
            '2' { Demo-ExportCSV; pause }
            '3' { Demo-ExportExcel; pause }
            '4' { Demo-HTMLReport; pause }
            '5' { Demo-ConvertToJSON; pause }
            '6' { Demo-ServerReportAllInOne; pause }
            'Q' { return }
            'q' { return }
            default { Write-Host "Invalid choice. Please try again." -ForegroundColor Red; pause }
        }
    } while ($true)
}

# Uncomment to run the demo
#Start-FormattingDemo