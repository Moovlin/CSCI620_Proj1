from flask import Flask
from flaskext.mysql import MySQL

app = Flask(__name__)
mysql = MySQL()
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = 'Eating4628@K' # replace **** with your local mysql password.
app.config['MYSQL_DATABASE_DB'] = 'IMDB_Local'
app.config['MYSQL_DATABASE_HOST'] = 'localhost'
mysql.init_app(app)

@app.route("/")
def hello():
    conn = mysql.connect()
    cursor = conn.cursor()

    cursor.execute("select * from new_title_akas where types='imdbDisplay'")
    data = cursor.fetchone()
    print(data)
    return "Hello World!"

if __name__ == "__main__":
    app.run()
    