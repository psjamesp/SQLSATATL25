https://github.com/powershell/powershell
https://github.com/psjamesp/sqsatatl25


verb-noun

Get-Verb

# Most Common Verbs you will use
Get
New
Set 

Get-ChildItem
Get-ChildItem -Path C:\Scripts
# These are the same thing
dir 
ls

Get-Verb | Sort-Object Verb
(get-command).count

Update-Help

get-help -Name Get-Command
get-help get-service -Full
get-help get-service -ShowWindow
get-help get-service -Examples
get-help get-service -Online

get-help -name *service*

show-command Restart-Service

Get-Command *service*
get-command -Module ActiveDirectory -name *user*
Get-Command -Module BitLocker -Verb Get

get-service | Get-Member


Get-Service -name Spooler
get-service -name spooler | Select-Object *

get-service -Name spooler | Stop-Service
get-service -Name spooler | Stop-Service -name Spooler
get-service -name bits, spooler | Start-Service

#DO NOT DO THIS BAD THINGS WILL HAPPEN
get-service | Stop-Service
get-process | Stop-Process
#Its ok to run anything past this

get-service | stop-service -WhatIf
get-service -name spooler, bits | Start-Service | out-file C:\scripts\SQLSATATL25\services.txt
stop-service -Name Spooler

$var = "daisy"
$lamb = "pink and fuzzy"
$var = "Marry had a little $lamb"
$var = "Marry had 'a little $lamb'"
$var = 'Marry had a little $lamb'

$service = get-service -name Spooler
$process = Get-Process

$dime = 10
$dime = "ten"
$dime = "10"

5 + 5
# this will not work
5 + "five" 

"five" + 5
"5" + 5

[string]5


$dime + 1

1 + $dime

"10" + 1

1 + "10"

Get-ChildItem | Sort-Object -Property name | Format-Table
Get-ChildItem | Select-Object * | Sort-Object -Property Name |
Format-Table -AutoSize


get-service bits | Tee-Object .\services.txt | select * | Sort-Object -Property Name


get-service -name bits | Format-List

get-process -name Code
get-process -name code | Out-Default
get-serivcess
Write-Output
Write-Error "danger danger"
Write-Warning "Almost a danger"
Write-verbose "i'm verbose are you?"

Write-Host "Why is write-host so bad?"
Write-Output "I'm the more correct way"

write-host "Hi Y'all" -BackgroundColor green
$VerbosePreference
$VerbosePreference = "continue"

New-Item -Path C:\Scripts\SQLSATATL25\ -name files -ItemType Directory
Mkdir files

1..10 | ForEach-Object { new-item -ItemType File -name "$_.md" }

$Planets = "Mars", "Earth", 'Saturn', "pluto"
$planets | ForEach-Object { new-item -ItemType File -name "$_.md" }

foreach ($p in $planets) {
    write-host $p
}

foreach ($p in $planets) {
    new-item -ItemType File -name "$p.md" -Force
}




"dog"

"dog" | Write-Output | Out-Default


$files = Get-ChildItem -path C:\Scripts\SQLSATATL25 | Select-Object Name

ForEach ($f in $files)
{ write-output $f }

get-service spooler, bits | Stop-Service

$service = get-service spooler, BITS
foreach ($s in $service) {
    stop-service -name $s.Name
    write-host "I have stopped the $($s.name) Service"
}


-eq Equal -ceq
-NE Not Equal
-gt Great Than
-lt Less Than
-le Less than or Equal to
-ge greater than or equal to
-and 
-like
-notlike
-match

5 -eq 5
"cat" -eq "cat"
"cat" -eq "dog"

if (condition) {
    <# Action to perform if the condition is true #>
}

$service = Get-Service spooler 
if ($service.name -eq "BITS") {
    write-host "Run forest run"
}

if ("cat" -ne "dog") {
    write-host "Go buy a fish"
}



$service = get-service spooler, BITS
foreach ($s in $service) {
    if ($s.status -eq "running") {
        Stop-Service $s.name
    }
}
$planet = "pluto"
if ($planet -eq "earth") {
    write-host "welcome Home"
}
else { write-host "go away" }

$service = get-service BITS
if ($service.status -eq "stopped") {
    Start-Service -name $service.name
}
else { write-host "$($service.name) is already started" }

if ($service.status -eq "stopped") {
    Start-Service -name $service.name
}
elseif ($service.status -eq "running") { 
    write-host "$($service.name) is already started" 

}
else {write-host "you have big problems"}



Get-Date 

get-date | Get-Member

get-date | Select-Object hour

