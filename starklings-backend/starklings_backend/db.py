import os
import pymysql
from sqlalchemy.orm import declarative_base, sessionmaker
from sqlalchemy import create_engine
from dotenv import load_dotenv
load_dotenv()

host=os.environ.get('DATABASE_HOST', '')
database=os.environ.get('DATABASE_NAME', '')
user=os.environ.get('DATABASE_USER', '')
password=os.environ.get('DATABASE_PWD', '')

engine = create_engine(f'mysql+pymysql://{user}:{password}@{host}/{database}', echo=True)

Base = declarative_base()

Session = sessionmaker(bind=engine)