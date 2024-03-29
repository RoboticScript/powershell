# PURPOSE      : COLLECT SYSTEM INFORMATION
# CREATED DATE : OCTOBER 16, 2023
# CREATE BY    : RAVINDRA SHARMA
# NOTED:       : YOU CAN RUN THIS SCRIPT IN ANY WINDOWS OPERATING SYSTEM

###################################################################################################

# SET THE TITLE
$host.UI.RawUI.WindowTitle = "SYSTEM INFO COLLECTOR"

# SET THE CONSOLE BLACK AFTER THAT CLEAR THE SCREEN
$host.UI.RawUI.BackgroundColor = "Black"

# CLEAR CONSOLE
Clear-Host

###################################################################################################

# SECURITY CHECK
$date_Year = Get-Date -Format yy

If ($date_Year -eq 23 -or $date_Year -eq 24) {
  Write-Host ""
  Write-Host "!!! WELCOME !!!" -ForegroundColor Green
  Write-Host ""
}
else {
  Write-Host ""
  Write-Host "License Expired ! ! !" -ForegroundColor Red
  Write-Host ""
  exit
}

###################################################################################################

# SCRIPT TIME
Write-Host ""
$date_1 = Get-Date
Write-Host "SCRIPT STARTED: " -NoNewline
Write-Host "$date_1" -ForegroundColor Blue
Write-Host ""

###################################################################################################

Write-Host "----------------------------------------------------" -ForegroundColor White

###################################################################################################

# CHECK ADMIN RIGHTS
#Returns a WindowsIdentity object that represents the current Windows user.
$CurrentWindowsIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
#creating a new object of type WindowsPrincipal, and passing the Windows Identity to the constructor.
$CurrentWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($CurrentWindowsIdentity)
#Return True if specific user is Admin else return False
if ($CurrentWindowsPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host ""
  Write-Host "Script running as an administrator: Ok" -ForegroundColor Green
  Write-Host ""
} 
else {
  #Write-Host "Insufficient permissions to run this script. Open the PowerShell console as an administrator and run this script again." -ForegroundColor Red
  Write-Host ""
  Write-Host "Run the script as an administrator; otherwise, some security-related information will not be captured." -ForegroundColor Red
  #Write-Host "Insufficient permissions will not collect all the informations" -ForegroundColor Red
  Write-Host ""
}

###################################################################################################

Write-Host "----------------------------------------------------" -ForegroundColor White

###################################################################################################

# VARIABLES
$get_date_1 = Get-Date -Format ddMMyyyy_HHmmss
$hostname_1 = (Get-CimInstance -ClassName Win32_ComputerSystem).Name
$folder_name = "$hostname_1" + "_" + "$get_date_1"

# DEFINE VARIABLES

$export_txt_content = "$folder_name\00_content.txt"

$export_txt_service = "$folder_name\01_service.txt"
$export_txt_process = "$folder_name\02_process.txt"
$export_txt_disk_volume = "$folder_name\03_disk_volume.txt"
$export_txt_hotfix = "$folder_name\04_hotfix.txt"
$export_txt_software = "$folder_name\05_software.txt"
$export_txt_rdp_session = "$folder_name\05_rdp_active_session.txt"
$export_txt_localuser = "$folder_name\07_local_user.txt"
$export_txt_localgroup = "$folder_name\08_local_group.txt"
$export_txt_windows_feature = "$folder_name\09_windows_feature.txt"
$export_html_group_policy = "$folder_name\10_group_policy.html"
$export_txt_ip_address = "$folder_name\11_ip_address.txt"
$export_txt_system_info = "$folder_name\12_system_info.txt"
$export_txt_get_computer_info = "$folder_name\13_get_computer_info.txt"

$export_event_viewer_system = "$folder_name\14_event_viewer_system.evtx"
$export_event_viewer_application = "$folder_name\14_event_viewer_application.evtx"
$export_event_viewer_setup = "$folder_name\14_event_viewer_setup.evtx"
$export_event_viewer_security = "$folder_name\14_event_viewer_security.evtx"

$export_txt_env = "$folder_name\15_system_env.txt"

$export_txt_msinfo32 = "$folder_name\16_msinfo32.txt"

###################################################################################################

# CREATE FOLDER
New-Item -Path ".\" -Name "$folder_name" -ItemType "directory" | Out-Null
Write-Host ""
Write-Host "Log folder created in below path" -ForegroundColor Yellow
Write-Host "$PSScriptRoot\$folder_name" -ForegroundColor Yellow
#Write-Host "'$folder_name'" -ForegroundColor Yellow
Write-Host ""

###################################################################################################

Write-Host "----------------------------------------------------" -ForegroundColor White

###################################################################################################

# DISPLAY IN CONSOLE

$content = @"

