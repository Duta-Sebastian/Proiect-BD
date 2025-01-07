from flask import Blueprint, jsonify, request

from services.helper import map_rows_to_dict

views_bp = Blueprint('views', __name__)


@views_bp.route('/api/views/getViews', methods=['GET'])
def get_views():
    connection = views_bp.connection
    cursor = connection.cursor()

    query = "SELECT view_name FROM user_views"
    cursor.execute(query)
    rows = cursor.fetchall()
    cursor.close()
    return jsonify({'views': rows}), 200


@views_bp.route('/api/views/getViewData', methods=['GET'])
def get_view_data():
    connection = views_bp.connection
    cursor = connection.cursor()

    view_name = request.args.get('view_name')

    if not view_name:
        return jsonify({"error": "view_name parameter is required"}), 400

    try:
        query = f"SELECT * FROM {view_name}"
        cursor.execute(query)
        rows = cursor.fetchall()
        column_names = [desc[0] for desc in cursor.description]
        result = [dict(zip(column_names, row)) for row in rows]
        cursor.close()
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@views_bp.route('/api/views/updateViewData', methods=['POST'])
def update_view_data():
    connection = views_bp.connection
    data = request.get_json()

    for entry in data['data']:
        cursor = connection.cursor()
        original = entry['original']
        updated = entry['updated']

        set_clause = ", ".join([f"{key} = '{value}'" for key, value in updated.items()])

        where_clause = " AND ".join([f"{key} = '{value}'" for key, value in original.items()])

        query = f"""
        UPDATE USER_CREDENTIALS_VIEW
        SET {set_clause}
        WHERE {where_clause}
        """
        cursor.execute(query)
        connection.commit()
        cursor.close()
    return jsonify({ "success": True, "message": "Success message" }), 200

@views_bp.route('/api/views/deleteViewData', methods=['POST'])
def delete_view_data():
    connection = views_bp.connection
    data = request.get_json()

    for entry in data['data']:
        cursor = connection.cursor()

        where_clause = " AND ".join([f"{key} = '{value}'" for key, value in entry.items()])

        query = f"""
        DELETE FROM USER_CREDENTIALS_VIEW
        WHERE {where_clause}
        """
        cursor.execute(query)
        connection.commit()
        cursor.close()
    return jsonify({ "success": True, "message": "Success message" }), 200

@views_bp.route('/api/views/insertViewData', methods=['POST'])
def insert_view_data():
    connection = views_bp.connection
    data = request.get_json()

    table_name = 'USER_CREDENTIALS_VIEW'
    allowed_keys = ['CNP', 'HASH_PAROLA', 'METODA_AUTENTIFICARE', 'NUME_UTILIZATOR', 'STATUS']

    for entry in data['data']:
        filtered_entry = {key: entry[key] for key in allowed_keys if key in entry}

        columns = ', '.join(filtered_entry.keys())
        values = ', '.join(f"'{v}'" if v is not None else 'NULL' for v in filtered_entry.values())

        sql_query = f"INSERT INTO {table_name} ({columns}) VALUES ({values})"

        cursor = connection.cursor()
        cursor.execute(sql_query)
        connection.commit()
        cursor.close()

    return jsonify({"success": True, "message": "Data inserted successfully"}), 200
