from flask import Flask, render_template, request
from flaskext.mysql import MySQL

app = Flask(__name__)
mysql = MySQL()
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = 'Root@123' # replace **** with your local mysql password.
app.config['MYSQL_DATABASE_DB'] = 'IMDB_Local'
app.config['MYSQL_DATABASE_HOST'] = 'localhost'
mysql.init_app(app)

@app.route("/")
def home_page():
    return render_template('home.html')
    #return render_template('Query_1.html')


@app.route("/query1")
def query_1():
    return render_template('Query_1.html')


@app.route("/query1")
def query_2():
    return render_template('Query_1.html')


@app.route("/query2")
def query_3():
    return render_template('Query_2.html')

@app.route("/query3")
def query_3():
    return render_template('Query_3.html')


@app.route("/query4")
def query_3():
    return render_template('Query_4.html')


@app.route("/query5")
def query_3():
    return render_template('Query_5.html')


@app.route("/query6")
def query_3():
    return render_template('Query_6.html')


@app.route("/query7")
def query_3():
    return render_template('Query_7.html')


@app.route("/query8")
def query_3():
    return render_template('Query_8.html')


@app.route("/query9")
def query_3():
    return render_template('Query_9.html')


@app.route("/query10")
def query_3():
    return render_template('Query_10.html')


@app.route('/result', methods=['POST', 'GET'])
def result():
    print(request.form['StartsWith'])
    print(request.form['year'])
    conn = mysql.connect()
    cursor = conn.cursor()
    cursor.execute("select * from new_title_akas where types='imdbDisplay'")
    records = cursor.fetchmany(10)
    return render_template('general_table_display.html', result=records)


if __name__ == "__main__":
    app.run()
