from flask import Blueprint, jsonify, request

tables_bp = Blueprint('tables', __name__)

def get_columns_for_table(table_name):
    allowed_table_names = ['AUTOR', 'CITITOR', 'CREDENTIALE_CITITOR', 'CARTE',
                           'EDITURA', 'CATEGORIE', 'RECENZIE', 'CARTE_CITITOR_RECENZIE']
    if table_name not in allowed_table_names:
        return None

    connection = tables_bp.connection
    cursor = connection.cursor()
    query = f"SELECT column_name FROM user_tab_columns WHERE table_name = '{table_name}' ORDER BY column_id"
    cursor.execute(query)
    rows = cursor.fetchall()
    cursor.close()

    # Return the column names
    return [row[0] for row in rows]

def map_rows_to_dict(columns, rows):
    return [{columns[i]: row[i] for i in range(len(columns))} for row in rows]

@tables_bp.route('/api/tables/getTableNames', methods=['GET'])
def get_table_names():
    connection = tables_bp.connection
    cursor = connection.cursor()

    query = "SELECT table_name FROM user_tables"
    cursor.execute(query)
    rows = cursor.fetchall()
    cursor.close()
    return jsonify({'nume_tabele': rows}), 200

@tables_bp.route('/api/tables/getTableColumns', methods=['GET'])
def get_table_columns():
    table_name = request.args.get('table_name', type=str)

    columns = get_columns_for_table(table_name)
    if not columns:
        return jsonify({"error": "Invalid table name"}), 400

    pk_query = f"SELECT acc.COLUMN_NAME FROM ALL_CONSTRAINTS ac JOIN ALL_CONS_COLUMNS acc ON ac.CONSTRAINT_NAME = acc.CONSTRAINT_NAME WHERE ac.TABLE_NAME = '{table_name}' AND ac.CONSTRAINT_TYPE = 'P'"
    connection = tables_bp.connection
    cursor = connection.cursor()
    cursor.execute(pk_query)
    rows = cursor.fetchall()
    cursor.close()

    return jsonify({'coloane': columns, 'pk':rows[0][0]}), 200

@tables_bp.route('/api/tables/getTableData', methods=['GET'])
def get_table_data():
    table_name = request.args.get('table_name', type=str)
    table_order_by_column = request.args.get('order_by', type=str)
    table_sort_order = request.args.get('sort_order', type=str)

    allowed_sort_orders = ['ASC', 'DESC']

    allowed_table_names = ['AUTOR', 'CITITOR', 'CREDENTIALE_CITITOR', 'CARTE',
                           'EDITURA', 'CATEGORIE', 'RECENZIE', 'CARTE_CITITOR_RECENZIE']

    if table_name not in allowed_table_names:
        return jsonify({"error": "Invalid order_by parameter"}), 400

    allowed_table_order_by_columns = get_columns_for_table(table_name)

    if table_order_by_column and table_order_by_column not in allowed_table_order_by_columns:
        return jsonify({"error": "Invalid order_by parameter"}), 400

    if table_sort_order and table_sort_order not in allowed_sort_orders:
        return jsonify({"error": "Invalid or missing 'sort_order' parameter. Use 'ASC' or 'DESC'."}), 400
    if not table_sort_order:
        table_sort_order = 'ASC'

    connection = tables_bp.connection
    cursor = connection.cursor()

    query = f"Select * from {table_name}"
    if table_order_by_column:
        query += f" ORDER BY {table_order_by_column} {table_sort_order}"
    cursor.execute(query)
    rows = cursor.fetchall()
    cursor.close()

    mapped_data = map_rows_to_dict(allowed_table_order_by_columns, rows)

    return jsonify({'data': mapped_data}), 200

@tables_bp.route('/api/tables/updateTableData', methods=['POST'])
def update_table_data():
    try:
        data = request.get_json()  # This will parse the incoming JSON body
        if not data:
            return jsonify({"error": "Invalid JSON"}), 400

        table_name = data.get("table_name")
        table_pk_column = data.get("pk_column")
        table_changes = data.get("changes")
        if not table_name or not table_pk_column or not table_changes:
            return jsonify({"error": "Missing required fields"}), 400
        connection = tables_bp.connection
        for row in table_changes:
            cursor = connection.cursor()
            pk = row['id']
            modified_columns = row.get('modified_columns', [])
            set_clause = []
            for column_data in modified_columns:
                column = column_data['column']
                value = column_data['value']
                set_clause.append(f"{column} = '{value}'")
            set_clause_str = ", ".join(set_clause)
            sql_query = f"UPDATE {table_name} SET {set_clause_str} WHERE {table_pk_column} = {pk}"
            cursor.execute(sql_query)
            connection.commit()
            cursor.close()

        return jsonify({"message": "Data updated successfully!"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@tables_bp.route('/api/tables/deleteRows', methods=['POST'])
def delete_rows():

    data = request.get_json()
    pk_column = data['primaryKeyColumn']
    pk_values = data['ids']

    table_name = data.get('table_name')
    pk_values_str = ', '.join(map(str, pk_values))

    sql_query = f"DELETE FROM {table_name} WHERE {pk_column} IN ({pk_values_str})"
    try:
        connection = tables_bp.connection
        cursor = connection.cursor()
        cursor.execute(sql_query)
        connection.commit()
        cursor.close()
        return jsonify({"message": "Data deleted successfully!"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

