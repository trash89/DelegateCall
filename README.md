Two Study cases of delegatecall hack, from Solidity by example site https://solidity-by-example.org/hacks/delegatecall/

In the first file, DelegateCall.sol, is using the assigment of owner in Lib.pwn() to change to override the first member "address public owner" of HackMe

From the Solidity documentation:
"The fallback function is executed on a call to the contract if none of the other functions match the given function signature, or if no data was supplied at all and there is no receive Ether function."

In this case, the fallback was called because there is no function hackMe.pwn() as specified in hackMe.call(abi.encodeWithSignature("pwn()"))

Uncommenting the pwn() function in HackMe will avoid triggering the fallback, but the call to delegatecall will still override the owner of the contract by the assigment in lib.pwn()

In the second file, DelegateCall2.sol, a different utilisation of delegatecall,
overriding variables in HackMe2 contract
