export FABRIC_CFG_PATH=`pwd`

# rm -rf chaincode channels crypto-config orderer

# -- to create with cryptogen
# cryptogen generate --config crypto-config.yaml

# -- to create with fabric-ca-cryptogen
# docker-compose up
# rm -rf crypto-config
# ./fabric-ca-cryptogen.sh
# rm `find crypto-config -name "*intermediate*"`


rm -rf orderer
mkdir orderer
configtxgen -profile ARTSTAMPEROrdererGenesis -outputBlock ./orderer/genesis.block

rm -rf channels
mkdir channels
configtxgen -profile testchannel -outputCreateChannelTx ./channels/testchannel.tx -channelID testchannel
configtxgen -profile testchannel -outputAnchorPeersUpdate ./channels/peerupdate_testchannel_org1.tx -channelID testchannel -asOrg Org1
configtxgen -profile testchannel -outputAnchorPeersUpdate ./channels/peerupdate_testchannel_org2.tx -channelID testchannel -asOrg Org2

docker rmi --force $(docker images -q dev-peer*)

docker exec cli.org1.com bash -c 'peer channel create -c testchannel -f ./channels/testchannel.tx -o orderer.artstamper.com:7050 --logging-level DEBUG'
docker exec cli.org1.com bash -c 'mv testchannel.block channels'

docker exec cli.org1.com bash -c 'peer channel join -b channels/testchannel.block'
docker exec cli.org2.com bash -c 'peer channel join -b channels/testchannel.block'

docker exec cli.org1.com bash -c 'peer channel update -o orderer.artstamper.com:7050 -c testchannel -f ./channels/peerupdate_testchannel_org1.tx'
docker exec cli.org2.com bash -c 'peer channel update -o orderer.artstamper.com:7050 -c testchannel -f ./channels/peerupdate_testchannel_org2.tx'

docker exec cli.org1.com bash -c 'cd /opt/gopath/src/catalog &&  go get && cd'

docker exec cli.org1.com bash -c 'peer chaincode install -p catalog -n catalog -v 0'
docker exec cli.org2.com bash -c 'peer chaincode install -p catalog -n catalog -v 0'

docker exec cli.org1.com bash -c "peer chaincode instantiate -C testchannel -n catalog -v 0 -c '{\"Args\":[]}'"

# http://localhost:5984/_utils/#_all_dbs
