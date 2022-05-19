INSTANCE="smartcityplatform"
VERSION=$1

echo "Blockcore Wallet // Hosting instance type: \"$INSTANCE\" and version \"$VERSION\"";

#apt-get update \
#  && apt-get install -y curl
#sudo apt-get install zip unzip

curl -Ls https://github.com/block-core/blockcore-extension/releases/download/$VERSION/$INSTANCE-$VERSION.zip --output ./$INSTANCE-$VERSION.zip

rm -rf www
mkdir www

unzip $INSTANCE-$VERSION.zip -d ./www

echo "Unpack completed, starting docker container to serve..."

sudo docker-compose -p "CITYWALLET" up -d
