from argparse import ArgumentParser
import asyncio
import os
from pathlib import Path
from rich.traceback import install
from src import cli
from src.config import current_working_directory

install(show_locals=True)


def is_valid_file(parser, arg):
    file_path = Path(arg).resolve()
    if not file_path.exists():
        file_path = current_working_directory / arg
    if not file_path.exists():
        return parser.error(f"The file {arg} does not exist!")
    return file_path


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
    metavar="relative_path_to_exercise",
    help="Verify a single exercise",
    type=lambda x: is_valid_file(root_parser, x),
)


root_parser.add_argument(
    "--watch",
    "-w",
    default=False,
    help="Watch edited files and verify them",
    action="store_true",
)

root_parser.add_argument(
    "-s",
    "--solution",
    metavar="relative_path_to_exercise",
    help="Provide a solution for an exercise",
    type=lambda x: is_valid_file(root_parser, x),
)

try:
    asyncio.run(cli(root_parser.parse_args()))
except Exception as error:
    print(
        "Unexpected Starklings error. Report it here:\n"
        + "https://github.com/onlydustxyz/starklings/issues\n"
    )
    raise error
