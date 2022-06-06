from pathlib import Path
from typing import List


def _is_exercise_not_done(exercise: Path) -> bool:
    return "\n# I AM NOT DONE\n" in exercise.read_text()


class ExerciseSeeker:
    def __init__(self, exercises: List[Path]):
        self._exercises = exercises

    def get_next_undone(self) -> Path:
        for exercise in self._exercises:
            if _is_exercise_not_done(exercise):
                return exercise
        return None
