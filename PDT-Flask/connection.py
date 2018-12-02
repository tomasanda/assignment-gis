import psycopg2

_connection = None


def get_connection():
    global _connection
    global _db_cur
    if not _connection:
        try:
            _connection = psycopg2.connect(dbname='MassGIS', host='localhost', port=5432, user='Tom', password='')
        except:
            print("I am unable to connect to the database")

    _db_cur = _connection.cursor(cursor_factory=psycopg2.extras.DictCursor)
    return _db_cur
