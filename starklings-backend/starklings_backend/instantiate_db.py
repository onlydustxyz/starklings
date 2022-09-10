from db import Base,engine
from models import StarklingsUser,Path,Exercise,ValidatedExercise

print("Creating database ....")

Base.metadata.create_all(engine)