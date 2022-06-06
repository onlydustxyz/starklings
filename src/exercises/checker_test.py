import pytest
from src.exercises.checker import ExerciceFailed, check_exercise


async def test_protostar_test_checker_success():
    await check_exercise("tests/test.cairo")


async def test_protostar_test_checker_missing_exercise():
    with pytest.raises(ExerciceFailed):
        await check_exercise("tests/test_missing.cairo")


async def test_protostar_test_checker_failing_exercise():
    with pytest.raises(ExerciceFailed):
        await check_exercise("tests/test_failure.cairo")


async def test_protostar_test_checker_invalid_exercise():
    with pytest.raises(ExerciceFailed):
        await check_exercise("tests/test_invalid.cairo")


async def test_protostar_test_checker_missing_syntax():
    with pytest.raises(ExerciceFailed):
        await check_exercise("tests/test_missing.cairo")
