from flask import Flask
from flask_cors import CORS

from connection import get_connection
from python_api.routes.views import views_bp
from routes.queries import queries_bp
from routes.tables import tables_bp

app = Flask(__name__)
CORS(app)

connection = get_connection()

tables_bp.connection = connection
queries_bp.connection = connection
views_bp.connection = connection

app.register_blueprint(tables_bp)

app.register_blueprint(queries_bp)

app.register_blueprint(views_bp)

if __name__ == '__main__':
    app.run()
