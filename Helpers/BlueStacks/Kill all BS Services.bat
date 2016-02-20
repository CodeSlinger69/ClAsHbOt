@ECHO OFF

net stop BstHdAndroidSvc

taskkill /F /IM HD-Agent.exe
taskkill /F /IM HD-BlockDevice.exe
taskkill /F /IM HD-Network.exe
taskkill /F /IM HD-Service.exe
taskkill /F /IM HD-SharedFolder.exe
taskkill /F /IM HD-UpdaterService.exe

reg add HKLM\SYSTEM\CurrentControlSet\Services\BstHdAndroidSvc /v Start /t REG_DWORD /d 4 /f
reg add HKLM\SYSTEM\CurrentControlSet\Services\BstHdLogRotatorSvc /v Start /t REG_DWORD /d 4 /f
reg add HKLM\SYSTEM\CurrentControlSet\Services\BstHdUpdaterSvc /v Start /t REG_DWORD /d 4 /f
