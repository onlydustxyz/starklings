import io
from unittest.mock import patch
from pathlib import Path
from src.runner import ExerciseSeeker, Runner, current_working_directory

PATH = Path("tests/exercises/test_end_of_exercise_messages")


def runner_on_file_changed(current_working_exercises):
    exercise_seeker = ExerciseSeeker(current_working_exercises)
    runner = Runner(exercise_seeker)
    runner.on_file_changed(current_working_directory)


@patch("sys.stdout", new_callable=io.StringIO)
def test_runner_on_file_changed_with_next_exercises(mock_stdout):
    current_working_exercises = [
        PATH / "with_next_exercises" / "syntax01.cairo",
        PATH / "with_next_exercises" / "syntax02.cairo",
    ]
    runner_on_file_changed(current_working_exercises)
    assert (
        mock_stdout.getvalue()
        != "Congratulations! You have completed all the exercises!\n"
    )


@patch("sys.stdout", new_callable=io.StringIO)
def test_runner_on_file_changed_without_next_exercises(mock_stdout):
    current_working_exercises = [
        PATH / "without_next_exercises" / "syntax01.cairo",
        PATH / "without_next_exercises" / "syntax02.cairo",
    ]
    runner_on_file_changed(current_working_exercises)
    assert (
        mock_stdout.getvalue()
        == "Congratulations! You have completed all the exercises!\n"
    )
