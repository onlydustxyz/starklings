import os
import pymysql


connection = pymysql.connect(
    host=os.environ.get('DATABASE_HOST', ''),
    database=os.environ.get('DATABASE_NAME', ''),
    user=os.environ.get('DATABASE_USER', ''),
    password=os.environ.get('DATABASE_PWD', ''),
    charset="utf8mb4",
    cursorclass=pymysql.cursors.DictCursor
)

cursor = connection.cursor()

path_sql_query = """CREATE TABLE starklingsCompletedExercise (
    exercise_name varchar(255) NOT NULL,
    user_id int NOT NULL,
    validated_exercises
)
"""


user_sql_query = """CREATE TABLE starklingsUser (
    user_id int NOT NULL PRIMARY KEY AUTO_INCREMENT,
    score int NOT NULL DEFAULT 0,
    email varchar(255) NOT NULL UNIQUE,
    password varchar(255) NOT NULL,
    username varchar(255) NOT NULL UNIQUE,
    address varchar(255) NOT NULL UNIQUE
)
"""

cursor.execute(user_sql_query)
connection.close()
