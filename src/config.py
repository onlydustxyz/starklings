from pathlib import Path

EXERCISES_DIRECTORY_NAME = "exercises"
PATCHES_DIRECTORY_NAME = ".patches"
SOLUTIONS_DIRECTORY_NAME = ".solutions"

root_directory = (Path(__file__).parents[1]).resolve()
exercises_directory = root_directory / EXERCISES_DIRECTORY_NAME
patches_directory = root_directory / PATCHES_DIRECTORY_NAME
solutions_directory = root_directory / SOLUTIONS_DIRECTORY_NAME
