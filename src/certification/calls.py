import requests
from src import prompt

from .config import URL


def register_exercise_success(exercise_path: str, access_token: str):
    route = "/route_to_post_at"
    response = requests.post(
        URL + route,
        data={
            "exercise_name": exercise_path,
            "access_token": access_token,
        },
    )
    if response.ok():
        prompt.on_nft_mint()
    else:
        prompt.on_nft_mint_failed()
