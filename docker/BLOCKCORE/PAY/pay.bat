set INSTANCE=blockcore
set VERSION=%1

echo "Blockcore Pay // Hosting instance type: \"%INSTANCE%\" and version \"%VERSION%\"";

@REM #apt-get update \
@REM #  && apt-get install -y curl
@REM #sudo apt-get install zip unzip

@REM powershell Invoke-WebRequest -Uri https://github.com/block-core/blockcore-extension/releases/download/%VERSION%/%INSTANCE%-%VERSION%.zip -OutFile ./%INSTANCE%-%VERSION%.zip

@REM powershell Remove-Item ".\www" -Recurse -Force
@REM mkdir www

@REM powershell Expand-Archive %INSTANCE%-%VERSION%.zip -DestinationPath www

@REM echo "Unpack completed, starting docker container to serve..."

call docker-compose -p "BLOCKCOREPAY" up -d
call docker restart blockcore-pay
