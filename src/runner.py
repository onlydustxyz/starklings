import asyncio
from pathlib import Path
from time import sleep
from src.exercise_checker.checker import ExerciceFailed, ProtostarExerciseChecker
from src.file_watcher.watcher import FileWatcher
from src.verify import ExerciseSeeker
from src.constants import exercise_files_architecture


class Runner:
    def __init__(self, root_path: Path):
        self._file_watcher = FileWatcher(root_path)
        self._exercise_checker = ProtostarExerciseChecker(root_path)
        self._exercise_seeker = ExerciseSeeker(exercise_files_architecture, root_path)

    def on_file_changed(self, _):
        asyncio.run(self._check_exercise())

    async def _check_exercise(self):
        next_exercise_path = self._exercise_seeker.find_next_exercise()
        print(f"Checking exercise {next_exercise_path}...")
        try:
            test_result = await self._exercise_checker.run(str(next_exercise_path))
            print(test_result)
        except ExerciceFailed as error:
            print(error.message)

    def run(self):
        self._file_watcher.start(self.on_file_changed)
        while True:
            sleep(5)
