import time
from ast import Return
from pathlib import Path
from .verify import find_next_exercise
from .watch import watch

from src.utils.starklings_directory import StarklingsDirectory, VersionManager


async def cli(args, script_root: Path):
    starklings_directory = StarklingsDirectory(script_root)
    version_manager = VersionManager(starklings_directory)

    if args.version:
        version_manager.print_current_version()

    if args.watch:
        watch(script_root.joinpath("contracts"))

    if args.verify:
        res = find_next_exercise(script_root)
        if not res:
            print("All exercises finished ! 🎉")
        else:
            print(res)
