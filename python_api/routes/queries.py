from flask import Blueprint, jsonify, request

from services.helper import map_rows_to_dict

queries_bp = Blueprint('queries', __name__)

@queries_bp.route('/api/queries', methods=['GET'])
def get_queries():
    allowed_query_type = ['Joined Data Filtered','Aggregated Data Having']
    queryType = request.args.get('queryType')
    if queryType not in allowed_query_type:
        return jsonify({'error': 'Invalid query parameter.'}), 400

    if queryType == 'Joined Data Filtered':
        query = f"SELECT C.Nume || ' ' || C.Prenume as \"Nume Cititor\", R.Nota, R.Titlu, CA.Titlu \
                  FROM CITITOR C JOIN Carte_Cititor_Recenzie CCR on C.CNP = CCR.CNP_Cititor \
                  JOIN RECENZIE R on CCR.id_recenzie = R.id_recenzie JOIN CARTE CA on CCR.ISBN = CA.ISBN \
                  WHERE R.nota > 5 and R.vizibil = 'Y'"
        columns = ["Nume Cititor", "Nota", "Titlu Recenzie", "Titlu Carte"]
    else:
        query = f"SELECT COUNT(R.id_recenzie) \
                  FROM RECENZIE R JOIN Carte_Cititor_Recenzie CCR on CCR.id_recenzie = R.id_recenzie \
                  GROUP BY R.id_recenzie, R.NOTA \
                  HAVING R.NOTA >5"
        columns = ["COUNT(R.id_recenzie)"]

    connection = queries_bp.connection
    cursor = connection.cursor()

    try:
        cursor.execute(query)
        rows = cursor.fetchall()
    except Exception as e:
        return jsonify({"error": f"Failed to execute query: {str(e)}"}), 500
    finally:
        cursor.close()

    if not rows:
        return jsonify({"error": "No data found"}), 404

    mapped_rows = map_rows_to_dict(columns, rows)

    return jsonify({'columns': columns,'data': mapped_rows}), 200
