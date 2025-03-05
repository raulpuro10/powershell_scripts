### Script que activa el Firewall de Windows y abre los puertos que están actualmente en uso ###

# Comprobar si el firewall de Windows está habilitado
$firewallEnabled = Get-NetFirewallProfile | Where-Object { $_.Enabled -eq 'True' }

if ($firewallEnabled) {
    Write-Output "El firewall de Windows está habilitado."
} else {
    Write-Output "El firewall de Windows no está habilitado. Activando el firewall..."
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
}

# Obtener los puertos de entrada en uso
$ports = Get-NetTCPConnection -State Listen | Select-Object -Unique LocalPort

# Crear reglas de firewall para cada puerto si no existen
foreach ($port in $ports) {
    $ruleName = "Port_$($port.LocalPort)"
    $existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue

    if ($existingRule) {
        Write-Output "La regla para el puerto $($port.LocalPort) ya existe."
    } else {
        New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -LocalPort $port.LocalPort -Protocol TCP -Action Allow
        Write-Output "Regla creada para el puerto $($port.LocalPort)."
    }
}