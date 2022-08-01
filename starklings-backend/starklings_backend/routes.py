from app import app, db
from flask import request
import asyncio
import bcrypt
from sqlalchemy.exc import IntegrityError
from starklings_backend.utils import verify_email
from starklings_backend.models import Starklingsuser
from starklings_backend.exercise import verify_exercise
from checker import ExerciceFailed


@app.route('/', methods=['GET'])
def landing():
    return 'Starklings API'

#######################
#     Users Routes    #
#######################
@app.route('/register', methods=['POST'])
def register_user():
    """
    Inserts a new user in the Database
    @TODO: Captcha Email Verification / Starknet ID / GitHub verification
    """
    try:
        username = request.json.get('username', None)
        email = request.json.get('email', None)
        password = request.json.get('password', None)
        wallet_address = request.json.get('address', None)
        if None in [username, email, password]:
            return "Wrong form", 400 
        if not verify_email(email):
            return "Wrong email format", 400
        if len(password) < 6:
            return "Password too weak", 400

        hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
        user = Starklingsuser(email=email, password=hashed, username=username, address=wallet_address)
        db.session.add(user)
        db.session.commit()

        return f'Welcome! {username}', 200

    except IntegrityError as e:
        db.session.rollback()
        return 'User Already Exists', 400
    except AttributeError:
        return 'Provide an Email and Password in JSON format in the request body', 400


@app.route('/login', methods=['POST'])
def login_user():
    """
    Authenticate a user
    """
    try:
        address = request.json.get('address', None)
        password = request.json.get('password', None)
        if not address:
            return 'Missing address', 400
        if not password:
            return 'Missing password', 400
        
        user = Starklingsuser.query.filter_by(address=address).first()
        if not user:
            return 'User Not Found!', 404
        
        if bcrypt.checkpw(password.encode('utf-8'), user.password.encode('utf-8')):
            return f'Logged in, Welcome {user.username}!', 200
        else:
            return 'Invalid Login Info!', 400
    except AttributeError as e:
        print(e)
        return 'Provide an Email and Password in JSON format in the request body', 400


#######################
#   Exercises Routes  #
#######################
@app.route('/exercise', methods=['POST'])
async def starklings_exercise_checker():
    """
    Check exercise given a body and a user
    @TODO: Implement User DB for storing results
    @TODO: Get solution file from API and temporarly store it File ? or Data
    """
    try:
        address = request.json.get('address', None) 
        exercise = request.json.get('exercise', 'storage/storage01')
        exercise_data = request.json.get('exercise_data', None) 
        if not address:
            return 'Missing Address', 400       
        res = await verify_exercise(f"../exercises/{exercise}.cairo")
        return {
            "result": "Exercice Succeed"
        }
    except ExerciceFailed as error:
        return {
            "result": "Exercice Failed",
            "error": error.message
        }
