from logging import getLogger
import os
from git import InvalidGitRepositoryError, Repo

logger = getLogger()


def check():
    try:
        repo = Repo(os.getcwd())
    except InvalidGitRepositoryError:
        logger.error(
            "You are not running starklings in a git repository, make sure you run it in the cloned starklings repository"
        )
        return False
    return True
