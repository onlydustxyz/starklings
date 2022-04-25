# scripts/deploy-only-dust-erc20.py
import os
from nile.nre import NileRuntimeEnvironment
from nile.core.call_or_invoke import call_or_invoke


def run(nre : NileRuntimeEnvironment):

    admin = os.environ['ADMIN']

    print("Compiling contracts…")

    nre.compile(["contracts/token/StarKonquestBoardingPass.cairo"])

    print("Deploying contracts…")

    name = str(str_to_felt("StarKonquestBoardingPass"))
    symbol = str(str_to_felt("SKBP"))
    owner = admin
    params = [name, symbol, owner]
    address, abi = nre.deploy("StarKonquestBoardingPass", params, alias="starkonquest_boarding_pass")
    print(f"ABI: {abi},\nContract address: {address}")

# Auxiliary functions
def str_to_felt(text):
    b_text = bytes(text, "ascii")
    return int.from_bytes(b_text, "big")
def uint(a):
    return(a, 0)