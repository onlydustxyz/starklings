from src.config import exercises_directory, current_working_exercises_directory


exercise_list = [
    "syntax/syntax01",
    "syntax/syntax02",
    "syntax/syntax03",
    "syntax/syntax04",
    "syntax/syntax05",
    "strings/strings00",
    "strings/strings01",
    "storage/storage01",
    "storage/storage02",
    "storage/storage03",
    "implicit_arguments/implicit_arguments01",
    "implicit_arguments/implicit_arguments02",
    "implicit_arguments/implicit_arguments03",
    "recursions/recursion01",
    "recursions/array01",
    "recursions/array02",
    "recursions/array03",
    "recursions/array04",
    "recursions/struct01",
    "recursions/collatz_sequence",
    "registers/registers00",
    "registers/registers01",
    "registers/registers02",
    "revoked_references/revoked_references01",
    "tricks/no_conditionals",
    "tricks/assert_bool",
    "hints/hints00",
    "hints/hints01",
]

exercises = [
    exercises_directory / f"{relative_path}.cairo" for relative_path in exercise_list
]
current_working_exercises = [
    current_working_exercises_directory / f"{relative_path}.cairo"
    for relative_path in exercise_list
]
