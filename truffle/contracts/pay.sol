pragma solidity ^0.4.22;

contract Purchase {
    /*
        1 equals to 1/1000, ex: 200 equals to 20%
    */
    uint private RETURN_DEDUCTION_RATIO = 200;
    
    
    address private contractOwner;
    struct Transaction {
        bytes32 TransKey;
        address User;
        address SP;
        address Business;
        bool isBusinessConfirm;
        bool isUserConfirm;
        bool isSPConfirm;
        uint UserShare;
        uint SPShare;
        bool isValue;
    }
    mapping(bytes32 => Transaction) private trans;
    
    constructor() public payable {
        contractOwner = msg.sender;
    }
    
    modifier OnlyOwner(){
        require(msg.sender == contractOwner);
        _;
    }

    modifier OnlyBusiness(bytes32 transKey) { 
        
        require (trans[transKey].Business == msg.sender); 
        _; 
    }
    
    modifier OnlyUser(bytes32 transKey) { 
        
        require (trans[transKey].User == msg.sender); 
        _; 
    }
    
    modifier OnlySP(bytes32 transKey) { 
        
        require (trans[transKey].SP == msg.sender); 
        _; 
    }
    
    modifier TransExist(bytes32 transKey) {
        require(trans[transKey].isValue == true);
        _;
    }
    
    event Aborted();
    event PurchaseConfirmed();
    event ItemReceived();
    
    function GetReturnDeductionRatio()
        public
        view
        returns (uint ratio)
    {
        return RETURN_DEDUCTION_RATIO;
    }
    
    function AdjustReturnDeductionRatio(uint ratio)
        public
        OnlyOwner
    {
        RETURN_DEDUCTION_RATIO = ratio;   
    }
    
    function GenerateTransKey(uint salt) 
        private view 
        returns (bytes32 TransKey) 
    {
        /* 
        Should I use other parameter beside "now"
        */
        return keccak256(abi.encodePacked(msg.sender, now, salt));
    }
    
    function InitTransaction(uint UserShare, uint SPShare) 
        public 
        payable
        returns (bytes32 TransKey) 
    {
        /*
        TODO set the minimum value for UserShare and SPShare?
        */
        
        /*
        check if value is enough
        */
        require(msg.value >= UserShare + SPShare);
        
        /*
        making sure the key is not duplicated
        */
        uint salt = 0;
        bytes32 transKey = GenerateTransKey(salt);
        while (true){
            if (trans[transKey].isValue){
                salt += 1;
                transKey = GenerateTransKey(salt);
            }else{
                break;
            }
        }    
        
        trans[transKey] = Transaction({
            TransKey : transKey,
            Business : msg.sender,
            User : address(0),
            SP : address(0),
            isBusinessConfirm : false,
            isUserConfirm: false,
            isSPConfirm: false,
            UserShare : UserShare,
            SPShare : SPShare,
            isValue: true
        });
        return transKey;
    }
    
    function AssignUser(bytes32 transKey, address User)
        public
        TransExist(transKey)
        OnlyBusiness(transKey)
    {
        Transaction storage t =  trans[transKey];
        t.User = User;
    }
    
    function AssignSP(bytes32 transKey, address SP)
        public
        TransExist(transKey)
        OnlyUser(transKey)
    {
        Transaction storage t =  trans[transKey];
        t.SP = SP;
    }
    
    function UserConfirm(bytes32 transKey)
        public
        TransExist(transKey)
        OnlyUser(transKey)
    {
        Transaction storage t =  trans[transKey];
        t.isUserConfirm = true;
        FulFill(transKey);
    }
    
    function SPConfirm(bytes32 transKey)
        public
        TransExist(transKey)
        OnlySP(transKey)
    {
        Transaction storage t =  trans[transKey];
        t.isSPConfirm = true;
        FulFill(transKey);
    }
    
    function BusinessConfirm(bytes32 transKey)
        public
        TransExist(transKey)
        OnlyBusiness(transKey)
    {
        Transaction storage t =  trans[transKey];
        t.isBusinessConfirm = true;
        FulFill(transKey);
    }
    
    function FulFill(bytes32 transKey)
        private
        TransExist(transKey)
    {
        
        Transaction storage t =  trans[transKey];
        require(address(this).balance >= t.SPShare + t.UserShare);
        if (t.isBusinessConfirm && t.isSPConfirm && t.isUserConfirm){
            t.User.transfer(t.UserShare);
            t.SP.transfer(t.SPShare);
            DeleteTrans(transKey);
        }
    }
    
    function UserReject(bytes32 transKey)
        public
        TransExist(transKey)
        OnlyUser(transKey)
    {
        Transaction storage t =  trans[transKey];
        if (t.isSPConfirm){
            uint spShare = t.SPShare * RETURN_DEDUCTION_RATIO / 1000;
            t.SP.transfer(spShare);
            t.Business.transfer(t.SPShare - spShare + t.UserShare);
        }else{
            t.Business.transfer(t.SPShare + t.UserShare);
        }
        DeleteTrans(transKey);
    }
    
    function SPReject(bytes32 transKey)
        public
        TransExist(transKey)
        OnlySP(transKey)
    {
        Transaction storage t =  trans[transKey];
        if (t.isUserConfirm){
            uint userShare = t.SPShare * RETURN_DEDUCTION_RATIO / 1000;
            t.User.transfer(userShare);
            t.Business.transfer(t.UserShare - userShare + t.SPShare);
        }else{
            t.Business.transfer(t.UserShare + t.SPShare);
        }
        DeleteTrans(transKey);
    }
    
    function DeleteTrans(bytes32 transKey)
        private
    {
        delete trans[transKey];
    }
}