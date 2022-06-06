from pathlib import Path
from src.config import solutions_directory


def get_solution(exercise_path: Path):
    # When packaged, the solutions are all flattened into the .solutions directory.
    solution_path = solutions_directory / exercise_path.name
    return solution_path.read_text()
