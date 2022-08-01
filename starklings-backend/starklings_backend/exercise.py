#Starklings Imports
from checker import check_exercise, ExerciceFailed
from threading import Lock

check_exercise_lock = Lock()

async def verify_exercise(exercise_path):
    if check_exercise_lock.locked():
        return
    with check_exercise_lock:
        try:
            await check_exercise(str(exercise_path))
        except ExerciceFailed as error:
            raise ExerciceFailed(error.message)
    return await check_exercise(exercise_path)