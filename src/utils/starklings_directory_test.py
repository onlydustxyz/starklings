from src.utils.starklings_directory import StarklingsDirectory, VersionManager


def test_version_manager():
    starklings_directory = StarklingsDirectory()
    version_manager = VersionManager(starklings_directory)

    assert version_manager.starklings_version > VersionManager.parse("0.0.0")
    assert version_manager.cairo_version > VersionManager.parse("0.0.0")
