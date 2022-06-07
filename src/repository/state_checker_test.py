from pathlib import Path
from packaging.version import Version
from src.repository.state_checker import check, versions_match


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


def test_versions_match(mocker):
    logger = mocker.patch("src.repository.state_checker.logger")
    version_manager = mocker.patch(
        "src.repository.state_checker.VersionManager"
    ).return_value
    repo = mocker.patch("src.repository.state_checker.Repo").return_value

    # Repo is behing binary
    version_manager.starklings_version = Version("2.0.0")
    repo.tags.pop.return_value.name = "v1.0.0"
    assert not versions_match(repo)
    logger.error.assert_called_once()

    # Repo is ahead of binary
    version_manager.starklings_version = Version("2.0.0")
    repo.tags.pop.return_value.name = "v3.0.0"
    logger.reset_mock()
    assert not versions_match(repo)
    logger.error.assert_called_once()

    # Repo is up to date
    version_manager.starklings_version = Version("2.0.0")
    repo.tags.pop.return_value.name = "v2.0.0"
    logger.reset_mock()
    assert versions_match(repo)
    logger.error.assert_not_called()

    # Repo is ahead of binary but not breaking
    version_manager.starklings_version = Version("2.0.0")
    repo.tags.pop.return_value.name = "v2.4.0"
    logger.reset_mock()
    assert versions_match(repo)
    logger.error.assert_not_called()
