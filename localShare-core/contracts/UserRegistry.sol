pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./LocalMarket.sol";

contract UserRegistry {
    mapping (address => uint) private addressToIndex;
    mapping (bytes16 => uint) private usernameToIndex;

    event NewUser(bytes16 username, address owner);
    event UpdatedUser (address owner, bytes32 refId);

    LocalMarket public localMarket;
    address public localMarketAddress;
    address[] private addresses;
    bytes16[] private usernames;
    bytes32[] private dbRefIds;

    address owner;

    modifier onlyOwner(){
        require (msg.sender != owner);
        _;
    }

    constructor (address _localMarketAddress) public {
        owner = msg.sender;
        localMarketAddress = _localMarketAddress;
        localMarket = LocalMarket(localMarketAddress);

        addresses.push(msg.sender);
        usernames.push('self');
        dbRefIds.push('ownerRefId');
    }

    function hasUser(address userAddress) public view returns (bool) {
        return (addressToIndex[userAddress] > 0);
    }


    function usernameTaken(bytes16 username) public view returns (bool){
        return (usernameToIndex[username] > 0 || username == 'self');
    }

    function createUser(bytes16 username, bytes32 dbRefId) public returns (bool) {
        require(!hasUser(msg.sender));
        require(!usernameTaken(username));

        addresses.push(msg.sender);
        usernames.push(username);
        dbRefIds.push(dbRefId);

        addressToIndex[msg.sender] = addresses.length - 1;
        usernameToIndex[username] = addresses.length - 1;

        emit NewUser(username, msg.sender);
        return true;
    }

    function createOffer(uint _value, bytes32 dbRefId) public payable {
        localMarket.createOffer(_value, msg.sender);
        updateUser(dbRefId);
    }


    function cancelOffer(uint _id, bytes32 dbRefId) public payable {
        localMarket.cancelOffer(_id, msg.sender);
        updateUser(dbRefId);
    }

    function updateUser(bytes32 dbRefId) public payable returns (bool _success) {
        require(hasUser(msg.sender), 'Your ethereum address does not belong to any Shasta account.');

        dbRefIds[addressToIndex[msg.sender]] = dbRefId;

        emit UpdatedUser(msg.sender, dbRefId);
        return true;
    }

    function getUserCount() public view returns(uint count)
    {
        return addresses.length;
    }

    function getAddressByIndex(uint index) public view returns(address userAddress)
    {
        require(index < addresses.length);

        return addresses[index];
    }

    function getAddressByUsername(bytes16 username) public view returns(address userAddress)
    {
        require(usernameTaken(username));

        return addresses[usernameToIndex[username]];
    }

    function getUserByAddress(address userAddress) public view returns(uint index, bytes16 username, bytes32 dbRefId) {
        require(index < addresses.length);

        return(addressToIndex[userAddress], usernames[addressToIndex[userAddress]], dbRefIds[addressToIndex[userAddress]]);
    }

    function getUsernameByAddress(address userAddress) public view returns(bytes16 username)
    {
        require(hasUser(userAddress));

        return usernames[addressToIndex[userAddress]];
    }


    function getdbRefIdByIndex(uint index) public view returns(bytes32 dbRefId)
    {
        require(index < addresses.length);

        return dbRefIds[index];
    }

    function getdbRefIdByAddress(address userAddress) public view returns(bytes32 dbRefId)
    {
        require(hasUser(userAddress));

        return dbRefIds[addressToIndex[userAddress]];
    }


    function getIpfsHashByUsername(bytes16 username) public view returns(bytes32 dbRefId)
    {
        require(usernameTaken(username), "Username does not exists.");

        return dbRefIds[usernameToIndex[username]];
    }

    function getIndexByAddress(address userAddress) public view returns(uint index)
    {
        require(hasUser(userAddress));

        return addressToIndex[userAddress];
    }

}
