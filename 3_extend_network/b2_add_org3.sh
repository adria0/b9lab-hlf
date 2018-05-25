# info taken from https://www.youtube.com/watch?v=DKuGU5CYV_E

# generate the org3, this will update the crypto-config folder
cryptogen generate --config crypto-config.org3.yaml

# generate configuration material for the org3
cp configtx.org3.yaml configtx.yaml
configtxgen -printOrg Org3 > orderer/org3.json

# restart docker
docker-compose stop
docker-compose start

# read the current configuration, convert from Protocol Buffer to JSON, extract the configuration part
docker exec cli.org1.com bash -c 'peer channel fetch config ./orderer/config_block.pb -o orderer.artstamper.com:7050 -c testchannel' 
curl -X POST --data-binary @orderer/config_block.pb http://127.0.0.1:7059/protolator/decode/common.Block | jq . > orderer/config_block.json
jq .data.data[0].payload.data.config orderer/config_block.json>  orderer/config.json

# append the new org3 configuration to the current configuration
jq -s '.[0] * {"channel_group":{"groups":{"Application": {"groups" : {"Org3MSP":.[1] }}}}}' orderer/config.json orderer/org3.json > orderer/config_with_org3.json

# encode to Protocol Buffer the new configuration
curl -X POST --data-binary @orderer/config.json http://127.0.0.1:7059/protolator/encode/common.Config > orderer/config.pb
curl -X POST --data-binary @orderer/config_with_org3.json http://127.0.0.1:7059/protolator/encode/common.Config > orderer/config_with_org3.pb

# compute the diff with the current configutation
curl -X POST -F channel=testchannel -F original=@orderer/config.pb -F updated=@orderer/config_with_org3.pb http://127.0.0.1:7059/configtxlator/compute/update-from-configs > orderer/config_update.pb
curl -X POST --data-binary @orderer/config_update.pb http://127.0.0.1:7059/protolator/decode/common.ConfigUpdate > orderer/config_update.json

# wrap the configuration diff within a Protocol Buffer message
echo '{"payload":{"header":{"channel_header":{"channel_id":"testchannel", "type":2}},"data":{"config_update":'$(cat orderer/config_update.json)'}}}' | jq . > orderer/config_update_in_envelope.json
curl -X POST --data-binary @orderer/config_update_in_envelope.json http://127.0.0.1:7059/protolator/encode/common.Envelope > orderer/config_update_in_envelope.pb

# sign the config update, and send it to the orderer
docker exec cli.org1.com bash -c 'peer channel signconfigtx -f ./orderer/config_update_in_envelope.pb'
docker exec cli.org2.com bash -c 'peer channel update -o orderer.artstamper.com:7050 -c testchannel -f ./orderer/config_update_in_envelope.pb'

exit

# fetch the channel in the orderer and join all peers
docker exec cli.org3.com bash -c 'peer channel fetch 0 mychannel.block -c testchannel -o orderer.artstamper.com:7050'
docker exec cli.org3.com bash -c 'CORE_PEER_ADDRESS=peer0.org3.com:7051 peer channel join -b mychannel.block'
docker exec cli.org3.com bash -c 'CORE_PEER_ADDRESS=peer1.org3.com:7051 peer channel join -b mychannel.block'

# install the chaincode in the new org
docker exec cli.org3.com bash -c 'peer chaincode install -p catalog -n catalog -v 0'

# quick test, call with org3, and get result with org1
docker exec cli.org3.com bash -c "peer chaincode invoke -C testchannel -n catalog -v 0 -c '{\"Args\":[\"register\", \"ART1\", \"description1\", \"ipfs1\"]}'"
docker exec cli.org1.com bash -c "peer chaincode query -C testchannel -n catalog -v 0 -c '{\"Args\":[\"query\",\"ART1\"]}'"  2> /dev/null




