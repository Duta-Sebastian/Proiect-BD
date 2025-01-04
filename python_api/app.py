from flask import Flask
from flask_cors import CORS

from connection import get_connection
from python_api.routes.tables import tables_bp

app = Flask(__name__)
CORS(app)

connection = get_connection()

tables_bp.connection = connection

app.register_blueprint(tables_bp)

@app.route('/')
def hello_world():  # put application's code here
    return 'Hello World!'

if __name__ == '__main__':
    app.run()
