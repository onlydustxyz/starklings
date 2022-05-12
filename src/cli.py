from pathlib import Path
from .runner import Runner
from .verify import ExerciseSeeker
from .constants import exercise_files_architecture
from .utils.starklings_directory import StarklingsDirectory, VersionManager
from .solution import SolutionPatcher


async def cli(args, script_root: Path):
    starklings_directory = StarklingsDirectory(script_root)
    version_manager = VersionManager(starklings_directory)

    if args.version:
        version_manager.print_current_version()

    if args.watch:
        runner = Runner(script_root, version_manager.protostar_version)
        runner.run()

    if args.verify:
        seeker = ExerciseSeeker(exercise_files_architecture, script_root)
        exercise_path = seeker.find_next_exercise()

        if not exercise_path:
            print("All exercises finished ! 🎉")
        else:
            print(exercise_path)

    if args.solution:
        displayer = SolutionPatcher(args.solution)
        opt_solution = displayer.get_solution()
        if opt_solution:
            print(opt_solution)
        else:
            print("Solution file not found")
