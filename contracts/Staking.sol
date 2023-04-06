// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "./ClaverToken.sol";

contract Staking {
    address payable public owner;
    ClaverToken token;
    uint constant LOCK_PERIOD = 60 * 1;
    uint constant PROFIT_PERCENTAGE = 10;
    uint constant MINIMUM_STAKE_AMOUNT = 10 ** 18;
    uint constant TOKEN_RATE = 100;

    mapping(address => Stake[]) stakes;

    constructor(ClaverToken _token) payable {
        owner = payable(msg.sender);
        token = _token;
    }

    enum StakeStatus {
        LOCKED,
        UNLOCKED,
        WITHDRAWN
    }

    struct Stake{
        address payable owner;
        uint amount;
        uint stakeTime;
        uint profitAmount;
        StakeStatus status;
    }

    function buyTokens() public payable {
        uint numberOfTokens = msg.value * TOKEN_RATE;

        // Check if Staking has enough tokens
        require(token.balanceOf(address(this)) >= numberOfTokens, "Insufficient tokens");

        // transfer tokens
        token.transfer(msg.sender, numberOfTokens);

        emit TokenPurchased(msg.sender, address(token), numberOfTokens, TOKEN_RATE);
    }

    function stake(uint _amount) public payable{
        require(_amount >= MINIMUM_STAKE_AMOUNT,"Stake amount is too low");
        Stake memory _stake = Stake(payable(msg.sender), _amount, block.timestamp, _amount + ((_amount * PROFIT_PERCENTAGE)/100), StakeStatus.LOCKED);
        stakes[msg.sender].push(_stake);

        token.transferFrom(msg.sender, address(this), _amount);

        emit Staked(msg.sender, (block.timestamp + LOCK_PERIOD), _amount);
    }

    function getStakesByInvestor(address _investor) public view returns(Stake[] memory){
        return stakes[_investor];
    }

    function withdraw() public {
        Stake[] memory _stakes = stakes[msg.sender];

        for(uint i = 0; i < _stakes.length; i++){
            if(block.timestamp >= (_stakes[i].stakeTime + LOCK_PERIOD) && (_stakes[i].status == StakeStatus.LOCKED)){
                stakes[msg.sender][i].status = StakeStatus.WITHDRAWN;
                emit StakeWithdrawn(msg.sender, _stakes[i].amount, _stakes[i].profitAmount);
                token.transfer(msg.sender, _stakes[i].profitAmount);
            }
        }
    }

    event TokenPurchased(address buyer, address token, uint amount, uint rate);
    event StakeWithdrawn(address account, uint amount, uint profitAmount);
    event Staked(address indexed account, uint maturity, uint amount);
}
