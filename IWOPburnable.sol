pragma solidity ^0.5.0;



interface IWOPburnable{
    function burnWOP(address account, uint256 amount) external returns(bool);
    function burn(address from, uint256 amount) external returns(bool);
}
