var ConvertLib = artifacts.require("./ConvertLib.sol");
var Purchase = artifacts.require("./contrcts/Purchase.sol");

module.exports = function(deployer) {
  deployer.deploy(ConvertLib);
  deployer.link(ConvertLib, Purchase);
  deployer.deploy(Purchase);
};
