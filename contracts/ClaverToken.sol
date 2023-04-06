// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

contract ClaverToken{
    address public owner;
    string public name = "Claver Token";
    string public symbol = "CLVR";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000 * 10**18; // 1 million tokens

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;

    constructor() {
        owner = msg.sender;
        balances[msg.sender] = totalSupply;
    }


    function mint(uint256 amount) external {
        // Only allow the contract owner to mint tokens
        require(msg.sender == owner, "Only the contract owner can mint tokens");
        
        // Increase the total supply of tokens
        totalSupply += amount;
        
        // Mint the new tokens and assign them to the contract owner
        balances[owner] += amount;
        
        // Emit an event to notify listeners that tokens have been minted
        emit Minted(owner, amount);
    }


    function balanceOf(address account) public view returns(uint256){
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns(bool){
        require(recipient != address(0), "Transfer to a zero address");
        require(balances[msg.sender] >= amount, "Insufficient funds");

        balances[msg.sender] -= amount;
        balances[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns(bool){
        require(spender != address(0), "Approve to a zero address");

        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address _owner, address spender) public view returns (uint256) {
        return allowances[_owner][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "Transfer to the zero address");
        require(amount <= balances[sender], "Insufficient balance");
        require(amount <= allowances[sender][msg.sender], "Insufficient allowance");
        balances[sender] -= amount;
        balances[recipient] += amount;
        allowances[sender][msg.sender] -= amount;
        
        emit Transfer(sender, recipient, amount);
        return true;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Minted(address indexed owner, uint value);

}