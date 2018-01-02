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
SET CYG_DESCR=Не указан путь к месту установки cygwin. Укажите его, или будет использован 
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

SET CHANGES=Запрошенные изменения.

SET END_TITLE=0. Послеустановочная настройка Cygwin.
SET END_DESCR=Сохранить изменения?
SET END="Действия: [Y]Да/[N]Нет: "

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
rem название ОС. От ОС зависит, в частности, вывод недокоманды reg.
rem set OS_NAME=7
echo %OS_TITLE%
FOR /F "tokens=5" %%i IN ('systeminfo 2^>Nul ^| findstr /R /C:"Windows"') DO SET OS_NAME=%%i
echo Windows Name: %OS_NAME%

rem количество пропускаемых строк в выводе недокоманды reg.
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
rem инициализируем переменные
rem положение cygwin.
rem Если не задано в командной строке, то берётся из реестра (если есть) или по умолчанию
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
rem добавление ссылок на диски в /mnt
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
	echo Переменные окружения:
	rem SET MY_OUT=CYGWIN_HOME=!LOCAL_CYGWIN!
	echo 	Добавить CYGWIN_HOME=%LOCAL_CYGWIN%
	echo 	Добавить CYGWIN_PATH=%%CYGWIN_HOME%%\bin;%%CYGWIN_HOME%%\usr\local\bin;%%CYGWIN_HOME%%\usr\ssl\certs
	FOR /f "skip=2 tokens=2*" %%i IN ('reg query HKCU\Environment /v PATH 2^>Nul') DO SET REG_VAL=%%j
	IF "x!REG_VAL!"=="x" (
		SET MY_OUT=PATH=%CYGWIN_PATH%
		echo 	Добавить PATH=%CYGWIN_PATH%
	) ELSE (
		SET MY_OUT=PATH=!REG_VAL!%%CYGWIN_PATH%%
		echo 	Добавить PATH=!REG_VAL!%%CYGWIN_PATH%%
	)
	IF NOT "x!HOME_UPD!"=="x" (
		echo 	Добавить HOME=%%USERPROFILE%%
	)
) ELSE (
	IF NOT "x!HOME_UPD!"=="x" (
		echo Переменные окружения:
		echo 	Добавить HOME=%%USERPROFILE%%
	)
)

IF "x!HOME_UPD!"=="xNew" (
	echo Домашняя директория:
	echo 	Создать символьную ссылку [%USR_HOME%], указывающую на [%HOME%]
)
IF "x!HOME_UPD!"=="xRm" (
	echo Домашняя директория:
	rem Проверяем, чем является сущенствующая домашняя директория: ссылкой или директорией
	!BASH! -c " [ -L %USR_HOME% ] || return_error_to_cmd " >Nul 2>&1
	IF ERRORLEVEL 1 GOTO home_upd_dir
	echo 	Удалить символьную ссылку [%USR_HOME%]
	GOTO home_upd_end
	:home_upd_dir
	echo 	Удалить директорию [%USR_HOME%] со всем её содержимым
	:home_upd_end
	echo 	Создать символьную ссылку [%USR_HOME%], указывающую на [%HOME%]
)
IF "x!HOME_UPD!"=="xMv" (
	echo Домашняя директория:
	echo 	Переименовать [%USR_HOME%] в
	!BASH! -c 'echo -e "\\\\t\\\\t[%USR_HOME%-`date \+\"%%s\"`]" '
	echo 	Создать символьную ссылку [%USR_HOME%], указывающую на [%HOME%]
)

IF "x!MNT_UPD!"=="xE" (
	echo Логические диски:
	echo Добавить
	!BASH! -c 'ls /cygdrive/ | sed -e "s/.*/\/mnt\/\0/"'
)
IF "x!MNT_UPD!"=="xA" (
	echo Логические диски:
	echo Добавить
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
	echo Переменная CYGWIN_HOME создана

	reg add HKCU\Environment /v CYGWIN_PATH /t REG_EXPAND_SZ /d %%CYGWIN_HOME%%\bin;%%CYGWIN_HOME%%\usr\local\bin;%%CYGWIN_HOME%%\usr\ssl\certs >Nul
	echo Переменная CYGWIN_PATH создана

	FOR /f "skip=2 tokens=2*" %%i IN ('reg query HKCU\Environment /v PATH 2^>Nul') DO SET REG_VAL=%%j
	IF "x!REG_VAL!"=="x" (
		reg add HKCU\Environment /v PATH /t REG_EXPAND_SZ /d %%CYGWIN_PATH%% /f >Nul
		echo Переменная PATH создана
	) ELSE (
		reg add HKCU\Environment /v PATH /t REG_EXPAND_SZ /d !REG_VAL!;%%CYGWIN_PATH%% /f >Nul
		echo Переменная PATH обновлена
	)
)
IF NOT "x!HOME_UPD!"=="x" (
	reg add HKCU\Environment /v HOME /t REG_EXPAND_SZ /d %%USERPROFILE%% /f >Nul
	echo Переменная HOME создана
)

IF "x!HOME_UPD!"=="xNew" (
	!BASH! -c 'ln -s "${HOME}/" /home/'
	echo Ссылка на домашнюю директорию создана
)
IF "x!HOME_UPD!"=="xRm" (
	!BASH! -c " [ -L %USR_HOME% ] && rm -f %USR_HOME% || rm -rf %USR_HOME% ; "
	IF ERRORLEVEL 1 echo error rm home dir
	echo Удаление домашней директории завершено
	!BASH! -c 'ln -s "${HOME}/" /home/'
	echo Ссылка на домашнюю директорию создана
)
IF "x!HOME_UPD!"=="xMv" (
	!BASH! -c "mv -f %USR_HOME% %USR_HOME%-`date \+\"%%s\"` "
	echo Переименование домашней директории завершено
	!BASH! -c 'ln -s "${HOME}/" /home/'
	echo Ссылка на домашнюю директорию создана
)

IF "x!MNT_UPD!"=="xE" (
	!BASH! -c "mkdir -p /mnt; ln -s /cygdrive/* /mnt/"
	echo Диски добавлены
)
IF "x!MNT_UPD!"=="xA" (
	!BASH! -c "mkdir -p /mnt; ln -s /cygdrive/{c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z} /mnt/"
	echo Диски добавлены
)

set PATH=%tmp_path%
set HOME=%tmp_home%

:end