from pathlib import Path

from src.utils.starklings_directory import StarklingsDirectory, VersionManager


async def cli(args, script_root: Path):
    starklings_directory = StarklingsDirectory(script_root)
    version_manager = VersionManager(starklings_directory)

    if args.version:
        version_manager.print_current_version()
