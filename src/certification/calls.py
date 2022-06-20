import requests
from .config import URL
import src.user.access_token


def register_exercise_success(exercise_path: str, access_token: str):
    route = "/route_to_post_at"
    requests.post(
        URL + route,
        data={
            "exercise_name": exercise_path,
            "access_token": access_token,
        },
    )
