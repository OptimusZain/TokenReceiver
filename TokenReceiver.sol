pragma solidity ^0.6.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4/contracts/access/Ownable.sol";

contract TokenReceiver is Ownable{
    
    event Received(address, uint);
    event TokenReceived(string _name, uint _decimals, uint _amount, address _from);
    
    ERC20 ERC20Contract;
    mapping(address => bool) public whitelist;
    
    address payable vault;
    
    constructor(address payable _vault) Ownable() public {
        vault = _vault;
    } 
    
    function receiveTokens(address [] memory _tokenAddr, uint [] memory _amount) external {
        require(checkWhitelisted(_tokenAddr), "Token not accepted");
        
        for(uint i = 0; i < _tokenAddr.length; i++){
            ERC20Contract = ERC20(_tokenAddr[i]);
            ERC20Contract.transferFrom(msg.sender, vault, _amount[i] * (10 ** decimals(_tokenAddr[i])));
        
            emit TokenReceived(ERC20Contract.name(), ERC20Contract.decimals(), _amount[i], msg.sender);
        }
    }
    
    function checkWhitelisted(address [] memory tokens) private view returns(bool){
        for(uint i = 0; i < tokens.length; i++){
            if(whitelist[tokens[i]] == false)
                return false;
        }
        return true;
    }
    
    function addToWhitelist(address _tokenAddr) external onlyOwner {
        require(_tokenAddr != address(0), "Address not eligible");
        whitelist[_tokenAddr] = true;
    }
    
    function removeFromWhitelist(address _tokenAddr) external onlyOwner {
        require(_tokenAddr != address(0), "Address not eligible");
        whitelist[_tokenAddr] = false;
    }
    
    function changeWalletAddress(address payable _newWallet) external onlyOwner {
        vault = _newWallet;
    }
    
    function decimals(address _tokenAddr) internal returns(uint) {
        ERC20Contract = ERC20(_tokenAddr);
        return ERC20Contract.decimals();
    }
    
    receive() external payable {
        vault.transfer(msg.value);
        emit Received(msg.sender, msg.value);
    }
    
}
