################################################# Command Line Arguments #################################################
param (
  [parameter(Mandatory=$true)][string]$logstash_ip_addr,
  [parameter(Mandatory=$true)][string]$logstash_port
)

################################################# Global vars #################################################
$WINLOGBEAT_VERSION="7.5.0"
$FILEBEAT_VERSION="7.5.0"

################################################# Install/Setup Sysmon #################################################
# Download Sysmon
cd $ENV:TMP
Write-Output "[+] - Downloading Sysmon"
Invoke-WebRequest -Uri https://download.sysinternals.com/files/Sysmon.zip -OutFile Sysmon.zip

# Unzip Sysmon
Write-Output "[+] - Unzipping Sysmon"
Expand-Archive .\Sysmon.zip -DestinationPath .

# Download SwiftOnSecurity config
Write-Output "[+] - Download SwiftOnSeccurity Sysmon config"
Invoke-WebRequest -Uri https://raw.githubusercontent.com/LorenaM22/sysmon-winlogbeat-win/master/sysmonconfig-export.xml -OutFile sysmonconfig-export.xml

# Install Sysmon
Write-Output "[+] - Starting Sysmon with SwiftOnSeccurity config"
.\Sysmon.exe -accepteula -i .\sysmonconfig-export.xml


################################################# Install/Setup Winlogbeat #################################################
cd $ENV:TEMP

# Download Winlogbeat
Write-Output "[+] - Downloading Winlogbeat"
Invoke-WebRequest -Uri https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-$WINLOGBEAT_VERSION-windows-x86_64.zip -OutFile winlogbeat-$WINLOGBEAT_VERSION-windows-x86_64.zip

# Extract zip
Write-Output "[+] - Unzipping Winlogbeat"
Expand-Archive .\winlogbeat-$WINLOGBEAT_VERSION-windows-x86_64.zip -DestinationPath .

# Move directory
Write-Output "[+] - Moving Winlogbeat directory to C:\Program Files\winlogbeat"
mv .\winlogbeat-$WINLOGBEAT_VERSION-windows-x86_64 'C:\Program Files\winlogbeat'
cd 'C:\Program Files\winlogbeat\'

# Get Winlogbeat config
Write-Output "[+] - Downloading Winlogbeat config"
Invoke-WebRequest -Uri https://raw.githubusercontent.com/LorenaM22/sysmon-winlogbeat-win/master/winlogbeat.yml -OutFile winlogbeat.yml

# Set Logstash server
Write-Output "[+] - Setting Logstash in Winlogbeat config"
(Get-Content -Path .\winlogbeat.yml -Raw) -replace "logstash_ip_addr","$logstash_ip_addr" | Set-Content -Path .\winlogbeat.yml
(Get-Content -Path .\winlogbeat.yml -Raw) -replace "logstash_port","$logstash_port" | Set-Content -Path .\winlogbeat.yml

#Download certs
Write-Output "[+] - Downloading filebeat certs"
Invoke-WebRequest -Uri https://raw.githubusercontent.com/LorenaM22/sysmon-winlogbeat-win/master/certs.zip -OutFile certs.zip
Expand-Archive .\certs.zip -DestinationPath ./certs

# Install Winlogbeat
Write-Output "[+] - Install Winlogbeat as a service"
powershell -Exec bypass -File .\install-service-winlogbeat.ps1

# Start Winlogbeat service
Write-Output "[+] - Start Winlogbeat service"
Set-Service -Name "winlogbeat" -StartupType automatic
Start-Service -Name "winlogbeat"
Get-Service -Name "winlogbeat"
