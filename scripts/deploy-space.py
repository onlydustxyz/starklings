# scripts/deploy.py
import os
from nile.nre import NileRuntimeEnvironment
from nile.core.call_or_invoke import call_or_invoke

def run(nre : NileRuntimeEnvironment):

    space_size = os.environ['SPACE_SIZE']
    turn_count = os.environ['TURN_COUNT']
    max_dust = os.environ['MAX_DUST']

    print("Compiling contracts…")

    nre.compile(
        [
            "contracts/core/rand.cairo",
            "contracts/core/space.cairo"
        ]
    )

    print("Deploying contracts…")

    randAddress, _ = nre.deploy("rand", [])
    print(f"Rand contract address: {randAddress}")

    print(f"Deploying Space contract with params: space_size={space_size} turn_count={turn_count} max_dust={max_dust}")
    spaceAddress, abi = nre.deploy("space")
    nre.invoke(spaceAddress, "initialize", [f"{randAddress}", f"{space_size}", f"{turn_count}", f"{max_dust}"])
    print(f"ABI: {abi},\nSpace contract address: {spaceAddress}")
