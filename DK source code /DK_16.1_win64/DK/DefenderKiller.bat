Исходный код DK 16.1 By Vlado, Eject, koxauuu
Репозиторий GitHub https://github.com/koxauuu/DefenderKiller

:Start
	cls
	@echo off
	Title DK
	chcp 65001 >nul
	Color 0f
	SetLocal EnableDelayedExpansion

	if not exist "%~dp0Work" echo  Нет папки Work рядом. Будет выполнен выход. && timeout /t 7 >nul && exit
	echo "%~dp0" | findstr /r "[()!]" >nul && echo  Путь до bat содержит недопустимые символы. Будет выполнен выход. && timeout /t 7 >nul && exit
	del "%SystemDrive%\latestVersion.bat" >nul 2>&1

	cd /d "%~dp0Work"
	set "ch=Helper /Print"
	set "Version=16.1"
	set "DateProgram=12.07.2026"

rem Проверка версии/билда/архитектуры
	call :CheckBuildArch

rem Список нужных файлов для работы
	set NeedFiles=DKTE.zip 7z.exe Helper.exe NSudoLG.exe
	call :CheckNeedFiles

rem Запрос админа
	reg query "HKU\S-1-5-19" >nul 2>&1 || NSudoLG -U:E "%~f0" && exit

rem C - если отключён UAC / E - если включён UAC
	call :NullVar ArgNsudo
	reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA | find /i "0x0" >nul 2>&1 && set "ArgNsudo=C" || set "ArgNsudo=E"

rem Запуск консоли от TrustedInstaller
	if /i "%UserName%" neq "%ComputerName%$" (
			reg add "HKU\S-1-5-18\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v AppsUseLightTheme /t reg_dword /d 0 /f >nul 2>&1
			call :CustomizeConsole
			NSudoLG -U:T -P:E -UseCurrentConsole %~f0 %1 && exit || call :StartTIService
	)
	
	Helper /CenterCMD
	Helper /Title "DK %Version% от %DateProgram% | сборка OC %NumberWin% "
	
rem Если передали с аргументом
	if not "%~1"=="" call :CheckArgs %*

rem Проверки для меню
	call :NullVar MainFolder1 MainFolder2 ProcList Maintenance Scan Verification Cleanup
	if exist "%ProgramData%\Microsoft\Windows Defender" (set "MainFolder1=04") else (set "MainFolder1=0a")
	if exist "%ProgramFiles%\Windows Defender" (set "MainFolder2=04") else (set "MainFolder2=0a")
	for /f "skip=3 tokens=1" %%a in ('tasklist') do set "ProcList=!ProcList! %%a "
	for %%p in (SmartScreen MsMpEng SgrmBroker MsSense NisSrv MpCmdRun MPSigStub SecurityHealthSystray SecurityHealthService SecurityHealthHost MpDefenderCoreService) do if "!ProcList!"=="!ProcList:%%p.exe =!" (set "%%~pP=0a") else (set "%%~pP=0c")
	for %%x in (WinDefend MDCoreSvc WdNisSvc Sense wscsvc SgrmBroker SecurityHealthService webthreatdefsvc webthreatdefusersvc WdNisDrv WdBoot WdFilter SgrmAgent MsSecWfp MsSecFlt MsSecCore KslD) do reg query "HKLM\System\CurrentControlSet\Services\%%x" >nul 2>&1 && set "%%x=0c" || set "%%x=0a"
	set PathTask=%SystemRoot%\System32\Tasks\Microsoft\Windows\Windows Defender
	if not exist "%PathTask%\Windows Defender Cache Maintenance" (set "Maintenance=0a") else (set "Maintenance=0c")
	if not exist "%PathTask%\Windows Defender Scheduled Scan" (set "Scan=0a") else (set "Scan=0c")
	if not exist "%PathTask%\Windows Defender Verification" (set "Verification=0a") else (set "Verification=0c")
	if not exist "%PathTask%\Windows Defender Cleanup" (set "Cleanup=0a") else (set "Cleanup=0c")

