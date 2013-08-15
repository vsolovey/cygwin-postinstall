@echo off

rem ������ன�� ᨣ����.
rem ��ࢮ-����ࢮ ���������� ����������� �맢��� ��� �� ��� ����
rem ��� �⮣� ᨣ��� ���������� � ���
rem ��⥬, ᮢ������� ����譨� ��४�ਨ. �� ����� ᤠ����, ������� �
rem /home ��뫪� �� ������� ��४��� ⠪�� ��, ��� ��� ���짮��⥫�, � 
rem ������� ��� ���� ��६����� �।�
rem ��⥬, � ������� ��४��� ���������� ᢮� ���䨣��樮��� 䠩��
rem �� ���, ���, ssh, inputrc � �.�.


rem �ਬ��� ࠡ��� � ॥��஬
rem reg query HKCU\Environment /v TMP
rem reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH

rem ������� � ��६����� ���祭�� �� ॥��� (� �뢮�� ������⨫��� ॥��� �ய�᪠���� ��������� � 4 ��ப� � 2 ᫮�� �� 5-�, ��������, ��ப�)
rem FOR /f "skip=4 tokens=2*" %%i IN ('reg query HKCU\Environment /v CYGWIN_HOME 2^>Nul') DO SET DBG=%%j

rem reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v HOME /t REG_EXPAND_SZ /d %HOMEDRIVE%%HOMEPATH%

rem IF DEFINED CYGWIN_HOME GOTO skip_test_env
rem echo CYGWIN_HOME �� ������! ��ࠢ��...
rem reg add HKCU\Environment /v CYGWIN_HOME /t REG_EXPAND_SZ /d %CYGWIN_HOME%;%%TMP%% /f
rem :skip_test_env
rem echo %CYGWIN_HOME%


rem �ਬ��� ࠡ��� � ��६���묨
rem ���� � home: "C:\Users\user" -> "/cygdrive/C/Users/user/"
rem SET cyg_home=%USERPROFILE:\=/%
rem SET cyg_home=/cygdrive/%cyg_home::=%/


rem =========
rem windows OS name
echo cmd version: %cmdextversion%

for /f "tokens=2 delims=[]" %%x in ('ver') do set WINVER=%%x
set WINVER=%WINVER:Version =%
echo WINVER: %WINVER%

FOR /F "tokens=5" %%i IN ('systeminfo 2^>Nul ^| findstr /R /C:"Microsoft Windows"') DO echo %%i

rem =========



SET DBG=
SET TMP_CYGWIN=d:\cygwin
SET BASH=%TMP_CYGWIN%\bin\bash

IF NOT "x%1"=="x" SET TMP_CYGWIN=%1

rem FOR /f "skip=4 tokens=2*" %%i IN ('reg query HKCU\Environment /v CYGWIN_HOME 2^>Nul') DO SET DBG=%%j
rem �� ᥬ�થ �ய�᪠�� �㦭� �� ���� ��ப�, � ���
FOR /f "skip=2 tokens=2*" %%i IN ('reg query HKCU\Environment /v CYGWIN_HOME 2^>Nul') DO SET DBG=%%j
IF NOT "x%DBG%"=="x" GOTO skip_root_cygwin
	echo CYGWIN_HOME �� ������. ������塞...

	rem ᮧ��� ��६�����
	reg add HKCU\Environment /v CYGWIN_HOME /t REG_EXPAND_SZ /d %TMP_CYGWIN% >Nul
	echo CYGWIN_HOME ᮧ����

	rem ������塞 ��६����� � path
		rem �ࠫ �� ��ப�: �������� %PATH% �� ᥬ�થ ����⠢����� �ᥣ��. �㬠�, �� XP ⠪��
		rem FOR /f "skip=4 tokens=2*" %%i IN ('reg query HKCU\Environment /v PATH 2^>Nul') DO SET DBG=%%j
		rem IF NOT "x%DBG%"=="x" GOTO add_root_cygwin
		rem FOR /f "skip=4 tokens=2*" %%i IN ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v PATH 2^>Nul') DO SET DBG=%%j
		rem :add_root_cygwin
	rem �� ᥬ�થ �ய�᪠�� �㦭� �� ���� ��ப�, � ���
	FOR /f "skip=2 tokens=2*" %%i IN ('reg query HKCU\Environment /v PATH 2^>Nul') DO SET DBG=%%j
echo DBG: %DBG%
		IF NOT "x%DBG%"=="x" GOTO upd_path
			reg add HKCU\Environment /v PATH /t REG_EXPAND_SZ /d %%CYGWIN_HOME%%\bin /f >Nul
			GOTO finish_path
		:upd_path
			reg add HKCU\Environment /v PATH /t REG_EXPAND_SZ /d %DBG%;%%CYGWIN_HOME%%\bin /f >Nul
		:finish_path
	echo ... � ��������� � ��६����� PATH ���짮��⥫�.
:skip_root_cygwin

IF EXIST %TMP_CYGWIN%\home\%USERNAME% GOTO skip_home_dir
	echo ��뫪� �� ������� ��४��� � /home ���������. ������...

	rem set tmp_path=%PATH%
	rem set tmp_home=%HOME%
	set PATH=%PATH%;%TMP_CYGWIN%\bin
	set HOME=%USERPROFILE%
	%BASH% -c 'ln -s "${HOME}/" /home/'
	rem set PATH=%tmp_path%
	rem set HOME=%tmp_home%


	reg add HKCU\Environment /v HOME /t REG_EXPAND_SZ /d %%USERPROFILE%% /f >Nul

:skip_home_dir

