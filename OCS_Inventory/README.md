1.- Install OCS-Iventory Server in server like you want following offical documentation of OCS: https://github.com/OCSInventory-NG/OCSInventory-Server

2.- Edit https://github.com/raulpuro10/powershell_scripts/blob/main/OCS_Inventory/ES-OCSAgent/ocsinventory.ini according to your needs.

3.- Deploy OCS-Inventory agent in Windows clients by GPO that apply on computers executing 2 scripts on startup.

3.1.- https://github.com/raulpuro10/powershell_scripts/blob/main/OCS_Inventory/ES-OCSAgent/OCS_autodeploy_Equipos.bat for install and version control (instructions in to the script).

3.2.- https://github.com/raulpuro10/powershell_scripts/blob/main/OCS_Inventory/ES-OCSAgent/Settings.ps1 for control parameters that https://github.com/raulpuro10/powershell_scripts/blob/main/OCS_Inventory/ES-OCSAgent/ocsinventory.ini must have.

4.- Execute https://github.com/raulpuro10/powershell_scripts/blob/main/OCS_Inventory/ES-OCSPlugins/SyncPlugins.cmd for install plugins that you want

Change "SERVERIP" and "GPO PATH" according to your scenary