rem Начало меню
	%ch% {03}Главные папки:{\n#}
	%ch% {%MainFolder1%} %ProgramData%\Microsoft\Windows Defender{\n#}
	%ch% {%MainFolder2%} %ProgramFiles%\Windows Defender{\n#}{\n#}
	%ch% {03}Процессы:{\n#}
	%ch% {%MpCmdRunP%} MpCmdRun {%SmartScreenP%} SmartScreen {%SecurityHealthSystrayP%} SecurityHealthSystray {%SecurityHealthHostP%} SecurityHealthHost{\n#}{\n#}
	%ch% {03}Службы и их процессы:{\n#}
	%ch% {08} Служба                │ Процесс службы{\n#}
	%ch% {08} {%WinDefend%}WinDefend             {08}│ {%MsMpEngP%}MsMpEng.exe{\n#}
	%ch% {08} {%MDCoreSvc%}MDCoreSvc             {08}│ {%MpDefenderCoreServiceP%}MpDefenderCoreService.exe{\n#}
	%ch% {08} {%WdNisSvc%}WdNisSvc              {08}│ {%NisSrvP%}NisSrv.exe{\n#}
	%ch% {08} {%Sense%}Sense                 {08}│ {%MsSenseP%}MsSense.exe{\n#}
	%ch% {08} {%SgrmBroker%}SgrmBroker            {08}│ {%SgrmBrokerP%}SgrmBroker.exe{\n#}
	%ch% {08} {%SecurityHealthService%}SecurityHealthService {08}│ {%SecurityHealthServiceP%}SecurityHealthService.exe{\n#}
	%ch% {%wscsvc%} wscsvc {%webthreatdefsvc%}webthreatdefsvc {%webthreatdefusersvc%}webthreatdefusersvc{\n#}{\n#}
	%ch% {03}Драйвера:{\n#}
	%ch% {%WdFilter%} WdFilter {%WdBoot%} WdBoot {%WdNisDrv%} WdNisDrv {%MsSecWfp%} MsSecWfp {%MsSecFlt%} MsSecFlt {%MsSecCore%} MsSecCore {%SgrmAgent%} SgrmAgent {%KslD%} KslD{\n#}{\n#}
	%ch% {03}Задания в планировщике:{\n#}
	%ch% {%Maintenance%} Windows Defender Cache Maintenance {08}^|{%Cleanup%} Windows Defender Cleanup{\n#}{%Scan%} Windows Defender Scheduled Scan {08}^|{%Verification%} Windows Defender Verification{\n#}
	%ch% {08} ---------------------------------------------------------------------------{\n#}
	%ch% {09} 1. {0c}Удалить Windows Defender{\n#}
	%ch% {09} 2. {08}Проверить состояние папок и файлов{\n#}
	%ch% {09} 3. {0e}Восстановление / Дополнительная чистка{\n#}
	%ch% {09} 4. {0e}(NEW) Отключение / Включение Брандмауэра Защитника Windows{\n#}
        %ch% {09} 5. {0e}(NEW) Отключение / Включение UAC (Контроль учетных записей){\n#}{\n#}
        
	%ch% {0e} [Enter]{08} - Обновить главное меню{\n#}

	set "input=" & set /p input=
	if not defined input endlocal && goto Start
	if "%input%"=="1"  goto StartProcessRemove
	if "%input%"=="2"  goto Catalogs
	if "%input%"=="3"  goto ManageDefender
        if "%input%"=="4"  goto FrwSettings
        if "%input%"=="5"  goto UACpox
        
	cls && %ch% {0c} Такой функции не существует{\n#}&& timeout /t 2 >nul && goto Start

:AddExclusionDef
rem Добавление в исключения всех дисков, чтобы не удалился Unlocker и проверка после
	sc query WinDefend | find /i "RUNNING" >nul 2>&1 && (
			%ch%  {03} Добавление в исключения ..{\n#}
			NSudoLG -U:%ArgNsudo% -ShowWindowMode:Hide -Wait PowerShell "foreach ($drive in [System.IO.DriveInfo]::GetDrives()) { Add-MpPreference -ExclusionPath $drive.Name }"
			Helper /Timer 1
			reg query "HKLM\Software\Microsoft\Windows Defender\Exclusions\Paths" | find /i "%SystemDrive%\" >nul 2>&1 && %ch% {08}  Исключения: {0a}добавлен диск {0b}%SystemDrive%\{\n#}{\n#}|| goto ErrorAddExclusion
	)
	exit /b

rem ============================== Здесь начало процесса ==============================
:StartProcessRemove
cls
rem 1. Добавление в исключения
rem # Если раздел драйвера и раздел wd (оба) не удалены и если не найден в исключениях системный диск
	reg query HKLM\System\CurrentControlSet\Services\WdFilter >nul 2>&1 && reg query "HKLM\Software\Microsoft\Windows Defender" >nul 2>&1 && (
		reg query "HKLM\Software\Microsoft\Windows Defender\Exclusions\Paths" | find /i "%SystemDrive%\" >nul 2>&1 && %ch% {08}  Исключения: {0a}диск %SystemDrive%\ уже добавлен{\n#}{\n#}|| call :AddExclusionDef
	)

rem 2. Распаковка. Получение свободного места на диске.
	call :Unpack Unlocker.exe
	Unlocker /CurrentDiskSize

	if not exist "%ProgramData%\Microsoft\Windows Defender" (
		if not exist "%SystemDrive%\Program Files\Windows Defender" (
			goto SkipUnlockerAndExclAndBackup
		)
	)
	
rem ==============================
	set "flag=0"
	reg query "HKLM\Software\Microsoft\Windows Advanced Threat Protection" >nul 2>&1 && set "flag=1"
	reg query "HKCR\Directory\shellex\ContextMenuHandlers\EPP" >nul 2>&1 && set "flag=1"
	reg query "HKLM\Software\Microsoft\Windows Security Health" >nul 2>&1 && set "flag=1"
rem Удаление выполнялось - пропускаем создание копии
	if not %flag%==1 goto StartUnlockerAndSkipBackup

rem Копия уже есть
	if exist "%SystemDrive%\WDefenderBackup" (
			%ch% {0a}  Найдена резервная копия перед удалением - {0e}%SystemDrive%\WDefenderBackup{\n#}
			%ch% {0e}  Если хотите пересоздать копию - закройте DK, удалите копию и повторите 1{\n#}
			%ch% {08}  Если нажать любую клавишу {0c}2 раза {08}- останется текущая и перейдет к удалению{\n#}
			call :Pause && call :Pause && goto StartUnlockerAndSkipBackup
	)

rem Копии нет 
	if not exist Unlocker.exe %ch% {0c} Unlocker.exe не найден в папке Work. Возвращаемся в главное меню{\n#}&& call :Pause && goto Start
	%ch% {08}  Создание копии:{#}
rem # Yes: 0 | No: 1 | Cancel: 2
		Unlocker /mbox YesNoCancel "Прочитайте readme перед созданием копии\nПри нажатии на 'Отмена' - будет выполнен возврат в главное меню\n\nСоздать копию перед удалением?"
			if errorlevel 2 goto Start
			if errorlevel 1 %ch% {0e} пропущено{\n#}{\n#}&& goto StartUnlockerAndSkipBackup
			if errorlevel 0 %ch% {0a} создаём копию{\n#}{\n#}&& call :CreateBackupDefender
			rem # Нужно запустить службы после Unlock. Иначе - долгий запуск любого софта. Намеренный шаг
			rem # Если не запустить - могут возникнуть проблемы с доступом к странице Настроек Защитника
			rem # Служба ProfSvc - иногда может держать папку. Если не запустить обратно - невозможно ничего повысить до админ прав через UAC
			%ch%  {08} Ожидание запуска служб после создания копии ..{\n#}
			for %%x in (WinDefend MDCoreSvc SecurityHealthService wscsvc WdFilter ProfSvc) do net start %%x >nul 2>&1
			Helper /Timer 3
			echo.
rem ==============================
:StartUnlockerAndSkipBackup
	if not exist Unlocker.exe %ch% {0c} Unlocker.exe не найден в папке Work. Возвращаемся в главное меню{\n#}&& call :Pause && goto Start
	
	call :CheckSAC && (
			call :Unpack dfntd.exe
			call :Unpack defendnot.dll
			%ch% {0b}  wait disable .. -^>{#}
			dfntd --silent --disable-autorun
			call :STATUS || (
				%ch% {0c} not succ. try second attempt..{\n#}
				Helper /Timer 2
				dfntd --silent --disable-autorun
				dfntd --silent --disable-autorun
			)
			call :STATUS && %ch% {0a}  Succesful{\n#}{\n#}|| %ch% {0c}  Not Stopped, skip...{\n#}{\n#}
	)

	start "" /min Helper /BlockWin
	NSudoLG -U:%ArgNsudo% -Wait Unlocker	/DеlWD
	for %%d in ("%ProgramData%\Microsoft\Windows Security Health", "%ProgramData%\Microsoft\Windows Defender", "%ProgramData%\Microsoft\Windows Defender", "%ProgramData%\Microsoft\Windows Defender") do (
		if exist %%d (
			%ch% {08}  Папка %%d не удалилась{\n#}
			%ch% {0c}  Повторное удаление{\n#}{\n#}
			timeout /t 2 /nobreak >nul
			Unlocker /DеlWD
		)
	)

rem 5. При удалении может выключиться служба. Не будет работать запрос на повышение прав UAC и запуск от админа.
	sc query ProfSvc | find /i "STOPPED" >nul 2>&1 && sc start ProfSvc >nul 2>&1
	
	taskkill /f /im Helper.exe >nul 2>&1

:SkipUnlockerAndExclAndBackup
rem 6. Если нет папки Windows Defender в ProgramData и в ProgramFiles [выполнялось удаление хотя бы 1 раз]
	%ch% {03}  Выполняется удаление{\n#}{\n#}
(
	rd /s /q "%SystemRoot%\System32\drivers\wd"
	for %%d in ("Windows Defender" "Windows Defender Advanced Threat Protection" "Windows Security Health" "Storage Health") do rd /s /q "%ProgramData%\Microsoft\%%~d"
	for %%d in ("Windows Defender" "Windows Defender Sleep" "Windows Defender Advanced Threat Protection" "Windows Security" "PCHealthCheck" "Microsoft Update Health Tools") do rd /s /q "%SystemDrive%\Program Files\%%~d"
	for %%d in ("Windows Defender" "Windows Defender Advanced Threat Protection") do rd /s /q "%SystemDrive%\Program Files (x86)\%%~d"
	for %%d in ("HealthAttestationClient" "SecurityHealth" "WebThreatDefSvc" "Sgrm") do rd /s /q "%SystemRoot%\System32\%%~d"
	rd /s /q "%SystemRoot%\security\database"
	rd /s /q "%SystemRoot%\System32\WindowsPowerShell\v1.0\Modules\Defender"
	rd /s /q "%SystemRoot%\System32\WindowsPowerShell\v1.0\Modules\DefenderPerformance"
	rd /s /q "%SystemRoot%\System32\Tasks_Migrated\Microsoft\Windows\Windows Defender"
	rd /s /q "%SystemRoot%\System32\Tasks\Microsoft\Windows\Windows Defender"
	rd /s /q "%SystemRoot%\SysWOW64\WindowsPowerShell\v1.0\Modules\Defender"
	rd /s /q "%SystemRoot%\SysWOW64\WindowsPowerShell\v1.0\Modules\DefenderPerformance"

	del /f /q "%SystemRoot%\Containers\WindowsDefenderApplicationGuard.wim"
	del /f /q "%SystemRoot%\Containers\serviced\WindowsDefenderApplicationGuard.wim"

rem Удаление файлов от Defender / Центра Безопасности и SmartScreen
	for %%f in (
		SecurityHealthService.exe SecurityHealthSystray.exe SecurityHealthHost.exe
		SecurityHealthAgent.dll SecurityHealthSSO.dll SecurityHealthProxyStub.dll smartscreen.dll wscisvif.dll
		wscproxystub.dll smartscreenps.dll wscapi.dll windowsdefenderapplicationguardcsp.dll wscsvc.dll SecurityHealthCore.dll
		SecurityHealthSsoUdk.dll SecurityHealthUdk.dll smartscreen.exe
	) do del /f /q "%SystemRoot%\System32\%%f" "%SystemRoot%\SysWOW64\%%f"

) >nul 2>&1

rem ==============================
(
	for %%s in (
		"Windows Defender Cache Maintenance"
		"Windows Defender Cleanup"
		"Windows Defender Scheduled Scan"
		"Windows Defender Verification"
	) do schtasks /Delete /TN "Microsoft\Windows\Windows Defender\%%~s" /f
	schtasks /Delete /TN "Microsoft\Windows\AppID\SmartScreenSpecific" /f

	reg delete "HKLM\Software\Microsoft\Windows Defender" /f
	reg delete "HKLM\Software\Microsoft\Windows Defender Security Center" /f
	reg delete "HKLM\Software\Microsoft\Windows Advanced Threat Protection" /f
	reg delete "HKLM\Software\Microsoft\Windows Security Health" /f

	reg delete "HKLM\System\CurrentControlSet\Control\WMI\Autologger\DefenderApiLogger" /f
	reg delete "HKLM\System\CurrentControlSet\Control\WMI\Autologger\DefenderAuditLogger" /f

	reg delete "HKCR\*\shellex\ContextMenuHandlers\EPP" /f
	reg delete "HKCR\Directory\shellex\ContextMenuHandlers\EPP" /f
	reg delete "HKCR\Drive\shellex\ContextMenuHandlers\EPP" /f
	reg delete "HKLM\Software\Classes\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}" /f

	reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "SecurityHealth" /f
	reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsDefender" /f
	reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "SecurityHealth" /f
	reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Defender" /f

	reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Windows Defender/WHC" /f
	reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\WINEVT\Channels\NIS-Driver-WFP/Diagnostic" /f
	reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Windows Defender/Operational" /f

rem Удаление надписи в параметрах
	REM reg delete "HKLM\Software\Microsoft\SystemSettings\SettingId\SystemSettings_WindowsDefender_UseWindowsDefender" /f

rem Удаление из Панели управления элемента Windows Defender [Windows 8.1]
	reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\{D8559EB9-20C0-410E-BEDA-7ED416AECC2A}" /f
	reg delete "HKCR\CLSID\{D8559EB9-20C0-410E-BEDA-7ED416AECC2A}" /f

) >nul 2>&1

rem # Fix list + Found
	Helper /SRVD
	echo.
	Unlocker /NewDiskSize

	sc start VMTools >nul 2>&1 & sc start VMTools >nul 2>&1
	reg query "HKLM\System\CurrentControlSet\Services\WdFilter" >nul 2>&1 && (
		call :CreateRunOnceDelReg
		echo.
		%ch% {04}  Часть служб/драйверов не удалена. Требуется перезагрузка ПК для подчистки^^!{\n#}
		%ch% {04}  Не удаляйте .bat файл и папку Work до перезагрузки ПК^^!{\n#}
	) || (
		%ch% {08}  Удалить Безопасность: {02}п. 4 - 2{\n#}{\n#}
		%ch% {0a}  Удаление выполнено{\n#}
	)
	
rem Возвращаем цвет заголовка по-умолчанию для TI программ. Нет в чистой Windows.
	reg delete "HKU\S-1-5-18\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /f >nul 2>&1
	reg delete "HKU\S-1-5-18\Console\%%SystemRoot%%_system32_cmd.exe" /f >nul 2>&1
	Helper /MsgRefresh
	del /q Unlocker.exe BackupWD.ps1 defendnot.dll dfntd.exe ctx.bin >nul 2>&1
	taskkill /f /im Helper.exe >nul 2>&1
rem Если запущено из аргумента - выход. Иначе - возврат в главное меню
	if "%1"=="/DelWD" (call :Pause && exit) else (call :Pause && goto Start)
	
rem ============================== Конец удаления ==============================

 :CreateRunOnceDelReg
	set "RegKey=HKLM\System\CurrentControlSet\Services"
	for %%p in (RegClean RegClean1) do reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "%%p" /t reg_sz /f /d "\"%~dp0Work\NSudoLG.exe\" -U:T -P:E -ShowWindowMode:Hide -Wait cmd.exe /c \"timeout /t 3 /nobreak ^& reg delete %RegKey%\WdFilter /f ^& reg delete %RegKey%\WinDefend /f ^& reg delete %RegKey%\WdNisDrv /f ^& reg delete %RegKey%\MDCoreSvc /f ^& reg delete %RegKey%\WdNisSvc /f ^& reg delete %RegKey%\WdBoot /f\"" >nul

	reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "DKRUN" /t reg_sz /f /d "\"%~dp0Work\NSudoLG.exe\" -U:C -ShowWindowMode:Hide -Wait cmd.exe /c \"timeout /t 6 /nobreak ^& msg * Запустите DK и проверьте состояние служб. Если что-то осталось красным - воспользуйтесь драйвером."" >nul

	exit /b

rem ==============================
:ManageDefender
	cls
	call :NullVar HideSettigns MenuSec
	2>nul reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "SettingsPageVisibility" | find /i "windowsdefender" >nul 2>&1 && set "HideSettigns={0a}скрыт" || set "HideSettigns={0c}не скрыт"
	for /f "usebackq delims=" %%a in (`PowerShell "$p=Get-AppxPackage -AllUsers | Where-Object { $_.Name -match 'SecHealthUI' }; if($p){'{0c}Удалить Безопасность с подтверждением'}else{'{0a}Восстановить Безопасность'}"`) do set "MenuSec=%%a"
	del /q Unlocker.exe SelectedPath.txt >nul 2>&1
	

	
	%ch% {9f}Восстановление копии{\n#}
	%ch% {03} 1. {green}Восстановить защитник из копии (Копию необходимо создать заранее){\n#}{\n#}
	%ch% {9f}Безопасность Windows{\n#}
	%ch% {03} 2. %MenuSec% {08}(Иконка в пуске)(Может не работать на 26H2){\n#}
	%ch% {03} 3. {08}Раздел Безопасность в Параметрах %HideSettigns%{\n#}{\n#}
	%ch% {9f}Другие настройки{\n#}
	%ch% {03} 4. {08}Отключить VBS (Безопасность на основе виртуализации){\n#}
	%ch% {03} 5. {08}Удалить папки Защитника из хранилища WinSxS {0e}с подтверждением{\n#}{\n#}
	%ch% {0e} [Enter] - {08}Вернуться в главное меню{\n#}

	set "input=" & set /p input=
	if not defined input goto Start
	if "%input%"=="1" goto RestoreDefender
	if "%input%"=="2" goto RemoveApps
	if "%input%"=="3" call :HideShowInSettings
	if "%input%"=="4" goto VBSDis
	if "%input%"=="5" call :WinSxSFolders
	goto ManageDefender

rem ============================================

:HideShowInSettings
	PowerShell "$p='HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'; $n='SettingsPageVisibility'; $t='windowsdefender'; $v=(Get-ItemProperty -Path $p -Name $n -ErrorAction SilentlyContinue).$n; Get-Process SystemSettings -ErrorAction SilentlyContinue | Stop-Process -Force; if (-not $v) {New-ItemProperty -Path $p -Name $n -PropertyType String -Value ('hide:' + $t) -Force; exit} elseif ($v -eq ('hide:' + $t)) {Remove-ItemProperty -Path $p -Name $n -Force; exit} elseif ($v -like '*hide:*' -and $v -like ('*' + $t + '*')) { $prefix='hide:'; $rest=$v.Substring($prefix.Length); $items = $rest -split ';' | Where-Object { $_ -ne $t -and $_ -ne '' }; if ($items.Count -eq 0) { Remove-ItemProperty -Path $p -Name $n -Force } else { Set-ItemProperty -Path $p -Name $n -Value ($prefix + ($items -join ';')) -Force }; exit } else { if ($v.StartsWith('hide:')) { Set-ItemProperty -Path $p -Name $n -Value ($v + ';' + $t) -Force } else { Set-ItemProperty -Path $p -Name $n -Value ('hide:' + $v + ';' + $t) -Force } }" >nul 2>&1
	exit /b

rem ============================================
:RemoveApps
	if %CurrentBuild% lss 19044 %ch% {04} Не поддерживается в данной версии Windows{\n#}&& timeout /t 5 >nul && goto ManageDefender

	set "KeyAPPX=SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore"
	
	PowerShell "$packages = Get-AppxPackage -AllUsers | Where-Object { $_.Name -match 'SecHealthUI|Apprep.ChxApp' }; if ($packages) { Write-Host; Write-Host \" Будут удалены:\" -F DarkGray; $packages | ForEach-Object { Write-Host \" $($_.PackageFullName)\" -F Red }; Write-Host} else { exit 1 }" || goto RestoreSecHealth

	%ch% {08} 1. {0e}Удалить{\n#}
	%ch% {08} 2. Отмена{\n#}
	choice /c 12 /n /m " "
	if errorlevel 2 goto ManageDefender
	
rem 1. Переименовать папки SecHealth в WindowsApps. Чтобы не удалилась при выполнении удаления приложения.
rem 2. Найти в InboxApplications SecHealthUI/Apprep.ChxApp и удалить [SysApps]
	PowerShell "gci '%ProgramFiles%\WindowsApps' -Dir | Where-Object { $_.Name -match 'SecHealth' -and $_.Name -notlike '*_' } | ForEach-Object { $new = $_.Name + '_'; $newPath = Join-Path $_.Parent $new; ren $_.FullName $new; Write-Host ' Переименована папка в WindowsApps:' -F DarkGray; Write-Host \" $new\" -F DarkCyan }; Get-ChildItem 'HKLM:\%KeyAPPX%\InboxApplications' | Where-Object { $_.Name -match 'SecHealthUI|Apprep.ChxApp' } | ForEach-Object { Remove-Item $_.PsPath -Recurse -Force }"

rem 3. Получить SID юзера
rem 4. Удалить в Applications разделы SecHealthUI/Apprep.ChxApp [STORE]
rem 5. EOL USER/SYSTEM SID Packages SecHealthUI/Apprep.ChxApp
rem 6. Выполнить удаление
	NSudoLG -U:%ArgNsudo% -ShowWindowMode:Hide -Wait PowerShell "$usrsid = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value; $filters = @('*SecHealthUI*', '*Apprep.ChxApp*'); foreach ($filter in $filters) { $packages = Get-AppxPackage -AllUsers | Where-Object { $_.PackageFullName -like $filter } | Select-Object -ExpandProperty PackageFullName; foreach ($app in $packages) { Remove-Item -Path \"HKLM:\%KeyAPPX%\Applications\$($app)\" -Force -Recurse -ErrorAction SilentlyContinue; $endOfLifePaths = @(\"HKLM:\%KeyAPPX%\EndOfLife\$usrsid\$($app)\", \"HKLM:\%KeyAPPX%\EndOfLife\S-1-5-18\$($app)\"); $endOfLifePaths | ForEach-Object { New-Item -Path $_ -Force | Out-Null }; Remove-AppxPackage -Package $app -AllUsers -ErrorAction SilentlyContinue }}"

rem 7. Выполнить удаление SYSTEM
	NSudoLG -U:S -P:E -ShowWindowMode:Hide -Wait PowerShell "Get-AppxPackage -AllUsers | Where-Object { $_.Name -match 'SecHealth|Apprep.ChxApp' } | Remove-AppxPackage -User 'S-1-5-18' -ErrorAction SilentlyContinue"

	reg delete "HKLM\%KeyAPPX%\EndOfLife" /f >nul 2>&1
	reg add "HKLM\%KeyAPPX%\EndOfLife" /f >nul 2>&1
rem Эти папки можно удалять. Восстанавливаются сами, если восстановить приложение.
	for /f "usebackq delims=" %%d In (`2^>nul dir /s /b /a:d "%ProgramData%\Microsoft\Windows\AppRepository\Packages\*SecHealth*"`) do rd /s /q "%%d"
	for /f "usebackq delims=" %%d In (`2^>nul dir /s /b /a:d "%ProgramData%\Microsoft\Windows\AppRepository\Packages\*Apprep.ChxApp*"`) do rd /s /q "%%d"
	for /f "usebackq delims=" %%d In (`2^>nul dir /s /b /a:d "%LocalAppData%\Packages\*SecHealth*"`) do rd /s /q "%%d"
	for /f "usebackq delims=" %%d In (`2^>nul dir /s /b /a:d "%LocalAppData%\Packages\*Apprep.ChxApp*"`) do rd /s /q "%%d"
	call :Pause && goto ManageDefender
	
:RestoreSecHealth
	reg delete "HKLM\Software\SecHealthRestore" /f >nul 2>&1

if exist "%SystemRoot%\SystemApps\Microsoft.Windows.SecHealthUI_cw5n1h2txyewy\AppxManifest.xml" (
rem Ищем все установленные пакеты SecHealthUI пользователей (S-...), кроме System (S-1-5-18)
rem Фильтруем записи. Только те, у которых есть параметр Path.
rem Если нашлось в реестре по такому фильтру - восстанавливает запись его раздела в InboxApplications.

	PowerShell "$pkgs = Get-ChildItem 'HKLM:\%KeyAPPX%' -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -like 'S-*' -and $_.PSChildName -ne 'S-1-5-18' } | Get-ChildItem -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -match 'SecHealth' -and (Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue).Path }; if ($pkgs.Count -gt 0) { foreach ($pkg in $pkgs) { $path = (Get-ItemProperty $pkg.PSPath).Path; $key = 'HKLM:\%KeyAPPX%\InboxApplications\' + $pkg.PSChildName; New-Item $key -Force -ErrorAction SilentlyContinue | Out-Null; Set-ItemProperty $key Path $path } } else { New-Item -Path 'HKLM:\Software\SecHealthRestore' -Force -ErrorAction SilentlyContinue | Out-Null }"

	reg query "HKLM\Software\SecHealthRestore" >nul 2>&1 && %ch% {0c} Не удалось получить имя для восстановления раздела InboxApplications{\n#}&& call :Pause && goto ManageDefender
	call :CheckClipSvc
	NSudoLG -U:!ArgNsudo! -Wait PowerShell "Add-AppxPackage -Register -DisableDevelopmentMode '%SystemRoot%\SystemApps\Microsoft.Windows.SecHealthUI_cw5n1h2txyewy\AppxManifest.xml'; Pause"
	call :Pause && goto ManageDefender
) else (
	%ch% {0c} Не найдено папки SecHealth в SystemApps{\n#}
	%ch% {0f} Будет выполнен поиск в папке WindowsApps{\n#}{\n#}
)

rem Если не нашлось папки в SystemApps, вероятно, она в WindowsApps , либо была удалена юзером
rem Проверка: есть ли в WindowsApps папки с именем SecHealth. Если есть - убрать в конце _ , чтоб вернуть оригинальное имя, которое было изменено при удалении
	PowerShell "$folders=Get-ChildItem \"$env:ProgramFiles\WindowsApps\" -Directory | Where-Object { $_.Name -match 'SecHealth' }; if ($folders) { Write-Host \" Найдена папка в Windows Apps\" -F Green; Start-Sleep 2; $folders | ForEach-Object { if ($_.Name -like '*_') { Rename-Item $_.FullName ($_.Name.TrimEnd('_')) } } } else { New-Item -Path 'HKLM:\Software\SecHealthRestore' -Force -ErrorAction SilentlyContinue | Out-Null }"
	
	reg query "HKLM\Software\SecHealthRestore" >nul 2>&1 && %ch% {0c} Не найдено папки SecHealth в WindowsApps{\n#}&& call :Pause && goto ManageDefender
	call :CheckClipSvc
	NSudoLG -U:!ArgNsudo! -Wait PowerShell "Get-ChildItem \"$env:ProgramFiles\WindowsApps\" -Directory -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -like '*SecHealth*' -and (Test-Path \"$($_.FullName)\AppxManifest.xml\") } | ForEach-Object { Add-AppxPackage -Register \"$($_.FullName)\AppxManifest.xml\" -DisableDevelopmentMode } ; Pause"
	call :Pause && goto ManageDefender

:CheckClipSvc
	sc query ClipSvc | find /i "STOPPED" >nul 2>&1 && (
		sc config ClipSvc start=demand
		net start ClipSvc
	)
	sc query LicenseManager | find /i "STOPPED" >nul 2>&1 && (
		sc config LicenseManager start=demand
		net start LicenseManager
	)
	exit /b

rem ============================================

:WinSxSFolders
	if not "%1" equ "NoVerbose" (
	%ch%   Если не создавалась рез. копия, удаление этих папок может сломать обновления.{\n#}
	%ch%   Позволяет очистить дополнительное место. {red}~300-500 мб.{\n#}
	%ch%  {08} 1. {0c}Удалить папки из WinSxS{\n#}
	%ch%  {08} 2. Отмена удаления папок{\n#}
	choice /c 12 /n /m " "
	if errorlevel 2 exit /b 0
	)

rem Если не существует службы - распаковываем unlocker, иначе без подсчета места (удалит Unlocker, если служба существует)
	sc query WinDefend >nul 2>&1 || call :Unpack Unlocker.exe
	if exist Unlocker.exe Unlocker /CurrentDiskSize
rem Удаление папок из хранилища WinSxS с бОльшей вероятностью сломает установку накопительных обновлений.
	for %%i in (windows-defender, windows-senseclient-service, windows-dynamic-image) do (
			for /f "usebackq delims=" %%d In (`2^>nul dir /s /b /a:d "%SystemRoot%\WinSxS\*%%i*"`) do rd /s /q "%%d" >nul 2>&1
	)
	if exist Unlocker.exe (
		echo.
		Unlocker /NewDiskSize
		if not "%1" equ "NoVerbose" call :Pause
	)
	del Unlocker.exe >nul 2>&1
	exit /b 0

rem ================ Создание резервной копии ================

:CreateBackupDefender
	call :CheckSAC || (
		%ch% {0e} Могут быть проблемы, если не отключить SAC. Создание копии может зависнуть{\n#}
		%ch% {0c} После нажатия любой кнопки - будет попытка создать копию, но идея не лучшая, если Вы его не выключили{\n#}
		call :Pause
	)
	start "" /min Helper /BlockWin
	start "" /min Helper /BlockWin
rem # Если выполнить unlock от TI - может запустить проводник от TI. HKU\.DEFAULT\Control Panel\Personalization. По нему можно проверять.
	for /l %%i in (1,1,3) do NSudoLG -U:%ArgNsudo% -Wait Unlocker /unlock "%ProgramData%\Microsoft\Windows Defender" "%SystemDrive%\Program Files\Windows Defender" "%SystemDrive%\Program Files (x86)\Windows Defender"
	call :Unpack BackupWD.ps1
	taskkill /f /im Helper.exe >nul 2>&1
	PowerShell -ExecutionPolicy Bypass -File "BackupWD.ps1" || (
		%ch%  {\n#}{0c} Повторите попытку. Будет выполнен возврат в главное меню.{\n#}
		rd /s /q "%SystemDrive%\WDefenderBackup"
		del BackupWD.ps1 >nul 2>&1
		call :Pause && goto Start
	)
	del BackupWD.ps1 >nul 2>&1
	%ch%  {08} Копия создана в: {0b}%SystemDrive%\WDefenderBackup{\n#}{\n#}
	exit /b
	
 rem ============================== Восстановление из копии ==============================
:RestoreDefender
	sc query WinDefend >nul 2>&1 && (
		2>nul reg query "HKLM\SYSTEM\CurrentControlSet\Services\WinDefend" >nul 2>&1 && set "WDKey={0c}не удален" || set "WDKey={0a}удален"
		%ch% {04} Восстановление недоступно{\n#}{\n#}
		%ch% {08} Состояние службы WinDefend:{\n#}
		%ch% {0e} Раздел в реестре: !WDKey!{\n#}
		%ch% {0e} Служба в SCM: {0c}не удалена{\n#}{\n#}
		%ch% {08} Сначала выполните удаление и перезагрузите ПК{\n#}
		call :Pause && goto ManageDefender
	)
	
rem Выбор папки с копией и проверка копии
	if not exist "%SystemRoot%\System32\config\systemprofile\Desktop" md "%SystemRoot%\System32\config\systemprofile\Desktop"
	call :NullVar BackupFolder
	call :Unpack Unlocker.exe
	Unlocker /SelectFolder "Выберите папку WDefenderBackup с ранее созданной резервной копией Windows Defender."
	echo.
	if not exist SelectedPath.txt goto ManageDefender
	for /f "tokens=*" %%a in (SelectedPath.txt) do set "BackupFolder=%%a"
	if not exist "%BackupFolder%\Folder" %ch% {04} Неверная папка резервной копии.{\n#}&& call :Pause && goto ManageDefender
	if not exist "%BackupFolder%\ServicesDrivers" %ch% {04} Неверная папка резервной копии.{\n#}&& call :Pause && goto ManageDefender
	
	%ch% {03} Выполняем восстановление из копии{\n#}{\n#}
	pushd "%BackupFolder%"
	
(
	copy /y "Files\System32" "%SystemRoot%\System32"
	copy /y "Files\SysWOW64" "%SystemRoot%\SysWOW64"
	copy /y "Files\Windows\Containers\WindowsDefenderApplicationGuard.wim" "%SystemRoot%\Containers\"
	copy /y "Files\Windows\Containers\serviced\WindowsDefenderApplicationGuard.wim" "%SystemRoot%\Containers\serviced"
	xcopy "Folder\Program Files\*" "%ProgramFiles%\" /E /H /K /Y
	xcopy "Folder\Program Files (x86)\*" "%ProgramFiles(x86)%\" /E /H /K /Y
	xcopy "Folder\ProgramData\*" "%ProgramData%\" /E /H /K /Y
	xcopy "Folder\System32\*" "%SystemRoot%\System32" /E /H /K /Y
	xcopy "Folder\SysWow64\*" "%SystemRoot%\SysWow64" /E /H /K /Y
	xcopy "Folder\Windows\*" "%SystemRoot%\" /E /H /K /Y
	xcopy "Folder\WinSxS\*" "%SystemRoot%\WinSxS\" /E /H /K /Y
	for %%f in ("RegEdit\*.reg") do reg import "%%f"
	for %%f in ("ServicesDrivers\*.reg") do reg import "%%f"
	for %%f in ("CLSID\*.reg") do reg import "%%f"
	reg delete "HKLM\Software\Microsoft\Windows Defender\Exclusions\Paths" /f
	reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /f
	reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /f
) >nul 2>&1

	popd
	
	NSudoLG -U:%ArgNsudo% -ShowWindowMode:Hide cmd.exe /c reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /f
	NSudoLG -U:%ArgNsudo% -ShowWindowMode:Hide cmd.exe /c reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /f
	
	del /q Unlocker.exe SelectedPath.txt >nul 2>&1
	%ch% {0f} Добавить все диски в исключения защитника?{\n#}{\n#}
	%ch% {0f} Полезно, чтобы после восстановления защитник не удалил Ваши файлы{\n#}
	%ch% {08} 1. {0a}Добавить в исключения{\n#}
	%ch% {08} 2. Отмена{\n#}
	choice /c 12 /n /m " "
	if "%errorlevel%"=="1" call :AddExclusionRestore
	%ch% {0a} Требуется перезагрузка ПК{\n#}&& call :Pause && goto Start
	call :Pause && goto Start

rem ============================================

:Catalogs
	cls
	for /l %%i in (0,1,17) do set "Folder%%i="
	for /l %%i in (1,1,18) do set "File%%i="
	if exist "%SystemRoot%\System32\Tasks\Microsoft\Windows\Windows Defender" (set "Folder0=0c") else (set "Folder0=0a")
	if exist "%SystemRoot%\System32\HealthAttestationClient" (set "Folder1=0c") else (set "Folder1=0a")
	if exist "%SystemRoot%\System32\SecurityHealth" (set "Folder2=0c") else (set "Folder2=0a")
	if exist "%SystemRoot%\System32\WebThreatDefSvc" (set "Folder3=0c") else (set "Folder3=0a")
	if exist "%SystemRoot%\System32\Sgrm" (set "Folder4=0c") else (set "Folder4=0a")
	if exist "%SystemRoot%\System32\WindowsPowerShell\v1.0\Modules\Defender" (set "Folder5=0c") else (set "Folder5=0a")
	if exist "%SystemRoot%\System32\WindowsPowerShell\v1.0\Modules\DefenderPerformance" (set "Folder6=0c") else (set "Folder6=0a")
	if exist "%SystemRoot%\System32\Tasks_Migrated\Microsoft\Windows\Windows Defender" (set "Folder7=0c") else (set "Folder7=0a")
	if exist "%ProgramFiles%\Windows Defender Sleep" (set "Folder8=0c") else (set "Folder8=0a")
	if exist "%ProgramFiles%\Windows Defender Advanced Threat Protection" (set "Folder9=0c") else (set "Folder9=0a")
	if exist "%ProgramFiles%\Windows Security" (set "Folder10=0c") else (set "Folder10=0a")
	if exist "%ProgramFiles%\PCHealthCheck" (set "Folder11=0c") else (set "Folder11=0a")
	if exist "%ProgramFiles%\Microsoft Update Health Tools" (set "Folder12=0c") else (set "Folder12=0a")
	if exist "%ProgramFiles(x86)%\Windows Defender" (set "Folder13=0c") else (set "Folder13=0a")
	if exist "%ProgramFiles(x86)%\Windows Defender Advanced Threat Protection" (set "Folder14=0c") else (set "Folder14=0a")
	if exist "%ProgramData%\Microsoft\Windows Defender Advanced Threat Protection" (set "Folder15=0c") else (set "Folder15=0a")
	if exist "%ProgramData%\Microsoft\Windows Security Health" (set "Folder16=0c") else (set "Folder16=0a")
	if exist "%ProgramData%\Microsoft\Storage Health" (set "Folder17=0c") else (set "Folder17=0a")

	if exist "%SystemRoot%\System32\SecurityHealthService.exe" (set "File3=04") else (set "File3=0a")
	if exist "%SystemRoot%\System32\SecurityHealthSystray.exe" (set "File4=04") else (set "File4=0a")
	if exist "%SystemRoot%\System32\SecurityHealthHost.exe" (set "File5=04") else (set "File5=0a")
	if exist "%SystemRoot%\System32\SecurityHealthAgent.dll" (set "File6=04") else (set "File6=0a")
	if exist "%SystemRoot%\System32\SecurityHealthSSO.dll" (set "File7=04") else (set "File7=0a")
	if exist "%SystemRoot%\System32\SecurityHealthProxyStub.dll" (set "File8=04") else (set "File8=0a")
	if exist "%SystemRoot%\System32\smartscreen.dll" (set "File9=04") else (set "File9=0a")
	if exist "%SystemRoot%\System32\wscisvif.dll" (set "File10=04") else (set "File10=0a")
	if exist "%SystemRoot%\System32\wscproxystub.dll" (set "File11=04") else (set "File11=0a")
	if exist "%SystemRoot%\System32\smartscreenps.dll" (set "File12=04") else (set "File12=0a")
	if exist "%SystemRoot%\System32\wscapi.dll" (set "File13=04") else (set "File13=0a")
	if exist "%SystemRoot%\System32\windowsdefenderapplicationguardcsp.dll" (set "File14=04") else (set "File14=0a")
	if exist "%SystemRoot%\System32\wscsvc.dll" (set "File15=04") else (set "File15=0a")
	if exist "%SystemRoot%\System32\SecurityHealthCore.dll" (set "File16=04") else (set "File16=0a")
	if exist "%SystemRoot%\System32\SecurityHealthSsoUdk.dll" (set "File17=04") else (set "File17=0a")
	if exist "%SystemRoot%\System32\SecurityHealthUdk.dll" (set "File18=04") else (set "File18=0a")
	
	%ch% {09}Папки в %SystemRoot%\System32{\n#}
	%ch% {%Folder0%} %SystemRoot%\System32\Tasks\Microsoft\Windows\Windows Defender{\n#}

	%ch% {%Folder1%} %SystemRoot%\System32\HealthAttestationClient{\n#}
	%ch% {%Folder2%} %SystemRoot%\System32\SecurityHealth{\n#}
	%ch% {%Folder3%} %SystemRoot%\System32\WebThreatDefSvc{\n#}
	%ch% {%Folder4%} %SystemRoot%\System32\Sgrm{\n#}
	%ch% {%Folder5%} %SystemRoot%\System32\WindowsPowerShell\v1.0\Modules\Defender{\n#}
	%ch% {%Folder6%} %SystemRoot%\System32\WindowsPowerShell\v1.0\Modules\DefenderPerformance{\n#}
	%ch% {%Folder7%} %SystemRoot%\System32\Tasks_Migrated\Microsoft\Windows\Windows Defender{\n#}{\n#}

	%ch% {09}Папки в %ProgramFiles% и в %ProgramFiles(x86)%{\n#}
	%ch% {%Folder8%} %ProgramFiles%\Windows Defender Sleep{\n#}
	%ch% {%Folder9%} %ProgramFiles%\Windows Defender Advanced Threat Protection{\n#}
	%ch% {%Folder10%} %ProgramFiles%\Windows Security{\n#}
	%ch% {%Folder11%} %ProgramFiles%\PCHealthCheck{\n#}
	%ch% {%Folder12%} %ProgramFiles%\Microsoft Update Health Tools{\n#}
	%ch% {%Folder13%} %ProgramFiles(x86)%\Windows Defender{\n#}
	%ch% {%Folder14%} %ProgramFiles(x86)%\Windows Defender Advanced Threat Protection{\n#}{\n#}
	
	%ch% {09}Папки в %ProgramData%{\n#}
	%ch% {%Folder15%} %ProgramData%\Microsoft\Windows Defender Advanced Threat Protection{\n#}
	%ch% {%Folder16%} %ProgramData%\Microsoft\Windows Security Health{\n#}
	%ch% {%Folder17%} %ProgramData%\Microsoft\Storage Health{\n#}{\n#}

	%ch% {09}Файлы{\n#}
	%ch% {%File3%} SecurityHealthService.exe {%File4%} SecurityHealthSystray.exe {%File5%} SecurityHealthHost.exe{\n#} {%File6%}SecurityHealthAgent.dll {%File7%} SecurityHealthSSO.dll {%File8%} SecurityHealthProxyStub.dll{\n#} {%File9%}smartscreen.dll {%File10%} wscisvif.dll {%File11%} wscproxystub.dll {%File12%} smartscreenps.dll{\n#} {%File13%}wscapi.dll {%File14%} windowsdefenderapplicationguardcsp.dll {%File15%} wscsvc.dll {%File16%} SecurityHealthCore.dll{\n#} {%File17%}SecurityHealthSsoUdk.dll {%File18%} SecurityHealthUdk.dll{\n#}
	call :Pause && goto Start

:VBSDis
	%ch% {0f} 1 - Отключить VBS{\n#}
	%ch% {0f} 2 - Вернуться обратно{\n#}
	choice /c 12 /n /m ""
	set "input=%errorlevel%"
	if %input%==2 goto ManageDefender

rem Отключение VBS
	bcdedit /set hypervisorlaunchtype off >nul
	for %%p in (
		HypervisorEnforcedCodeIntegrity
		LsaCfgFlags
		RequirePlatformSecurityFeatures
		ConfigureSystemGuardLaunch
		ConfigureKernelShadowStacksLaunch
	) do reg delete "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "%%p" /f >nul 2>&1
	for %%p in (
		EnableVirtualizationBasedSecurity
		HVCIMATRequired
	) do reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "%%p" /t reg_dword /d 0 /f >nul 2>&1
	for %%p in (
		WasEnabledBy
		WasEnabledBySysprep
	) do reg delete "HKLM\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "%%p" /f >nul 2>&1
	for %%p in (
		Enabled
		HVCIMATRequired
		Locked
	) do reg add "HKLM\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "%%p" /t reg_dword /d 0 /f >nul 2>&1
	for %%p in (
		EnableVirtualizationBasedSecurity
		RequirePlatformSecurityFeatures
		Locked
	) do reg add "HKLM\System\CurrentControlSet\Control\DeviceGuard" /v "%%p" /t reg_dword /d 0 /f >nul 2>&1
	for %%p in (
		Enabled
		AuditModeEnabled
		WasEnabledBy
	) do reg add "HKLM\System\CurrentControlSet\Control\DeviceGuard\Scenarios\KernelShadowStacks" /v "%%p" /t reg_dword /d 0 /f >nul 2>&1
	%ch% {0a} Готово. Перезагрузите ПК.{\n#}
	call :Pause && goto ManageDefender

rem ******** НАЧАЛО МЕТОДОВ ********
:CustomizeConsole
rem Если установлен шрифт и если установлен шрифт для CMD SYSTEM - выход
	2>nul reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Cascadia Mono (TrueType)" >nul 2>&1 && 2>nul reg query "HKU\S-1-5-18\Console\%%SystemRoot%%_system32_cmd.exe" /v FaceName | find /i "Cascadia Mono" >nul 2>&1 && exit /b
	call :Unpack CascadiaMono-Regular.ttf
	copy "CascadiaMono-Regular.ttf" "%SystemRoot%\Fonts" /y >nul 2>&1
	reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Cascadia Mono (TrueType)" /t reg_sz /d "CascadiaMono-Regular.ttf" /f >nul 2>&1
	del CascadiaMono-Regular.ttf >nul 2>&1
(
	reg delete "HKU\S-1-5-18\Console\%%SystemRoot%%_system32_cmd.exe" /f
	reg add "HKU\S-1-5-18\Console\%%SystemRoot%%_system32_cmd.exe" /v FaceName /t REG_SZ /d "Cascadia Mono" /f
	reg add "HKU\S-1-5-18\Console\%%SystemRoot%%_system32_cmd.exe" /v CursorType /t REG_DWORD /d 1 /f
	reg add "HKU\S-1-5-18\Console\%%SystemRoot%%_system32_cmd.exe" /v ScreenBufferSize /t REG_DWORD /d "0x23290059" /f
	reg add "HKU\S-1-5-18\Console\%%SystemRoot%%_system32_cmd.exe" /v WindowSize /t REG_DWORD /d "0x220059" /f
	reg add "HKU\S-1-5-18\Console\%%SystemRoot%%_system32_cmd.exe" /v FontWeight /t REG_DWORD /d "0x190" /f
	reg add "HKU\S-1-5-18\Console\%%SystemRoot%%_system32_cmd.exe" /v FontSize /t REG_DWORD /d "0x120008" /f
) >nul 2>&1
	exit /b

:CheckSAC
	if %CurrentBuild% lss 22000 exit /b 0
	reg query "HKLM\System\CurrentControlSet\Control\CI\Protected" /v VerifiedAndReputablePolicyStateMinValueSeen >nul 2>&1 || exit /b 0
	reg query "HKLM\Software\Microsoft\Windows Defender" /v VerifiedAndReputableTrustModeEnabled | find /i "0x1" >nul 2>&1 || exit /b 0
	reg query "HKLM\System\CurrentControlSet\Control\CI\Policy" /v VerifiedAndReputablePolicyState | find /i "0x0" >nul 2>&1 && (
		%ch%  {0c} Требуется перезагрузить ПК{\n#}
		call :Pause && goto Start
	)
	tasklist /fi "imagename eq SecurityHealthService.exe" 2>nul | find /i "SecurityHealthService.exe" >nul || (
		%ch%  {0c} Не запущена служба SecurityHealthService. SAC отмена{\n#}{\n#}
		exit /b 1
	)
rem Если запущено из аргумента
	%ch%  {0b} Отключите Smart App Control{\n#}
	%ch%  {08} Интеллектуальное управление приложениями{\n#}
	explorer windowsdefender://SmartApp
	Helper /Activate
	tasklist /fi "imagename eq SecHealthUI.exe" 2>nul | find /i "SecHealthUI.exe" >nul && (
		PowerShell "while ($true) { if (-not (Get-Process SecHealthUI -EA 0)) {exit}; $val = (Get-ItemProperty HKLM:\System\CurrentControlSet\Control\CI\Policy).VerifiedAndReputablePolicyState; if ($val -eq 0) {exit 0}; Start-Sleep -Seconds 1 }"
	) || (
		%ch%  {0c} Не открылось окно настроек{\n#}
	)
	taskkill /f /im SecHealthUI.exe >nul 2>&1
	reg query "HKLM\System\CurrentControlSet\Control\CI\Policy" /v VerifiedAndReputablePolicyState | find /i "0x0" >nul 2>&1 && (
		%ch% {\n#} {0a} SAC отключен{\n#}{\n#}
		exit /b 0
	) || (
		%ch% {\n#} {0c} SAC не отключен{\n#}{\n#}
		exit /b 1
	)

:Timer
	PowerShell "for ($i=%1; $i -ge 0; $i--) { Write-Host '  Wait ' -F DarkGray -NoNewline; Write-Host $i -F Green -NoNewline; Write-Host ' sec' -F Gray; Start-Sleep 1; if ($i -gt 0) { [Console]::SetCursorPosition(0, [Console]::CursorTop - 1) } }"
	exit /b

:Unpack
	7z x -aoa -bso0 -bsp1 "DKTE.zip" -p"DDK" "%1" >nul
	exit /b

:StartTIService
	sc query TrustedInstaller >nul 2>&1 || %ch% {0c} Нет службы TrustedInstaller. Будет выполнен выход{\n#}&& call :Pause && exit
	sc qc TrustedInstaller | find /i "DISABLED" >nul 2>&1 && (
		sc config TrustedInstaller start=demand
		net start TrustedInstaller
		timeout /t 2 /nobreak >nul
	)
	sc query TrustedInstaller | find /i "STOPPED" >nul 2>&1 && (
		sc config TrustedInstaller start=demand
		net start TrustedInstaller
		timeout /t 2 /nobreak >nul
	)
	%ch% {0a} Перезапустите DK{\n#}
	call :Pause && exit

:CheckNeedFiles
	for %%f in (%NeedFiles%) do if not exist %%f (
		echo  Нет файла %%f в папке Work.
		echo  Будет выполнен выход. Открыть сайт для скачивания последней версии - нажать любую клавишу.
		pause
		start https://github.com/koxauuu/DefenderKiller
		exit
	)
	exit /b
	
:AddExclusionRestore
	echo Windows Registry Editor Version 5.00 > exclusions.reg
	echo. >> exclusions.reg
	echo [HKEY_LOCAL_MACHINE\Software\Microsoft\Windows Defender\Exclusions\Paths] >> exclusions.reg
	for %%d in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%d:\ (
        echo "%%d:\\"=dword:00000000>> exclusions.reg)
	)
	if exist exclusions.reg reg import exclusions.reg >nul 2>&1
	del /q exclusions.reg >nul 2>&1
	exit /b

:CheckBuildArch
	call :NullVar NumberWin Arch CurrentBuild
	set "Arch=x64" & (If "%PROCESSOR_ARCHITECTURE%"=="x86" if not defined PROCESSOR_ARCHITEW6432 set Arch=x86)
	if %Arch%==x86 (
		echo  Нет поддержки x32 систем
		echo  Будет выполнен выход
		echo.
		pause && exit
	)
	reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v ProductName | find /i "Windows 7" >nul 2>&1 && (
		echo  Нет поддержки для Windows 7
		echo  Будет выполнен выход
		echo. && pause && exit
	)
	for /f "tokens=4 delims=[] " %%v in ('ver') do set "NumberWin=%%v"
	set "NumberWin=!NumberWin:*0.0.=!"
	
	for /f "tokens=2*" %%a in ('reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion" /v "CurrentBuild" 2^>nul') do set CurrentBuild=%%b
	set /a CurrentBuild=%CurrentBuild%
	exit /b
:Pause
    %ch% {\n#}{08} Для продолжения нажмите любую клавишу...{\n#}& pause >nul & exit /b
:NullVar
	for %%a in (%*) do set "%%a=" 2>nul
	exit /b
	
:ErrorAddExclusion
	%ch%  {\n#}{0c} Ошибка добавления в исключения. Шаги:{\n#}
	%ch%  {08} Вариант 1: {0e}попробуйте еще раз через DK.{\n#}
	%ch%  {08} Вариант 2: {0e}вручную добавьте в исключения диск {0b}%SystemDrive%\{\n#}
	%ch%  {08} Инструкция: {0b}В открытой странице - Добавить исключение - Папка - Выбрать диск{\n#}{\n#}
	%ch%  {0e} Нажмите любую клавишу для открытия страницы исключений.{\n#}
	call :Pause
	explorer windowsdefender://exclusions/
	%ch%  {08} Будет выполнен возврат в главное меню{\n#}
	call :Pause && goto Start

:STATUS
	sc query WinDefend | find /i "STOPPED" >nul 2>&1 && exit /b 0
	exit /b 1

:CheckArgs
	set "Arg=%*"
	for %%a in (-help /help -h /h) do if /i "%~1"=="%%a" (
		%ch% {0e} Список аргументов:{\n#}
		%ch% {08} /DelWD - {0c}удаление в тихом режиме [вместе с копией]{\n#}
		%ch% {08} /DelWinSxS - {0c}удаление папок из хранилища WinSxS{\n#}
		%ch% {08} Будет выполнен выход из программы{\n#}
		call :Pause && exit
	)
	if "%Arg%"=="/DelWD" goto StartProcessRemove
	if "%Arg%"=="/DelWinSxS" (
		Helper /HideConsole
		call :WinSxSFolders NoVerbose
		msg * /time:3 Удаление папок из хранилища выполнено
		exit
	)
	%ch% {0c} Такого аргумента для программы не существует{\n#}&& call :Pause && exit
:FrwSettings
cls & call :NullVar %FRWEnable%
	2>nul reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "SettingsPageVisibility" | find /i "windowsdefender" >nul 2>&1 && set "FRWEnable={0a}не выключен" || set "FRWEnable={0c}выключен"
rem Отключение Брандмауэра Защитника Windows
%ch% {9f}Настройки Брандмауэра{\n#}
%ch% {09} 1. {08}Отключение Брандмауэра Защитника Windows{\n#}
%ch% {09} 2. {08}Включение Брандмауэра Защитника Windows (Значение по умолчанию){\n#}{\n#}
%ch% {0e} [Enter] - {08}Вернуться в главное меню{\n#}
	set "input=" & set /p input=
	if not defined input goto Start
	if "%input%"=="1" goto Frwudud
        if "%input%"=="2" goto Frwudud2
cls && %ch% {0c} Такой функции не существует{\n#}&& timeout /t 2 >nul && goto FrwSettings
:Frwudud
@echo off
call firewall_off.bat
%ch% {0a}Готово.{\n#}
	call :Pause && goto FrwSettings 
:Frwudud2
@echo off
call firewall_on.bat
%ch% {0a}Готово.{\n#}
	call :Pause && goto FrwSettings

:UACpox
cls & call :NullVar %FRWEnable%
	2>nul reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "SettingsPageVisibility" | find /i "windowsdefender" >nul 2>&1 && set "FRWEnable={0a}не выключен" || set "FRWEnable={0c}выключен"
rem UAC бла бла бла
%ch% {9f}Настройки UAC (Контроль учетных записей){\n#}
%ch% {09} 1. {08}Всегда уведомлять{\n#}
%ch% {09} 2. {08}Уведомлять при попытках приложений изменить параметры (Значение по умолчанию){\n#}
%ch% {09} 3. {08}Уведомлять без затемнения экрана{\n#}
%ch% {09} 4. {08}Отключить UAC и не уведомлять{\n#}
%ch% {09} 5. {0c}Полностью отключить UAC{\n#}{\n#}
%ch% {0e} [Enter] - {08}Вернуться в главное меню{\n#}
set "input=" & set /p input=
	if not defined input goto Start
	if "%input%"=="1" goto Uacc1
        if "%input%"=="2" goto Uacc2
        if "%input%"=="3" goto Uacc3
        if "%input%"=="4" goto Uacc4
        if "%input%"=="5" goto Uacc5
cls && %ch% {0c} Такой функции не существует{\n#}&& timeout /t 2 >nul && goto UACpox
:Uacc1
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 1 /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d 1 /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d 2 /f
%ch% {0a}Готово.{\n#}
	call :Pause && goto UACpox
:Uacc2
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 1 /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d 1 /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d 5 /f
%ch% {0a}Готово.{\n#}
	call :Pause && goto UACpox
:Uacc3
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 0 /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d 1 /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d 5 /f
%ch% {0a}Готово.{\n#}
	call :Pause && goto UACpox
:Uacc4
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 0 /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d 1 /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d 0 /f
%ch% {0a}Готово.{\n#}
	call :Pause && goto UACpox
:Uacc5
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 0 /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d 0 /f
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d 0 /f
%ch% {0a}Готово. Перезагрузите ПК для полного отключения UAC.{\n#}
	call :Pause && goto UACpox

:SvstbrowserRestrictFiles
cls & call :NullVar %FRWEnable%
	2>nul reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "SettingsPageVisibility" | find /i "windowsdefender" >nul 2>&1 && set "FRWEnable={0a}не выключен" || set "FRWEnable={0c}выключен"
rem Плашка не работает
%ch% {9f}Настройки не работает {\n#}
%ch% {09} 1. {08}Отключение Плашки {\n#}
%ch% {09} 2. {08}Включение Плашки (Значение по умолчанию){\n#}{\n#}
%ch% {0e} [Enter] - {08}Вернуться в главное меню{\n#}
	set "input=" & set /p input=
	if not defined input goto Start
	if "%input%"=="1" goto RestrictFilesOFF
        if "%input%"=="2" goto RestrictFilesON
cls && %ch% {0c} Такой функции не существует{\n#}&& timeout /t 2 >nul && goto SvstbrowserRestrictFiles
:RestrictFilesON
(неправильные команды)REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /V "1806" /T REG_DWORD /D "00000000" /F
%ch% {0a}Готово.{\n#}
	call :Pause && goto SvstbrowserRestrictFiles
:RestrictFilesOFF
(неправильные команды)REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /V "1806" /T REG_DWORD /D 0 /F
%ch% {0a}Готово.{\n#}
	call :Pause && goto SvstbrowserRestrictFiles
вырез %ch% {09} 6. {0e}(NEW) Отключение / Включение Плашки о запуске программ и небезопасных файлов {\n#}{\n#}
вырез if "%input%"=="6"  goto SvstbrowserRestrictFiles
новые функции в стадии теста
