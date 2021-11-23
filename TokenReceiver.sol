pragma solidity ^0.6.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.4/contracts/access/Ownable.sol";

contract TokenReceiver is Ownable{
    
    event TokenReceived(string _name, uint _decimals, uint _amount, address _from);
    
    ERC20 ERC20Contract;
    mapping(address => bool) public whitelist;
    
    address payable vault;
    
    constructor(address payable _vault) Ownable() public {
        vault = _vault;
    } 
    
    function receiveTokens(address _tokenAddr, uint _amount) external {
        require(whitelist[_tokenAddr], "Token not accepted");
        require(_amount > 0, "Amount Not Valid");
        ERC20Contract = ERC20(_tokenAddr);
        ERC20Contract.transferFrom(msg.sender, vault, _amount);
        
        emit TokenReceived(ERC20Contract.name(), ERC20Contract.decimals(), _amount, msg.sender);
    }
    
    function receiveEther() external payable {
        require(msg.value > 0, "Invalid Ether amount");
        vault.transfer(msg.value);
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
    
    // function decimals(address _tokenAddr) external view returns(uint) {
    //     ERC20Contract.
    // }
    
}
