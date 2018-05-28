# Part 1. Art forgery is a major problem for the art market:

## Problem & current solutions

_Explain the problem and mention current solutions. (2 points)_

As Wikipedia describes, "Art forgery is the creating and selling of works of art
which are falsely credited to other, usually more famous artists."

There are some important factors when analyzing the problem 

- If the art is original, a tribute art or fake art
- good/bad intentions of the seller, awareness of the seller
- good/bad intentions of the seller, awareness of the issuer of a certificate of authenticity, methods used like
  - Examination of the piece to determine authenticity by experts (frame, manipulations, signature, stroke style, etc...)
  - Forensic authentication (X-Ray, Carbon Dating, etc...)
  - Statistical analysis of digital images 
- Awareness of the buyer

Usually is always expected a kind of certificate of authenticity, so it seems that this is
one of the key points to issue certificates for art assets.

In blockchain solution world there are some interesting proposals:

- https://www.verisart.com/
- https://www.creativechain.org (seems that only adds timestamps)


#### Blockchain solution 

_Describe the advantages and disadvantages of using a blockchain solution. (5 points)_

A good solution for blockchain should provide a bunch of advantages
 
- Provides a way to identify the owner of the asset
- Provides a way to securely transfer the ownership of the asset, timestamped
- Provides a way to check the chain of transmissions, traceability
- Allows that operations can be done automatically without human interaction
- All the aftermentioned properties are provided in a way that no central authority
  can change it (in a good design when nodes are replicated over the world), that
  data can never be deleted (irreversibility), only appended.

Unfortunately, there are some disadvantages 

- Blockchain systems are hard to audit and only can be done by specialized technical
  people

- If the majority of the nodes reaches consensus about assigning the Mona Lisa
  painting certificate to themselves is not possible to revert it in a PoA. It means
  that the incentives for the owner of the nodes should be designed in a way that prevents
  that.


#### Design a network to help the art market.

_Think about Peers, CA, Channels and Smart Contracts. Make a critical analysis. (8 points)_

A nice design for an hyperledger art market could be: 

- CAs
  - Certificates used should be issued from CAs issuing qualified certificates,
    eIDAS-certified or an equivalent level of trust, acting as a trusted three party.
- Network & peers
  - Create a PoR (proof of reputation, like PoA.network) network among well known certificate of
    authenticity issuers.
  - Each issuer has its own node (x2), private key of the node should be protected by hardware security
    module
  - Orderers are being provided in the IBM Cloud
- Channels
  - There's one unique channel for all art assets
- Smartcontract & Assets
  - An simple smartcontract is made to track the ownership of the certificate. The ownership of
    the certificate means to be the owner of the art piece, except in the process of its creation
    by the issuer of the certificate. 
  - The proof of possession of the art asset is made by the combination of its issuance in the
    blockchain plus the ownership of the private key. The ownership of the asset can be
    transferred only by its ower.
  - As a proof of authenticity, an ultra-resolution microphotography of a part of the art piece is done.
    In the art asset is stored the IPFS multihash of this scan, and can be public available
    or not.
  - Assets are transferred via HyperLedger Zero-Knowledge Asset Transfer mechanism (see https://www.ibm.com/developerworks/cloud/library/cl-blockchain-private-confidential-transactions-hyperledger-fabric-zero-knowledge-proof/index.html)


