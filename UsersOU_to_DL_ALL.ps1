### Script que agrega todos los usuarios con correo de una OU a la lista de distribución correspondiente ###

# Especifica las rutas de las OUs y sus respectivos grupos de distribución
$OUtoDLMap = @{
    'OU=OU_USERS1,OU=.ES,DC=domain,DC=corp' = '#DL_ES_USERS1'
    'OU=OU_USERS2,OU=.ES,DC=domain,DC=corp' = '#DL_ES_USERS2'
    

    ### Añade más OUs y sus grupos de distribución aquí ###
    
}

# Itera a través de cada OU y su grupo de distribución correspondiente
foreach ($OU in $OUtoDLMap.Keys) {
    $DL = $OUtoDLMap[$OU]

    # Obtiene todos los usuarios con correo electrónico dentro de la OU
    $usuariosConCorreo = Get-ADUser -Filter {EmailAddress -like "*"} -SearchBase $OU | Select-Object DistinguishedName, UserPrincipalName

    # Añadir los usuarios al grupo de distribución correspondiente
    foreach ($usuario in $usuariosConCorreo) {
        Add-ADGroupMember -Identity $DL -Members $usuario
    }

    Write-Host "Se han añadido $($usuariosConCorreo.Count) usuarios al grupo de distribución $DL desde $OU."
}