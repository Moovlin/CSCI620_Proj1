from flask import Flask, render_template, request
from flaskext.mysql import MySQL

app = Flask(__name__)
mysql = MySQL()
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = 'Root@123' # replace **** with your local mysql password.
app.config['MYSQL_DATABASE_DB'] = 'group3_movies'
app.config['MYSQL_DATABASE_HOST'] = 'localhost'
mysql.init_app(app)


@app.route("/")
def home_page():
    return render_template('home.html')
    #return render_template('Query_1.html')


@app.route("/query1", methods=['POST', 'GET'])
def query_1():
    return render_template('Query_1.html')


@app.route("/query2", methods=['POST', 'GET'])
def query_2():
    return render_template('Query_2.html')


@app.route("/query3", methods=['POST', 'GET'])
def query_3():
    return render_template('Query_3.html')


@app.route("/query4", methods=['POST', 'GET'])
def query_4():
    return render_template('Query_4.html')


@app.route("/query5", methods=['POST', 'GET'])
def query_5():
    if request.method == 'GET':
        return render_template('Query_5.html')
    else:
        print("In query5")
        Number_Movies = request.form["Number_Movies"]
        queryString = "Select actlist " \
                      "FROM (Select actList, Count(actList) as countOfMovies " \
                      "FROM (Select  r.rating as rating, GROUP_CONCAT(p.act_name SEPARATOR ',') as actList, g.title as title " \
                      "from movie m " \
                      "JOIN general_movies g on (g.tconst = m.movie_tconst) " \
                      "JOIN participates p on (g.tconst = p.movie_tconst) " \
                      "JOIN persons per on (p.act_name = per.primary_name) " \
                      "JOIN previous_rating r on (g.tconst = r.tconst) " \
                      "group by g.title, r.rating " \
                      "order by r.rating) as listOfActors " \
                      "GROUP by actlist) as listandCount " \
                      "Where countOfMovies > {};"
        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.execute(queryString.format(Number_Movies))
        records = cursor.fetchall()
        return render_template("general_table_display.html", result=records)


@app.route("/query6", methods=['POST', 'GET'])
def query_6():
    if request.method == 'GET':
        return render_template('Query_6.html')
    else:
        number_episodes = request.form["numberOfEpisodes"]
        mini_rating = request.form["mini_rating"]
        running_time = request.form["running_time"]
        queryString = "Select g.title " \
                      "from tvEpisode tve " \
                      "LEFT JOIN rating r " \
                      "ON (tve.episode_tconst = r.tconst AND r.rating> {}) " \
                      "LEFT JOIN general_movies g " \
                      "ON (g.tconst = tve.episode_tconst) " \
                      "where tve.episode_number> {} " \
                      "AND g.runtime < {};"
        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.execute(queryString.format(mini_rating, number_episodes, running_time))
        records = cursor.fetchall()
        return render_template("general_table_display.html", result=records)


@app.route("/query7", methods=['POST', 'GET'])
def query_7():
    if request.method == 'GET':
        return render_template('Query_7.html')
    else:
        language = request.form["language"]
        actor_name = request.form["actor_name"]
        print(actor_name)
        queryString = "Select g.title, p.act_name, loc.lang  " \
                      "from movie m " \
                      "LEFT JOIN general_movies g on " \
                      "(g.tconst = m.movie_tconst) " \
                      "JOIN participates p on (g.tconst = p.movie_tconst) " \
                      "JOIN localize loc on (loc.tconst = m.movie_tconst) " \
                      "where loc.lang = '"+language+"' and p.act_name like '"+actor_name+"%';"
        print(queryString)
        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.execute(queryString.format(language, actor_name))
        records = cursor.fetchall()
        return render_template("general_table_display.html", result=records)


@app.route("/query8", methods=['POST', 'GET'])
def query_8():
    return render_template('Query_8.html')


@app.route("/query9", methods=['POST', 'GET'])
def query_9():
    return render_template('Query_9.html')


@app.route("/query10", methods=['POST', 'GET'])
def query_10():
    return render_template('Query_10.html')


@app.route('/result', methods=['POST', 'GET'])
def result():
    print(request.form['StartsWith'])
    print(request.form['year'])
    conn = mysql.connect()
    cursor = conn.cursor()
    #select DISTINCT act_name from acts where act_name LIKE 'B%' and acts.movie_tconst not in (Select movie_tconst from movie where release_year = '2011') and EXISTS (select death_year from persons p where p.primary_name = act_name) order by act_name;
#select DISTINCT a.act_name from acts a where a.act_name LIKE 'B%' and a.movie_tconst not in (Select a.movie_tconst from movie where release_year = '2011') and EXISTS (select p.death_year from persons p where p.primary_name = a.act_name) order by act_name;
    query = "select DISTINCT a.act_name from acts a where a.act_name LIKE '"+request.form['StartsWith']+"%' " \
        "and a.movie_tconst not in (Select m.movie_tconst from movie m where m.release_year = '"+request.form['year']+"') and " \
        "NOT EXISTS (select p.death_year from persons p where p.primary_name = a.act_name) order by act_name"
    print(query)
    cursor.execute(query)
    records = cursor.fetchmany(10)
    return render_template('general_table_display.html', result=records)

if __name__ == "__main__":
    app.config['TEMPLATES_AUTO_RELOAD'] = True
    app.run()
