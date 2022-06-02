from argparse import ArgumentParser
import asyncio
import os
from pathlib import Path
from src import cli


script_root = Path(os.getcwd())
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


def is_valid_file(parser, arg):
    if not os.path.exists(arg):
        return parser.error(f"The file {arg} does not exist!")
    return Path(arg)


root_parser.add_argument(
    "-s",
    "--solution",
    help="path to an exercise file",
    type=lambda x: is_valid_file(root_parser, x),
)

try:
    asyncio.run(cli(root_parser.parse_args(), script_root))
except Exception as error:
    print(
        "Unexpected Starklings error. Report it here:\n"
        + "https://github.com/onlydustxyz/starklings/issues\n"
    )
    raise error
