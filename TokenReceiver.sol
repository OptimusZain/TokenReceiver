pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenReceiver is Ownable{
    
    event EtherReceived(address from, uint value);
    event vaultChanged(address new_address);
    event TokenReceived(string _name, uint _decimals, uint _amount, address _from);
    

    //public list show struct[{bool,name, symbol, address}]
    
    uint counter; 
    //7
    //f() return{7}

    ERC20 ERC20Contract;
    mapping(address => bool) public whitelist;
    
    address payable vault;
    
    constructor() {
        vault = payable(owner());
    } 
    
 function receiveTokens(address _tokenAddr, uint _amount) external {
        require(whitelist[_tokenAddr], "Token not accepted");
        require(_amount > 0, "Amount Not Valid");
        ERC20Contract = ERC20(_tokenAddr);
        ERC20Contract.transferFrom(msg.sender, vault, _amount);

        emit TokenReceived(ERC20Contract.name(), ERC20Contract.decimals(), _amount, msg.sender);
    }
    
    function checkWhitelisted(address [] memory tokens) private view returns(bool){
        for(uint i = 0; i < tokens.length; i++){
            if(whitelist[tokens[i]] == false)
                return false;
        }
        return true;
    }
    
    function addToWhitelist(address _tokenAddr) external onlyOwner {
        require(_tokenAddr != address(0), "addToWhitelist: 0 Address cannot be added");
        whitelist[_tokenAddr] = true;
    }
    
    function removeFromWhitelist(address _tokenAddr) external onlyOwner {
        require(_tokenAddr != address(0), "removeFromWhitelist: Wrong Address");
        whitelist[_tokenAddr] = false;
    }
    
    function changeWalletAddress(address payable _newWallet) external onlyOwner {
        vault = _newWallet;
        emit vaultChanged(_newWallet);
    }
    
    function decimals(address _tokenAddr) public returns(uint) {
        ERC20Contract = ERC20(_tokenAddr);
        return ERC20Contract.decimals();
    }
    
    receive() external payable {
        vault.transfer(msg.value);
        emit EtherReceived(msg.sender, msg.value);
    }
    
}
