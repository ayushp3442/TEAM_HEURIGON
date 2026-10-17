@REM ----------------------------------------------------------------------------
@REM Licensed to the Apache Software Foundation (ASF)
@REM Maven Wrapper startup batch script
@REM ----------------------------------------------------------------------------
@IF "%__MVNW_ARG0_NAME__%"=="" (SET __MVNW_ARG0_NAME__=%~nx0)
@SET %%ENV_VAR%%=
@SETLOCAL

@SET MAVEN_PROJECTBASEDIR=%MAVEN_BASEDIR%
@IF NOT "%MAVEN_PROJECTBASEDIR%"=="" GOTO endDetectBaseDir

@SET EXEC_DIR=%CD%
@SET WDIR=%EXEC_DIR%
:findBaseDir
@IF EXIST "%WDIR%"\.mvn GOTO baseDirFound
@cd ..
@SET WDIR=%CD%
@IF NOT "%WDIR%"=="%EXEC_DIR%" GOTO findBaseDir
@SET MAVEN_PROJECTBASEDIR=%EXEC_DIR%
@GOTO endDetectBaseDir
:baseDirFound
@SET MAVEN_PROJECTBASEDIR=%WDIR%
:endDetectBaseDir
@cd "%EXEC_DIR%"

@SET MVNW_VERBOSE=false
@IF NOT "%MVNW_VERBOSE%"=="true" @ECHO off

@SET WRAPPER_JAR="%MAVEN_PROJECTBASEDIR%\.mvn\wrapper\maven-wrapper.jar"
@SET WRAPPER_LAUNCHER=org.apache.maven.wrapper.MavenWrapperMain

@SET DOWNLOAD_URL="https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.3.2/maven-wrapper-3.3.2.jar"

FOR /F "usebackq tokens=1,2 delims==" %%A IN ("%MAVEN_PROJECTBASEDIR%\.mvn\wrapper\maven-wrapper.properties") DO (
    IF "%%A"=="wrapperUrl" SET DOWNLOAD_URL=%%B
)

@IF EXIST %WRAPPER_JAR% (
    @IF "%MVNW_VERBOSE%" == "true" (
        @ECHO Found %WRAPPER_JAR%
    )
) ELSE (
    @IF NOT "%MVNW_REPOURL%" == "" (
        @SET DOWNLOAD_URL="%MVNW_REPOURL%/org/apache/maven/wrapper/maven-wrapper/3.3.2/maven-wrapper-3.3.2.jar"
    )
    @IF "%MVNW_VERBOSE%" == "true" (
        @ECHO Downloading from: %DOWNLOAD_URL%
    )

    powershell -Command "&{"^
        "$webclient = new-object System.Net.WebClient;"^
        "if (-not ([string]::IsNullOrEmpty('%MVNW_USERNAME%') -and [string]::IsNullOrEmpty('%MVNW_PASSWORD%'))) {"^
        "$webclient.Credentials = new-object System.Net.NetworkCredential('%MVNW_USERNAME%', '%MVNW_PASSWORD%');"^
        "}"^
        "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $webclient.DownloadFile('%DOWNLOAD_URL%', '%WRAPPER_JAR%')"^
        "}"
    if "%ERRORLEVEL%"=="0" GOTO :downloadedWrapperJar
    echo Cannot download %WRAPPER_JAR%
    exit /B 1
    :downloadedWrapperJar
)

@SET JAVA_HOME_DETECTED=%JAVA_HOME%
@IF "%JAVA_HOME_DETECTED%"=="" (
    FOR /F "usebackq tokens=*" %%F IN (`where java 2^>nul`) DO (
        SET "JAVA_HOME_DETECTED=%%~dpF.."
        GOTO :foundJava
    )
    :foundJava
)

@SET JAVA_EXE="%JAVA_HOME_DETECTED%\bin\java.exe"
@IF NOT EXIST %JAVA_EXE% SET "JAVA_EXE=java"

%JAVA_EXE% ^
  -classpath %WRAPPER_JAR% ^
  "-Dmaven.multiModuleProjectDirectory=%MAVEN_PROJECTBASEDIR%" ^
  %WRAPPER_LAUNCHER% %MAVEN_CONFIG% %*
if ERRORLEVEL 1 goto error
goto end
:error
SET ERROR_CODE=%ERRORLEVEL%
:end
@ENDLOCAL & SET ERROR_CODE=%ERROR_CODE%
exit /B %ERROR_CODE%
