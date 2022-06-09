from colorama import init, Fore, Style

init(autoreset=True)


def on_watch_start(exercise_path):
    print(f"{Style.BRIGHT}🤖🤖🤖 Watch mode started.")
    print(f"You can start to work on exercise {exercise_path}.\n")


def on_single_exercise_success(exercise_path):
    print(f"{Style.BRIGHT}{Fore.GREEN}🥳🥳🥳 Exercise {exercise_path} completed!")


def on_watch_exercise_success():
    print("You can keep working on this exercise,")
    print("or move on to the next one by removing the `I AM NOT DONE` comment.\n")


def on_exercise_failure(exercise_path, error_message):
    print(f"{Fore.RED}🚧 Exercise {exercise_path} failed. Please try again.")
    print(error_message)


def on_exercise_check(exercise_path):
    print(f"{Style.DIM}👀 Checking exercise {exercise_path}...")


def on_file_not_found():
    print(
        f"{Fore.RED}🧐 Creepy crap it looks that you are not running this script from the root directory of the repository."
    )
    print(
        f"{Fore.RED}Please make sure you are running the CLI from the cloned Starklings repository."
    )
