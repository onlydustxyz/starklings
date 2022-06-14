from src.user.login import login


def test_user_login(mocker):
    requests_mock = mocker.patch("src.user.login.requests")
    on_user_verification_mock = mocker.patch("src.user.login.on_user_verification")

    verification_uri = mocker.sentinel.verification_uri
    user_code = mocker.sentinel.user_code
    requests_mock.post.return_value.json.return_value = {
        "verification_uri": verification_uri,
        "user_code": user_code,
    }

    login()

    requests_mock.post.assert_called_once()
    on_user_verification_mock.assert_called_once_with(verification_uri, user_code)
