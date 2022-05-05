from argparse import ArgumentParser
import asyncio
from pathlib import Path
from tokenize import String
from src import cli
from typing import List


script_root = Path(__file__).parent
root_parser = ArgumentParser()

root_parser.add_argument(
    "--version",
    "-V",
    default=False,
    help="Show version-related data",
    action="store_true",
)

root_parser.add_argument(
    "--verify",
    "-v",
    default=False,
    help="Verifies all exercises according to the recommended order",
    action="store_true",
)

root_parser.add_argument(
    "--watch",
    "-w",
    default=False,
    help="Reruns `verify` when files were edited",
    action="store_true",
)

try:
    asyncio.run(cli(root_parser.parse_args(), script_root))
except Exception as error:
    print(
        "Unexpected Starklings error. Report it here:\nhttps://github.com/onlydustxyz/starklings/issues\n"
    )
    raise error
