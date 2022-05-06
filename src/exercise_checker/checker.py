import asyncio
from src.protostar import protostar_bin


class ExerciceFailed(Exception):
    def __init__(self, message, **kwargs):
        super().__init__(**kwargs)
        self._message = message

    @property
    def message(self):
        return self._message


class ProtostarExerciseChecker:
    def __init__(self, script_root):
        self._protostar_bin = protostar_bin()
        self._current_check = None
        self._script_root = script_root

    async def run(self, exercise_path):
        if self._current_check is not None:
            self._current_check.terminate()
        self._current_check = await asyncio.create_subprocess_shell(
            f"{self._protostar_bin} test {exercise_path}",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
            cwd=str(self._script_root),
        )

        raw_stdout, raw_stderr = await self._current_check.communicate()
        stdout = raw_stdout.decode("utf-8")
        stderr = raw_stderr.decode("utf-8")
        self._current_check = None
        if len(stderr) > 0:
            raise ExerciceFailed(stderr)
        if "------- FAILURES --------" in stdout:
            raise ExerciceFailed(stdout)

        return stdout
