# import pdb; pdb.set_trace()
from flask import request, Blueprint
import asyncio
import bcrypt
from sqlalchemy.exc import IntegrityError
from flask_sqlalchemy import SQLAlchemy
from starklings_backend.utils import verify_email, VerifySignature
from starklings_backend.models import (
    StarklingsUser,
    Path,
    Exercise,
    ValidatedExercise,
    Base,
)
# from starklings_backend.exercise import verify_exercise
# from checker import ExerciceFailed
import tempfile
from db import Session
from pathlib import Path
import json


app_routes = Blueprint("app_routes", __name__)

db = Session()


@app_routes.route("/", methods=["GET"])
def landing():
    return "Starklings API"


#######################
#     Users Routes    #
#######################
@app_routes.route("/registerUser", methods=["POST"])
def register_user():
    """
    Inserts a new user in the Database
    """
    try:
        signature = request.json.get("signature", None)
        wallet_address = request.json.get("wallet_address", None)
        username = request.json.get("username", wallet_address)
        github = request.json.get("github", None)
        message_hash = request.json.get("message_hash", "")
        network = request.json.get("network", "testnet")
        if None in [wallet_address, signature]:
            return "Wrong form", 400
        # verify signature
        abi = Path.cwd() / "abi" / "account.json"
        verify_signature = VerifySignature(abi, network, wallet_address)
        is_valid, error = verify_signature(message_hash, signature)
        # import pdb; pdb.set_trace()
        if error is None:
            user = StarklingsUser(
                wallet_address=wallet_address,
                signature=json.dumps(signature),
                github=github,
                username=username,
            )
            db.add(user)
            db.commit()
            return f"Welcome! {username}", 200
        return "Signature invalid", 400

    except IntegrityError as e:
        db.rollback()
        return "User Already Exists", 400
    except AttributeError:
        return "Provide an Email and Password in JSON format in the request body", 400

@app_routes.route("/updateUser", methods=["POST"])
def update_user():
    try:
        update_parameter = request.json.get("update_parameter", None)
        if update_parameter is None:
            return "Missing update parameter", 400
        for k, v in update_parameter.items():
            if k not in ['username', 'github']:
                return f"Incorrect payload {k}", 400

        wallet_address = request.json.get("wallet_address", None)
        signature = request.json.get("signature", None)
        if not wallet_address:
            return "Missing address", 400
        if not signature:
            return "Missing signature", 400
        user = db.query(StarklingsUser).filter_by(wallet_address=wallet_address, signature=str(signature))
        if user is None:
            return "Invalid wallet and signature pair", 400
        user.update(update_parameter, synchronize_session="fetch")
        db.commit()
        return f"Update successful", 200 
    except AttributeError as e:
        print(e)
        return "Provide the wallet address in JSON format in the request body", 400
    


@app_routes.route("/fetchUserInfo", methods=["POST"])
def fetch_user_info():
    """
    Authenticate a user
    @TODO Implements Fetch User Information
    """
    try:
        wallet_address = request.json.get("wallet_address", None)
        if not wallet_address:
            return "Missing address", 400
        user = db.query(StarklingsUser).filter_by(wallet_address=wallet_address).first()
        if not user:
            return "User Not Found!", 404

        return f"Logged in, Welcome {user.username}!", 200
    except AttributeError as e:
        print(e)
        return "Provide the wallet address in JSON format in the request body", 400


#######################
#   Exercises Routes  #
#######################
@app_routes.route("/exercise/check", methods=["POST"])
async def starklings_exercise_checker():
    """
    Check exercise given a body and a user
    @TODO: Implement User DB for storing results
    """
    try:
        address = request.json.get("wallet_address", None)
        exercise = request.json.get("exercise", "storage/storage01")
        exercise_data = request.json.get("exercise_data", None)
        if not address:
            return "Missing Address", 400
        tmp = tempfile.NamedTemporaryFile()
        with open(tmp.name, "w") as temp_exercise:
            temp_exercise.write(exercise_data)
        res = await verify_exercise(tmp.name)
        tmp.close()
        return {"result": "success"}
    except ExerciceFailed as error:
        print(error)
        return {"result": "failure", "error": error.message}, 400
