from flask import request, Blueprint
import asyncio
import bcrypt
from sqlalchemy.exc import IntegrityError
from flask_sqlalchemy import SQLAlchemy
from starklings_backend.utils import verify_email
from starklings_backend.models.shared import db
from starklings_backend.models.user import Starklingsuser
from starklings_backend.exercise import verify_exercise
from checker import ExerciceFailed
import tempfile

app_routes = Blueprint('app_routes', __name__)

@app_routes.route('/', methods=['GET'])
def landing():
    return 'Starklings API'

#######################
#     Users Routes    #
#######################
@app_routes.route('/registerUser', methods=['POST'])
def register_user():
    """
    Inserts a new user in the Database
    @TODO: Starknet ID / Signature and implements model
    """
    try:
        signature = request.json.get('signature', None)
        wallet_address = request.json.get('wallet_address', None)
        username = request.json.get('username', wallet_address)
        if None in [wallet_address, signature]:
            return "Wrong form", 400 
        #@TODO: Check Signature validity
        
        user = Starklingsuser(wallet_address=wallet_address, signature=signature, username=username)
        db.session.commit()
        return f'Welcome! {username}', 200

    except IntegrityError as e:
        db.session.rollback()
        return 'User Already Exists', 400
    except AttributeError:
        return 'Provide an Email and Password in JSON format in the request body', 400


@app_routes.route('/fetchUserInfo', methods=['POST'])
def fetch_user_info():
    """
    Authenticate a user
    @TODO Implements Fetch User Information
    """
    try:
        wallet_address = request.json.get('wallet_address', None)
        if not wallet_address:
            return 'Missing address', 400
        user = Starklingsuser.query.filter_by(wallet_address=wallet_address).first()
        if not user:
            return 'User Not Found!', 404
        
        return f'Logged in, Welcome {user.username}!', 200
    except AttributeError as e:
        print(e)
        return 'Provide the wallet address in JSON format in the request body', 400


#######################
#   Exercises Routes  #
#######################
@app_routes.route('/exercise/check', methods=['POST'])
async def starklings_exercise_checker():
    """
    Check exercise given a body and a user
    @TODO: Implement User DB for storing results
    """
    try:
        address = request.json.get('wallet_address', None) 
        exercise = request.json.get('exercise', 'storage/storage01')
        exercise_data = request.json.get('exercise_data', None)   
        if not address:
            return 'Missing Address', 400
        tmp = tempfile.NamedTemporaryFile()
        with open(tmp.name, 'w') as temp_exercise:
            temp_exercise.write(exercise_data)
        res = await verify_exercise(tmp.name)
        tmp.close()
        return {
            "result": "success"
        }
    except ExerciceFailed as error:
        print(error)
        return {
            "result": "failure",
            "error": error.message
        }, 400
