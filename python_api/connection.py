import cx_Oracle
from dotenv import load_dotenv
import os

def get_connection():
    load_dotenv()
    DB_HOSTNAME = os.getenv("DB_HOSTNAME")
    DB_PORT = os.getenv("DB_PORT")
    DB_USER = os.getenv("DB_USER")
    DB_PASSWORD = os.getenv("DB_PASSWORD")

    dsn = cx_Oracle.makedsn(DB_HOSTNAME, DB_PORT)
    connection = cx_Oracle.connect(user=DB_USER, password=DB_PASSWORD, dsn=dsn)
    return connection