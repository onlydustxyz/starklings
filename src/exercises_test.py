from src.exercises import exercises


def test_exercises_exist():
    for exercise in exercises:
        assert exercise.exists()
