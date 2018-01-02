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
SET CYG_DESCR=�� 㪠��� ���� � ����� ��⠭���� cygwin. ������ ���, ��� �㤥� �ᯮ�짮��� 
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

SET CHANGES=����襭�� ���������.

SET END_TITLE=0. ��᫥��⠭���筠� ����ன�� Cygwin.
SET END_DESCR=���࠭��� ���������?
SET END="����⢨�: [Y]��/[N]���: "

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
rem �������� ��. �� �� ������, � ��⭮��, �뢮� ����������� reg.
rem set OS_NAME=7
echo %OS_TITLE%
FOR /F "tokens=5" %%i IN ('systeminfo 2^>Nul ^| findstr /R /C:"Windows"') DO SET OS_NAME=%%i
echo Windows Name: %OS_NAME%

rem ������⢮ �ய�᪠���� ��ப � �뢮�� ����������� reg.
IF "x%OS_NAME%"=="x10" (
	SET REG_SKIP=2
)
IF "x%OS_NAME%"=="x7" (
	SET REG_SKIP=2
)
IF "x%OS_NAME%"=="xXP" (
	SET REG_SKIP=4
)
rem ------------------------------------


rem ------------------------------------
rem ���樠�����㥬 ��६����
rem ��������� cygwin.
rem �᫨ �� ������ � ��������� ��ப�, � ������� �� ॥��� (�᫨ ����) ��� �� 㬮�砭��
IF NOT "x%1"=="x" (
	SET LOCAL_CYGWIN=%1
) ELSE (
	FOR /f "skip=%REG_SKIP% tokens=2*" %%i IN ('reg query HKCU\Environment /v CYGWIN_HOME 2^>Nul') DO SET REG_VAL=%%j
	IF NOT "x!REG_VAL!"=="x" (
		SET LOCAL_CYGWIN=!REG_VAL!
	)
	echo %CYG_TITLE%
	echo %CYG_DESCR% "!LOCAL_CYGWIN!"
	:begin_cyg
	SET /P choice=%CYG_MK%
	IF /I "x!choice!"=="xS" GOTO end_cyg
	IF /I NOT "x!choice!"=="xA" GOTO begin_cyg
	
	SET /P LOCAL_CYGWIN=%CYG_MK_PATH%
)
:end_cyg
echo cygwin root: %LOCAL_CYGWIN%
SET BASH=!LOCAL_CYGWIN!\bin\bash
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

	SET ENV_UPD=Yes
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
		SET HOME_UPD=Rm
		GOTO mk_home
	)
	IF /I "x!choice!"=="xR" (
		SET HOME_UPD=Mv
		GOTO mk_home
	)
	IF /I NOT "x!choice!"=="xS" (
		GOTO begin_home_warn
	) ELSE (
		GOTO end_home
	)
) ELSE (
	SET HOME_UPD=New
)

:mk_home

:end_home
rem ------------------------------------


rem ------------------------------------
rem ���������� ��뫮� �� ��᪨ � /mnt
echo %MNT_TITLE%
echo %MNT_DESCR%
:begin_mnt
SET /P choice=%MNT_MK%
IF /I "x%choice%"=="xE" (
	SET MNT_UPD=E
	GOTO end_mnt
)
IF /I "x%choice%"=="xA" (
	SET MNT_UPD=A
	GOTO end_mnt
)
IF /I "x%choice%"=="xS" (
	GOTO end_mnt
) ELSE (
	GOTO begin_mnt
)

:end_mnt
rem ------------------------------------

echo =====================================================
echo %CHANGES%
echo -----------------------------------------------------

IF "x!ENV_UPD!"=="xYes" (
	echo ��६���� ���㦥���:
	rem SET MY_OUT=CYGWIN_HOME=!LOCAL_CYGWIN!
	echo 	�������� CYGWIN_HOME=%LOCAL_CYGWIN%
	echo 	�������� CYGWIN_PATH=%%CYGWIN_HOME%%\bin;%%CYGWIN_HOME%%\usr\local\bin;%%CYGWIN_HOME%%\usr\ssl\certs
	FOR /f "skip=2 tokens=2*" %%i IN ('reg query HKCU\Environment /v PATH 2^>Nul') DO SET REG_VAL=%%j
	IF "x!REG_VAL!"=="x" (
		SET MY_OUT=PATH=%CYGWIN_PATH%
		echo 	�������� PATH=%CYGWIN_PATH%
	) ELSE (
		SET MY_OUT=PATH=!REG_VAL!%%CYGWIN_PATH%%
		echo 	�������� PATH=!REG_VAL!%%CYGWIN_PATH%%
	)
	IF NOT "x!HOME_UPD!"=="x" (
		echo 	�������� HOME=%%USERPROFILE%%
	)
) ELSE (
	IF NOT "x!HOME_UPD!"=="x" (
		echo ��६���� ���㦥���:
		echo 	�������� HOME=%%USERPROFILE%%
	)
)

