from pathlib import Path

from .solution import SolutionPatcher
from unittest.mock import mock_open
from unittest import mock


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


def test_find_patch_ok(mocker):
    exercise_path = Path("./exercise/beginner/ex00.cairo")

    patcher = SolutionPatcher(exercise_path)

    mock = mocker.patch("os.path.exists", new=lambda x: True)

    assert patcher.find_patch(patcher.path) == Path(
        "./.patches/beginner/ex00.cairo.patch"
    )


def test_find_patch_ko(mocker):
    exercise_path = Path("./exercise/beginner/ex00.cairo")

    patcher = SolutionPatcher(exercise_path)

    mock = mocker.patch("os.path.exists", new=lambda x: False)

    assert patcher.find_patch(patcher.path) == None


def test_get_solution(mocker):
    exercise_path = Path("./exercise/beginner/ex00.cairo")
    mock_exists = mocker.patch("os.path.exists", new=lambda x: True)

    contents = [
        b"diff --git a/exercises/syntax/syntax01.cairo b/exercises/syntax/syntax01.cairo\nindex f5b07a3..2e4537d 100644\n--- a/exercises/syntax/syntax01.cairo\n+++ b/exercises/syntax/syntax01.cairo\n@@ -0,0 +1 @@\n+%lang starknet\n",
        b"# All Starknet files must start with a specific line indicating the file is a smart contract,\n# not just a regular Cairo file\n\n# I AM NOT DONE\n\n# TODO: add the Starknet file specifier at the beginning of the file\n\n# You can ignore what follows for now\n@external\nfunc test_ok():\n    return ()\nend\n",
    ]

    m = multi_mock_open(*contents)

    patcher = SolutionPatcher(exercise_path)
    solution = ""
    with mock.patch("builtins.open", m):
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
