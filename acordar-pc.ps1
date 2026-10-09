# Envia o pacote mágico para ligar um PC na mesma rede.
# Uso:
#   powershell -ExecutionPolicy Bypass -File .\acordar-pc.ps1 -Mac A1-B2-C3-D4-E5-F6

param(
    [Parameter(Mandatory = $true)]
    [string]$Mac,
    [string]$Broadcast = '255.255.255.255',
    [int]$Port = 9
)

$hex = $Mac -replace '[-:.\s]', ''
if ($hex -notmatch '^[0-9A-Fa-f]{12}$') {
    Write-Error "MAC inválido: $Mac"
    exit 1
}

$bytes = for ($i = 0; $i -lt 12; $i += 2) { [Convert]::ToByte($hex.Substring($i, 2), 16) }
$packet = [byte[]](,0xFF * 6) + [byte[]]($bytes * 16)

$udp = New-Object System.Net.Sockets.UdpClient
$udp.EnableBroadcast = $true
$udp.Connect([System.Net.IPAddress]::Parse($Broadcast), $Port)
[void]$udp.Send($packet, $packet.Length)
$udp.Close()

Write-Host "Pacote mágico enviado para $Mac"
