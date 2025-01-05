def map_rows_to_dict(columns, rows):
    return [{columns[i]: row[i] for i in range(len(columns))} for row in rows]
