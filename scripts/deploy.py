# scripts/deploy.py
from nile.nre import NileRuntimeEnvironment
from nile.core.call_or_invoke import call_or_invoke

SPACE_SIZE = 20

def run(nre : NileRuntimeEnvironment):

    print("Compiling contracts…")

    #nre.compile([])

    print("Deploying account…")

    account = nre.get_or_deploy_account("PKEYADMIN")

    print("Deploying contracts…")

    rand, _ = nre.deploy("rand", [])
    space, _ = nre.deploy("space", [account.address])
    dust, _ = nre.deploy("dust", [space, rand])
    #call_or_invoke(space, "invoke", "initialize", [dust, SPACE_SIZE], nre.network, account.signer)
    nre.invoke(space, "initialize", [f"{dust}", f"{SPACE_SIZE}"]) #caller_address=ADMIN
    basic_ship, _ = nre.deploy("basic_ship", [])

    print(f"rand contract address: {rand}")
    print(f"space contract address: {space}")
    print(f"dust contract address: {dust}")
    print(f"basic_ship contract address: {basic_ship}")
