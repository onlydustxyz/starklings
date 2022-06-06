from src.config import exercises_directory


exercise_list = [
    "syntax/syntax01",
    "syntax/syntax02",
    "syntax/syntax03",
    "syntax/syntax04",
    "syntax/syntax05",
    "strings/strings00",
    "strings/strings01",
]

exercises = (
    exercises_directory / f"{relative_path}.cairo" for relative_path in exercise_list
)
