export FABRIC_CFG_PATH=`pwd`
export GOPATH=~/go
export PATH=$PATH:/Users/amb/Feina/amb/hlf/bin

# --log into console
# docker exec -e COLUMNS=200  -ti cli.org1.com bash

# -- to create with cryptogen
# cryptogen generate --config crypto-config.yaml

# -- create the genersis block
rm -rf orderer
mkdir orderer
configtxgen -profile ARTSTAMPEROrdererGenesis -outputBlock ./orderer/genesis.block

# -- create channel, and tx updates
rm -rf channels
mkdir channels
configtxgen -profile testchannel -outputCreateChannelTx ./channels/testchannel.tx -channelID testchannel
configtxgen -profile testchannel -outputAnchorPeersUpdate ./channels/peerupdate_testchannel_org1.tx -channelID testchannel -asOrg Org1
configtxgen -profile testchannel -outputAnchorPeersUpdate ./channels/peerupdate_testchannel_org2.tx -channelID testchannel -asOrg Org2

# -- execute it to update chaincode
# docker rmi --force $(docker images -q dev-peer*)

# -- create channel in the orderer without TLS
# docker exec cli.org1.com bash -c 'peer channel create -c testchannel -f ./channels/testchannel.tx -o orderer.artstamper.com:7050 --logging-level DEBUG'
# -- create channel in the orderer with TLS
docker exec cli.org1.com bash -c 'peer channel create -c testchannel -f ./channels/testchannel.tx -o orderer.artstamper.com:7050 --logging-level DEBUG --tls --cafile /etc/hyperledger/orderers/orderer.artstamper.com/msp/cacerts/ca.artstamper.com-cert.pem'
docker exec cli.org1.com bash -c 'mv testchannel.block channels'

# -- peers join the channel
docker exec cli.org1.com bash -c 'peer channel join -b channels/testchannel.block --tls --cafile /etc/hyperledger/orderers/orderer.artstamper.com/msp/cacerts/ca.artstamper.com-cert.pem'
docker exec cli.org2.com bash -c 'peer channel join -b channels/testchannel.block --tls --cafile /etc/hyperledger/orderers/orderer.artstamper.com/msp/cacerts/ca.artstamper.com-cert.pem'

# -- peers update their channel with tx without TLS
# docker exec cli.org1.com bash -c 'peer channel update -o orderer.artstamper.com:7050 -c testchannel -f ./channels/peerupdate_testchannel_org1.tx'
# docker exec cli.org2.com bash -c 'peer channel update -o orderer.artstamper.com:7050 -c testchannel -f ./channels/peerupdate_testchannel_org2.tx'
# -- peers update their channel with tx with TLS
docker exec cli.org1.com bash -c 'peer channel update -o orderer.artstamper.com:7050 -c testchannel -f ./channels/peerupdate_testchannel_org1.tx --tls --cafile /etc/hyperledger/orderers/orderer.artstamper.com/msp/cacerts/ca.artstamper.com-cert.pem'
docker exec cli.org2.com bash -c 'peer channel update -o orderer.artstamper.com:7050 -c testchannel -f ./channels/peerupdate_testchannel_org2.tx --tls --cafile /etc/hyperledger/orderers/orderer.artstamper.com/msp/cacerts/ca.artstamper.com-cert.pem'

# get libraries, if requiered
# docker exec cli.org1.com bash -c 'cd /opt/gopath/src/catalog &&  go get && cd'

# -- install the chainode
docker exec cli.org1.com bash -c 'peer chaincode install -p catalog -n catalog -v 0 --tls --cafile /etc/hyperledger/orderers/orderer.artstamper.com/msp/cacerts/ca.artstamper.com-cert.pem'
docker exec cli.org2.com bash -c 'peer chaincode install -p catalog -n catalog -v 0 --tls --cafile /etc/hyperledger/orderers/orderer.artstamper.com/msp/cacerts/ca.artstamper.com-cert.pem'

# -- initialize 
docker exec cli.org1.com bash -c "peer chaincode instantiate -C testchannel -n catalog -v 0 -c '{\"Args\":[]}' --tls true --cafile /etc/hyperledger/orderers/orderer.artstamper.com/msp/cacerts/ca.artstamper.com-cert.pem"
