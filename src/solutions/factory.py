import os
from pathlib import Path
import shutil
from typing import List
from src.config import solutions_directory, exercises_directory, patches_directory
from src.exercises import exercises


def empty_directory(path: Path):
    if path.exists():
        shutil.rmtree(path)
    path.mkdir()


def create_solution(exercise_path: Path):
    exercise_relative_path = exercise_path.relative_to(exercises_directory)
    solution_path = (
        solutions_directory / exercise_path.name
    )  # Flatten the exercises tree in the solutions directory
    patch_path = patches_directory / f"{exercise_relative_path}.patch"
    try:
        os.makedirs(solution_path.parent)
    except FileExistsError:
        pass
    solution_path.touch()
    os.system(f"patch {exercise_path} -o {solution_path} < {patch_path}")


def init(exercise_list: List[Path] = None):
    exercise_list = exercise_list or exercises
    empty_directory(solutions_directory)
    for exercise in exercise_list:
        create_solution(exercise)
