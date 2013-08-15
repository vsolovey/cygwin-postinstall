@echo off
setlocal EnableDelayedExpansion
cls

SET LOCAL_CYGWIN=d:\cygwin
SET BASH=%LOCAL_CYGWIN%\bin\bash
SET USR_HOME=/home/%USERNAME%
SET OS_NAME=
SET REG_SKIP=
SET REG_VAL=

SET BEGIN_TITLE=0. ��᫥��⠭���筠� ����ன�� Cygwin.
SET BEGIN_DESCR=��������� ���஭�� ⮫쪮 ⥪�饣� ���짮��⥫�. � �ਯ� ����� ��।��� ���� � ��४�ਨ cygwin: "%0 c:\dir"
SET BEGIN="����⢨�: [R]�������� ����ன��, [C]�⬥����: "

SET CYG_TITLE=1. ��४��� ��⠭���� cygwin.
SET CYG_DESCR=��������� ���� � cygwin. ������� ���, ��� �㤥� �ᯮ�짮���� ���祭�� �� 㬮�砭�� "%LOCAL_CYGWIN%".
SET CYG_MK_PATH="���� � cygwin: "
SET CYG_MK="����⢨�: [A]��������, [S]�ய�����: "

SET OS_TITLE=-- ����祭�� ���ᨨ ��.

SET ENV_TITLE=2. ��६����� PATH ��� cygwin.
SET ENV_DESCR=���������� �ᯮ������ 䠩��� � ���� ���᪠.
SET ENV_WARN1=� ��⥬� ���� 䠩�� UNIX-���㦥���. ���������� Cygwin �ਢ���� � ���䫨�⠬
SET ENV_WARN2=��宦�, �� ��� 㦥 �ய�ᠭ�.
SET ENV_MK="����⢨�: [A]��������, [S]�ய�����: "

SET HOME_TITLE=3. ������� ��४���.
SET HOME_DESCR=�������� %USERPROFILE% � ����⢥ ����譥� ��४�ਨ.
SET HOME_WARN1=������� ��४��� 㦥 �������.
SET HOME_MK="����⢨�: [A]��������, [S]�ய�����: "
SET HOME_MK1="����⢨�: [D]������� � ���ᮧ����, [R]��२�������� � ᮧ����, [S]�ய�����: "

SET MNT_TITLE=4. �����᪨� ��᪨.
SET MNT_DESCR=������ ��뫪� � /mnt ��� �����᪨� ��᪮�
SET MNT_MK="����⢨�: ��� [E]���������, ��� [A]��� �㪢 ��䠢��, [S]�ய�����: "


rem ------------------------------------
rem  command line options

echo %BEGIN_TITLE%
echo %BEGIN_DESCR%
rem ------------------------------------
:begin
SET /p choice=%BEGIN%
IF /I "x%choice%"=="xC" GOTO end
IF /I NOT "x%choice%"=="xR" GOTO begin
rem ------------------------------------

rem ------------------------------------
rem ���樠�����㥬 ��६����
rem ��������� cygwin. �᫨ �� ������ � ��������� ��ப�, � ������� ���祭�� �� 㬮�砭��
IF NOT "x%1"=="x" (
	SET LOCAL_CYGWIN=%1
) ELSE (
	echo %CYG_TITLE%
	echo %CYG_DESCR%
	:begin_cyg
	echo choice: %choice%
	SET /P choice=%CYG_MK%
	IF /I "x!choice!"=="xS" GOTO end_cyg
	IF /I NOT "x!choice!"=="xA" GOTO begin_cyg
	
	SET /P LOCAL_CYGWIN=%CYG_MK_PATH%
)
:end_cyg
echo cygwin root: %LOCAL_CYGWIN%
rem ------------------------------------

rem ------------------------------------
rem �������� ��. �� �� ������, � ��⭮��, �뢮� ����������� reg.
rem set OS_NAME=7
echo %OS_TITLE%
FOR /F "tokens=5" %%i IN ('systeminfo 2^>Nul ^| findstr /R /C:"Microsoft Windows"') DO SET OS_NAME=%%i
echo Windows Name: %OS_NAME%

rem ������⢮ �ய�᪠���� ��ப � �뢮�� ����������� reg.
IF "x%OS_NAME%"=="x7" (
	SET REG_SKIP=2
)
IF "x%OS_NAME%"=="xXP" (
	SET REG_SKIP=4
)
rem ------------------------------------


rem ------------------------------------
rem ���������� cygwin � ����

echo %ENV_TITLE%
echo %ENV_DESCR%
:begin_env
SET /P choice=%ENV_MK%
IF /I "x%choice%"=="xS" GOTO end_env
IF /I NOT "x%choice%"=="xA" GOTO begin_env

