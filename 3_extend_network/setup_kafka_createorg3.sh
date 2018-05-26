export FABRIC_CFG_PATH=`pwd`
export GOPATH=~/go
export PATH=$PATH:/Users/amb/Feina/amb/hlf/bin

# -- create channel in the orderer without TLS
docker exec cli.org1.com bash -c 'peer channel create -c testchannel -f ./channels/testchannel.tx -o orderer0.artstamper.com:7050 --logging-level DEBUG'
docker exec cli.org1.com bash -c 'mv testchannel.block channels'

# -- peers join the channel
docker exec cli.org1.com bash -c 'peer channel join -b channels/testchannel.block'
docker exec cli.org2.com bash -c 'peer channel join -b channels/testchannel.block'
docker exec cli.org3.com bash -c 'peer channel join -b channels/testchannel.block'

# -- peers update their channel with tx without TLS
docker exec cli.org1.com bash -c 'peer channel update -o orderer0.artstamper.com:7050 -c testchannel -f ./channels/peerupdate_testchannel_org1.tx'
docker exec cli.org2.com bash -c 'peer channel update -o orderer1.artstamper.com:7050 -c testchannel -f ./channels/peerupdate_testchannel_org2.tx'
docker exec cli.org3.com bash -c 'peer channel update -o orderer2.artstamper.com:7050 -c testchannel -f ./channels/peerupdate_testchannel_org3.tx'

# -- install the chainode
docker exec cli.org1.com bash -c 'peer chaincode install -p catalog -n catalog -v 0'
docker exec cli.org2.com bash -c 'peer chaincode install -p catalog -n catalog -v 0'
docker exec cli.org3.com bash -c 'peer chaincode install -p catalog -n catalog -v 0'

# -- initialize 
docker exec cli.org1.com bash -c "peer chaincode instantiate -C testchannel -n catalog -v 0 -c '{\"Args\":[]}'"

# quick test, call with org3, and get result with org1
docker exec cli.org3.com bash -c "peer chaincode invoke -C testchannel -n catalog -v 1 -c '{\"Args\":[\"register\", \"ARTX\", \"description1\", \"ipfs1\"]}'"
sleep 5
docker exec cli.org1.com bash -c "peer chaincode query -C testchannel -n catalog -v 1 -c '{\"Args\":[\"query\",\"ARTX\"]}'"  2> /dev/null
