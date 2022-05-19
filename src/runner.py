import asyncio
import contextlib
from pathlib import Path
import sys
from threading import Lock
from time import sleep
from src.exercise_checker.checker import ExerciceFailed, check_exercise
from src.file_watcher.watcher import FileWatcher
from src import prompt
from src.verify import ExerciseSeeker
from src.constants import exercise_files_architecture

check_exercise_lock = Lock()


class Runner:
    def __init__(self, root_path: Path):
        self._file_watcher = FileWatcher(root_path)
        self._exercise_seeker = ExerciseSeeker(exercise_files_architecture, root_path)
        try:
            prompt.on_watch_start(self._exercise_seeker.find_next_exercise())
        except FileNotFoundError:
            prompt.on_file_not_found()
            sys.exit(1)

    def on_file_changed(self, _):
        asyncio.run(self._check_exercise())

    async def _check_exercise(self):
        if check_exercise_lock.locked():
            return
        with check_exercise_lock:
            next_exercise_path = self._exercise_seeker.find_next_exercise()
            prompt.on_exercise_check(next_exercise_path)
            try:
                await check_exercise(str(next_exercise_path))
                prompt.on_exercise_success(next_exercise_path)
            except ExerciceFailed as error:
                prompt.on_exercise_failure(next_exercise_path, error.message)

    def run(self):
        try:
            with contextlib.suppress(KeyboardInterrupt):
                self._file_watcher.start(self.on_file_changed)
                while True:
                    sleep(5)
        except FileNotFoundError:
            prompt.on_file_not_found()
