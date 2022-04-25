# scripts/deploy-only-dust-erc20.py
from nile.nre import NileRuntimeEnvironment
from nile.core.call_or_invoke import call_or_invoke


def run(nre : NileRuntimeEnvironment):

    print("Compiling contracts…")

    nre.compile(["contracts/token/StarKonquestBoardingPass.cairo"])

    print("Deploying contracts…")

    name = str(str_to_felt("StarKonquestBoardingPass"))
    symbol = str(str_to_felt("SKBP"))
    owner = "0x2fe83d7f898b275ca82ccaf6146b49f4827fb1b1415d3973d714874588b313d"
    params = [name, symbol, owner]
    address, abi = nre.deploy("StarKonquestBoardingPass", params, alias="starkonquest_boarding_pass")
    print(f"ABI: {abi},\nContract address: {address}")

# Auxiliary functions
def str_to_felt(text):
    b_text = bytes(text, "ascii")
    return int.from_bytes(b_text, "big")
def uint(a):
    return(a, 0)