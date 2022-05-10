import asyncio

from packaging.version import Version
from src.protostar import protostar_bin


class ExerciceFailed(Exception):
    def __init__(self, message, **kwargs):
        super().__init__(**kwargs)
        self._message = message

    @property
    def message(self):
        return self._message


def _check_v_0_1_0(stdout, stderr):
    if len(stderr) > 0:
        raise ExerciceFailed(stderr)
    if "------- FAILURES --------" in stdout:
        raise ExerciceFailed(stdout)

    return stdout


def _check_v_0_2_0(stdout, stderr):
    if len(stdout) == 0:
        raise ExerciceFailed(stderr)
    if "FAIL" in stdout:
        raise ExerciceFailed(stderr)
    if "Unexpected Protostar error" in stdout:
        raise ExerciceFailed(stderr)
    if "ERROR" in stderr:
        raise ExerciceFailed(stdout)

    return stdout


class ProtostarExerciseChecker:
    def __init__(self, script_root, protostar_version: Version):
        self._protostar_bin = protostar_bin()
        self._current_check = None
        self._script_root = script_root
        self._check = (
            _check_v_0_2_0 if protostar_version > Version("0.1.0") else _check_v_0_1_0
        )

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
        return self._check(stdout, stderr)
