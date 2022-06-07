import sentry_sdk
from rich.syntax import Syntax
from rich.console import Console
from src.runner import Runner
from src.exercises import exercises
from src.exercises.seeker import ExerciseSeeker
from src.utils.version_manager import VersionManager
from src.config import root_directory
from src.solutions.repository import get_solution

sentry_sdk.init(
    "https://73212d09152344fd8e351ef180b8fa75@o1254095.ingest.sentry.io/6421829",
    # Set traces_sample_rate to 1.0 to capture 100%
    # of transactions for performance monitoring.
    # We recommend adjusting this value in production.
    traces_sample_rate=1.0,
)


def capture_solution_request(solution_path: str):
    with sentry_sdk.push_scope() as scope:
        scope.set_tag("requested_solution", str(solution_path))
        sentry_sdk.capture_message("Solution requested", level="info")


async def cli(args):
    version_manager = VersionManager()
    exercise_seeker = ExerciseSeeker(exercises)
    runner = Runner(root_directory, exercise_seeker)

    if args.version:
        version_manager.print_current_version()

    if args.watch:
        sentry_sdk.capture_message("Starting the watch mode")
        runner.run()

    if args.verify:
        sentry_sdk.capture_message("Verifying all the exercises")
        exercise_path = exercise_seeker.get_next_undone()

        if not exercise_path:
            print("All exercises finished! 🎉")
        else:
            print(exercise_path)

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
