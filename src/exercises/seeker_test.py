import pytest
from src.exercises.seeker import ExerciseSeeker


@pytest.fixture(name="finished_exercise")
def finished_exercise_fixture(mocker):
    mock = mocker.patch("src.exercises.seeker.Path").return_value
    mock.read_text.return_value = "Yolo"
    return mock


@pytest.fixture(name="unfinished_exercise")
def unfinished_exercise_fixture(mocker):
    mock = mocker.patch("src.exercises.seeker.Path").return_value
    mock.read_text.return_value = "Yolo\n# I AM NOT DONE\nNext"
    return mock


def test_next_undone_exercise(finished_exercise, unfinished_exercise):
    exercise_seeker = ExerciseSeeker([finished_exercise])
    assert exercise_seeker.get_next_undone() is None

    exercise_seeker = ExerciseSeeker([finished_exercise, unfinished_exercise])
    assert exercise_seeker.get_next_undone() is unfinished_exercise
