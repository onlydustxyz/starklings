import os
import pymysql
from sqlalchemy.orm import declarative_base, sessionmaker
from sqlalchemy import create_engine
from dotenv import load_dotenv
load_dotenv()


engine = create_engine('mysql+pymysql://root:dazzura1@localhost/wtf', echo=True)

Base = declarative_base()

Session = sessionmaker(bind=engine)