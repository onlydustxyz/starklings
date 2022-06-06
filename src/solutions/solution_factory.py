import os
from pathlib import Path
import shutil
from src.config import solutions_directory, exercises_directory, patches_directory


def empty_directory(path: Path):
    if path.exists():
        shutil.rmtree(path)
    path.mkdir()


def create_solution(exercise_path: Path):
    exercise_relative_path = exercise_path.relative_to(exercises_directory)
    solution_path = solutions_directory / exercise_relative_path
    patch_path = patches_directory / f"{exercise_relative_path}.patch"
    os.makedirs(solution_path.parent)
    solution_path.touch()
    os.system(f"patch {exercise_path} -o {solution_path} < {patch_path}")


class SolutionFactory:
    def __init__(self):
        empty_directory(solutions_directory)
        create_solution(exercises_directory / "hints/hints00.cairo")
