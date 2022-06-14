from src.config import exercises_directory, current_working_exercises_directory

from .course_representation_types import Directory, Exercice

course = [
    Directory(
        "syntax",
        [
            Exercice("syntax01"),
            Exercice("syntax02"),
            Exercice("syntax03"),
            Exercice("syntax04"),
            Exercice("syntax05"),
        ],
    ),
    Directory(
        "strings",
        [
            Exercice("strings00"),
            Exercice("strings01"),
        ],
    ),
    Directory(
        "storage",
        [
            Exercice("storage01"),
            Exercice("storage02"),
            Exercice("storage03"),
        ],
    ),
    Directory(
        "implicit_arguments",
        [
            Exercice("implicit_arguments01"),
            Exercice("implicit_arguments02"),
            Exercice("implicit_arguments03"),
        ],
    ),
    Directory(
        "recursions",
        [
            Exercice("recursion01"),
            Exercice("array01"),
            Exercice("array02"),
            Exercice("array03"),
            Exercice("array04"),
            Exercice("struct01"),
            Exercice("collatz_sequence"),
        ],
    ),
    Directory(
        "registers",
        [
            Exercice("registers00"),
            Exercice("registers01"),
            Exercice("registers02"),
            Exercice("registers03"),
        ],
    ),
    Directory(
        "revoked_references",
        [
            Exercice("revoked_references01"),
        ],
    ),
    Directory(
        "tricks",
        [
            Exercice("no_conditionals"),
            Exercice("assert_bool"),
        ],
    ),
    Directory(
        "hints",
        [
            Exercice("hints00"),
            Exercice("hints01"),
        ],
    ),
]

exercises = Directory(exercises_directory, course).list_exercises("")

current_working_exercises = Directory(
    current_working_exercises_directory, course
).list_exercises("")