rem set REG_VAL=dbg
FOR /f "skip=%REG_SKIP% tokens=2*" %%i IN ('reg query HKCU\Environment /v CYGWIN_HOME 2^>Nul') DO SET REG_VAL=%%j
IF "x%REG_VAL%"=="x" (

	rem �������� �஢�ઠ �� ��������
	call ls -la >Nul 2>&1
	IF NOT ERRORLEVEL 1 GOTO err_env
	call bash --version >Nul 2>&1
	IF NOT ERRORLEVEL 1 GOTO err_env
	call which man >Nul 2>&1
	IF NOT ERRORLEVEL 1 GOTO err_env
	call man --help >Nul 2>&1
	IF NOT ERRORLEVEL 1 GOTO err_env
	call ln --help >Nul 2>&1
	IF NOT ERRORLEVEL 1 GOTO err_env
	call mv --help >Nul 2>&1
	IF NOT ERRORLEVEL 1 GOTO err_env

	reg add HKCU\Environment /v CYGWIN_HOME /t REG_EXPAND_SZ /d %LOCAL_CYGWIN% >Nul
	echo CYGWIN_HOME ᮧ����
	
	reg add HKCU\Environment /v CYGWIN_PATH /t REG_EXPAND_SZ /d %%CYGWIN_HOME%%\bin;%%CYGWIN_HOME%%\usr\local\bin;%%CYGWIN_HOME%%\usr\ssl\certs >Nul
	echo CYGWIN_PATH ᮧ����

	FOR /f "skip=2 tokens=2*" %%i IN ('reg query HKCU\Environment /v PATH 2^>Nul') DO SET REG_VAL=%%j
	IF "x!REG_VAL!"=="x" (
		reg add HKCU\Environment /v PATH /t REG_EXPAND_SZ /d %%CYGWIN_PATH%% /f >Nul
	) ELSE (
		reg add HKCU\Environment /v PATH /t REG_EXPAND_SZ /d !REG_VAL!;%%CYGWIN_PATH%% /f >Nul
	)
	echo ��� �ய�ᠭ�

) ELSE (
	echo %ENV_WARN2%
)
GOTO end_env

:err_env
echo %ENV_WARN1%

:end_env
rem ------------------------------------

set tmp_path=%PATH%
set tmp_home=%HOME%
set PATH=%PATH%;%LOCAL_CYGWIN%\bin
set HOME=%USERPROFILE%


rem ------------------------------------
rem ���������� ����譥� ��४�ਨ � /home
echo %HOME_TITLE%
echo %HOME_DESCR%
:begin_home
SET /P choice=%HOME_MK%
IF /I "x%choice%"=="xS" GOTO end_home
IF /I NOT "x%choice%"=="xA" GOTO begin_home

IF EXIST %LOCAL_CYGWIN%\home\%USERNAME% (
	echo %HOME_WARN1%
	:begin_home_warn
	SET /P choice=%HOME_MK1%
	IF /I "x!choice!"=="xD" (
		%BASH% -c " [ -L %USR_HOME% ] && rm -f %USR_HOME% || rm -rf %USR_HOME% ; "
		IF ERRORLEVEL 1 echo error
		GOTO mk_home
	)
	IF /I "x!choice!"=="xR" (
		%BASH% -c "mv -f %USR_HOME% %USR_HOME%-`date \+\"%%s\"` "
		GOTO mk_home
	)
	IF /I NOT "x!choice!"=="xS" (
		GOTO begin_home_warn
	) ELSE (
		GOTO end_home
	)
)

:mk_home
%BASH% -c 'ln -s "${HOME}/" /home/'
reg add HKCU\Environment /v HOME /t REG_EXPAND_SZ /d %%USERPROFILE%% /f >Nul

:end_home
rem ------------------------------------


rem ------------------------------------
rem �������� ��뫪� �� ��᪨ � /mnt
echo %MNT_TITLE%
echo %MNT_DESCR%
:begin_mnt
SET /P choice=%MNT_MK%
IF /I "x%choice%"=="xE" (
	%BASH% -c "mkdir -p /mnt; cd /mnt; ln -s /cygdrive/* ."
	GOTO end_mnt
)
IF /I "x%choice%"=="xA" (
	%BASH% -c "mkdir -p /mnt; cd /mnt; ln -s /cygdrive/{c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z} ."
	GOTO end_mnt
)
IF /I "x%choice%"=="xS" (
	GOTO end_mnt
) ELSE (
	GOTO begin_mnt
)

:end_mnt
rem ------------------------------------

set PATH=%tmp_path%
set HOME=%tmp_home%

:end