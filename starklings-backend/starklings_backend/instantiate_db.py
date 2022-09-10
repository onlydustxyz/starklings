from db import Base,engine
from models import StarklingsUser,Path,Exercise,ValidatedExercise

Base.metadata.create_all(engine)