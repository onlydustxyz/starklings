from pathlib import Path
import sentry_sdk
from rich.syntax import Syntax
from rich.console import Console
from src.runner import Runner, single_exercise_check
from src.exercises import current_working_exercises
from src.exercises.seeker import ExerciseSeeker
from src.utils.version_manager import VersionManager
from src.config import root_directory, current_working_directory, dev_mode
from src.solutions.repository import get_solution

version_manager = VersionManager()

sentry_sdk.init(
    "https://73212d09152344fd8e351ef180b8fa75@o1254095.ingest.sentry.io/6421829",
    # Set traces_sample_rate to 1.0 to capture 100%
    # of transactions for performance monitoring.
    # We recommend adjusting this value in production.
    traces_sample_rate=1.0,
    environment="development" if dev_mode else "production",
    release=str(version_manager.starklings_version),
)


def capture_solution_request(solution_path: str):
    with sentry_sdk.push_scope() as scope:
        scope.set_tag("requested_solution", str(solution_path))
        sentry_sdk.capture_message("Solution requested", level="info")


def capture_single_exercise_check(exercise_path: Path):
    exercise_relative_path = exercise_path.relative_to(current_working_directory)
    with sentry_sdk.push_scope() as scope:
        scope.set_tag("exercise_to_check", str(exercise_relative_path))
        sentry_sdk.capture_message("Single exercise check", level="info")


async def cli(args):
    exercise_seeker = ExerciseSeeker(current_working_exercises)
    runner = Runner(exercise_seeker)

    if args.version:
        version_manager.print_current_version()
        return

    if args.watch:
        sentry_sdk.capture_message("Starting the watch mode")
        runner.watch()
        return

    if args.verify:
        exercise_path = args.verify
        capture_single_exercise_check(exercise_path)
        await single_exercise_check(exercise_path)
        return

    if args.solution:
        capture_solution_request(args.solution)
        exercise_path = root_directory / args.solution
        try:
            solution = get_solution(exercise_path)

            console = Console()
            syntax = Syntax(
                solution, "python", line_numbers=True, background_color="default"
            )
            console.print(syntax)
        except FileNotFoundError:
            print("Solution not found")
        return
