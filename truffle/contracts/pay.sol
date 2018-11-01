pragma solidity ^0.4.22;

contract Purchase {
    struct Transaction {
        string TransNum;
        address User;
        address SP;
        address Business;
        // index 0 for user, index 1 for SP, index 3 for Business
        bool[] Confirmations;
        uint UserShare;
        uint SPShare;
    }
    Transaction[] public trans;
    // mapping(uint => Transaction) public trans;
    // User or SP or Business
    address[] public customers;
    
    // Ensure that `msg.value` is an even number.
    // Division will truncate if it is an odd number.
    // Check via multiplication that it wasn't an odd number.
    constructor() public payable {

    }

    modifier condition(bool _condition) {
        require(_condition);
        _;
    }
    
    // # 10
    // This is the combine API for UserVerification SPVerification, BusinessVerification
    modifier InContract() {
        bool res = false;
        for (uint i = 0; i < customers.length; i++) {
            if (msg.sender == customers[i]) {
                res = true;
                break;
            }
        }
        require(res);
        _;
    }




    // Not being used yet
    // Still figuring out how to use events

    event Aborted();
    event PurchaseConfirmed();
    event ItemReceived();
    
   

    
    // I haven't thought of a good way to generate a transNum, maybe get the blockchain No.
    function GenerateTransNum() private pure returns (string thatString) {
        return "0000000";
    }
    
    // # 7
    function InitTransaction(uint UserShare, uint SPShare) private returns (string thatString) {
        string memory tranNum = GenerateTransNum();
        
        trans.push(Transaction({
            TransNum : tranNum,
            Business : msg.sender,
            User : address(0),
            SP : address(0),
            Confirmations : new bool[](3),
            UserShare : UserShare,
            SPShare : SPShare
        }));
        for (uint i = 0; i < 3; i++) {
            trans[trans.length - 1].Confirmations[i] = false;
        }
        customers.push(msg.sender);
        return tranNum;
    }
    
    // #8
    // 1. Assign the target user into the contract 
    // 2.Check if User is a valid address or not
    function AssignUser(string transNum, address User)
        public
        InContract()
    {
        uint index = 0;
        bool found = false;
        for (uint i = 0; i < trans.length; i++) {
            if (keccak256(trans[i].TransNum) == keccak256(transNum)) {
                index = i;
                found = true;
                break;
            }
        }
        if (!found) {
            revert();
            // return;
        }
        Transaction storage t =  trans[index];
        if (msg.sender == t.Business) {
            t.User = User;
            customers.push(User);
        }
        
            
    }
    
    function AssignSP(string transNum, address SP)
        public
        InContract()
    {
        uint index = 0;
        bool found = false;
        for (uint i = 0; i < trans.length; i++) {
            if (keccak256(trans[i].TransNum) == keccak256(transNum)) {
                index = i;
                found = true;
                break;
            }
        }
        if (!found) {
            revert();
        }
        Transaction storage t =  trans[index];
        if (msg.sender == t.User) {
            t.User = SP;
            customers.push(SP);
        }
        
            
    }

    /// Confirm the purchase 
    function confirmPurchase(string transNum)
        public
        InContract()
    {
        uint index = 0;
        bool found = false;
        // Need to check map
        for (uint i = 0; i < trans.length; i++) {
            if (keccak256(trans[i].TransNum) == keccak256(transNum)) {
                index = i;
                found = true;
                break;
            }
        }
        if (!found) {
            revert();
        }
        Transaction storage t =  trans[index];
        if (msg.sender == t.User) {
            t.Confirmations[0] = true;
        } else if (msg.sender == t.SP) {
            t.Confirmations[1] = true;
        } else if (msg.sender == t.Business) {
            t.Confirmations[2] = true;
        }
        for (uint j = 0; j < 3; j++) {
            if (!t.Confirmations[j]) {
                revert();
            }
        }
        FullFill(index);
            
    }
    
    function deleteTrans(uint index) 
    private
    {
        trans[index] = trans[trans.length - 1];
        delete trans[trans.length - 1];
        trans.length--;
    }
    
    // Business cancel, only available before user confirmed
    function Cancel(string transNum)
        public
        InContract()
    {
        uint index = 0;
        bool found = false;
        for (uint i = 0; i < trans.length; i++) {
            if (keccak256(trans[i].TransNum) == keccak256(transNum)) {
                index = i;
                found = true;
                break;
            }
        }
        if (!found) {
            revert();
        }
        Transaction storage t =  trans[index];
        if (msg.sender != t.Business || t.Confirmations[0]) {
            revert();
        }
        deleteTrans(index);
    }
    
    // SP cancel, only available before Business confirmed
    function SPReject(string transNum)
        public
        InContract()
    {
        uint index = 0;
        bool found = false;
        for (uint i = 0; i < trans.length; i++) {
          // Change the transN uint64
            if (keccak256(trans[i].TransNum) == keccak256(transNum)) {
                index = i;
                found = true;
                break;
            }
        }
        if (!found) {
            revert();
        }
        Transaction storage t =  trans[index];
        if (msg.sender != t.SP || t.Confirmations[2]) {
            revert();
        }
        deleteTrans(index);
    }
    
     // User cancel, only available before Business confirmed
    function UserReject(string transNum)
        public
        InContract()
    {
        uint index = 0;
        bool found = false;
        for (uint i = 0; i < trans.length; i++) {
            if (keccak256(trans[i].TransNum) == keccak256(transNum)) {
                index = i;
                found = true;
                break;
            }
        }
        if (!found) {
            revert();
        }
        Transaction storage t =  trans[index];
        if (msg.sender != t.User || t.Confirmations[1] || t.Confirmations[2]) {
            revert();
        }
        deleteTrans(index);
    }
    
     // # 25/26
    function FullFill(uint TransIndex)
        private
    {
        Transaction storage t =  trans[TransIndex];
        // To be implemented 
        // Pay User and SP the right Partial
        
    }
    
       
}