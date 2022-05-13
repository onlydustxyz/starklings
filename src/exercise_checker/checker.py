from starklings_protostar.commands.test import run_test_runner
from starklings_protostar.commands.test.cases import PassedCase


class ExerciceFailed(Exception):
    def __init__(self, message, **kwargs):
        super().__init__(**kwargs)
        self._message = message

    @property
    def message(self):
        return self._message


class ProtostarExerciseChecker:
    def __init__(self):
        self._checking = False

    async def run(self, exercise_path):
        if self._checking:
            return
        try:
            self._checking = True
            [reporter] = await run_test_runner(exercise_path, None, None, None)
        except Exception as error:
            self._checking = False
            raise ExerciceFailed(error) from error
        self._checking = False
        [test_case_result] = reporter.test_case_results
        if isinstance(test_case_result, PassedCase):
            return str(test_case_result)
        raise ExerciceFailed(str(test_case_result))
