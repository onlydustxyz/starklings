from os import environ, path
from dotenv import load_dotenv

basedir = path.abspath(path.dirname(__file__))
load_dotenv(path.join(basedir, '.env'))

class Config:
    """Base config."""
    SECRET_KEY = environ.get('SECRET_KEY')
    host = environ.get('DATABASE_HOST', '')
    database = environ.get('DATABASE_NAME', '')
    user = environ.get('DATABASE_USER', '')
    password = environ.get('DATABASE_PWD', '')
    SQLALCHEMY_DATABASE_URI = f"mysql+pymysql://{user}:{password}@{host}/{database}"

    SQLALCHEMY_TRACK_MODIFICATIONS = False


class DevConfig(Config):
    ENV='development'
    TESTING = True
    DEBUG = True
    DEVELOPMENT = True
    DATABASE_URI = environ.get('DEV_DATABASE_URI')


class ProdConfig(Config):
    ENV='production'
    TESTING = False
    DEBUG = False
    DEVELOPMENT = False
    DATABASE_URI = environ.get('PROD_DATABASE_URI')

