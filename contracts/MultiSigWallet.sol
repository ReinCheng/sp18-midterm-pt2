pragma solidity ^0.4.15;

contract MultiSigWallet {
    address private _owner;
    mapping(address => uint8) private _owners;

    mapping (uint => Transaction) private _transactions;
    uint[] private _pendingTransactions;

    // auto incrememnting transaction ID
    uint private _transactionIndex;
    // constant: we need x amount of signatures to sign Transaction
    uint constant MIN_SIGNATURES = 2;

    struct Transaction {
        address source;
        address destination;
        uint value;
        //add how many people signed and who
        uint signatureCount;
        //need to keep record of who signed
        mapping (address => uint8) signatures;
    }

    modifier isOwner() {
        require(msg.sender == _owner);
        _;
    }

    modifier validOwner() {
        require(msg.sender == _owner || _owners[msg.sender] == 1);
        _;
    }

    /// @dev logged events
    event DepositFunds(address source, uint amount);
    /// @dev full sequence of the transaction event logged
    event TransactionCreated(address source, address destination, uint value, uint transactionID);
    event TransactionCompleted(address source, address destination, uint value, uint transactionID);
    /// @dev keeps track of who is signing the transactions
    event TransactionSigned(address by, uint transactionID);


    /// @dev Contract constructor sets initial owners
    function MultiSigWallet() public {
        _owner = msg.sender;
    }

    /// @dev add new owner to have access, enables the ability to create more than one owner to manage the wallet
    function addOwner(address newOwner) isOwner public {
      //YOUR CODE HERE
      _owners[newOwner] = 1;
    }

    /// @dev remove suspicious owners
    function removeOwner(address existingOwner) isOwner public {
      //YOUR CODE HERE
      _owners[existingOwner] = 0;
    }

    /// @dev Fallback function, which accepts ether when sent to contract
    function () public payable {
        DepositFunds(msg.sender, msg.value);
    }

    function withdraw(uint amount) public {
      require(address(this).balance >= value);
      //YOUR CODE HERE
      msg.sender.transfer(amount); //not quite sure what to do here

    }

    /// @dev Send ether to specific a transaction
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    ///
    /// Start by creating your transaction. Since we defined it as a struct,
    /// we need to define it in a memory context. Update the member attributes.
    ///
    /// note, keep transactionID updated
    function transferTo(address destination, uint value) validOwner public {
      require(address(this).balance >= value);
      //YOUR CODE HERE
      _transactionIndex++;

      //create the transaction
      //YOUR CODE HERE
      _transactions[_transactionIndex] = Transaction(msg.sender, destination, value, 0);
      _pendingTransactions.push(_transactionIndex);


      //add transaction to the data structures
      //YOUR CODE HERE
      _pendingTransactions.push(_transactionIndex);


      //log that the transaction was created to a specific address
      //YOUR CODE HERE
      TransactionCreated(msg.sender, destination, value, _transactionIndex);
    }

    //returns pending transcations
    function getPendingTransactions() constant validOwner public returns (uint[]) {
      //YOUR CODE HERE
      return _pendingTransactions;
    }

    /// @dev Allows an owner to confirm a transaction.
    /// @param transactionId Transaction ID.
    /// Sign and Execute transaction.
    function signTransaction(uint transactionID) validOwner public {
      //Use Transaction Structure. Above in TransferTo function, because
      //we created the structure, we had to specify the keyword memory.
      //Now, we are pulling in the structure from a storage mechanism
      //Basically, 'storage' will stop the EVM from duplicating the actual
      //object, and instead will reference it directly.

      //Create variable transaction using storage (which creates a reference point)
      //YOUR CODE HERE
      Transaction storage transaction = _transactions[transactionId];

      // Transaction must exist, note: use require(), but can't do require(transaction), .
      //YOUR CODE HERE
      require(transaction.source != address(0));

      // Creator cannot sign the transaction, use require()
      //YOUR CODE HERE
      require(msg.sender != transaction.source);

      // Cannot sign a transaction more than once, use require()
      //YOUR CODE HERE
      require(transaction.signatures[msg.sender] == 0);

      // assign the transaction = 1, so that when the function is called again it will fail
      //YOUR CODE HERE
      transaction.signatures[msg.sender] = 1;


      // increment signatureCount
      //YOUR CODE HERE
      transaction.signatureCount++;


      // log transaction
      //YOUR CODE HERE
      TransactionSigned(msg.sender, transactionId);


      //  check to see if transaction has enough signatures so that it can actually be completed
      // if true, make the transaction. Don't forget to log the transaction was completed.
      if (transaction.signatureCount >= MIN_SIGNATURES) {
        require(address(this).balance >= transaction.value); //validate transaction
        //YOUR CODE HERE
        transaction.destination.transfer(transaction.value);

        //log that the transaction was complete
        //YOUR CODE HERE
        TransactionCompleted(transaction.source, transaction.destination, transaction.value, transactionId);

        //end with a call to deleteTransaction
        deleteTransaction(transactionId);
      }
    }

    /// @dev clean up function
    function deleteTransaction(uint transactionId) validOwner public {
      uint8 replace = 0;
      for(uint i = 0; i < _pendingTransactions.length; i++) {
        if (1 == replace) {
          _pendingTransactions[i-1] = _pendingTransactions[i];
        } else if (transactionId == _pendingTransactions[i]) {
          replace = 1;
        }
      }
      delete _pendingTransactions[_pendingTransactions.length - 1];
      _pendingTransactions.length--;
      delete _transactions[transactionId];
    }

    /// @return Returns balance
    function walletBalance() constant public returns (uint) {
      //YOUR CODE HERE
      return address(this).balance;
    }

 }
