from src.config import exercises_directory, current_working_exercises_directory

from .model import Directory, Exercise

course = [
    Directory(
        "syntax",
        [
            Exercise("syntax01"),
            Exercise("syntax02"),
            Exercise("syntax03"),
            Exercise("syntax04"),
            Exercise("syntax05"),
        ],
    ),
    Directory(
        "operations",
        [
            Exercise("operations00"),
            Exercise("operations01"),
            Exercise("operations02"),
            Exercise("operations03"),
        ],
    ),
    Directory(
        "strings",
        [
            Exercise("strings00"),
            Exercise("strings01"),
        ],
    ),
    Directory(
        "storage",
        [
            Exercise("storage01"),
            Exercise("storage02"),
            Exercise("storage03"),
        ],
    ),
    Directory(
        "implicit_arguments",
        [
            Exercise("implicit_arguments01"),
            Exercise("implicit_arguments02"),
            Exercise("implicit_arguments03"),
        ],
    ),
    Directory(
        "recursions",
        [
            Exercise("recursion01"),
            Exercise("array01"),
            Exercise("array02"),
            Exercise("array03"),
            Exercise("array04"),
            Exercise("struct01"),
            Exercise("collatz_sequence"),
        ],
    ),
    Directory(
        "registers",
        [
            Exercise("registers00"),
            Exercise("registers01"),
            Exercise("registers02"),
            Exercise("registers03"),
            Exercise("registers04"),
        ],
    ),
    Directory(
        "revoked_references",
        [
            Exercise("revoked_references01"),
        ],
    ),
    Directory(
        "builtins",
        [
            Exercise("bitwise"),
        ],
    ),
    Directory(
        "tricks",
        [
            Exercise("no_conditionals"),
            Exercise("assert_bool"),
            Exercise("inline_if"),
        ],
    ),
    Directory(
        "hints",
        [
            Exercise("hints00"),
            Exercise("hints01"),
        ],
    ),
]

exercises = Directory(exercises_directory, course).list_exercises()

current_working_exercises = Directory(
    current_working_exercises_directory, course
).list_exercises()
