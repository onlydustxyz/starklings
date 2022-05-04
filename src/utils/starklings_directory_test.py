from pathlib import Path

import pytest

from src.utils.starklings_directory import StarklingsDirectory


@pytest.fixture
def script_root(tmpdir: str) -> Path:
    return Path(tmpdir)


def test_protostar_binary_dir_path(script_root: Path):
    starklings_directory = StarklingsDirectory(script_root)

    assert starklings_directory.binary_dir_path == script_root


def test_directory_root_path(script_root: Path):
    starklings_directory = StarklingsDirectory(script_root)

    assert starklings_directory.root_dir_path == script_root / ".." / ".."
