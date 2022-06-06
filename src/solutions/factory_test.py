import pytest
from src.solutions.factory import init
from src.config import exercises_directory
from src.solutions.repository import get_solution


@pytest.fixture(name="an_exercise")
def an_exercise_fixture():
    return exercises_directory / "syntax/syntax01.cairo"


@pytest.fixture(autouse=True)
def init_fixture(an_exercise):
    init([an_exercise])


def test_solution_getter(an_exercise):
    solution = get_solution(an_exercise)
    assert (
        solution
        == """%lang starknet
# All Starknet files must start with a specific line indicating the file is a smart contract,
# not just a regular Cairo file

# I AM NOT DONE

# TODO: add the Starknet file specifier at the beginning of the file

# You can ignore what follows for now
@external
func test_ok():
    return ()
end
"""
    )
