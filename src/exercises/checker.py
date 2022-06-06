import asyncio
from queue import Queue
from pathlib import Path
from threading import Lock
from starklings_protostar.commands.test.runner import TestRunner
from starklings_protostar.commands.test.reporter import Reporter
from starklings_protostar.commands.test.cases import PassedCase
from starklings_protostar.commands.test.test_collector import TestCollector

lock = Lock()


class ExerciceFailed(Exception):
    def __init__(self, message, **kwargs):
        super().__init__(**kwargs)
        self._message = message

    @property
    def message(self):
        return self._message


async def check_exercise(exercise_path):
    try:
        test_subjects = TestCollector(
            target=Path(exercise_path),
        ).collect()
        queue = Queue()
        reporter = Reporter(queue)
        runner = TestRunner(reporter=reporter, include_paths=[])
        await asyncio.gather(
            *[runner.run_test_subject(subject) for subject in test_subjects]
        )
    except Exception as error:
        raise ExerciceFailed(str(error)) from error
    for test_case_result in reporter.test_case_results:
        if not isinstance(test_case_result, PassedCase):
            raise ExerciceFailed(str(test_case_result))
