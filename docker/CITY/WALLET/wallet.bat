set INSTANCE=smartcityplatform
set VERSION=%1

echo "Blockcore Wallet // Hosting instance type: \"%INSTANCE%\" and version \"%VERSION%\"";

@REM #apt-get update \
@REM #  && apt-get install -y curl
@REM #sudo apt-get install zip unzip


powershell Invoke-WebRequest -Uri https://github.com/block-core/blockcore-extension/releases/download/%VERSION%/%INSTANCE%-%VERSION%.zip -OutFile ./%INSTANCE%-%VERSION%.zip

del www -Recurse -Force
mkdir www

powershell Expand-Archive %INSTANCE%-%VERSION%.zip -DestinationPath www

echo "Unpack completed, starting docker container to serve..."

call docker-compose -p "CITYWALLET" up -d
call docker restart city-wallet
