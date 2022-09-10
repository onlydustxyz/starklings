from sqlalchemy import create_engine, Column, Integer, String, ForeignKey
from sqlalchemy.orm import sessionmaker, relationship, declarative_base
# from db import Base

Base = declarative_base()

class StarklingsUser(Base):
    __tablename__ = "starklings_user"
    wallet_address = Column(String(42), primary_key=True)
    signature = Column(String(255), nullable=False)
    github = Column(String(255), nullable=False)
    username = Column(String(255), nullable=False)
    score = Column(Integer, nullable=False, default=0)
    starklings_user = relationship("ValidatedExercise")


class Path(Base):
    __tablename__ = "path"
    path_name = Column(String(255), primary_key=True)
    num_exercises = Column(Integer, nullable=False)
    path = relationship("Exercise")


class Exercise(Base):
    __tablename__ = "exercise"
    exercise_name = Column(String(255), primary_key=True)
    score = Column(Integer, nullable=False, default=0)
    path_name = Column(String(255), ForeignKey("path.path_name"), nullable=False)
    exercise = relationship("ValidatedExercise")


class ValidatedExercise(Base):
    __tablename__ = "validated_exercise"
    validated_exercise_id = Column(String(64), primary_key=True)
    exercise_name = Column(
        String(255),
        ForeignKey("exercise.exercise_name"),
        nullable=False,
    )
    wallet_address = Column(
        String(42), ForeignKey("starklings_user.wallet_address"), nullable=False
    )

