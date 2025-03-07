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
get-service -name bits,spooler | Start-Service

#DO NOT DO THIS BAD THINGS WILL HAPPEN
get-service | Stop-Service
get-process | Stop-Process
#Its ok to run anything past this

get-service | stop-service -WhatIf
get-service -name spooler,bits | Start-Service | out-file C:\scripts\SQLSATATL25\services.txt
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


New-Item -Path C:\Scripts\SQLSATBR-2024\ -name files -ItemType Directory

1..10 | ForEach-Object  (new-item -ItemType File -name $_.md)


"dog"

"dog" | Write-Output | Out-Default


Write-Host "hi" -ForegroundColor green
Write-Output

1..10 | Write-Output
1..10 | % { write-output $_ }
1..10 | ForEach-Object { write-output $_ }

Get-ChildItem -Path C:\Scripts\SQLSATBR-2024 | Select-Object name | ForEach-Object { write-output $_ }


$files = Get-ChildItem -path C:\Scripts\SQLSATBR-2024 | Select-Object Name

ForEach ($f in $files)
{ write-output $f }

get-service spooler, bits | Stop-Service

$service = get-service spooler, BITS
foreach ($s in $service) {
    stop-service -name $s.Name
}

$service = get-service spooler, BITS
foreach ($s in $service) {
    if ($s.status -eq "stopped"){
        Start-Service $s.name}
}


Get-Date 

get-date | Get-Member

get-date | Select-Object hour

get-date -Format mm-dd-yyyy

get-date -Format "MM-dd-yyyy hh:mm"

get-date -Format MMddyyyyhhmm
(get-date).AddDays(-4)

$dog = "Daisy"
"My dogs name is $dog"
'My dogs name is $dog'

$files = 20..100
foreach ($f in $files){new-item -path .\files\$f.md}

$folder = 'C:\scripts\SQLSATBR-2024\files'


Get-ChildItem -Path $folder -Recurse | Where-Object Name -NE "_readmefirst.txt" | Remove-Item
Get-ChildItem -Path $folder -Recurse | Where-Object {$_.Name -eq "_readmefirst.txt" `
-and $_.lastwritetime -gt "5/5/2024"}| Remove-Item

-eq Equal
-NE Not Equal
-gt Great Than
-lt Less Than
-le Less than or Equal to
-ge greater than or equal to
-and 
-like
-notlike
-match




Remove-Item

# Remoting
$cred = Get-Credential
Enter-PSSession -ComputerName srv01 -Credential $cred

invoke-command -ComputerName srv01, srv02 -ScriptBlock {$env:COMPUTERNAME} -Credential 714tech\bob

invoke-command -ComputerName (get-content c:\scripts\computers.txt) -ScriptBlock {$env:COMPUTERNAME}
invoke-command -ComputerName (Import-Csv c:\scripts\computers.Import-Csv) -ScriptBlock {$env:COMPUTERNAME}
invoke-command -ComputerName (get-adcomputer -filter "OU=printers,dc=test,dc=lab") -ScriptBlock {$env:COMPUTERNAME}

invoke-command -ComputerName srv01, srv02 -FilePath c:\scripts\myfile.ps1 -Credential 714tech\bob

# File system
Get-ChildItem
Set-LocalGroup
New-Item

Get-PSDrive

$env:computername

If ($IsMacOS -eq $true){}
elseif ($IsLinux -eq $true){}
else {}

switch ($OS)
{
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


$session = New-PSSession -ComputerName srv01,srv02,dc01 -Credential 714tech\bob

Enter-PSSession -Session $session

copy-item -fromsession $session -path c:\sql.msu -Destination d:\temp

invoke-command srv01,srv02 -ScriptBlock {copy-item -path \\myserverpath\sqlupdate.msu -Destination d:\temp}