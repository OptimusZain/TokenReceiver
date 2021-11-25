pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract payment is Ownable{
    
    event EtherReceived(address from, uint value);
    event vaultChanged(address new_address);
    event TokenReceived(string _name, uint _decimals, uint _amount, address _from);
    
    struct Tokens{
        string Name;
        string Symbol;
        address Address;
    }

    struct test{
        uint num;
    }

    ERC20 ERC20Contract;
    mapping(address => bool) public whitelist;
    Tokens [] private TokensList;

    address payable vault;
    test [] public Value;
 
    constructor() {

    vault = payable(owner());
   
    // addresses to receive payments
        address[4] memory tokens = [
        0xaD6D458402F60fD3Bd25163575031ACDce07538D,
        0x6EE856Ae55B6E1A249f04cd3b947141bc146273c,
        0xE1E545c89F3996Cf06E1f12C6D05e3412c7C7b11,
        0x5D9Bb02f1ac65d10e16EED5E2212D31E6AdD0b04
        // 0x512a34a032116ecde07bfe47e731b2d16b77a5fb,
        // 0x512a34a032116ecde07bfe47e731b2d16b77a5fb,
        // 0x512a34a032116ecde07bfe47e731b2d16b77a5fb,
        // 0x0F5D2fB29fb7d3CFeE444a200298f468908cC942
        ];

        for(uint i = 0; i < tokens.length; i++){
            addToWhitelist(tokens[i]);
        }
    } 
    
    function receiveTokens(address _tokenAddr, uint _amount) external {
        require(whitelist[_tokenAddr], "Token not accepted");
        require(_amount > 0, "Amount Not Valid");
        ERC20Contract = ERC20(_tokenAddr);
        ERC20Contract.transferFrom(msg.sender, vault, _amount);

        emit TokenReceived(ERC20Contract.name(), ERC20Contract.decimals(), _amount, msg.sender);
    }
    
    function checkWhitelisted(address [] memory token) private view returns(bool){
        for(uint i = 0; i < token.length; i++){
            if(whitelist[token[i]] == false)
                return false;
        }
        return true;
    }
    
    function addToWhitelist(address _tokenAddr) public onlyOwner {
        require(_tokenAddr != address(0), "addToWhitelist: 0 Address cannot be added");
        require(whitelist[_tokenAddr] != true, "addToWhitelist: Already Whitelisted");

        whitelist[_tokenAddr] = true;
        ERC20Contract = ERC20(_tokenAddr);

        TokensList.push(Tokens(
        ERC20Contract.name(),
        ERC20Contract.symbol(),
        _tokenAddr
        ));
    }
    
    function removeFromWhitelist(address _tokenAddr) external onlyOwner {
        require(_tokenAddr != address(0), "removeFromWhitelist: Wrong Address");
        require(whitelist[_tokenAddr] != false, "removeFromWhitelist: Already removed from Whitelist");
        whitelist[_tokenAddr] = false;

        for (uint i = 0; i < TokensList.length; i++){
            if(TokensList[i].Address == _tokenAddr){
                TokensList[i] = TokensList[TokensList.length - 1];
                TokensList.pop();
            }
        }
    }
 
    function changeWalletAddress(address payable _newWallet) external onlyOwner {
        vault = _newWallet;
        emit vaultChanged(_newWallet);
    }

    function ListTokens() public view returns(Tokens [] memory){
        return TokensList;
    } 
    
    function getContractDecimals(address _tokenAddr) public returns(uint) {
        ERC20Contract = ERC20(_tokenAddr);
        return ERC20Contract.decimals();
    }
    
    receive() external payable {
        vault.transfer(msg.value);
        emit EtherReceived(msg.sender, msg.value);
    }
    
}
