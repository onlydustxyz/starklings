from colorama import init, Fore, Style

init(autoreset=True)


def on_watch_start(exercise_path):
    print(f"{Style.BRIGHT}🤖🤖🤖 Watch mode started.")
    print(f"You can start to work on exercise {exercise_path}.\n")


def on_exercise_success(exercise_path):
    print(f"{Style.BRIGHT}{Fore.GREEN}🥳🥳🥳 Exercise {exercise_path} completed!")
    print("You can keep working on this exercise,")
    print("or move on to the next one by removing the `I AM NOT DONE` comment.\n")


def on_exercise_failure(exercise_path, error_message):
    print(f"{Fore.RED}🚧 Exercise {exercise_path} failed. Please try again.")
    print(error_message)


def on_exercise_check(exercise_path):
    print(f"{Style.DIM}👀 Checking exercise {exercise_path}...")
