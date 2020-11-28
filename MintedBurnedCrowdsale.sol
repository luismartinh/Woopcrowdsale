pragma solidity ^0.5.0;

import "./MintedCrowdsale.sol";
import "./IWOPburnable.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/token/ERC20/ERC20Mintable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/ownership/Ownable.sol";



/**
 * @title MintedBurnedCrowdsale
 * @dev Extension of MintedCrowdsale contract whose tokens are burned.
 * 
 */
contract MintedBurnedCrowdsale is MintedCrowdsale,Ownable {
    
    
    event TokensSelled(address indexed vendor,  uint256 value, uint256 amount);
    
    function sellTokens(uint256 tkAmount) public nonReentrant payable {

        address vendor =address(msg.sender);
        
        
        // calculate wei amount to be created
        uint256 weis = _getWeiAmount(tkAmount);
        
        _preValidateSale(vendor, tkAmount,weis);

        // update state
        _weiRaised = _weiRaised.sub(weis, "MintedBurnedCrowdsale: transfer amount exceeds _weiRaised");

        emit TokensSelled(vendor, weis, tkAmount);
        _processSeller(vendor,tkAmount);
        
        _updateSellingState(vendor,tkAmount);

        msg.sender.transfer(weis);
        
        _postValidateSeller(vendor,tkAmount);
    }    
    

/*
    function burnMyTokens(uint256 tkAmount) public nonReentrant  {

        address vendor =address(msg.sender);

        _preValidateBurn(vendor, tkAmount);

        _processSeller(vendor,tkAmount);
        
        _updateSellingState(vendor,tkAmount);

        _postValidateSeller(vendor,tkAmount);
    }    

    
    function _preValidateBurn(address vendor, uint256 tkAmount) internal view {
        require(tkAmount != 0, "MintedBurnedCrowdsale: tkAmount is 0");
        require(tkAmount <= _token.balanceOf(vendor), "MintedBurnedCrowdsale: insuficient balance tkAmount");
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    }
    
*/

    function sellUserTokens(address payable user, uint256 tkAmount) public onlyOwner nonReentrant payable {

        address vendor =address(user);
        
        
        // calculate wei amount to be created
        uint256 weis = _getWeiAmount(tkAmount);
        
        _preValidateSale(vendor, tkAmount,weis);

        // update state
        _weiRaised = _weiRaised.sub(weis, "MintedBurnedCrowdsale: transfer amount exceeds _weiRaised");

        emit TokensSelled(vendor, weis, tkAmount);
        _processSeller(vendor,tkAmount);
        
        _updateSellingState(vendor,tkAmount);

       // msg.sender.transfer(weis);
       user.transfer(weis);
        
        _postValidateSeller(vendor,tkAmount);
    }    

    
    function buyMyTokens() public payable {
        address buyer =address(msg.sender);
        buyTokens(buyer);
    }
    

    function _preValidateSale(address vendor, uint256 tkAmount,uint256 weiAmount) internal view {
        address payable self = address(this);
        uint256 bal =  self.balance;    
        
        require(tkAmount != 0, "MintedBurnedCrowdsale: tkAmount is 0");
        require(tkAmount <= _token.balanceOf(vendor), "MintedBurnedCrowdsale: insuficient balance tkAmount");
        require(weiAmount <= bal, "MintedBurnedCrowdsale: insuficient balance weiAmount");
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    }



    function _getWeiAmount(uint256 tkAmount) internal view returns (uint256) {
        return tkAmount.div(_rate);
    }
    
    function _processSeller(address vendor, uint256 tokenAmount) internal {
        _burnTokens(vendor, tokenAmount);
    }

    function _updateSellingState(address vendor, uint256 tokenAmount) internal {
        // solhint-disable-previous-line no-empty-blocks
    }
    
    function _postValidateSeller(address vendor, uint256 tokenAmount) internal view {
        // solhint-disable-previous-line no-empty-blocks
    }
    
    /**
     * @dev Overrides delivery by minting tokens upon purchase.
     * @param vendor Token seller
     * @param tokenAmount Number of tokens to be burned
     */
    function _burnTokens(address vendor, uint256 tokenAmount) internal {
        // Potentially dangerous assumption about the type of the token.
        require(
            IWOPburnable(address(token())).burn(vendor, tokenAmount),
                "MintedBurnedCrowdsale: burn failed"
        );
    }



}


