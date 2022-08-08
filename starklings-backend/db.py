import os
import pymysql
from dotenv import load_dotenv
load_dotenv()

connection = pymysql.connect(
    host=os.environ.get('DATABASE_HOST', ''),
    database=os.environ.get('DATABASE_NAME', ''),
    user=os.environ.get('DATABASE_USER', ''),
    password=os.environ.get('DATABASE_PWD', ''),
    charset="utf8mb4",
    cursorclass=pymysql.cursors.DictCursor
)

cursor = connection.cursor()

validated_sql_query = """CREATE TABLE validated_exercise (
    exercise_name varchar(255) NOT NULL,
    user_id int NOT NULL FOREIGN KEY
    ...
)
"""


user_sql_query = """CREATE TABLE starklings_user (
    user_id int NOT NULL PRIMARY KEY AUTO_INCREMENT,
    wallet_address varchar(255) NOT NULL UNIQUE,
    score int NOT NULL DEFAULT 0,
    username varchar(255) NOT NULL UNIQUE,
    signature varchar(255) NOT NULL
)
"""

#cursor.execute(validated_sql_query)
cursor.execute(user_sql_query)
connection.close()
