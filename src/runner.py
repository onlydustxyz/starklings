import asyncio
import contextlib
from pathlib import Path
import sys
from threading import Lock
from time import sleep

import sentry_sdk

from src.exercises.checker import ExerciceFailed, check_exercise
from src.file_watcher.watcher import FileWatcher
from src import prompt
from src.exercises.seeker import ExerciseSeeker

check_exercise_lock = Lock()


async def single_exercise_check(exercise_path: Path):
    if check_exercise_lock.locked():
        return
    with check_exercise_lock:
        prompt.on_exercise_check(exercise_path)
        try:
            await check_exercise(str(exercise_path))
            capture_exercise_solved(exercise_path)
            prompt.on_exercise_success(exercise_path)
        except ExerciceFailed as error:
            prompt.on_exercise_failure(exercise_path, error.message)


def capture_exercise_solved(exercise_path: str):
    with sentry_sdk.push_scope() as scope:
        scope.set_tag("exercise_solved", str(exercise_path))
        sentry_sdk.capture_message("Exercise solved", level="info")


class Runner:
    def __init__(self, root_path: Path, exercise_seeker: ExerciseSeeker):
        self._file_watcher = FileWatcher(root_path)
        self._exercise_seeker = exercise_seeker

    def on_file_changed(self, _):
        next_exercise_path = self._exercise_seeker.get_next_undone()
        asyncio.run(single_exercise_check(next_exercise_path))

    def watch(self):
        try:
            prompt.on_watch_start(self._exercise_seeker.get_next_undone())
            with contextlib.suppress(KeyboardInterrupt):
                self._file_watcher.start(self.on_file_changed)
                while True:
                    sleep(5)
        except FileNotFoundError:
            prompt.on_file_not_found()
            sys.exit(1)
