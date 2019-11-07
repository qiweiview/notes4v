# Windows启动脚本

```
@echo off

setlocal
set bin=%~dp0%..\bin
set log=%~dp0%..\log
set conf=%~dp0%..\conf\conf.yml
set lib=%~dp0%..\lib\soldier_client-1.0-SNAPSHOT-jar-with-dependencies.jar


echo %bin%
echo %log%
echo %conf%
echo %lib%



set JAVA_HOME=%JAVA_HOME:"=%

if not exist "%JAVA_HOME%"\bin\java.exe (
  echo Error: JAVA_HOME is incorrectly set.
  goto :eof
)

set JAVA="%JAVA_HOME%"\bin\java


call %JAVA% -Xms16m -Xmx32m -jar %lib% %conf% %log% 
endlocal
pause
```
