import requests
from urllib3 import Retry
from src.config import GITHUB_CLIENT_ID, GITHUB_GRANT_TYPE
from src.prompt import on_user_verification, waiting_for_user_login


class RetryWithoutBackoff(Retry):
    def __init__(self, waiting_time, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._waiting_time = waiting_time

    def get_backoff_time(self):
        return self._waiting_time


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

        poll_access_token = requests.post(
            "https://github.com/login/oauth/access_token",
            data={
                "client_id": GITHUB_CLIENT_ID,
                "grant_type": GITHUB_GRANT_TYPE,
                "device_code": user_verification_response["device_code"],
            },
            retry=RetryWithoutBackoff(
                interval, total=total_retries, status_forcelist=[400]
            ),
        )

        access_token = poll_access_token.json()["access_token"]
        return access_token
