import os
from pathlib import Path
import pytest
from packaging.version import Version
from src.exercise_checker.checker import ExerciceFailed, ProtostarExerciseChecker


@pytest.fixture(name="runner")
def runner_fixture():
    script_root = Path(os.getcwd())
    return ProtostarExerciseChecker(script_root, Version("0.2.0"))


async def test_protostar_test_runner_success(runner):
    await runner.run("tests/test.cairo")


async def test_protostar_test_runner_missing_exercise(runner):
    with pytest.raises(ExerciceFailed):
        await runner.run("tests/test_missing.cairo")


async def test_protostar_test_runner_failing_exercise(runner):
    with pytest.raises(ExerciceFailed):
        await runner.run("tests/test_failure.cairo")


async def test_protostar_test_runner_invalid_exercise(runner):
    with pytest.raises(ExerciceFailed):
        await runner.run("tests/test_invalid.cairo")


async def test_protostar_test_runner_missing_syntax(runner):
    with pytest.raises(ExerciceFailed):
        await runner.run("tests/test_missing.cairo")
