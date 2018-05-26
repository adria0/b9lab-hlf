export FABRIC_CFG_PATH=`pwd`
export GOPATH=~/go
export PATH=$PATH:/Users/amb/Feina/amb/hlf/bin

# --log into console
# docker exec -e COLUMNS=200  -ti cli.org1.com bash

# -- to create with cryptogen
cryptogen generate --config crypto-config.kafka.yaml
cp configtx.kafka.yaml configtx.yaml

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
configtxgen -profile testchannel -outputAnchorPeersUpdate ./channels/peerupdate_testchannel_org3.tx -channelID testchannel -asOrg Org3

cp docker-compose.kafka.yaml docker-compose.yaml
docker-compose up

