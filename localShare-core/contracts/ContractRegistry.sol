pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "zos-lib/contracts/migrations/Migratable.sol";
import "./libraries/LocalShareTypes.sol";

contract ContractRegistry is Ownable, Migratable {

    LocalShareTypes.SharedContract[] public contracts;

    event NewContract(address seller, address consumer, uint index);

    function initialize() public isInitializer("ContractRegistry", "0") {
    }

    function newContract(
        address tokenAddress,
        address seller,
        address consumer,
        uint dailyRate,
        uint monthsLeased,
        bool enabled,
        string dbRefId
    ) public returns (uint newIndex) {
        newIndex = contracts.push(
            LocalShareTypes.SharedContract(tokenAddress, seller, consumer, dailyRate, monthsLeased, enabled, dbRefId)
        ) - 1;
        emit NewContract(seller, consumer, newIndex);
    }


    function setContractStatus(uint index, bool status) public {
        LocalShareTypes.SharedContract storage currentContract = contracts[index];
        require(currentContract.seller == msg.sender || currentContract.consumer == msg.sender, "You must be the consumer or the producer address");
        currentContract.enabled = status;
    }


    function getContractsLength() public view  returns (uint length) {
        length = contracts.length;
    }

    function isEnabled(uint index) public view returns (bool enabled) {
        LocalShareTypes.SharedContract memory currentContract = contracts[index];
        enabled = currentContract.enabled;
    }

    function getContract(uint index) public view returns (
        address tokenAddress,
        address seller,
        address consumer,
        uint dailyRate,
        bool enabled,
        string dbRefId
    ) {
        LocalShareTypes.SharedContract memory currentContract = contracts[index];
        tokenAddress = currentContract.tokenAddress;
        seller = currentContract.seller;
        consumer = currentContract.consumer;
        dailyRate = currentContract.dailyRate;
        enabled = currentContract.enabled;
        dbRefId = currentContract.dbRefId;
    }

    function getContractData(uint index) public view returns (
        address,
        address,
        address,
        uint,
        bool
    ) {
        LocalShareTypes.SharedContract storage currentContract = contracts[index];
        return (currentContract.tokenAddress, currentContract.seller, currentContract.consumer, currentContract.dailyRate, currentContract.enabled);
    }
}
