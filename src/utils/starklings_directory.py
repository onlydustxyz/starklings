from pathlib import Path
from packaging import version
from packaging.version import Version as PackagingVersion
from typing import Optional
import tomli
from logging import getLogger

class StarklingsDirectory:
    def __init__(self, binary_dir_path: Path):
        self._binary_dir_path = binary_dir_path
    
    @property
    def binary_dir_path(self) -> Path:
        return self._binary_dir_path

    @property
    def root_dir_path(self) -> Path:
        return self._binary_dir_path / ".." / ".."

class VersionManager:
    @staticmethod
    def parse(version_str: str) -> PackagingVersion:
        return version.parse(version_str)

    def __init__(self, starklings_directory: StarklingsDirectory) -> None:
        self._starklings_directory = starklings_directory

    @property
    def starklings_version(self) -> Optional[PackagingVersion]:
        path = (
            self._starklings_directory.root_dir_path
            / "dist"
            / "starklings"
            / "info"
            / "pyproject.toml"
        )
        try:
            with open(path, "r", encoding="UTF-8") as file:
                version_s = tomli.loads(file.read())["tool"]["poetry"]["version"]
                return VersionManager.parse(version_s)
        except FileNotFoundError:
            getLogger().warning("Couldn't read Starklings version")
            return None

    @property
    def protostar_version(self) -> Optional[PackagingVersion]:
        path = (
            self._starklings_directory.root_dir_path
            / "dist"
            / "starklings"
            / "info"
            / "pyproject.toml"
        )
        try:
            with open(path, "r", encoding="UTF-8") as file:
                version_s = tomli.loads(file.read())["tool"]["poetry"]["dependencies"][
                    "protostar"
                ]["tag"].replace("v", "")
                return VersionManager.parse(version_s)
        except FileNotFoundError:
            getLogger().warning("Couldn't read Protostar version")
            return None

    @property
    def cairo_version(self) -> Optional[PackagingVersion]:
        path = (
            self._starklings_directory.root_dir_path
            / "dist"
            / "starklings"
            / "info"
            / "pyproject.toml"
        )
        try:
            with open(path, "r", encoding="UTF-8") as file:
                version_s = tomli.loads(file.read())["tool"]["poetry"]["dependencies"][
                    "cairo-lang"
                ].replace("^", "")
                return VersionManager.parse(version_s)
        except FileNotFoundError:
            getLogger().warning("Couldn't read cairo-lang version")
            return None

    def print_current_version(self) -> None:
        print(f"Starklings version: {self.starklings_version or 'unknown'}")
        print(f"Protostar version: {self.protostar_version or 'unknown'}")
        print(f"Cairo-lang version: {self.cairo_version or 'unknown'}")
