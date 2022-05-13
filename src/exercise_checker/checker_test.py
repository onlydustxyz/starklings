import pytest
from src.exercise_checker.checker import ExerciceFailed, ProtostarExerciseChecker


@pytest.fixture(name="checker")
def checker_fixture():
    return ProtostarExerciseChecker()


async def test_protostar_test_checker_success(checker):
    await checker.run("tests/test.cairo")


async def test_protostar_test_checker_missing_exercise(checker):
    with pytest.raises(ExerciceFailed):
        await checker.run("tests/test_missing.cairo")


async def test_protostar_test_checker_failing_exercise(checker):
    with pytest.raises(ExerciceFailed):
        await checker.run("tests/test_failure.cairo")


async def test_protostar_test_checker_invalid_exercise(checker):
    with pytest.raises(ExerciceFailed):
        await checker.run("tests/test_invalid.cairo")


async def test_protostar_test_checker_missing_syntax(checker):
    with pytest.raises(ExerciceFailed):
        await checker.run("tests/test_missing.cairo")
