# Configura o Windows para aceitar Wake on LAN na placa de rede cabeada.
# Rode no PowerShell como Administrador:
#   powershell -ExecutionPolicy Bypass -File .\configurar-wol.ps1
# Ativar o Wake on LAN na BIOS/UEFI continua sendo um passo manual.

#Requires -RunAsAdministrator

$adapter = Get-NetAdapter -Physical |
    Where-Object { $_.Status -eq 'Up' -and $_.MediaType -eq '802.3' } |
    Select-Object -First 1

if (-not $adapter) {
    Write-Error "Nenhuma placa de rede cabeada conectada foi encontrada."
    exit 1
}

Write-Host "Placa: $($adapter.InterfaceDescription)"
Write-Host "MAC:   $($adapter.MacAddress)"

# Permite que a placa acorde o computador apenas com o pacote mágico.
Set-NetAdapterPowerManagement -Name $adapter.Name -WakeOnMagicPacket Enabled -ErrorAction SilentlyContinue
Set-NetAdapterPowerManagement -Name $adapter.Name -WakeOnPattern Disabled -ErrorAction SilentlyContinue

# Opções avançadas do driver (o nome varia entre fabricantes).
$props = Get-NetAdapterAdvancedProperty -Name $adapter.Name -ErrorAction SilentlyContinue
foreach ($p in $props) {
    if ($p.DisplayName -match 'Magic Packet|Wake on Magic|Wake from S5|Shutdown Wake|WOL & Shutdown') {
        $on = $p.ValidDisplayValues | Where-Object { $_ -match '^(Enabled|Habilitado|On)$' } | Select-Object -First 1
        if ($on) {
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName $p.DisplayName -DisplayValue $on
            Write-Host "Ativado: $($p.DisplayName)"
        }
    }
    if ($p.DisplayName -match 'Energy Efficient Ethernet|Green Ethernet') {
        $off = $p.ValidDisplayValues | Where-Object { $_ -match '^(Disabled|Desabilitado|Off)$' } | Select-Object -First 1
        if ($off) {
            Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName $p.DisplayName -DisplayValue $off
            Write-Host "Desativado: $($p.DisplayName)"
        }
    }
}

# Permite que o dispositivo tire o PC da suspensão.
$devices = powercfg /devicequery wake_programmable
if ($devices -contains $adapter.InterfaceDescription) {
    powercfg /deviceenablewake "$($adapter.InterfaceDescription)"
}

# Desliga a inicialização rápida, que impede o Wake on LAN com o PC desligado.
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name HiberbootEnabled -Value 0
Write-Host "Inicialização rápida desativada."

Write-Host ""
Write-Host "Pronto. Anote o MAC acima e use-o no app do celular ou no acordar-pc.ps1."
