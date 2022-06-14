from src.config import GITHUB_CLIENT_ID, GITHUB_GRANT_TYPE
from src.user.login import login


def test_user_login(mocker):
    requests_mock = mocker.patch("src.user.login.requests")
    on_user_verification_mock = mocker.patch("src.user.login.on_user_verification")
    retry_mock = mocker.patch("src.user.login.RetryWithoutBackoff")

    verification_uri = mocker.sentinel.verification_uri
    user_code = mocker.sentinel.user_code
    access_token = mocker.sentinel.access_token
    device_code = mocker.sentinel.device_code

    requests_mock.post.return_value.json.side_effect = [
        {
            "verification_uri": verification_uri,
            "user_code": user_code,
            "interval": 1,
            "expires_in": 899,
            "device_code": device_code,
        },
        {"access_token": access_token},
    ]

    assert login() is access_token

    on_user_verification_mock.assert_called_with(verification_uri, user_code)
    requests_mock.post.assert_called_with(
        "https://github.com/login/oauth/access_token",
        data={
            "client_id": GITHUB_CLIENT_ID,
            "grant_type": GITHUB_GRANT_TYPE,
            "device_code": device_code,
        },
        retry=retry_mock.return_value,
    )
