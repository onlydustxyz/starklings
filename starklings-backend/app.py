from flask import Flask
from flask_cors import CORS
import os
import sys
sys.path.append('../src/exercises')
from starklings_backend.routes import app_routes
from starklings_backend.models.shared import db


app = Flask(__name__)
CORS(app)
env_config = os.getenv("APP_SETTINGS", "config.DevConfig")
app.config.from_object('config.DevConfig')

db.init_app(app)
app.register_blueprint(app_routes)



if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8080)