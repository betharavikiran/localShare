pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";

import "./UserRegistry.sol";

contract LocalMarket is Ownable, Pausable {
    UserRegistry public userRegistry;
    mapping(address => uint[]) private addressToOffersIndex;
    Offer[] private offersList;
    address public owner;


    struct Offer {
        address seller;
        uint value;
        bool isActive;
    }

    event newOffer(address seller, uint value);
    event cancelOfferEvent(address seller, uint value);

    modifier onlyUser() {
        require(userRegistry.hasUser(msg.sender));
        _;
    }

    function createOffer(uint _value, address _seller) public whenNotPaused {
        Offer memory myOffer;
        myOffer.seller = _seller;
        myOffer.value = _value;
        myOffer.isActive = true;

        uint index = offersList.push(myOffer) - 1;
        addressToOffersIndex[_seller].push(index);
        emit newOffer(_seller, _value);
    }

    function cancelOffer(uint _id, address sender) public whenNotPaused {
        require(offersList[_id].seller == sender);
        offersList[_id].isActive = false;
        emit cancelOfferEvent(sender, offersList[_id].value);
    }

    function getOfferFromIndex(uint _index) public view returns(uint, address, bool) {
        require(offersList.length > _index);
        return (offersList[_index].value, offersList[_index].seller, offersList[_index].isActive);
    }

    function getOfferIndexesFromAddress() public view returns(uint[]) {
        return addressToOffersIndex[msg.sender];
    }

    function getOffersLength() public view returns(uint) {
        return offersList.length;
    }
}
