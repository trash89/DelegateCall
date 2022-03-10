from brownie import accounts, Lib, Attack, HackMe


def main():

    # Examples from DelegateCall.sol
    lib = Lib.deploy({"from": accounts[0]})
    print(f"Accounts[0] deployed Lib at {lib}")

    hm = HackMe.deploy(lib.address, {"from": accounts[0]})
    print(f"Accounts[0] deployed HackMe at {hm}")

    print(f"HackMe owner is {hm.owner()}")

    att = Attack.deploy(hm.address, {"from": accounts[1]})
    print(f"Accounts[1] deployed Attack at {att}")

    tx = att.attack({"from": accounts[1]})
    tx.wait(1)
    print(f"Now, HackMe owner is {hm.owner()}")
