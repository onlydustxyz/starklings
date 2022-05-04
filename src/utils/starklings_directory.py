from pathlib import Path

class StarklingsDirectory:
    def __init__(self, binary_dir_path: Path):
        self._binary_dir_path = binary_dir_path
    
    @property
    def binary_dir_path(self) -> Path:
        return self._binary_dir_path

    @property
    def root_dir_path(self) -> Path:
        return self._binary_dir_path / ".." / ".."