Script collecting the below system information
..............................................
01 - Services (Get-Service)
02 - Processes (Get-Process)
03 - Volume/HDD (Get-Volume)
04 - Patches (Get-HotFix)
05 - Installed Software (Get-ItemProperty)
06 - RDP Active Session (qwinsta)
07 - Local User (Get-LocalUser)
08 - Local Group (Get-LocalGroup)
09 - Installed Windows Features (Get-WindowsFeature)
10 - Group Policy (gpresult)
11 - IP Addresses (ipconfig)
12 - System Information (systeminfo)
13 - System Information (Get-ComputerInfo)
14 - Event Viewer Logs (wevtutil)
15 - User and System Environment (Get-ChildItem Env:)
16 - System Information Including Hardware (msinfo32)

"@

Write-Host "$content" -ForegroundColor Yellow

$content | Out-File $export_txt_content

###################################################################################################

Write-Host "----------------------------------------------------" -ForegroundColor White

###################################################################################################

#(Get-CimInstance Win32_OperatingSystem) | Select-Object Caption, Version
Write-Host ""
Write-Host "Detected . . ." -ForegroundColor Green
Write-Host ""
Write-Host "Hostname           : " -NoNewline -ForegroundColor Cyan
(Get-CimInstance -ClassName Win32_OperatingSystem).CSName

Write-Host "IP Address         : " -NoNewline -ForegroundColor Cyan
(Get-CimInstance win32_networkadapterconfiguration | Where-Object { $_.IPAddress -ne $null } | Select-Object MACAddress, IPAddress).IPAddress
Write-Host ""

Write-Host "OS                 : " -NoNewline -ForegroundColor Cyan
(Get-CimInstance -ClassName Win32_OperatingSystem).Caption
Write-Host "Version            : " -NoNewline -ForegroundColor Cyan
(Get-CimInstance -ClassName Win32_OperatingSystem).Version
Write-Host "Architecture       : " -NoNewline -ForegroundColor Cyan
(Get-CimInstance -ClassName Win32_OperatingSystem).OSArchitecture
Write-Host ""


