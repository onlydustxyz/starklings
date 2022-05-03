import re
import sys
from pathlib import Path
from typing import Optional

import tomli
from git.repo import Repo
from packaging import version

# check if the active branch is master
SCRIPT_ROOT = Path(__file__).parent
repo = Repo(SCRIPT_ROOT)

assert str(repo.active_branch) == "main", "Checkout to main and try again."
assert len(repo.index.diff(None)) == 0, "There are uncommited changes, aborting."
assert not repo.head.is_detached, "You are on a detached HEAD, aborting."

# get current Starklings version
path = SCRIPT_ROOT / "pyproject.toml"

new_starklings_version_str: Optional[str] = None
with open(path, "r+", encoding="UTF-8") as file:
    raw_pyproject = file.read()
    pyproject = tomli.loads(raw_pyproject)
    version_str = pyproject["tool"]["poetry"]["version"]
    starklings_version = version.parse(version_str)
    print(f"Current Starklings version: {starklings_version}")

    # prompt new Starklings version
    new_starklings_version_str = input("Provide the new Starklings version: ")

    # validate new version
    match_result = re.compile(r"^\d*\.\d*\.\d*$").match(new_starklings_version_str)
    if match_result is None:
        print("Invalid syntax")
        sys.exit(1)
    new_starklings_version = version.parse(new_starklings_version_str)

    if new_starklings_version <= starklings_version:
        print(f"New version must be greater than {starklings_version}")
        sys.exit(1)

    # update version in starklings.toml
    file.seek(0)
    file.truncate()
    file.write(
        raw_pyproject.replace(
            f'version = "{starklings_version}"', f'version = "{new_starklings_version}"'
        )
    )

assert new_starklings_version_str is not None

# add commit
repo.git.add("pyproject.toml")
commit = repo.index.commit(f":bookmark: Starklings {new_starklings_version_str}")

# add tag
tag = repo.create_tag(f"v{new_starklings_version_str}", ref=commit.hexsha)

# push to main
origin = repo.remote(name="origin")
origin.push()
origin.push(tag.path)
