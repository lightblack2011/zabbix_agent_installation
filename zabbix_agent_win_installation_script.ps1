$serviceName = 'Zabbix Agent'
$path_folder = 'C:\Program Files\zabbix-agentd'
$server_name = hostname
$info_path = 'C:\info_zabbix_agentd.txt'


If (Get-Service $serviceName -ErrorAction SilentlyContinue) {

    If ((Get-Service $serviceName).Status -eq 'Running') {

        
        Write-Host "Service $serviceName is already installed! Nothing to do."

    } Else {

        Write-Host "$serviceName found, but it is not running."

    }

} Else {

    Write-Host "$serviceName not found"
    cmd /c "C:\zabbix_agent_installation\OpenSSL\bin\openssl.exe rand -hex 32 > C:\zabbix_agent_installation\zabbix-agentd\conf\zabbix_agentd.psk"
    Copy-Item 'C:\zabbix_agent_installation\zabbix-agentd' 'C:\Program Files\' -Recurse
    Start-Process -FilePath "C:\Program Files\zabbix-agentd\bin\zabbix_agentd.exe" -ArgumentList '-c "C:\Program Files\zabbix-agentd\conf\zabbix_agentd.conf" -i' -NoNewWindow
    cmd /c "C:\zabbix_agent_installation\OpenSSL\bin\openssl.exe rand -hex 32 > C:\zabbix_agent_installation\OpenSSL\zabbix_agentd.psk"
    (gc "$path_folder\conf\zabbix_agentd.conf") -creplace "^Server=127.0.0.1$", "Server=10.1.10.7" | Set-Content "$path_folder\conf\zabbix_agentd.conf"
    (gc "$path_folder\conf\zabbix_agentd.conf") -creplace "^ServerActive=127.0.0.1$", "ServerActive=10.1.10.7" | Set-Content "$path_folder\conf\zabbix_agentd.conf"
    (gc "$path_folder\conf\zabbix_agentd.conf") -creplace "^Hostname=Windows host$", "Hostname=$server_name" | Set-Content "$path_folder\conf\zabbix_agentd.conf"
    (gc "$path_folder\conf\zabbix_agentd.conf") -creplace "^# TLSConnect=unencrypted$", "TLSConnect=psk" | Set-Content "$path_folder\conf\zabbix_agentd.conf"
    (gc "$path_folder\conf\zabbix_agentd.conf") -creplace "^# TLSAccept=unencrypted$", "TLSAccept=psk" | Set-Content "$path_folder\conf\zabbix_agentd.conf"
    (gc "$path_folder\conf\zabbix_agentd.conf") -creplace "^# TLSPSKIdentity=$", "TLSPSKIdentity=$server_name" | Set-Content "$path_folder\conf\zabbix_agentd.conf"
    (gc "$path_folder\conf\zabbix_agentd.conf") -creplace "^# TLSPSKFile=$", "TLSPSKFile=$path_folder\conf\zabbix_agentd.psk" | Set-Content "$path_folder\conf\zabbix_agentd.conf"
    Start-Process -FilePath "C:\Program Files\zabbix-agentd\bin\zabbix_agentd.exe" -ArgumentList '-c "C:\Program Files\zabbix-agentd\conf\zabbix_agentd.conf" -s' -NoNewWindow
}

$server_name | Out-File "C:\info_zabbix_agentd.txt"
gc $path_folder\conf\zabbix_agentd.psk | Add-Content $info_path
$localIpAddress=((ipconfig | findstr [0-9].\.)[0]).Split()[-1] | Add-Content $info_path
