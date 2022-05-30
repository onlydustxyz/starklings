import os
from pathlib import Path
from typing import Optional
from patch import PatchSet
from git.repo import Repo


class SolutionPatcher:
    def __init__(self, exercise_path: Path, script_root: Path):
        self.path = exercise_path
        self.repository = Repo(script_root)

    @staticmethod
    def find_patch(exercise_path: Path) -> Optional[Path]:
        patch_path = Path(f"./.patches/{Path(*exercise_path.parts[1:])}.patch")
        if not os.path.exists(patch_path):
            return None

        return patch_path

    def get_solution(self) -> Optional[str]:
        patch_path = SolutionPatcher.find_patch(self.path)
        if not patch_path:
            return None

        solution = b""
        self.repository.git.stash()
        try:
            with open(patch_path, "rb") as patch_f:
                patches = PatchSet()
                patches.parse(patch_f)
                with open(self.path, "rb") as exercise_f:
                    solution = solution.join(
                        patches.patch_stream(
                            exercise_f,
                            patches.items[0].hunks,
                        )
                    )
        finally:
            self.repository.git.stash("pop")

        return solution.decode()