IF "x!HOME_UPD!"=="xNew" (
	echo ������� ��४���:
	echo 	������� ᨬ������ ��뫪� [%USR_HOME%], 㪠�뢠���� �� [%HOME%]
)
IF "x!HOME_UPD!"=="xRm" (
	echo ������� ��४���:
	rem �஢��塞, 祬 ���� ��饭������ ������� ��४���: ��뫪�� ��� ��४�ਥ�
	!BASH! -c " [ -L %USR_HOME% ] || return_error_to_cmd " >Nul 2>&1
	IF ERRORLEVEL 1 GOTO home_upd_dir
	echo 	������� ᨬ������ ��뫪� [%USR_HOME%]
	GOTO home_upd_end
	:home_upd_dir
	echo 	������� ��४��� [%USR_HOME%] � �ᥬ �� ᮤ�ন��
	:home_upd_end
	echo 	������� ᨬ������ ��뫪� [%USR_HOME%], 㪠�뢠���� �� [%HOME%]
)
IF "x!HOME_UPD!"=="xMv" (
	echo ������� ��४���:
	echo 	��२�������� [%USR_HOME%] �
	!BASH! -c 'echo -e "\\\\t\\\\t[%USR_HOME%-`date \+\"%%s\"`]" '
	echo 	������� ᨬ������ ��뫪� [%USR_HOME%], 㪠�뢠���� �� [%HOME%]
)

IF "x!MNT_UPD!"=="xE" (
	echo �����᪨� ��᪨:
	echo ��������
	!BASH! -c 'ls /cygdrive/ | sed -e "s/.*/\/mnt\/\0/"'
)
IF "x!MNT_UPD!"=="xA" (
	echo �����᪨� ��᪨:
	echo ��������
	!BASH! -c 'echo cdefghijklmnopqrstuvwxyz | sed -e "s/./\/mnt\/\0\n/g"'
)
echo =====================================================

echo %END_TITLE%
echo %END_DESCR%
:begin_end
SET /P choice=%END%
IF /I "x%choice%"=="xY" GOTO commit
IF /I NOT "x%choice%"=="xN" GOTO begin_end

GOTO end

:commit

IF "x!ENV_UPD!"=="xYes" (
	reg add HKCU\Environment /v CYGWIN_HOME /t REG_EXPAND_SZ /d %LOCAL_CYGWIN% >Nul
	echo ��६����� CYGWIN_HOME ᮧ����

	reg add HKCU\Environment /v CYGWIN_PATH /t REG_EXPAND_SZ /d %%CYGWIN_HOME%%\bin;%%CYGWIN_HOME%%\usr\local\bin;%%CYGWIN_HOME%%\usr\ssl\certs >Nul
	echo ��६����� CYGWIN_PATH ᮧ����

	FOR /f "skip=2 tokens=2*" %%i IN ('reg query HKCU\Environment /v PATH 2^>Nul') DO SET REG_VAL=%%j
	IF "x!REG_VAL!"=="x" (
		reg add HKCU\Environment /v PATH /t REG_EXPAND_SZ /d %%CYGWIN_PATH%% /f >Nul
		echo ��६����� PATH ᮧ����
	) ELSE (
		reg add HKCU\Environment /v PATH /t REG_EXPAND_SZ /d !REG_VAL!;%%CYGWIN_PATH%% /f >Nul
		echo ��६����� PATH ���������
	)
)
IF NOT "x!HOME_UPD!"=="x" (
	reg add HKCU\Environment /v HOME /t REG_EXPAND_SZ /d %%USERPROFILE%% /f >Nul
	echo ��६����� HOME ᮧ����
)

IF "x!HOME_UPD!"=="xNew" (
	!BASH! -c 'ln -s "${HOME}/" /home/'
	echo ��뫪� �� ������� ��४��� ᮧ����
)
IF "x!HOME_UPD!"=="xRm" (
	!BASH! -c " [ -L %USR_HOME% ] && rm -f %USR_HOME% || rm -rf %USR_HOME% ; "
	IF ERRORLEVEL 1 echo error rm home dir
	echo �������� ����譥� ��४�ਨ �����襭�
	!BASH! -c 'ln -s "${HOME}/" /home/'
	echo ��뫪� �� ������� ��४��� ᮧ����
)
IF "x!HOME_UPD!"=="xMv" (
	!BASH! -c "mv -f %USR_HOME% %USR_HOME%-`date \+\"%%s\"` "
	echo ��२��������� ����譥� ��४�ਨ �����襭�
	!BASH! -c 'ln -s "${HOME}/" /home/'
	echo ��뫪� �� ������� ��४��� ᮧ����
)

IF "x!MNT_UPD!"=="xE" (
	!BASH! -c "mkdir -p /mnt; ln -s /cygdrive/* /mnt/"
	echo ��᪨ ���������
)
IF "x!MNT_UPD!"=="xA" (
	!BASH! -c "mkdir -p /mnt; ln -s /cygdrive/{c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z} /mnt/"
	echo ��᪨ ���������
)

set PATH=%tmp_path%
set HOME=%tmp_home%

:end