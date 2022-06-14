from rich import print as rich_print
from src.console import console


def on_watch_start(exercise_path):
    rich_print("[bold]:robot::robot::robot: Watch mode started.[/bold]")
    rich_print(f"You can start to work on exercise {exercise_path}.\n")


def on_single_exercise_success(exercise_path):
    console.clear()
    rich_print(
        f"[bold green]:partying_face::partying_face::partying_face: Exercise {exercise_path} completed![/bold green]"
    )


def on_watch_exercise_success():
    rich_print("You can keep working on this exercise,")
    rich_print("or move on to the next one by removing the `I AM NOT DONE` comment.\n")


def on_watch_no_next_exercise():
    rich_print("Congratulations! You have completed all the exercises!")


def on_exercise_failure(exercise_path, error_message):
    console.clear()
    rich_print(
        f"[red]:construction: Exercise {exercise_path} failed. Please try again.[/red]"
    )
    rich_print(error_message)


def on_exercise_check(exercise_path):
    console.clear()
    rich_print(f"[gray]:eyes: Checking exercise {exercise_path}...[/gray]")


def on_file_not_found():
    console.clear()
    rich_print(
        "[red]:face_with_monocle: Creepy crap it looks that you are not running this script from the root directory of the repository.[/red]"
    )
    rich_print(
        "[red]Please make sure you are running the CLI from the cloned Starklings repository.[/red]"
    )


def on_user_verification(verification_uri: str, verification_code: str):
    console.clear()
    rich_print(
        f"Please visit {verification_uri} to login and enter the following code: [bold]{verification_code}[/bold]"
    )


def waiting_for_user_login():
    return console.status("Waiting for user login...")
