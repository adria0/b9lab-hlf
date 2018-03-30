echo ==== REGISTERING ====

TLSCFG="--tls --cafile /etc/hyperledger/orderers/orderer.artstamper.com/msp/cacerts/ca.artstamper.com-cert.pem"
CFG="-C testchannel -n catalog -v 0 $TLSCFG"

# Define two pieces of art to register
ARTID1=A$(date +%s)
ARTID2=B$(date +%s)

# Register this two pieces of art
docker exec cli.org1.com bash -c "peer chaincode invoke $CFG -c '{\"Args\":[\"register\", \"$ARTID1\", \"description1\", \"ipfs1\"]}'"
docker exec cli.org2.com bash -c "peer chaincode invoke $CFG -c '{\"Args\":[\"register\", \"$ARTID2\", \"description2\", \"ipfs2\"]}'"

echo ==== LIST ====

LIST=$(docker exec cli.org2.com bash -c "peer chaincode query $CFG -c '{\"Args\":[\"list\"]}'" 2> /dev/null | cut -d ' ' -f 3-)

# Wait to mine
sleep 10

echo Collection is $LIST

# ==== RETRIEVEING CLIENT IDS ====

CLIORG1ID=$(docker exec cli.org1.com bash -c "peer chaincode query $CFG -c '{\"Args\":[\"whoami\"]}' $TLSCFG" 2> /dev/null | cut -d ' ' -f 3-)
CLIORG2ID=$(docker exec cli.org2.com bash -c "peer chaincode query $CFG -c '{\"Args\":[\"whoami\"]}' $TLSCFG" 2> /dev/null | cut -d ' ' -f 3-)

echo ==== ARTID1 IS ====

docker exec cli.org1.com bash -c "peer chaincode query $CFG-c '{\"Args\":[\"query\",\"$ARTID1\"]}'"  2> /dev/null | cut -d ' ' -f 3-

echo ==== TRASFER ARTID1 FROM CLI1 TO CLI2 ====

docker exec cli.org1.com bash -c "peer chaincode invoke $CFG -c '{\"Args\":[\"transfer\",\"$ARTID1\",\"$CLIORG2ID\"]}' $TLSCFG"

# Wait to mine
sleep 10

echo ==== ARTID1 NOW IS ====

docker exec cli.org2.com bash -c "peer chaincode query $CFG '{\"Args\":[\"query\",\"$ARTID1\"]}' $TLSCFG" 2> /dev/null | cut -d ' ' -f 3-

## Inspect database
# http://localhost:5984/_utils/#_all_dbs

