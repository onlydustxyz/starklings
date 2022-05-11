import os
from pathlib import Path
from patch import PatchSet


class SolutionDisplayer:
    def __init__(self, exercise_path: Path):
        self.path = exercise_path

    @staticmethod
    def find_patch(exercise_path: Path) -> Path:
        patch_path = Path("./.patches/{}.patch".format(Path(*exercise_path.parts[1:])))
        if not os.path.exists(patch_path):
            return None
        else:
            return patch_path

    def get_solution(self) -> str:
        patch_path = SolutionDisplayer.find_patch(self.path)
        if not patch_path:
            print("Solution file not found")
            return

        x = b""
        with open(patch_path, "rb") as patch_f:
            patches = PatchSet()
            patches.parse(patch_f)
            with open(self.path, "rb") as exercise_f:
                x = x.join(
                    patches.patch_stream(
                        exercise_f,
                        patches.items[0].hunks,
                    )
                )

        return x.decode()
