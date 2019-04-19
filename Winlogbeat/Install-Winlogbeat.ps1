<#
.SYNOPSIS
Install-Winlogbeat downloads Winlogbeat and installs Winlogbeat
with a configuration file.
.DESCRIPTION
PowerShell script or module to install Winlogbeat with configuration
.PARAMETER path
The path to the working directory. The default is user Documents.
.EXAMPLE
Install-Winlogeat.ps1 -path C:\Users\example\Desktop
#>
[CmdletBinding()]
#Establish parameters for path
param (
    [string]$path="C:\Windows\Temp",
    [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false)]
    [string]$SensorIP
)
$SensorIP=$SensorIP + ":5044"

#Test path and create it if required
If(!(test-path $path))
{
    Write-Information -MessageData "Path does not exist. Creating Path..." -InformationAction Continue
    New-Item -ItemType Directory -Force -Path $path | Out-Null
    Write-Information -MessageData "...Complete" -InformationAction Continue
}
Set-Location $path

# Create Configuration File
$winlogbeat = "
winlogbeat.event_logs:
  - name: Application
  - name: Security
  - name: System
  - name: Windows Powershell
  - name: Microsoft-Windows-Sysmon/Operational
  - name: Microsoft-Windows-PowerShell/Operational
  - name: Microsoft-Windows-RemoteDesktopServices-RdpCoreTS/Operational
  - name: Microsoft-Windows-SmbClient/Security
  - name: Microsoft-Windows-SMBServer/Security
  - name: Microsoft-Windows-TaskScheduler/Operational
  - name: Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational
  - name: Microsoft-Windows-Windows Defender/Operational
  - name: Microsoft-Windows-Windows Firewall With Advanced Security/Firewall
  - name: Microsoft-Windows-Winlogon/Operational
  - name: Microsoft-Windows-WinRM/Operational
  - name: Microsoft-Windows-WMI-Activity/Operational

name: `"Container`"

#----------------------------- Logstash output --------------------------------
output.logstash:
  hosts: [`"$SensorIP`"]
"
$winlogbeat | Out-File winlogbeat.yml
Write-Host "Configuration File Created"


# Unzip Winlogbeat
Write-Host "Unzip Winlogbeat..."
Expand-Archive .\winlogbeat-7.0.0-windows-x86_64.zip -DestinationPath 'C:\Program Files\'
Rename-Item -Path 'C:\Program Files\winlogbeat-7.0.0-windows-x86_64' -NewName 'C:\Program Files\Winlogbeat' -Force
Copy-Item winlogbeat.yml -Destination 'C:\Program Files\Winlogbeat\' -Force
Write-Host "Unzip Complete. Configuration File moved to C:\Program Files\Winlogbeat\"

# Install Winlogbeat
Set-Location -Path 'C:\Program Files\Winlogbeat\'
Write-Host "Installing Winlogbeat..."
.\install-service-winlogbeat.ps1
Start-Service winlogbeat
Write-Host "Winlogbeat Installed!"