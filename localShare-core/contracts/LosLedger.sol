pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract LosLedger  is ERC20, Ownable, ERC20Burnable, ERC20Mintable {
    string public name = "Los";
    string public symbol = "LOS";
    uint8 public decimals = 18;

    bool private _mintingFinished = false;

    function mint(
        address to,
        uint256 amount
    )
    public
        // onlyBeforeMintingFinished
    returns (bool)
    {
        uint user_balance = balanceOf(to);
        require(user_balance < 1000000000000000000000, "You can't mint more if you have an amount greater than 1000 LOS tokens");
        require(amount <= 1000000000000000000000, "You can't mint more than 1000 LOS tokens");
        _mint(to, amount);
        return true;
    }

    /**
      * @dev Disable or enable mintin
      * @param _bool Set to false to disable minting. True to reenable minting.
      * @return bool Returns true if the operation was succesful
      */
    function toggleMinting(bool _bool)
    public
    onlyMinter
        // onlyBeforeMintingFinished
    returns (bool)
    {
        _mintingFinished = _bool;
        //emit MintingFinished();
        return true;
    }

    /**
      * @dev Basic approveAndCall implementation. Allows an ERC20 holder to approve the movement of funds and call to bytecoded function
      * @return bool Returns true if the operation was succesful
      */
    function approveAndCall(address _spender, uint256 _value, bytes _data) public payable returns (bool) {
        require(_spender != address(this));
        require(super.approve(_spender, _value));
        require(_spender.call(_data));
        return true;
    }
}
