const hfc = require('fabric-client');

const client = new hfc();

const responseInspect = function(results) {
    const proposalResponses = results[0];
    const proposal = results[1];
    const header = results[2];
  
    return false;
  };
  
  
async function init(options) {
  
    const wallet = await hfc.newDefaultKeyValueStore({ path: options.wallet_path })
    client.setStateStore(wallet);
  
    const user = await client.getUserContext(options.user_id, true);
   
    if(typeof user === "undefined" || !user.isEnrolled())
       throw "User not enrolled";
    
    let channel
    try {
      channel = client.newChannel(options.channel_id);
      const peer = client.newPeer(options.peer_url);
      channel.addPeer(peer);
      channel.addOrderer(client.newOrderer(options.orderer_url));
    } catch(e) { // channel already exists
      channel = client.getChannel(options.channel_id);
    }
  
    return channel
  }
  
exports.sendTransaction= async function (options, func, args) {
     
    const channel = await init(options)
  
    const proposal = {
        targets: null,
        chaincodeId: options.chaincode_id,
        fcn: func,
        args: args,
        chainId: options.channel_id,
        txId: client.newTransactionID()
    };
    
    const responses =  await channel.sendTransactionProposal(proposal);
    const response = responses[0] // proposalresponse
    if (!response
        || response.length == 0
        || !(response[0].response)
        || response[0].response.status !== 200) {
          throw "Response is bad ";
    }

    const transaction = {
       proposalResponses: responses[0],
       proposal: responses[1],
       header: responses[2]
    };
  
    return await channel.sendTransaction(transaction);

};

exports.query = async function (options, func, args) {
     
 const channel = await init(options)

 const request = {
    targets: null,
    chaincodeId: options.chaincode_id,
    fcn: func,
    args: args,
    chainId: options.channel_id,
    txId: client.newTransactionID()
  }

  const responses = await channel.queryByChaincode(request);
  return responses[0].toString('utf8')

}