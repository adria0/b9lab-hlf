docker-compose down
rm -rf fabric-ca-client fabric-ca-server crypto-config channels orderer
cp configtx.org2.yaml configtx.yaml
docker system prune
docker rmi --force $(docker images -q dev-peer*)
