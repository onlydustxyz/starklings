# scripts/deploy-only-dust-erc20.py
from nile.nre import NileRuntimeEnvironment
from nile.core.call_or_invoke import call_or_invoke


def run(nre : NileRuntimeEnvironment):

    print("Compiling contracts…")

    nre.compile(["contracts/tournament/Tournament.cairo"])

    print("Deploying contracts…")

    owner = "0x2fe83d7f898b275ca82ccaf6146b49f4827fb1b1415d3973d714874588b313d"
    season_id = "1"
    season_name = str(str_to_felt("StarkNet Hackathon AMS"))
    reward_token_address = "0x00746683a9dd511d66aaa7ecd2c6d8019c11105061a18cf63a82ab5d2bcbfc1d"
    params = [owner, season_id, season_name, reward_token_address]
    address, abi = nre.deploy("Tournament", params, alias="tournament")
    print(f"ABI: {abi},\nContract address: {address}")

# Auxiliary functions
def str_to_felt(text):
    b_text = bytes(text, "ascii")
    return int.from_bytes(b_text, "big")
def uint(a):
    return(a, 0)