@ECHO OFF

IF EXIST dfs-result-list.txt DEL /F /Q dfs-result-list.txt >NUL 2>NUL

ECHO.

IF NOT EXIST "C:\Windows\System32\dfsutil.exe" SET FILE=dfsutil.exe && SET FOLDER=C:\Windows\System32\ && GOTO ERROR1
IF NOT EXIST "C:\Windows\System32\dfscmd.exe" SET FILE=dfscmd.exe && SET FOLDER=C:\Windows\System32\ && GOTO ERROR1
IF NOT EXIST "C:\Windows\dfsradmin.exe" SET FILE=dfsradmin.exe && SET FOLDER=C:\Windows\ && GOTO ERROR1

IF NOT EXIST "dfs-decomm-servers-list.txt" SET FILE=dfs-decomm-servers-list.txt&& GOTO ERROR2

FOR %%a IN ("dfs-decomm-servers-list.txt") DO IF %%~za LSS 3 SET FILE=dfs-decomm-servers-list.txt&& GOTO ERROR3

FOR /F %%i IN (dfs-decomm-servers-list.txt) DO (
PING -n 1 %%i | FINDSTR /I Pinging>NUL 2>NUL || SET WRONGHOST=%%i
IF DEFINED WRONGHOST GOTO ERROR4
)


:DFSN

ECHO.
ECHO === CHECKING DFS NAMESPACES ===
ECHO.>>dfs-result-list.txt
ECHO === DFS NAMESPACES ===>>dfs-result-list.txt
ECHO.

FOR /F %%a IN (dfs-decomm-servers-list.txt) DO (
ECHO.
ECHO SEARCHING FOR SERVER %%a IN DFSN...
ECHO.>>dfs-result-list.txt
ECHO %%a>>dfs-result-list.txt
ECHO.>>dfs-result-list.txt
ECHO.
FOR /F %%i IN ('dfsutil domain \\%USERDNSDOMAIN% ^| FINDSTR /V "Roots Done" ^| FINDSTR /V /R /C:"^[ ]" /C:"^$"') DO (
FOR /F "TOKENS=3" %%j IN ('dfscmd /view \\%USERDNSDOMAIN%\%%i /batch ^| FINDSTR /V /I "completed DFSFolderLink" ^| FINDSTR /V /I /C:"REM BATCH" /V /I /C:"REM DFSCMD" ^| FINDSTR /V /R /C:"^[ ]" /C:"^$" ^| SORT ^| FINDSTR /I %%a') DO (
ECHO %%~j
ECHO %%~j>>dfs-result-list.txt
)
)
)


:DFSR

ECHO.
ECHO.
ECHO === CHECKING DFS REPLICATIONS ===
ECHO.>>dfs-result-list.txt
ECHO.>>dfs-result-list.txt
ECHO === DFS REPLICATIONS ===>>dfs-result-list.txt
ECHO.

FOR /F %%a IN (dfs-decomm-servers-list.txt) DO (
ECHO.
ECHO SEARCHING FOR SERVER %%a IN DFSR...
ECHO.>>dfs-result-list.txt
ECHO %%a>>dfs-result-list.txt
ECHO.>>dfs-result-list.txt
ECHO.
FOR /F %%i IN ('dfsradmin rg list /Attr:RgName ^| FINDSTR /V "RgName Command Domain" ^| FINDSTR /V /R /C:"^[ ]" /C:"^$"') DO (
FOR /F %%j IN ('dfsradmin mem list /RgName:"%%i" /attr:MemName ^| FINDSTR /V /I "MemName completed" ^| FINDSTR /V /R /C:"^[ ]" /C:"^$" ^| FINDSTR /I %%a') DO (
ECHO %%i
ECHO %%i>>dfs-result-list.txt
)
)
)

ECHO.
ECHO END OF SEARCHING IN DFSN/DFSR STRUCTURE

GOTO END



:ERROR1

ECHO ================================================================
ECHO TOOL %FILE% IS MISSING IN %FOLDER%
ECHO PLEASE ENSURE THAT "DFS Management Tools" ARE PROPERLY INSTALLED
ECHO ================================================================
GOTO END

:ERROR2

ECHO ================================================================
ECHO FILE %FILE% IS MISSING IN THE CURRENT DIRECTORY
ECHO IT NEEDS TO EXIST AND CONTAIN DECOMISSIONED SERVER(S) NAME(S)
ECHO ================================================================
GOTO END

:ERROR3

ECHO ================================================================
ECHO FILE %FILE% SEEMS TO BE EMPTY
ECHO PLEASE ENTER THE NAMES OF DECOMMISSIONED SERVERS THERE
ECHO ================================================================
GOTO END

:ERROR4

ECHO ================================================================
ECHO PLEASE CHECK %WRONGHOST% SERVER NAME SPELLING IN THE TXT LIST
ECHO ================================================================
SET WRONGHOST=
GOTO END


:END

ECHO.>dfs-decomm-servers-list.txt

ECHO.
ECHO PRESS ANY KEY TO EXIT THE SCRIPT
ECHO.

PAUSE>NUL

