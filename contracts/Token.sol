pragma solidity ^0.4.24;
/*
 * @title: Verified Token
 * Implementation of transfer() and transferFrom() that checks if the receiver
 * has enlisted in the registries required by the token issuer/controller
 * Created on 2018-04-26, by Blockchain Labs, NZ
 */
import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./interfaces/IController.sol";
import "./interfaces/IToken.sol";


contract Token is IToken, Ownable, StandardToken {
  IController private tokenController;

  /*
   * @dev: It requires to setup controller on deployment of the token contract
   * @param _controller - address of Verified Token Controller contract
   */
  constructor(IController _controller) public {
    changeController(_controller);
  }

  /*
   * @dev: It calls standard transfer() function after checking if the transfer is allowed.
   * @param _to  - address of recipient
   * @param _value - the amount to transfer
   */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(tokenController.isTransferAllowed(_to, msg.sender));
    super.transfer(_to, _value);
  }

  /*
   * @dev: It calls standard transferFrom() function after checking if the transfer is allowed.
   * @param _from - address of sender
   * @param _to  - address of recipient
   * @param _value - the amount to transfer
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(tokenController.isTransferAllowed(_to, _from));
    super.transferFrom(_from, _to, _value);
  }

  /*
   * @dev: It returns address of current Controller contract
   */
  function getController() public view returns (address) {
    return address(tokenController);
  }

  /*
   * @dev: Change the controller of the Token
   */
  function changeController(IController _controller) public onlyOwner returns (address) {
    require(_controller != tokenController, "Controller should not be the same");
    tokenController = IController(_controller);
    emit ControllerChanged(_controller, now);
  }
}
