import asyncio
from pathlib import Path
from time import sleep
from src.exercise_checker.checker import ExerciceFailed, ProtostarExerciseChecker
from src.file_watcher.watcher import FileWatcher
from src import prompt
from src.verify import ExerciseSeeker
from src.constants import exercise_files_architecture


class Runner:
    def __init__(self, root_path: Path, protostar_version):
        self._file_watcher = FileWatcher(root_path)
        self._exercise_checker = ProtostarExerciseChecker(root_path, protostar_version)
        self._exercise_seeker = ExerciseSeeker(exercise_files_architecture, root_path)
        prompt.on_watch_start(self._exercise_seeker.find_next_exercise())

    def on_file_changed(self, _):
        asyncio.run(self._check_exercise())

    async def _check_exercise(self):
        next_exercise_path = self._exercise_seeker.find_next_exercise()
        prompt.on_exercise_check(next_exercise_path)
        try:
            await self._exercise_checker.run(str(next_exercise_path))
            prompt.on_exercise_success(next_exercise_path)
        except ExerciceFailed as error:
            prompt.on_exercise_failure(next_exercise_path, error.message)

    def run(self):
        try:
            self._file_watcher.start(self.on_file_changed)
            while True:
                sleep(5)
        except KeyboardInterrupt:
            pass
