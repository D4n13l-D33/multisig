// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Multisig{
    address Owner;
    address newOwner;
    uint quorum;
    uint txcount;
    address [] signers;

    struct Transaction{
        uint txId;
        string description;
        uint amount;
        address receiver;
        bool isExecuted;
        uint signerCount;

    }
    Transaction [] public alltransactions;

    mapping(uint => Transaction) transactions;

    mapping(address => bool) validSigner;  

    mapping(uint => mapping(address => bool)) hasSigned;

    event TransactionCreated(uint _TxID, address _creator);
    event TransactionApproved(uint _TxID, address _signer);
    event TransactionExecuted(uint _TxID, uint amount, address receiver);
    event OwnershipTransferred(address _newOwner);

    constructor(address [] memory _signers, uint _quorum){
        Owner = msg.sender;
        quorum = _quorum;
        signers = _signers;

        for(uint i; i<signers.length; i++){
            validSigner[signers[i]] = true;
        }
    }

    function initiateTransaction (uint _amount, string calldata _description, address _receiver) external {
        require(msg.sender != address(0));
        require (validSigner[msg.sender]==true, "Not a Valid Signer");
        require (_amount > 0, "No Zero Value allowed ");
        uint tnxID = txcount + 1;

        Transaction storage tnx = transactions[tnxID]; 

        tnx.amount = _amount;
        tnx.description = _description;
        tnx.receiver = _receiver;
        tnx.txId = tnxID;
        tnx.signerCount += 1;

        alltransactions.push(tnx);

        txcount = txcount + 1;

        hasSigned[tnxID][msg.sender] = true;

        emit TransactionCreated(tnxID, msg.sender);
    }

    function approveTransaction (uint _txID) external {
        require(msg.sender != address(0));

        require (validSigner[msg.sender]==true, "Not a Valid Signer");

        require (_txID <= txcount, "Invalid Transaction ID");

        require(!hasSigned[_txID][msg.sender], "Can't Sign Twice");

        require(transactions[_txID].isExecuted, "Transaction already executed");

        Transaction storage tnx = transactions[_txID];

        tnx.signerCount = tnx.signerCount + 1;

        hasSigned[_txID][msg.sender] = true;

        emit TransactionApproved(_txID, msg.sender);

        require (address(this).balance >= tnx.amount);

        if(tnx.signerCount == quorum){
            payable (tnx.receiver).transfer(tnx.amount);

            emit TransactionExecuted(_txID, tnx.amount, tnx.receiver);
        }

    }

    function addSigner(address _newSigner) external {
        onlyOwner();

        require(!validSigner[_newSigner], "Signer already exists");
        
        validSigner[_newSigner] = true;

        signers.push(_newSigner);
    }

    function onlyOwner() internal view {
        require(msg.sender == Owner, "You are not the owner");
    }

    function transferOwnership(address _newOwner) external {
        onlyOwner();

        newOwner = _newOwner;
       
    }

    function claimOwnership () external{
        require(msg.sender == newOwner, "Not New Owner");

        Owner = msg.sender;

        emit OwnershipTransferred(newOwner);

    }
}