// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/token/ERC20/ERC20Mintable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/token/ERC20/ERC20Detailed.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/token/ERC20/ERC20Burnable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/token/ERC20/ERC20Pausable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/access/Roles.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/ownership/Ownable.sol";


import "./MintedCrowdsale.sol";
import "./MintedBurnedCrowdsale.sol";



contract ETHWOP is ERC20Mintable,ERC20Burnable, ERC20Detailed,ERC20Pausable,Ownable  {
    
    using Roles for Roles.Role;

    Roles.Role private _minters;
    Roles.Role private _burners;
    
    constructor(
        uint256 initialSupply,
        address[] memory minters, 
        address[] memory burners        
        ) ERC20Detailed("Woonkly Power", "WOP", 18) public {  
        _mint(msg.sender, initialSupply);

        
        for (uint256 i = 0; i < minters.length; ++i) {
            _minters.add(minters[i]);
        }

        for (uint256 i = 0; i < burners.length; ++i) {
            _burners.add(burners[i]);
        }        
        
    }    
    
    function burnWOP(address account, uint256 amount) public onlyOwner returns(bool) {
        _burn(account, amount) ;   
        return true;
    }


    function addBurner(address burner) public onlyOwner {
        _burners.add(burner);
    }

    function burn(address from, uint256 amount) public returns (bool) {
        // Only burners can burn
        require(_burners.has(msg.sender), "DOES_NOT_HAVE_BURNER_ROLE");

       _burn(from, amount);
       return true;
    }

    function isBurner(address account) public view returns (bool) {
        return _burners.has(account);
    }
    
    function()  external payable { }
    
    function getMyether() public view returns(uint256){
            address payable self = address(this);
            uint256 bal =  self.balance;    
            
            return bal;
            
    }
    
}




contract ETHWOPCrowdsale is  MintedBurnedCrowdsale {
    constructor(
        uint256 rate,    // rate in TKNbits
        address payable wallet,
        IERC20 token
    )
        MintedCrowdsale()
        Crowdsale(rate, wallet, token)
        public
    {

    }
    
    
    function changeRate(uint256 newrate) public onlyOwner {
        _rate=newrate;
    }

    function changeWallet(address payable newWallet) public onlyOwner {
        _wallet=newWallet;
    }

    function()  external payable { }
    
    function getMyether() public view returns(uint256){
            address payable self = address(this);
            uint256 bal =  self.balance;    
            
            return bal;
            
    }

    function getWeiAmount(uint256 tkAmount) public view returns (uint256) {
        return _getWeiAmount( tkAmount);
    }

    function getTokenAmount(uint256 weiAmount) public view returns (uint256) {
        return _getTokenAmount(weiAmount);
    }

    
    event FundsWithdrawed(address indexed beneficiary, address indexed provider, uint256 value);

    function withdrawFunds(uint256 ret) public onlyOwner nonReentrant payable{
        require(ret<=getMyether(),"WOPCrowdsale: Error insuficients funds");
        msg.sender.transfer(ret);
        
        if(_weiRaised<=ret){
            _weiRaised = _weiRaised.sub(ret, "WOPCrowdsale: transfer amount exceeds _weiRaised");
        }else{
            _weiRaised=0;
        }

        
        emit FundsWithdrawed(address(msg.sender), address(_wallet), ret);
    }



    event FundsDeposited(address indexed provider, address indexed beneficiary, uint256 value);
    
    function depositFunds() public nonReentrant payable{
        _wallet.transfer(msg.value);
        _weiRaised = _weiRaised.add(msg.value);
        
        emit FundsDeposited(address(msg.sender), address(_wallet), msg.value);
    }
 
    
}

contract ETHWOPCrowdsaleDeployer is Ownable {
    
    address public crowdsale;
    address public token;
    
    constructor(
        uint256 initialSupply,
        //address payable wallet,
        uint256 initialRate
        )
        public
    {

        address user =address(msg.sender);
        address[] memory mn = new address[](1);
        mn[0]=address(user);


        // create a mintable token
        ETHWOP _token = new ETHWOP(
            initialSupply,
             mn,
             mn
             );

        // create the crowdsale and tell it about the token
        ETHWOPCrowdsale _crowdsale = new ETHWOPCrowdsale(
            initialRate,               // rate, still in TKNbits
            msg.sender,      // send Ether to the deployer msg.sender
            _token            // the token
        );
        
        
        
        // transfer the minter role from this contract (the default)
        // to the crowdsale, so it can mint tokens
        _token.addMinter(address(_crowdsale));
        _token.addBurner(address(_crowdsale));
        _token.addMinter(user);
        _token.addPauser(user);
        _token.renounceMinter();
        _token.transferOwnership(user);
        
        address payable nwallet = address(uint160(address(_crowdsale)));
        _crowdsale.changeWallet(nwallet);
        _crowdsale.transferOwnership(user);
        
        crowdsale=address(_crowdsale);
        token=address(_token);
        
        
        
    }
    
    

}