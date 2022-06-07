from pathlib import Path
from src.repository.state_checker import check


def test_is_a_repo(mocker):
    logger = mocker.patch("src.repository.state_checker.logger")
    mocked_os = mocker.patch("src.repository.state_checker.os")

    # Running directory is not a git repository
    mocked_os.getcwd.return_value = str(Path(__file__).parents[3])
    assert not check()
    logger.error.assert_called_once()

    # Running directory is a git repository
    mocked_os.getcwd.return_value = str(Path(__file__).parents[2])
    logger.reset_mock()
    assert check()
    logger.error.assert_not_called()
