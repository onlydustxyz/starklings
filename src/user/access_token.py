from src.database import database

ACCESS_TOKEN_KEY = "access_token"


def get_access_token():
    return database.get(ACCESS_TOKEN_KEY)


def set_access_token(access_token: str):
    database.set(ACCESS_TOKEN_KEY, access_token)
