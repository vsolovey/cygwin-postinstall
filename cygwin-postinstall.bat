@echo off

rem Донастройка сигвина.
rem Перво-наперво добавляется возможность вызвать баш из любого места
rem Для этого сигвин добавляется в пути
rem Затем, совмещаются домашние директории. Это можно сдалать, положив в
rem /home ссылку на домашнюю директорию такую же, как имя пользователя, и 
rem добавив ещё одну переменную среды
rem Затем, в домашнюю директорию копируются свои конфигурационные файлы
rem это баш, вим, ssh, inputrc и т.д.


rem примеры работы с реестром
rem reg query HKCU\Environment /v TMP
rem reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH

rem Загнать в переменную значение из реестра (в выводе говноутилиты реестра пропускается заголовок в 4 строки и 2 слова из 5-й, полезной, строки)
rem FOR /f "skip=4 tokens=2*" %%i IN ('reg query HKCU\Environment /v CYGWIN_HOME 2^>Nul') DO SET DBG=%%j

rem reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v HOME /t REG_EXPAND_SZ /d %HOMEDRIVE%%HOMEPATH%

rem IF DEFINED CYGWIN_HOME GOTO skip_test_env
rem echo CYGWIN_HOME не задана! Исправим...
rem reg add HKCU\Environment /v CYGWIN_HOME /t REG_EXPAND_SZ /d %CYGWIN_HOME%;%%TMP%% /f
rem :skip_test_env
rem echo %CYGWIN_HOME%


rem примеры работы с переменными
rem путь к home: "C:\Users\user" -> "/cygdrive/C/Users/user/"
rem SET cyg_home=%USERPROFILE:\=/%
rem SET cyg_home=/cygdrive/%cyg_home::=%/


rem =========
rem windows OS name
echo cmd version: %cmdextversion%

for /f "tokens=2 delims=[]" %%x in ('ver') do set WINVER=%%x
set WINVER=%WINVER:Version =%
echo WINVER: %WINVER%

FOR /F "tokens=5" %%i IN ('systeminfo ^| findstr /R /C:"Microsoft Windows"') DO echo %%i

rem =========



SET DBG=
SET TMP_CYGWIN=d:\cygwin
SET BASH=%TMP_CYGWIN%\bin\bash

IF NOT "x%1"=="x" SET TMP_CYGWIN=%1

rem FOR /f "skip=4 tokens=2*" %%i IN ('reg query HKCU\Environment /v CYGWIN_HOME 2^>Nul') DO SET DBG=%%j
rem на семёрке пропускать нужно не четыре строки, а две
FOR /f "skip=2 tokens=2*" %%i IN ('reg query HKCU\Environment /v CYGWIN_HOME 2^>Nul') DO SET DBG=%%j
IF NOT "x%DBG%"=="x" GOTO skip_root_cygwin
	echo CYGWIN_HOME не задана. Добавляем...

	rem создаём переменную
	reg add HKCU\Environment /v CYGWIN_HOME /t REG_EXPAND_SZ /d %TMP_CYGWIN% >Nul
	echo CYGWIN_HOME создана

	rem добавляем переменную в path
		rem убрал три строки: глобальный %PATH% на семёрке подставляется всегда. Думаю, на XP также
		rem FOR /f "skip=4 tokens=2*" %%i IN ('reg query HKCU\Environment /v PATH 2^>Nul') DO SET DBG=%%j
		rem IF NOT "x%DBG%"=="x" GOTO add_root_cygwin
		rem FOR /f "skip=4 tokens=2*" %%i IN ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH 2^>Nul') DO SET DBG=%%j
		rem :add_root_cygwin
	rem на семёрке пропускать нужно не четыре строки, а две
	FOR /f "skip=2 tokens=2*" %%i IN ('reg query HKCU\Environment /v PATH 2^>Nul') DO SET DBG=%%j
echo DBG: %DBG%
		IF NOT "x%DBG%"=="x" GOTO upd_path
			reg add HKCU\Environment /v PATH /t REG_EXPAND_SZ /d %%CYGWIN_HOME%%\bin /f >Nul
			GOTO finish_path
		:upd_path
			reg add HKCU\Environment /v PATH /t REG_EXPAND_SZ /d %DBG%;%%CYGWIN_HOME%%\bin /f >Nul
		:finish_path
	echo ... и добавлена в переменную PATH пользователя.
:skip_root_cygwin

IF EXIST %TMP_CYGWIN%\home\%USERNAME% GOTO skip_home_dir
	echo Ссылка на домашнюю директорию в /home отсутствует. Создаём...

	rem set tmp_path=%PATH%
	rem set tmp_home=%HOME%
	set PATH=%PATH%;%TMP_CYGWIN%\bin
	set HOME=%USERPROFILE%
	%BASH% -c 'ln -s "${HOME}/" /home/'
	rem set PATH=%tmp_path%
	rem set HOME=%tmp_home%


	reg add HKCU\Environment /v HOME /t REG_EXPAND_SZ /d %%USERPROFILE%% /f >Nul

:skip_home_dir

