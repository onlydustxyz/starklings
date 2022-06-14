from collections import namedtuple
from pathlib import Path
from typing import List


class Exercice(namedtuple("Exercise", ["name"])):
    pass


class Directory(namedtuple("Directory", ["name", "children"])):
    def list_exercises(self, prefix) -> List[Path]:
        res = []

        dir_prefix = f"{self.name}/"

        for child in self.children:
            if isinstance(child, Exercice):
                res.append(Path(f"{prefix}{dir_prefix}{child.name}.cairo"))
            elif isinstance(child, Directory):
                res += child.list_exercises(dir_prefix)

        return res

    def print(self):
        print(self.display(""))

    def display(self, parent_prefix):
        res = f"{parent_prefix}{self.name}/\n"

        for child in self.children:
            if isinstance(child, Exercice):
                res += f"  {parent_prefix}- {child.name}\n"
            elif isinstance(child, Directory):
                res += child.display(parent_prefix + "    ")

        return res


def test_display_course():
    my_course = Directory(
        "exercises",
        [
            Directory(
                "syntax",
                [
                    Exercice("syntax00"),
                    Exercice("syntax01"),
                ],
            ),
            Directory(
                "string",
                [
                    Exercice("strings00"),
                    Exercice("strings01"),
                ],
            ),
        ],
    )

    assert (
        my_course.display("")
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
                    Exercice("syntax01"),
                    Exercice("syntax02"),
                ],
            ),
            Directory(
                "string",
                [
                    Exercice("strings00"),
                    Exercice("strings01"),
                ],
            ),
        ],
    )

    assert my_course.list_exercises("") == [
        Path("exercises/syntax/syntax01.cairo"),
        Path("exercises/syntax/syntax02.cairo"),
        Path("exercises/string/strings00.cairo"),
        Path("exercises/string/strings01.cairo"),
    ]
