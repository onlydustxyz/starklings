from logging import getLogger
import os
from packaging.version import Version
from git import InvalidGitRepositoryError, Repo

from src.utils.version_manager import VersionManager

logger = getLogger()


def versions_match(repo: Repo):
    # Check there is no breaking change between the binary and the repository
    repo_version = Version(repo.tags.pop().name[1:])
    binary_version = VersionManager().starklings_version
    if repo_version.major > binary_version.major or repo_version < binary_version:
        logger.error(
            """You installed starklings in version %s, but the repository is cloned in version %s
Please update starklings running `bash install.sh` and update the repository running `git pull origin stable`""",
            binary_version,
            repo_version,
        )
        return False
    return True


def correct_branch(repo: Repo):
    if repo.active_branch.name != "stable":
        logger.error(
            "You are not on the stable branch, please switch running `git checkout stable`"
        )
        return False
    return True


def check():
    # Check cwd is a repository
    try:
        repo = Repo(os.getcwd())
    except InvalidGitRepositoryError:
        logger.error(
            "You are not running starklings in a git repository, make sure you run it in the cloned starklings repository"
        )
        return False

    return correct_branch(repo) and versions_match(repo)
