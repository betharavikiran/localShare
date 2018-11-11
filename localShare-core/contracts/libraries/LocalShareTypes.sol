pragma solidity ^0.4.24;

library LocalShareTypes {

    struct SharedContract {
        address tokenAddress;
        address seller;
        address consumer;
        uint dailyRate;
        uint    monthsLeased;
        bool    enabled;
        string  dbRefId; //Meta Data
    }

    struct Bill {
        uint daysConsumed;
        address tokenAddress;
        address seller;
        address consumer;
        uint dailyRate;
        uint amount;
        string dbRefId;
    }
}
