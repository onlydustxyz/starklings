from src.utils.version_manager import VersionManager


def test_version_manager():
    version_manager = VersionManager()

    assert version_manager.starklings_version > VersionManager.parse("0.0.0")
    assert version_manager.cairo_version > VersionManager.parse("0.0.0")
