import pytest
from src.exercise_runner.runner import ExerciceFailed, ProtostarExerciseRunner


async def test_protostar_test_runner_success():
    runner = ProtostarExerciseRunner()
    await runner.run("tests/test.cairo")


async def test_protostar_test_runner_missing_exercise():
    runner = ProtostarExerciseRunner()
    with pytest.raises(ExerciceFailed):
        await runner.run("tests/test_missing.cairo")


async def test_protostar_test_runner_failing_exercise():
    runner = ProtostarExerciseRunner()
    with pytest.raises(ExerciceFailed):
        await runner.run("tests/test_failure.cairo")


async def test_protostar_test_runner_invalid_exercise():
    runner = ProtostarExerciseRunner()
    with pytest.raises(ExerciceFailed):
        await runner.run("tests/test_invalid.cairo")
