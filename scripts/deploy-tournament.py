# scripts/deploy-only-dust-erc20.py
import os
from nile.nre import NileRuntimeEnvironment
from nile.core.call_or_invoke import call_or_invoke


def run(nre : NileRuntimeEnvironment):
    
    admin = os.environ['ADMIN']

    season_id = os.environ['SEASON_ID']
    ships_per_battle = os.environ['SHIPS_PER_BATTLE']
    max_players = os.environ['MAX_PLAYER']

    print("Compiling contracts…")

    nre.compile(
        [
            "contracts/tournament/Tournament.cairo",
            "contracts/core/rand.cairo"
        ]
    )

    print("Deploying contracts…")
    
    rand, _ = nre.deploy("rand", [])

    owner = admin
    season_name = str(str_to_felt("StarkNet Hackathon AMS"))
    reward_token_address, _ = nre.get_deployment("only_dust_token")
    boarding_pass_token_address, _ = nre.get_deployment("starkonquest_boarding_pass")
    print(f"reward_token_address={reward_token_address} boarding_pass_token_address={boarding_pass_token_address}")
    params = [owner, season_id, season_name, reward_token_address, boarding_pass_token_address, rand, ships_per_battle, max_players]
    address, abi = nre.deploy("Tournament", params, alias="tournament")
    print(f"ABI: {abi},\nContract address: {address}")

# Auxiliary functions
def str_to_felt(text):
    b_text = bytes(text, "ascii")
    return int.from_bytes(b_text, "big")
def uint(a):
    return(a, 0)