from time import sleep
import requests
from src.config import GITHUB_CLIENT_ID
from src.prompt import on_user_verification, waiting_for_user_login


def login():
    user_verification_request = requests.post(
        "https://github.com/login/device/code",
        data={
            "client_id": GITHUB_CLIENT_ID,
        },
        headers={
            "Accept": "application/json",
        },
    )
    user_verification_response = user_verification_request.json()

    on_user_verification(
        user_verification_response["verification_uri"],
        user_verification_response["user_code"],
    )
    with waiting_for_user_login():
        pass
