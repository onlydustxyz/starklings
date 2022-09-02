from pathlib import Path
from .model import Directory, Exercise


def test_display_course():
    my_course = Directory(
        "exercises",
        [
            Directory(
                "syntax",
                [
                    Exercise("syntax00"),
                    Exercise("syntax01"),
                ],
            ),
            Directory(
                "strings",
                [
                    Exercise("string00"),
                    Exercise("string01"),
                ],
            ),
        ],
    )

    assert (
        my_course.__str__()
        == """exercises/
    syntax/
      - syntax00
      - syntax01
    strings/
      - string00
      - string01
"""
    )


def test_list_exercise():
    my_course = Directory(
        "exercises",
        [
            Directory(
                "syntax",
                [
                    Exercise("syntax01"),
                    Exercise("syntax02"),
                ],
            ),
            Directory(
                "string",
                [Exercise("strings00"), Exercise("strings01")],
            ),
        ],
    )

    assert my_course.list_exercises() == [
        Path("exercises/syntax/syntax01.cairo"),
        Path("exercises/syntax/syntax02.cairo"),
        Path("exercises/string/strings00.cairo"),
        Path("exercises/string/strings01.cairo"),
    ]
