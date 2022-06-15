import os
from pathlib import Path

EXERCISES_DIRECTORY_NAME = "exercises"
PATCHES_DIRECTORY_NAME = ".patches"
SOLUTIONS_DIRECTORY_NAME = ".solutions"

GITHUB_CLIENT_ID = "e5335dd9a6d4456d5a61"
GITHUB_GRANT_TYPE = "urn:ietf:params:oauth:grant-type:device_code"

root_directory = (Path(__file__).parents[1]).resolve()
current_working_directory = Path(os.getcwd()).resolve()
exercises_directory = root_directory / EXERCISES_DIRECTORY_NAME
current_working_exercises_directory = (
    current_working_directory / EXERCISES_DIRECTORY_NAME
)
patches_directory = root_directory / PATCHES_DIRECTORY_NAME
solutions_directory = root_directory / SOLUTIONS_DIRECTORY_NAME

dev_mode = root_directory == current_working_directory
