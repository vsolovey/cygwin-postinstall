@echo off
setlocal EnableDelayedExpansion
cls

SET LOCAL_CYGWIN=d:\cygwin
SET BASH=%LOCAL_CYGWIN%\bin\bash
SET USR_HOME=/home/%USERNAME%
SET OS_NAME=
SET REG_SKIP=
SET REG_VAL=

SET BEGIN_TITLE=0. Послеустановочная настройка Cygwin.
SET BEGIN_DESCR=Изменения затронут только текущего пользователя. В скрипт можно передать путь к директории cygwin: "%0 c:\dir"
SET BEGIN="Действия: [R]Запустить настройку, [C]Отменить: "

SET CYG_TITLE=1. Директория установки cygwin.
SET CYG_DESCR=Отсутствует путь к cygwin. Добавьте его, или будет использовано значение по умолчанию "%LOCAL_CYGWIN%".
SET CYG_MK_PATH="Путь к cygwin: "
SET CYG_MK="Действия: [A]Добавить, [S]Пропустить: "

SET OS_TITLE=-- Получение версии ОС.

SET ENV_TITLE=2. Переменная PATH для cygwin.
SET ENV_DESCR=Добавление исполнимых файлов в путь поиска.
SET ENV_WARN1=В системе есть файлы UNIX-окружения. Добавление Cygwin приведёт к конфликтам
SET ENV_WARN2=Похоже, что пути уже прописаны.
SET ENV_MK="Действия: [A]Добавить, [S]Пропустить: "

SET HOME_TITLE=3. Домашняя директория.
SET HOME_DESCR=Добавить %USERPROFILE% в качестве домашней директории.
SET HOME_WARN1=Домашняя директория уже существует.
SET HOME_MK="Действия: [A]Добавить, [S]Пропустить: "
SET HOME_MK1="Действия: [D]Удалить и пересоздать, [R]Переименовать и создать, [S]Пропустить: "

SET MNT_TITLE=4. Логические диски.
SET MNT_DESCR=Завести ссылки в /mnt для логических дисков
SET MNT_MK="Действия: Для [E]существующих, Для [A]всех букв алфавита, [S]Пропустить: "


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
rem инициализируем переменные
rem положение cygwin. Если не задано в командной строке, то берётся значение по умолчанию
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
rem название ОС. От ОС зависит, в частности, вывод недокоманды reg.
rem set OS_NAME=7
echo %OS_TITLE%
FOR /F "tokens=5" %%i IN ('systeminfo 2^>Nul ^| findstr /R /C:"Microsoft Windows"') DO SET OS_NAME=%%i
echo Windows Name: %OS_NAME%

rem количество пропускаемых строк в выводе недокоманды reg.
IF "x%OS_NAME%"=="x7" (
	SET REG_SKIP=2
)
IF "x%OS_NAME%"=="xXP" (
	SET REG_SKIP=4
)
rem ------------------------------------


rem ------------------------------------
rem добавление cygwin в путь

echo %ENV_TITLE%
echo %ENV_DESCR%
:begin_env
SET /P choice=%ENV_MK%
IF /I "x%choice%"=="xS" GOTO end_env
IF /I NOT "x%choice%"=="xA" GOTO begin_env

rem set REG_VAL=dbg
FOR /f "skip=%REG_SKIP% tokens=2*" %%i IN ('reg query HKCU\Environment /v CYGWIN_HOME 2^>Nul') DO SET REG_VAL=%%j
IF "x%REG_VAL%"=="x" (

	rem небольшая проверка на коллизии
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
	echo CYGWIN_HOME создана
	
	reg add HKCU\Environment /v CYGWIN_PATH /t REG_EXPAND_SZ /d %%CYGWIN_HOME%%\bin;%%CYGWIN_HOME%%\usr\local\bin;%%CYGWIN_HOME%%\usr\ssl\certs >Nul
	echo CYGWIN_PATH создана

	FOR /f "skip=2 tokens=2*" %%i IN ('reg query HKCU\Environment /v PATH 2^>Nul') DO SET REG_VAL=%%j
	IF "x!REG_VAL!"=="x" (
		reg add HKCU\Environment /v PATH /t REG_EXPAND_SZ /d %%CYGWIN_PATH%% /f >Nul
	) ELSE (
		reg add HKCU\Environment /v PATH /t REG_EXPAND_SZ /d !REG_VAL!;%%CYGWIN_PATH%% /f >Nul
	)
	echo пути прописаны

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
rem добавление домашней директории в /home
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
rem добавить ссылки на диски в /mnt
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