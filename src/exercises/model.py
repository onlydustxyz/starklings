from collections import namedtuple
from pathlib import Path
from typing import List


class Exercise(namedtuple("Exercise", ["name"])):
    pass


class Directory(namedtuple("Directory", ["name", "children"])):
    def __new__(cls, name, children):
        assert all(
            isinstance(x, (Directory, Exercise)) for x in children
        ), "Directory children can only be of type Directory of Exercise"
        self = super(Directory, cls).__new__(cls, name, children)
        return self

    def list_exercises(self) -> List[Path]:
        return self.__inner_list_exercises__("")

    def __inner_list_exercises__(self, prefix) -> List[Path]:
        dir_prefix = f"{self.name}/"

        res = []

        for child in self.children:
            if isinstance(child, Exercise):
                res.append(Path(f"{prefix}{dir_prefix}{child.name}.cairo"))
            elif isinstance(child, Directory):
                res += child.__inner_list_exercises__(dir_prefix)
            else:
                raise Exception(
                    "directory children can only contain Exercises and Directory types"
                )

        return res

    def __str__(self):
        return self.__inner_str__("")

    def __inner_str__(self, parent_prefix):
        res = f"{parent_prefix}{self.name}/\n"

        for child in self.children:
            if isinstance(child, Exercise):
                res += f"  {parent_prefix}- {child.name}\n"
            elif isinstance(child, Directory):
                res += child.__inner_str__(parent_prefix + "    ")

        return res
