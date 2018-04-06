package main

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"

	"github.com/golang/protobuf/proto"
	"github.com/hyperledger/fabric/core/chaincode/shim"
	"github.com/hyperledger/fabric/protos/msp"
	pb "github.com/hyperledger/fabric/protos/peer"
)

// Catalog contains a mapping of the commands and their handlers
type Catalog struct {
	handlers map[string]commandHandler
}

// The item entry in the catalog
type Item struct {
	ID          string // The ID of the item
	Owner       string // The owner of the item
	Description string // Desription
	HiResIPFS   string // An IPFS link to a high resolution image of asset
}

// Define commandHandler, to handle function
type commandHandler func(shim.ChaincodeStubInterface, []string) pb.Response

// NewCatalog creates a new catalog handler
func NewCatalog() *Catalog {

	c := &Catalog{}
	c.handlers = map[string]commandHandler{
		"register": c.register,
		"transfer": c.transfer,
		"list":     c.list,
		"query":    c.query,
		"whoami":   c.whoami,
	}

	return c
}

// Initialization, not too much to do!
func (c *Catalog) Init(stub shim.ChaincodeStubInterface) pb.Response {
	return shim.Success(nil)
}

// Invoke just looks for the handles, and calls the appropiate function
func (c *Catalog) Invoke(stub shim.ChaincodeStubInterface) pb.Response {

	function, args := stub.GetFunctionAndParameters() // get function name and args

	if handler, ok := c.handlers[function]; ok {
		return handler(stub, args)
	}

	availableFunctions := ""
	for function = range c.handlers {
		availableFunctions += " " + function
	}

	return shim.Error("Available functions: " + availableFunctions)

}

// getCreatorID returns the identifier of the current creator (sender of te TX)
//   we manage the hash of the entry. Of course this could be done better,
//   retrievient the public key of the certificate of the client, and then
//   hashing it
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
	idhash := sha256.Sum256(id.IdBytes)
	return hex.EncodeToString(idhash[:]), nil
}

// Register a new item in the collection
func (c *Catalog) register(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	if len(args) != 3 {
		return shim.Error("register arguments usage: ID, Description, HiResIPFS")
	}

	id, description, hiResIPFS := args[0], args[1], args[2]
	creatorID, err := c.getCreatorID(stub)
	if err != nil {
		return shim.Error(err.Error())
	}

	item := Item{
		ID:          id,
		Owner:       creatorID,
		Description: description,
		HiResIPFS:   hiResIPFS,
	}

	itemAsBytes, err := json.Marshal(item)
	if err != nil {
		return shim.Error(err.Error())
	}

	// Look for the ID
	_, err = stub.GetState(id)
	if err != nil {
		return shim.Error("Serialnumber " + id + " already exists ")
	}

	err = stub.PutState(item.ID, itemAsBytes)

	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(nil)
}

// Change the owner, checking that the current owner is the sender of the tx
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

	var item Item
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

// List items in the catalog
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

	keys := []string{}
	// This interface includes HasNext,Close and Next
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		keys = append(keys, queryResponse.Key)
	}
	res, _ := json.Marshal(keys)
	return shim.Success(res) // response info
}

// Query information about an item in the catalog
func (c *Catalog) query(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	if len(args) != 1 {
		return shim.Error("This function needs the item ID")
	}

	id := args[0]

	value, err := stub.GetState(id)
	if err != nil {
		return shim.Error("ID" + id + " not found")
	}

	return shim.Success(value) // response info
}

// whoami retrieves the current identity of the caller
func (c *Catalog) whoami(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	if len(args) != 0 {
		return shim.Error("This does not accepts arguments")
	}

	creatorID, err := c.getCreatorID(stub)
	if err != nil {
		return shim.Error(err.Error())
	}

	res, _ := json.Marshal(creatorID)
	return shim.Success(res) // response info
}

// serve
func main() {
	err := shim.Start(NewCatalog())
	if err != nil {
		fmt.Printf("Error starting chaincode sample: %s", err)
	}
}
