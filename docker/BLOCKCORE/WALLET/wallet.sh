echo "Blockcore Wallet // Hosting instance type: \"$1\" and version \"$2\"";

#apt-get update \
#  && apt-get install -y curl
#sudo apt-get install zip unzip

curl -Ls https://github.com/block-core/blockcore-extension/releases/download/$2/$1-$2.zip --output ./$1-$2.zip

rm -rf www
mkdir www

unzip $1-$2.zip -d ./www

echo "Unpack completed, starting docker container to serve..."

sudo docker-compose up -d
