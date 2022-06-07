from pathlib import Path
import pytest
from packaging.version import Version
from src.repository.state_checker import check, correct_branch, versions_match


@pytest.fixture(name="repo")
def repo_fixture(mocker):
    return mocker.patch("src.repository.state_checker.Repo").return_value


def test_is_a_repo(mocker):
    logger = mocker.patch("src.repository.state_checker.logger")
    mocked_os = mocker.patch("src.repository.state_checker.os")
    mocker.patch("src.repository.state_checker.versions_match").return_value = True
    mocker.patch("src.repository.state_checker.correct_branch").return_value = True

    # Running directory is not a git repository
    mocked_os.getcwd.return_value = str(Path(__file__).parents[3])
    assert not check()
    logger.error.assert_called_once()

    # Running directory is a git repository
    mocked_os.getcwd.return_value = str(Path(__file__).parents[2])
    logger.reset_mock()
    assert check()
    logger.error.assert_not_called()


def test_versions_match(mocker, repo):
    logger = mocker.patch("src.repository.state_checker.logger")
    version_manager = mocker.patch(
        "src.repository.state_checker.VersionManager"
    ).return_value

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


def test_correct_branch(repo):
    repo.active_branch.name = "stable"
    assert correct_branch(repo)

    repo.active_branch.name = "master"
    assert not correct_branch(repo)
