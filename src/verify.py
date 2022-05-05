from pathlib import Path

exercises = [
    ("contracts/beginner", ["ex00", "ex01", "ex02", "ex03", "ex04"]),
    ("contracts/advanced", ["ex00", "ex01"]),
]


def is_exercise_done(path: str) -> bool:
    file = open(path, "r")
    lines = file.readlines()

    for line in lines:
        if line == "# I AM NOT DONE\n":
            return False

    return True


def find_next_exercise(script_root: Path) -> str:
    for (path, exercise_list) in exercises:
        for exercise in exercise_list:
            exercise_path = script_root.joinpath(path).joinpath(
                "{}.cairo".format(exercise)
            )
            if not is_exercise_done(exercise_path):
                return exercise_path

    return None
