import responses
from src.user.login import login


@responses.activate
def test_user_login(mocker):
    on_user_verification_mock = mocker.patch("src.user.login.on_user_verification")
    set_access_token_mock = mocker.patch("src.user.login.set_access_token")

    verification_uri = "https://github.com/login/device"
    user_code = "user_code"
    access_token = "access_token"
    device_code = "device_code"

    user_verification_response = responses.Response(
        method="POST",
        url="https://github.com/login/device/code",
        json={
            "verification_uri": verification_uri,
            "user_code": user_code,
            "interval": 0.01,
            "expires_in": 899,
            "device_code": device_code,
        },
    )

    authorization_pending_response = responses.Response(
        method="POST",
        url="https://github.com/login/oauth/access_token",
        json={"error": "authorization_pending"},
    )

    access_token_response = responses.Response(
        method="POST",
        url="https://github.com/login/oauth/access_token",
        json={
            "access_token": access_token,
        },
    )

    responses.add(user_verification_response)
    responses.add(authorization_pending_response)
    responses.add(authorization_pending_response)
    responses.add(authorization_pending_response)
    responses.add(access_token_response)

    login()

    on_user_verification_mock.assert_called_with(verification_uri, user_code)
    set_access_token_mock.assert_called_with(access_token)
