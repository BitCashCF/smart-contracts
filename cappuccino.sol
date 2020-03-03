pragma solidity ^0.5.7;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Cappuccino is ERC20 {

    // Token symbol (short)
    string public symbol;

    // Token name (Long)
    string public  name;

    // Decimals (18 maximum)
    uint8 public decimals;

    /**
    * @dev Public functions to make the contract accesible
    */
    constructor (address initialAccount, string memory _tokenSymbol, string memory _tokenName, uint256 initialBalance) public {
        // Initialize Contract Parameters
        symbol = _tokenSymbol;
        name = _tokenName;
        decimals = 18;  // default decimals is going to be 18 always

        _mint(initialAccount, initialBalance);
    }

}