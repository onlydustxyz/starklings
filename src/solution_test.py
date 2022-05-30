from pathlib import Path
from unittest import mock
from unittest.mock import mock_open
import pytest

from .solution import SolutionPatcher


def multi_mock_open(*file_contents):
    """Create a mock "open" that will mock open multiple files in sequence
    Args:
        *file_contents ([str]): a list of file contents to be returned by open
    Returns:
        (MagicMock) a mock opener that will return the contents of the first
            file when opened the first time, the second file when opened the
            second time, etc.
    """
    mock_files = [
        mock_open(read_data=content).return_value for content in file_contents
    ]
    mock_opener = mock_open()
    mock_opener.side_effect = mock_files

    return mock_opener


@pytest.fixture(name="patcher")
def solution_patcher(mocker):
    mocker.patch("os.path.exists", new=lambda x: True)
    mocker.patch("src.solution.Repo", autospec=True)

    exercise_path = Path("./exercise/beginner/ex00.cairo")
    patcher = SolutionPatcher(exercise_path, Path("."))
    return patcher


def test_find_patch_ok(patcher):
    assert patcher.find_patch(patcher.path) == Path(
        "./.patches/beginner/ex00.cairo.patch"
    )


def test_find_patch_ko(mocker):
    exercise_path = Path("./exercise/beginner/ex00.cairo")

    patcher = SolutionPatcher(exercise_path, Path("."))

    mocker.patch("os.path.exists", new=lambda x: False)

    assert patcher.find_patch(patcher.path) is None


def test_get_solution(patcher):

    contents = [
        b"diff --git a/exercises/syntax/syntax01.cairo b/exercises/syntax/syntax01.cairo\nindex f5b07a3..2e4537d 100644\n--- a/exercises/syntax/syntax01.cairo\n+++ b/exercises/syntax/syntax01.cairo\n@@ -0,0 +1 @@\n+%lang starknet\n",
        b"# All Starknet files must start with a specific line indicating the file is a smart contract,\n# not just a regular Cairo file\n\n# I AM NOT DONE\n\n# TODO: add the Starknet file specifier at the beginning of the file\n\n# You can ignore what follows for now\n@external\nfunc test_ok():\n    return ()\nend\n",
    ]

    multi_file_mock = multi_mock_open(*contents)

    solution = ""
    with mock.patch("builtins.open", multi_file_mock):
        solution = patcher.get_solution()

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
