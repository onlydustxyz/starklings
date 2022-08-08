from starklings_backend.models.shared import db

class Starklingsuser(db.Model):
    user_id = db.Column(db.Integer, primary_key=True)
    score = db.Column(db.Integer, nullable=False, default=0)
    signature = db.Column(db.String(255), nullable=False)
    username = db.Column(db.String(255), unique=True, nullable=False)
    wallet_address = db.Column(db.String(255), unique=True, nullable=False)
