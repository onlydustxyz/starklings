from time import sleep
import requests
from src.config import GITHUB_CLIENT_ID, GITHUB_GRANT_TYPE
from src.prompt import on_user_verification, waiting_for_user_login
from src.user.access_token import set_access_token


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
        interval = user_verification_response["interval"]
        total_retries = user_verification_response["expires_in"] // interval
        device_code = user_verification_response["device_code"]
        retry_count = 0

        poll_access_token = request_access_token(device_code)
        while "error" in poll_access_token.json():
            if retry_count == total_retries:
                raise Exception("Failed to get access token")
            retry_count += 1
            sleep(interval)
            poll_access_token = request_access_token(device_code)

        access_token = poll_access_token.json()["access_token"]
        set_access_token(access_token)


def request_access_token(device_code: str):
    return requests.post(
        "https://github.com/login/oauth/access_token",
        data={
            "client_id": GITHUB_CLIENT_ID,
            "grant_type": GITHUB_GRANT_TYPE,
            "device_code": device_code,
        },
        headers={
            "Accept": "application/json",
        },
    )
