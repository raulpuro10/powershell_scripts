# 1. Comprobar y cambiar el perfil de la red a "Privado" si no lo está
$networkProfile = Get-NetConnectionProfile

# Iterar sobre cada perfil de red
foreach ($profile in $networkProfile) {
    # Comprobar si el perfil no es privado
    if ($profile.NetworkCategory -ne "Private") {
        Write-Host "La red '$($profile.Name)' no es privada. Cambiando el perfil a 'Privado'..."
        Set-NetConnectionProfile -Name $profile.Name -NetworkCategory Private
    } else {
        Write-Host "La red '$($profile.Name)' ya está configurada como 'Privada'."
    }
}

# 2. Habilitar WinRM
Write-Host "Habilitando WinRM..."
winrm quickconfig -force

# 3. Establecer el nivel de autenticación (habilitar autenticación básica)
Write-Host "Configurando autenticación básica en WinRM..."
winrm set winrm/config/service/Auth '@{Basic="true"}'

# 4. Permitir credenciales sin cifrar
Write-Host "Permitiendo credenciales sin cifrar en WinRM..."
winrm set winrm/config/service '@{AllowUnencrypted="true"}'

# 5. Aumentar el límite de memoria de la solicitud
Write-Host "Aumentando el límite de memoria para la sesión de WinRM..."
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'

# 6. Configurar el tiempo de espera (número máximo de shells por usuario)
Write-Host "Configurando el tiempo de espera y el número máximo de shells por usuario..."
winrm set winrm/config/winrs '@{MaxShellsPerUser="10"}'

# 7. Obtener el FQDN del servidor actual
$fqdn = $env:COMPUTERNAME + "." + (Get-WmiObject -Class Win32_ComputerSystem).Domain

# 8. Comprobar si ya existe un certificado en el almacén de certificados
$cert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { $_.Subject -like "*$fqdn*" }

# Si no se encuentra el certificado, crear un certificado autofirmado
if ($null -eq $cert) {
    Write-Host "No se encontró un certificado para $fqdn, creando uno nuevo..."
    $cert = New-SelfSignedCertificate -DnsName $fqdn -CertStoreLocation "Cert:\LocalMachine\My"
}

# 9. Obtener el thumbprint del certificado
$thumbprint = $cert.Thumbprint
Write-Host "Thumbprint del certificado: $thumbprint"

# 10. Eliminar el listener de HTTP (si existe)
Write-Host "Eliminando listener de HTTP..."
winrm delete winrm/config/Listener?Address=*+Transport=HTTP

# 11. Configurar WinRM para usar HTTPS con el certificado encontrado o generado
Write-Host "Configurando WinRM sobre HTTPS..."
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"$fqdn`";CertificateThumbprint=`"$thumbprint`"}"

# 12. Verificar la configuración de WinRM sobre HTTPS
Write-Host "Verificando configuración de WinRM sobre HTTPS..."
winrm enumerate winrm/config/Listener

# 13. Comprobar si existe una regla en el firewall para HTTPS (puerto 5986)
$firewallRule = Get-NetFirewallRule | Where-Object { $_.DisplayName -like "*WinRM HTTPS*" }

# Si no existe la regla, crearla
if ($null -eq $firewallRule) {
    Write-Host "No se encontró una regla en el firewall para WinRM HTTPS, creando una nueva..."
    New-NetFirewallRule -Name "WinRM HTTPS" -DisplayName "Ansible WinRM HTTPS" -Protocol TCP -LocalPort 5986 -Action Allow -Direction In
} else {
    Write-Host "Ya existe una regla en el firewall para WinRM HTTPS."
}

# 14. Verificar las reglas de firewall
Write-Host "Verificando las reglas de firewall..."
Get-NetFirewallRule | Where-Object { $_.DisplayName -like "*WinRM HTTPS*" }
