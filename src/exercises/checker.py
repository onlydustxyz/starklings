from threading import Lock
from protostar.testing import TestCollector
from protostar.utils.compiler.pass_managers import StarknetPassManagerFactory
from protostar.utils.starknet_compilation import CompilerConfig, StarknetCompiler
from ..config import current_working_directory

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
        include_paths = []
        factory = StarknetPassManagerFactory

        result = TestCollector(
            StarknetCompiler(
                config=CompilerConfig(
                    disable_hint_validation=True, include_paths=include_paths
                ),
                pass_manager_factory=factory,
            ),
            config=TestCollector.Config(safe_collecting=True),
        ).collect(
            targets=[exercise_path],
            ignored_targets=None,
            default_test_suite_glob=str(current_working_directory),
        )
    except Exception as error:
        raise ExerciceFailed(str(error)) from error
    if len(result.broken_test_suites) > 0:
        raise ExerciceFailed(str("Broken test suite"))
