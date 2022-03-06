pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
// import "@openzeppelin/contracts/access/Ownable.sol"; 
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol
import "@openzeppelin/contracts/utils/Strings.sol";

contract YourContract {

  event SetPurpose(address sender, string purpose);
  event Log(address indexed sender, string msg);

  struct AccountInfo {
      string name;
      string photoUrl;
      bool verified;
  }

  address public owner = 0x2f9A926bE323A74567F0258a2e431340D74ED83f;
//   address public owner;

  mapping(address => uint256) public balance;
  AccountInfo[] public accountInfos;

  string public purpose = "Building Unstoppable Apps!!!";

  constructor() payable {
    // owner = msg.sender;
    balance[owner] = 100;
  }

  modifier onlyOwner() {
      require( msg.sender == owner, "NOT OWNER");
      _;
  }

  function createAccount(string memory _name, string memory _photoUrl) public onlyOwner {
      accountInfos.push(AccountInfo(_name, _photoUrl, false));
  }

  function updateAccount(uint _index, string memory _name, string memory _photoUrl, bool _verified) public onlyOwner {
      require( msg.sender == owner, "NOT OWNER");
      AccountInfo storage accountInfo = accountInfos[_index];
      accountInfo.name = _name;
      accountInfo.photoUrl = _photoUrl;
      accountInfo.verified = _verified;
      emit Log(msg.sender, "Account updated");
  }

  function transfer(address to, uint256 amount) public {
      require( balance[msg.sender] >= amount, "NOT ENOUGH");
      balance[msg.sender] -= amount;
      balance[to] += amount;
      console.log(string(abi.encodePacked("tranfered amount of ", Strings.toString(amount), " to ", to)));
      emit Log(msg.sender, string(abi.encodePacked("tranfered amount of ", Strings.toString(amount), " to ", to)));
  }

  function setPurpose(string memory newPurpose) public payable {
      require( msg.value == 0.001 ether, "NOT ENOUGH");
      purpose = newPurpose;
      console.log(msg.sender,"set purpose to",purpose);
      emit SetPurpose(msg.sender, purpose);
  }

  function withdraw() public {
    require( msg.sender == owner, "NOT OWNER");
    (bool success,) =  owner.call{value: address(this).balance }("");
    require( success, "FAILED");
  }

  // to support receiving ETH by default
  receive() external payable {}
  fallback() external payable {}
}

contract A {
    function foo() public pure virtual returns (string memory) {
        return "A";
    }
}

contract B {
    function foo() public pure virtual returns (string memory) {
        return "B";
    }
}

contract C is A,B {
    function foo() public pure override(A, B) returns (string memory) {
        return super.foo();
    }
}

contract Fallback {
    event Log(uint gas);

    fallback() external payable {
        emit Log(gasleft());
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract SendToFallback {
    function transferToFallback(address payable _to) public payable {
        _to.transfer(msg.value);
    }

    function callFallback(address payable _to) public payable {
        (bool sent, ) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
}
