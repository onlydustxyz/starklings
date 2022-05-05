import time
from ast import Return
from pathlib import Path
from .verify import ExerciseSeeker
from .watch import FilesystemWatcher
from .constants import exercise_files_architecture

from src.utils.starklings_directory import StarklingsDirectory, VersionManager


async def cli(args, script_root: Path):
    starklings_directory = StarklingsDirectory(script_root)
    version_manager = VersionManager(starklings_directory)

    if args.version:
        version_manager.print_current_version()

    if args.watch:
        watcher = FilesystemWatcher(script_root.joinpath("contracts"))
        watcher.start()

    if args.verify:
        seeker = ExerciseSeeker(exercise_files_architecture, script_root)
        exercise_path = seeker.find_next_exercise()

        if not exercise_path:
            print("All exercises finished ! 🎉")
        else:
            print(exercise_path)
