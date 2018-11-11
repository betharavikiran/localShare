pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "zos-lib/contracts/migrations/Migratable.sol";
import "./libraries/LocalShareTypes.sol";
import "./ContractRegistry.sol";

contract BillSystem is Ownable, Migratable {

    address public contractRegistryAddress;
    ContractRegistry contractRegistry;

    LocalShareTypes.Bill[] public bills;

    mapping(address => uint256[]) sellerBillIndex;
    mapping(address => uint256[]) consumerBillIndex;
    mapping(address => string) consumerDbRefIds;
    mapping(uint => bool) isBillPaid;

    mapping (address => mapping (address => uint)) public balances;

    event NewBill(address consumer, address seller, uint index);
    event Newseller(address seller);
    event BillPaid(uint index, address consumer, address seller);

    function initialize() public isInitializer("BillSystem", "0") {
    }

    function setContractRegistry(address _contractRegistryAddress) public {
        contractRegistryAddress = _contractRegistryAddress;
        contractRegistry = ContractRegistry(_contractRegistryAddress);
    }

    function getBill(uint index) public view returns(
        uint256 daysConsumed,
        address tokenAddress,
        address seller,
        address consumer,
        uint256 dailyRate,
        uint256 amount,
        string dbRefId
    ) {
        LocalShareTypes.Bill storage bill = bills[index];

        daysConsumed = bill.daysConsumed;
        tokenAddress = bill.tokenAddress;
        seller = bill.seller;
        consumer = bill.consumer;
        dailyRate = bill.dailyRate;
        amount = bill.amount;
        dbRefId = bill.dbRefId;
    }


    function getBillsLength() public view returns (uint length) {
        length = bills.length;
    }

    function getConsumerBillsLength(address _address) public view returns (uint length) {
        length = consumerBillIndex[_address].length;
    }

    function getSellerBillsLength(address _address) public view returns (uint length) {
        length = sellerBillIndex[_address].length;
    }

    function getBalance(address tokenAddress, address userAddress) public view returns(uint256 balance) {
        balance = balances[tokenAddress][userAddress];
    }

    function newPrepaidContract(
        address tokenAddress,
        address seller,
        address consumer,
        uint dailyRate,
        uint monthsLeased,
        bool enabled,
        string contractDbRefId,
        string billDbRefId
    ) public {
        uint newIndex = contractRegistry.newContract(tokenAddress, seller, consumer, dailyRate, monthsLeased, enabled, contractDbRefId);
        uint totalDays = monthsLeased * 30;
        uint newBillIndex = generateBill(totalDays, newIndex, billDbRefId);
        payBillERC20(newBillIndex);
    }

    function generateBill(uint totalDays, uint contractId, string dbRefId) public returns(uint newIndex) {
        (address tokenAddress, address seller, address consumer, uint dailyRate, bool enabled) = ContractRegistry(contractRegistryAddress).getContractData(contractId);
        require(enabled == true, "Contract is not enabled.");
        newIndex = bills.push(
            LocalShareTypes.Bill(
                totalDays,
                tokenAddress,
                seller,
                consumer,
                dailyRate,
                totalDays * dailyRate,
                dbRefId
            )
        ) - 1;
        consumerBillIndex[consumer].push(newIndex);
        sellerBillIndex[seller].push(newIndex);
        emit NewBill(consumer, seller, newIndex);
    }

    function withdrawETH() public {
        uint256 allBalance = balances[address(0)][msg.sender];
        require(allBalance > 0,  "No balance left.");
        balances[address(0)][msg.sender] = 0;
        msg.sender.transfer(allBalance);
    }

    function withdrawERC20(address tokenAddress) public {
        require(tokenAddress != address(0), "Token address can not be zero. Reserved for ETH payments.");
        uint256 allBalance = balances[tokenAddress][msg.sender];
        require(allBalance > 0,  "No balance left.");
        balances[tokenAddress][msg.sender] = 0;
        require(IERC20(tokenAddress).transfer(msg.sender, allBalance), "Error while making ERC20 transfer");
    }

    function payBillETH(uint256 billIndex) public payable {
        LocalShareTypes.Bill memory bill = bills[billIndex];
        require(bill.tokenAddress == address(0), "The ERC20 token is not the same as defined in the contract.");
        require(bill.consumer == msg.sender, "Bill is from consumer");
        require(bill.amount > 0, "Bill does not exists");
        require(bill.amount == msg.value, "Bill amount is not the same as the amount argument.");
        require(isBillPaid[billIndex] == false, "Bill is already paid.");
        isBillPaid[billIndex] = true;
        balances[address(0)][bill.seller] += msg.value;
    }

    function payBillERC20(uint256 billIndex) public {
        LocalShareTypes.Bill memory bill = bills[billIndex];
        require(bill.amount > 0, "Bill does not exists");
        require(bill.tokenAddress != address(0), "The ERC20 token address must not be 0x00.");
        require(isBillPaid[billIndex] == false, "Bill is already paid.");
        IERC20 tokenInstance = IERC20(bill.tokenAddress);
        // Add allowance requirement, for better error handling HERE
        tokenInstance.transferFrom(bill.consumer, address(this), bill.amount);
        isBillPaid[billIndex] = true;
        balances[bill.tokenAddress][bill.seller] += bill.amount;
        emit BillPaid(billIndex, bill.consumer, bill.seller);
    }
}