get-date -Format mm-dd-yyyy
get-date -format MM-dd-yyyy

get-date -Format "MM-dd-yyyy hh:mm"

get-date -Format MMddyyyyhhmm
(get-date).AddDays(-4)
(get-date).AddDays(4)

$days = (get-date 12/25/2025) - (get-date)
write-host "There are $($days.days) until christmas"

get-date 2024/12/25

$dog = "Daisy"
"My dogs name is $dog"
'My dogs name is $dog'

$files = 20..100
foreach ($f in $files) { new-item -path .\files\$f.md }

get-service -name s*
get-service | Where-Object name -like "s*"

get-service -name s* | Select-Object name,status 
get-service -name s* | Select-Object name,status | % {write-host $_.name} 
get-service -name s* | Select-Object name,status | Sort-Object -Property Status
if ($_.status -eq "stopped") { % {write-host $_.name} }


Get-ChildItem c:\scripts -Recurse| where-object {$_.name -like "*.ps1"}


get-item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'

Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name PortNumber -value "3399"

New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "smileyface" -value "yes"

Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "smileyface"

Get-PSProvider
Get-PSDrive
$thumb = Get-ChildItem -Path Cert:\CurrentUser\my | Where-Object EnhancedKeyUsageList -like "*code*" | 
select-object -ExpandProperty Thumbprint -First 1



new-item -Path C:\Scripts\SQLSATATL25\files -name "_readmefirst.txt" -ItemType File
$folder = 'C:\scripts\SQLSATATL25\files'


Get-ChildItem -Path $folder -Recurse | Where-Object Name -NE "_readmefirst.txt" | Remove-Item
Get-ChildItem -Path $folder -Recurse | Where-Object { $_.Name -eq "_readmefirst.txt" `
        -and $_.lastwritetime -gt "5/5/2024" } | Remove-Item

if ($service.name -eq "bits" -or $service.status -eq "running"){write-host "Party time"}




Remove-Item

# Remoting
$cred = Get-Credential
Enter-PSSession -ComputerName srv01 -Credential $cred

invoke-command -ComputerName srv01, srv02 -ScriptBlock { $env:COMPUTERNAME } -Credential $cred

invoke-command -ComputerName (get-content c:\scripts\computers.txt) -ScriptBlock { $env:COMPUTERNAME }
invoke-command -ComputerName (Import-Csv c:\scripts\computers.csv) -ScriptBlock { $env:COMPUTERNAME } -
invoke-command -ComputerName (get-adcomputer -filter "OU=servers,dc=local,dc=714tech") -ScriptBlock { $env:COMPUTERNAME }

invoke-command -ComputerName srv01, srv02 -FilePath c:\scripts\SQLSATATL25\myfile.ps1 -Credential $cred

code C:\ProgramData\ssh\sshd_config

Enter-PSSession -HostName dc01 -UserName 714tech\bob
invoke-command -HostName srv01,srv02 -ScriptBlock { $env:COMPUTERNAME}
Enter-PSSession -HostName ubuntu -UserName azureuser

$session = New-PSSession -ComputerName dc01 -Credential $cred
Get-PSSession

invoke-command -Session $session -ScriptBlock {get-services bits | Start-Service}
Get-PSSession | Remove-PSSession

$Error[0] | Out-File C:\scripts\SQLSATATL25\error.txt -Append
$null = get-service bits | Stop-Service
get-service bits | Out-Null

get-service | export-csv C:\scripts\SQLSATATL25\services.csv

get-content C:\Scripts\SQLSATATL25\services.txt 
$csv = import-csv C:\scripts\SQLSATATL25\services.csv


Get-PSDrive

$env:computername

If ($IsMacOS -eq $true) {}
elseif ($IsLinux -eq $true) {}
else {}

switch ($OS) {
    $IsMacOS {}
    $IsLinux {}
    $IsWindows {}
    Default {}
}

get-item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'

Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name PortNumber -value "3399"

New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "smileyface" -value "yes"

Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "smileyface"

ForEach-Object ($s in $servers)
copy-item -Path \\myshare.test.lab\sql2024update.msu -Destination \\$s\d:\temp
} -parallel


$session = New-PSSession -ComputerName srv01, srv02, dc01 -Credential 714tech\bob

Enter-PSSession -Session $session

copy-item -fromsession $session -path c:\sql.msu -Destination d:\temp

invoke-command srv01, srv02 -ScriptBlock { copy-item -path \\myserverpath\sqlupdate.msu -Destination d:\temp }




$env:SystemDrive
$env:HOMEPATH

$IsMacOS
$IsWindows