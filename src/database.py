import pickledb
from src.config import root_directory

database = pickledb.load(str(root_directory / "starklings.db"), True)
