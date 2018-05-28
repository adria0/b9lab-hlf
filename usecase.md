# Art forgery is a major problem for the art market:

## Problem & current solutions

_Explain the problem and mention current solutions. (2 points)_

As Wikipedia describes, "Art forgery is the creating and selling of works of art
which are falsely credited to other, usually more famous artists."

There are some important factors when analyzing the problem 

- If the art is original, a tribute art or fake art
- good/bad intentions of the seller, awareness of the seller
- good/bad intentions of the seller, awareness of the issuer of a certificate of authenticity, methods used
  - Examination of the piece to determine authenticity by experts (frame, manipulations, signature, stroke style, etc...)
  - Forensic authentication (X-Ray, Carbon Dating, etc...)
  - Stadistical analisys of digital images 
- Awareness of the buyer

Usually always is expected a kind of certificate of authenticity, so it seems that this is
one of the key points to issue certificates.

In blockchain solution world there's some interesting proposals:

- https://www.verisart.com/
- https://www.creativechain.org (seems that only adds timestamps)


#### Blockchain solution 

_Describe the advantages and disadvantages of using a blockchain solution. (5 points)_

A good solution for blockchain should provide a bunch of adavntages
 
- Provides a way to identify the owner of the asset
- Provides a way to secure transfer the ownership of the asset, timestamped
- Provides a way to check the chain of transmissions, traceability
- Allows that this mechanisms can be done automatically without human interaction
- All the aftermentioned properties are provided in a way that no central authority
  can change it (in a good design when nodes are replicated over the world), that
  data cannot never be deleted (irreversebility), only appended.

Unfortunatelly, there's some disadvantages 

- Blockchain systems are hard to audit and only can be done by specialized technical
  people

- If the majority of the nodes reach concensus about creating assigning the  mona lisa
  painting certificate to themselves, is not possible to revert it in a PoA. It means
  that the incentivation for the owner of the nodes should be done in a way that prevents
  that.


#### Design a network to help the art market.

_Think about Peers, CA, Channels and Smart Contracts. Make a critical analysis. (8 points)_

A nice design for an hyperledger art market could be: 

- Network & peers
  - Create a PoR (proof of reputation, like PoA.network) network among reputated certificate of
    authenticity issuers.
  - Each issuer has its own node (x2), private key of the node should be protected by hardware security
    module
  - Orderers are being provided in the IBM Cloud
- Channels
  - There's one unique channel for all art assets
- Smartcontract & Assets
  - An simple smartcontract is made to track the ownership of the certificate. The ownership of
    the certificate means the ownership of the art piece, except in the process of its creation
    by the issuer of the certificate. 
  - The proof of possession of the certificate is made by the combination of its issuance in the
    blockchain plus the ownership of the private key. The ownership of the certificate can be
    transferred only by its ower.
  - As a proof of authentiticy, an ultra-resolution scan of a part of the art piece is done.
    In the art asset is stored the IPFS multihash of this scan, and can be public available
    or not.

