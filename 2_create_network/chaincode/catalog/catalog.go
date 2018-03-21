package main

import (
	"encoding/hex"
	"encoding/json"
	"fmt"

	"github.com/golang/protobuf/proto"
	"github.com/hyperledger/fabric/core/chaincode/shim" // import for Chaincode Interface
	"github.com/hyperledger/fabric/protos/msp"
	pb "github.com/hyperledger/fabric/protos/peer" // import for peer response
)

// Defined to implement chaincode interface
type Catalog struct {
}

// Define our struct to store PCs in Blockchain, start fields upper case for JSON
type Item struct {
	ID          string // This one will be our key
	Owner       string
	Description string
	HiResIPFS   string // this will contain its status on the exchange
}

// Implement Init
func (c *Catalog) Init(stub shim.ChaincodeStubInterface) pb.Response {
	return shim.Success(nil)
}

// Implement Invoke
func (c *Catalog) Invoke(stub shim.ChaincodeStubInterface) pb.Response {

	function, args := stub.GetFunctionAndParameters() // get function name and args

	switch function {
	case "register":
		// A computer is produced and available
		return c.register(stub, args)
	case "transfer":
		// A market bought a computer
		return c.transfer(stub, args)
	case "list":
		// A market bought a computer
		return c.list(stub, args)
	default:
		return shim.Error("Available functions: register, transfer, list")
	}
}

// createPC puts an available PC in the Blockchain
func (c *Catalog) getCreatorID(stub shim.ChaincodeStubInterface) (string, error) {

	creator, err := stub.GetCreator()
	if err != nil {
		return "", err
	}
	var id msp.SerializedIdentity
	err = proto.Unmarshal(creator, &id)
	if err != nil {
		return "", err
	}
	return hex.EncodeToString(id.IdBytes), nil
}

// createPC puts an available PC in the Blockchain
func (c *Catalog) register(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	if len(args) != 3 {
		return shim.Error("createPC arguments usage: ID, Description, HiResIPFS")
	}

	id, description, hiResIPFS := args[0], args[1], args[2]
	creatorID, err := c.getCreatorID(stub)
	if err != nil {
		return shim.Error(err.Error())
	}

	// A newly created computer is available
	item := Item{
		ID:          id,
		Owner:       creatorID,
		Description: description,
		HiResIPFS:   hiResIPFS,
	}

	// Use JSON to store in the Blockchain
	itemAsBytes, err := json.Marshal(item)
	if err != nil {
		return shim.Error(err.Error())
	}

	// Use serial number as key
	err = stub.PutState(item.ID, itemAsBytes)

	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(nil)
}

// updateStatus handles sell and hand back
func (c *Catalog) transfer(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	if len(args) != 2 {
		return shim.Error("This function needs the ID, newOwner as argument")
	}

	id, newOwner := args[0], args[1]

	creatorID, err := c.getCreatorID(stub)
	if err != nil {
		return shim.Error(err.Error())
	}

	// Look for the ID
	v, err := stub.GetState(id)
	if err != nil {
		return shim.Error("Serialnumber " + id + " not found ")
	}

	// Get Information from Blockchain
	var item Item
	// Decode JSON data
	err = json.Unmarshal(v, &item)
	if err != nil {
		return shim.Error(err.Error())
	}

	if item.Owner != creatorID {
		return shim.Error("Non-owner cannot transfer item " + item.ID)
	}

	// Change the status
	item.Owner = newOwner
	// Encode JSON data
	itemAsBytes, err := json.Marshal(item)

	// Store in the Blockchain
	err = stub.PutState(item.ID, itemAsBytes)
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

// queryStock gives all stored keys in the database
func (c *Catalog) list(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	// See stub.GetStateByRange in interfaces.go
	start, end := "", ""

	if len(args) == 2 {
		start, end = args[0], args[1]
	}

	// resultIterator is a StateQueryIteratorInterface
	resultsIterator, err := stub.GetStateByRange(start, end)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	keys := " \n"
	// This interface includes HasNext,Close and Next
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		keys += queryResponse.Key + " \n"
	}

	fmt.Println(keys)

	return shim.Success([]byte(keys))
}

func main() {
	err := shim.Start(new(Catalog))
	if err != nil {
		fmt.Printf("Error starting chaincode sample: %s", err)
	}
}
