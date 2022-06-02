from pathlib import Path
import re
from logging import getLogger
from typing import Optional
import tomli
from packaging import version
from packaging.version import Version as PackagingVersion


class StarklingsDirectory:
    def __init__(self):
        self._binary_dir_path = Path(__file__).parents[2].resolve()

    @property
    def binary_dir_path(self) -> Path:
        return self._binary_dir_path


class VersionManager:
    @staticmethod
    def parse(version_str: str) -> PackagingVersion:
        return version.parse(version_str)

    def __init__(self, starklings_directory: StarklingsDirectory) -> None:
        self._starklings_directory = starklings_directory

    @property
    def _pyproject_toml_path(self) -> Path:
        # When running from the built binary, the pyproject.toml file is under an "info" directory
        info_directory = self._starklings_directory.binary_dir_path / "info"
        if info_directory.exists():
            return info_directory / "pyproject.toml"
        return self._starklings_directory.binary_dir_path / "pyproject.toml"

    @property
    def starklings_version(self) -> Optional[PackagingVersion]:
        try:
            with open(self._pyproject_toml_path, "r", encoding="UTF-8") as file:
                version_s = tomli.loads(file.read())["tool"]["poetry"]["version"]
                return VersionManager.parse(version_s)
        except FileNotFoundError:
            getLogger().warning("Couldn't read Starklings version")
            return None

    @property
    def cairo_version(self) -> Optional[PackagingVersion]:
        try:
            with open(self._pyproject_toml_path, "r", encoding="UTF-8") as file:
                raw_version = tomli.loads(file.read())["tool"]["poetry"][
                    "dependencies"
                ]["cairo-lang"]["url"]
                version_regex = re.compile(r".*cairo-lang-(.+)\.zip.*")
                version_match = version_regex.match(raw_version)
                return VersionManager.parse(version_match[1])
        except FileNotFoundError:
            getLogger().warning("Couldn't read cairo-lang version")
            return None

    def print_current_version(self) -> None:
        print(f"Starklings version: {self.starklings_version or 'unknown'}")
        print(f"Cairo-lang version: {self.cairo_version or 'unknown'}")
