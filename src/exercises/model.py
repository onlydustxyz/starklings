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
        return self.inner_list_exercises("")

    def inner_list_exercises(self, prefix) -> List[Path]:
        dir_prefix = f"{self.name}/"

        res = []

        for child in self.children:
            if isinstance(child, Exercise):
                res.append(Path(prefix) / dir_prefix / f"{child.name}.cairo")
            elif isinstance(child, Directory):
                res += child.inner_list_exercises(dir_prefix)
            else:
                raise Exception(
                    "directory children can only contain Exercises and Directory types"
                )

        return res

    def __str__(self):
        return self.inner_str("")

    def inner_str(self, parent_prefix):
        res = f"{parent_prefix}{self.name}/\n"

        for child in self.children:
            if isinstance(child, Exercise):
                res += f"  {parent_prefix}- {child.name}\n"
            elif isinstance(child, Directory):
                res += child.inner_str(parent_prefix + "    ")

        return res
