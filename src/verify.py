from pathlib import Path


class ExerciseSeeker:
    def __init__(self, exercises, root_directory: Path):
        self._exercises = exercises
        self._directory = root_directory

    @staticmethod
    def _is_exercise_done(path: str) -> bool:
        file = open(path, "r")
        lines = file.readlines()

        for line in lines:
            if line == "# I AM NOT DONE\n":
                return False

        return True

    def find_next_exercise(self) -> str:
        for (path, exercise_list) in self._exercises:
            for exercise in exercise_list:
                exercise_path = self._directory.joinpath(path).joinpath(
                    "{}.cairo".format(exercise)
                )
                if not self._is_exercise_done(exercise_path):
                    return exercise_path

        return None
