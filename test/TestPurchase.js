var Purchase = artifacts.require("./Purchase.sol");

contract('Purchase', function(accounts){
  it("should return generated transkey", function(){
    var prchse;
    var trnsky;
    return Purchase.deployed().then(function(instance){
      prchse = instance;
      return prchse.GenerateTransKey(0);
    }).then(function(key){
      console.log('trnsky', key);
      assert.equal(key.toString().length, 66);
    });
  });
  it("should contains trans after InitTransaction", function(){
    var prchse;
    var trnsky;
    return Purchase.deployed().then(function(instance){
      prchse = instance;
      return prchse.InitTransaction(20,20);
    }).then(function(key){
      trnsky = key;
      console.log('trnsky', key);
      assert.equal(key.toString().length, 66);
    });
  });
  it("trans should exist after InitTransaction", function(){
    var prchse;
    var trnsky;
    return Purchase.deployed().then(function(instance){
      prchse = instance;
      return prchse.InitTransaction(20,20);
    }).then(function(key){
      trnsky = key;
      return prchse.GetTransExist(trnsky);
    }).then(function(isExist){
      assert.equal(isExist, true);
    });
  });
  // it("Desc", function(){
  //   var purchase;
  //   var transKey;
  //   return Purchase.deployed().then(function(instance){
  //     purchase = instance;
  //     return purchase.InitTransaction(
  //       20,20, {value: web3.toWei(2, 'ether')});
  //   }).then(function(key){
  //     transKey = key;
  //     console.log(transKey);
  //     return purchase.getTransEntities(transKey);
  //   }).then(function(k,u,sp,b){
  //     console.log(k,u,sp,b);
  //   });
  // });
});