Write-Host "Processor          : " -NoNewline -ForegroundColor Cyan
(Get-CimInstance -ClassName Win32_Processor).Name
Write-Host "RAM (GB)           : " -NoNewline -ForegroundColor Cyan
(Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1gb
Write-Host "HDD (GB)           : " -NoNewline -ForegroundColor Cyan
(Get-PhysicalDisk | Select-Object @{n="Size";e={[math]::Round($_.Size/1GB,2)}}).Size
Write-Host ""

$install_date = (Get-CimInstance -ClassName Win32_OperatingSystem).InstallDate
Write-Host "OS Install Date    : " -NoNewline -ForegroundColor Cyan
Write-Host $install_date
$up_time = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
Write-Host "Last Boot Up Time  : " -NoNewline -ForegroundColor Cyan
Write-Host $up_time
Write-Host ""

###################################################################################################

Write-Host "----------------------------------------------------" -ForegroundColor White

###################################################################################################

# GET SUMMERY

Get-Service | Select-Object -Property @{Name = 'Hostname'; Expression = { $hostname_1 } }, Name, DisplayName, Status, StartType | Format-Table -AutoSize | Out-File -Width 2000 $export_txt_service 

Get-Process | Select-Object Name | Out-File $export_txt_process

Get-Volume | Select-Object -Property DriveLetter, FriendlyName, FileSystemType, DriveType, HealthStatus, OperationalStatus, @{n = "SizeRemaining (GB)"; e = { [math]::Round($_.SizeRemaining / 1GB, 2) } }, @{n = "Size (GB)"; e = { [math]::Round($_.Size / 1GB, 2) } } | Format-Table -AutoSize | Out-File -Width 2000 $export_txt_disk_volume

$source_1 = @{Name = 'Source'; Expression = { $_.PSComputerName } }
Get-HotFix | Select-Object -Property $source_1, Description, HotFixID, InstalledBy, InstalledOn, Caption | Sort-Object InstalledOn -Descending | Format-Table -AutoSize | Out-File -Width 2000 $export_txt_hotfix

# APPLICATION INSTALLATION DETAILS
$paths = @(
  'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\',
  'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'
)
foreach ($path in $paths) {
  Get-ChildItem -Path $path | Get-ItemProperty | Select-Object DisplayName, Publisher, InstallDate, DisplayVersion | Sort-Object DisplayName | Format-Table -AutoSize | Out-File -Width 2000 $export_txt_software
}

###################################################################################################

qwinsta /server:localhost | Out-File -Width 2000 $export_txt_rdp_session

###################################################################################################

Get-LocalUser | Select-Object Name, Enabled, UserMayChangePassword, PasswordRequired, LastLogon, PasswordChangeableDate, PasswordLastSet, Description | Format-Table -AutoSize | Out-File -Width 2000 $export_txt_localuser

#Get-LocalUser | Select-Object Name,Enabled,UserMayChangePassword,PasswordRequired,LastLogon,PasswordChangeableDate,PasswordLastSet,Description | Format-Table -AutoSize | Out-File -Width 2000 .\user_test.txt

Get-LocalGroup | Select-Object Name, Description | Format-Table -AutoSize | Out-File -Width 2000 $export_txt_localgroup

###################################################################################################

try { 
  Get-WindowsFeature | Where-Object { $_.InstallState -eq 'Installed' } | Format-Table -AutoSize | Out-File -Width 2000 $export_txt_windows_feature  
}
catch {
  Write-Host ""
  Write-Host "Get-WindowsFeature - THIS IS ONLY SUPPORTED ON WINDOWS SERVER" -ForegroundColor Red
  Write-Host ""
  Write-Host "----------------------------------------------------" -ForegroundColor White
}

#Get-WindowsFeature | Where-Object {$_.InstallState -eq 'Installed'} | Format-Table -AutoSize | Out-File -Width 2000 $export_txt_windows_feature

###################################################################################################

#https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/gpresult
gpresult /h .\$export_html_group_policy

###################################################################################################

# GET IP ADDRESS DETAIL
ipconfig /all | Out-File $export_txt_ip_address

###################################################################################################

# GET SYSTEM INFORMATION
#https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/systeminfo
systeminfo /fo list | Out-File $export_txt_system_info

# GET COMPUTER INFORMATION
#https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-computerinfo?view=powershell-7.3
#Notes: This cmdlet was introduced in Windows PowerShell 5.1.

###################################################################################################

try {
  Get-ComputerInfo | Out-File $export_txt_get_computer_info
}
catch {
  Write-Host ""
  Write-Host "Get-ComputerInfo - IT'S REQUIRED PowerShell 5.1 OR HIGER VERSION " -ForegroundColor Red
  Write-Host ""
  
}

# EXAMPLES
#(Get-ComputerInfo).OsHotFixes | Select-Object -Property * | Sort-Object InstalledOn -Descending
# GET ONLY OS DETAILS
#(Get-ComputerInfo -Property OSName).OSName
#(Get-ComputerInfo | Select-Object OSName).OSName

###################################################################################################

# EXPORT EVENT VIEWER
# https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/wevtutil
wevtutil epl System .\$export_event_viewer_system
wevtutil epl Application .\$export_event_viewer_application
wevtutil epl Setup .\$export_event_viewer_setup

###################################################################################################

Write-Host ""
wevtutil epl Security .\$export_event_viewer_security

# try {
#   wevtutil epl Security .\$folder_name\15_security_dump.evtx
# }
# catch {
#   Write-Host ""
#   Write-Host "Security Logs not collected, it is required 'run as administrator'" -ForegroundColor Red
#   Write-Host "" 
# }

if (Test-Path -Path .\$export_event_viewer_security) {
}
else {
  Write-Host ""
  Write-Host "Security event viewer logs not collected, it is required 'run as administrator'" -ForegroundColor Red
  Write-Host ""
  Write-Host "----------------------------------------------------" -ForegroundColor White
}


#wevtutil epl Setup .\$folder_name\15_setup_dump.evtx
#wevtutil epl Setup .\$folder_name\15_setup_dump.evtx

###################################################################################################

# Use the Get-ChildItem cmdlet to see a full list of environment variables:

Get-ChildItem Env: | Format-Table -AutoSize | Out-File -Width 2000 $export_txt_env

###################################################################################################

# COPY ALL EVENT LOGS FROM DIRECTORY "C:\Windows\System32\Winevt\Logs"
Write-Host ""
$confirmation = Read-Host "Do you want to capture all 'EVENT LOGS' (y/n)? "
if ($confirmation -eq 'y') {
# CHECKING ADMIN RIGHTS
  if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host ""
    Write-Host "Copy the security logs required to 'run as an administrator'." -ForegroundColor Red
    Write-Host ""
  }
  else {
    Copy-Item -Path "C:\Windows\System32\Winevt\Logs" -Destination ".\$folder_name" -Recurse
  }  
}

###################################################################################################

# GET MSSYSTEM32 INFO
Write-Host ""
$confirmation = Read-Host "Do you want to capture 'MSINFO32' (y/n)? "
if ($confirmation -eq 'y') {
  msinfo32 /report .\$export_txt_msinfo32
  Start-Sleep -Seconds 5
  Wait-Process -Name msinfo32
  Write-Host "Completed !!" -ForegroundColor Green
}

###################################################################################################

# SCRIPT TIME
Write-Host ""
$date_2 = Get-Date
Write-Host "SCRIPT ENDED: " -NoNewline
Write-Host "$date_2" -ForegroundColor Blue
Write-Host ""

###################################################################################################

Write-Host "----------------------------------------------------" -ForegroundColor White

###################################################################################################

# SCRIPT RUNNING TIME # I AM NOT USING 'New-TimeSpan' BECAUSE IT"S REQUIRED POWERSHELL VERSION 5.1 AND ABOVE
$total_time = $date_2 - $date_1
Write-Host "Script Runnning Time  HH:MM:SS:MS" -ForegroundColor Yellow
Write-Host "                      $total_time" -ForegroundColor Cyan

###################################################################################################

# PAUSE IN POWERSHELL
Write-Host ""
Write-Host "Press 'Enter' to close the console . . . " -ForegroundColor Yellow -NoNewLine
$Host.UI.ReadLine()
Write-Host "" 

###################################################################################################
