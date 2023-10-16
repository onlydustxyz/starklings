import os
import pymysql
from sqlalchemy.orm import declarative_base, sessionmaker
from starklings_backend.models import StarklingsUser,Path,Exercise,ValidatedExercise, Base
from sqlalchemy import create_engine
from dotenv import load_dotenv
load_dotenv()

host=os.environ.get('DATABASE_HOST', '')
database=os.environ.get('DATABASE_NAME', '')
user=os.environ.get('DATABASE_USER', '')
password=os.environ.get('DATABASE_PWD', '')

engine = create_engine(f'mysql+pymysql://{user}:{password}@{host}/{database}', echo=True)

Session = sessionmaker(bind=engine)
Base.metadata.create_all(engine)