from pathlib import Path

import pytest

from src.utils.starklings_directory import StarklingsDirectory, VersionManager


@pytest.fixture(name="script_root")
def script_root_fixture(tmpdir: str) -> Path:
    return Path(tmpdir)


def test_starklings_binary_dir_path(script_root: Path):
    starklings_directory = StarklingsDirectory(script_root)

    assert starklings_directory.binary_dir_path == script_root


def test_directory_root_path(script_root: Path):
    starklings_directory = StarklingsDirectory(script_root)

    assert starklings_directory.root_dir_path == script_root / ".." / ".."


def test_version_manager():
    starklings_directory = StarklingsDirectory(Path(__file__).parent)
    version_manager = VersionManager(starklings_directory)

    assert version_manager.starklings_version > VersionManager.parse("0.0.0")
    assert version_manager.protostar_version > VersionManager.parse("0.0.0")
    assert version_manager.cairo_version > VersionManager.parse("0.0.0")
