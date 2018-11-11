var LosLedger = artifacts.require("./LosLedger.sol");
var UserRegistry = artifacts.require("./UserRegistry.sol");
var LocalMarket = artifacts.require("./LocalMarket.sol");
var BillSystem = artifacts.require("./BillSystem.sol");
var ContractRegistry = artifacts.require("./ContractRegistry.sol");


module.exports = function(deployer) {
    deployer.deploy(LosLedger);
    deployer.deploy(BillSystem);
    deployer.deploy(ContractRegistry);
    deployer.deploy(LocalMarket).then(function() {
       return deployer.deploy(UserRegistry, LocalMarket.address);
    });

}