from flask import Flask
from flask_sqlalchemy import SQLAlchemy
import sys

sys.path.append('../src/exercises')

app = Flask(__name__)
app.config.from_object('config.DevConfig')

db = SQLAlchemy()
db.init_app(app)

import starklings_backend.routes


if __name__ == '__main__':
    app.run()