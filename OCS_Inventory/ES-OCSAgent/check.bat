@echo on

cd..\..
cd..\..

cd %PROGRAMDATA%

cd Application Data\OCS Inventory NG\Agent

if exist ocsinventory.ini GOTO Comprobar

start \\newrest.corp\SysVol\newrest.corp\Policies\{FAD9211D-9636-47FD-98EF-BA567E12D97B}\Machine\Scripts\Startup\OCSAgentSetupx64.exe /S /NOSPLASH /DEBUG /NOW /SERVER=http://10.34.1.15/ocsinventory

GOTO FIN

:Comprobar

find "10.34.1.15" < ocsinventory.ini 

if errorlevel = 0 GOTO FIN

sc stop "OCS Inventory Service"

del ocsinventory.ini

copy \\newrest.corp\SysVol\newrest.corp\Policies\{FAD9211D-9636-47FD-98EF-BA567E12D97B}\Machine\Scripts\Startup\ocsinventory.ini

sc start "OCS Inventory Service"

:FIN
