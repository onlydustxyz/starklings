from argparse import ArgumentParser
import asyncio
from src import cli


root_parser = ArgumentParser()

root_parser.add_argument(
    "--version",
    "-v",
    default=False,
    help="Show version-related data",
    action="store_true",
)

try:
    asyncio.run(cli(root_parser.parse_args()))
except Exception as error:
    print(
        "Unexpected Starklings error. Report it here:\nhttps://github.com/onlydustxyz/starklings/issues\n"
    )
    raise err
