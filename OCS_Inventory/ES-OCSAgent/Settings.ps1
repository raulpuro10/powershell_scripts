function buscarCadena([String]$cadena , [String]$file) {

    # Se verifica que el fichero existe y la cadena no es nula
    if ((Test-Path -Path $file) -and $cadena) {
        $list = Get-Content $file
        # Si se encuentra la cadena se devuelve true
        if ($list -match $cadena) {
            return $true
           
        }
    }
    # Se devuelve false si no encuentra nada o el fichero no existe
    return $false
 
}
    if (-not [System.IO.File]::Exists($archivoInstalaciones)) {
        Add-Content '\\es-cpd-bck01\LogsGPO$\Instalaciones.csv' "Equipo;Windows;ServidorCorrecto"
    }

#capturamos el nombre a buscar en el fichero de ejemplo
$nom= "10.34.1.15"

#almacenamos el fichero en una variable
$fichero = "C:\ProgramData\OCS Inventory NG\Agent\ocsinventory.ini"

#ejecutamos la función con los parametros capturados
$resultado=buscarcadena $nom $fichero


#Mostramos por pantalla el resultado siendo True o False
Write-Host "Fichero encontrado = $resultado"

Start-Sleep -Seconds 120

if ($resultado -match "False"){
    stop-service "OCS Inventory Service"
    (New-Object -ComObject Scripting.FileSystemObject).CopyFile('\\newrest.corp\SysVol\newrest.corp\Policies\{FAD9211D-9636-47FD-98EF-BA567E12D97B}\Machine\Scripts\Startup\ocsinventory.ini', 'C:\ProgramData\OCS Inventory NG\Agent\ocsinventory.ini')
    #Copy-Item -Path "\\newrest.corp\SysVol\newrest.corp\Policies\{FAD9211D-9636-47FD-98EF-BA567E12D97B}\Machine\Scripts\Startup\ocsinventory.ini" -Destination "C:\ProgramData\OCS Inventory NG\Agent\ocsinventory.ini" -Force

        $archivoInstalaciones = "\\es-cpd-bck01\LogsGPO$\Instalaciones.csv"
        $windowsVersion = (Get-WmiObject -class Win32_OperatingSystem).Caption
        Add-Content $archivoInstalaciones "$($env:COMPUTERNAME);$($windowsVersion);$($resultado)"

    start-service "OCS Inventory Service"


    if ($resultado -match "True"){

        $archivoInstalaciones = "\\es-cpd-bck01\LogsGPO$\Instalaciones.csv"
        $windowsVersion = (Get-WmiObject -class Win32_OperatingSystem).Caption
        Add-Content $archivoInstalaciones "$($env:COMPUTERNAME);$($windowsVersion);$($resultado)"
    }
}
