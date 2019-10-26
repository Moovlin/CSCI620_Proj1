from flask import Flask, render_template, request
from flaskext.mysql import MySQL

app = Flask(__name__)
mysql = MySQL()
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = 'Root@123' # replace **** with your local mysql password.
app.config['MYSQL_DATABASE_DB'] = 'group3_movies_v1'
app.config['MYSQL_DATABASE_HOST'] = 'localhost'
mysql.init_app(app)


@app.route("/")
def home_page():
    return render_template('home.html')
    #return render_template('Query_1.html')


@app.route("/query1", methods=['POST', 'GET'])
def query_1():
    if request.method == 'GET':
        return render_template('Query_1.html')
    else:
        StartsWith = request.form['StartsWith']
        year = request.form['year']
        queryString = "SELECT per.primary_name " \
                      "FROM persons per, surrogate_person sur " \
                      "WHERE per.primary_name= sur.primary_name " \
                      "AND per.birth_year = sur.birth_year " \
                      "AND per.death_year " \
                      "IS NULL AND per.primary_name " \
                      "LIKE '"+StartsWith+"%' " \
                      "AND sur.nconst " \
                      "NOT IN( SELECT act.nconst " \
                      "FROM movie mov, acts act " \
                      "WHERE mov.movie_tconst = act.tconst " \
                      "AND mov.release_year = "+year+") " \
                      "AND sur.nconst NOT IN(" \
                      "SELECT par.nconst " \
                      "FROM participates par, movie mov " \
                      "WHERE mov.movie_tconst = par.tconst " \
                      "AND mov.release_year = "+year+")";
        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.execute(queryString)
        records = cursor.fetchall()
        headers = ["Actor Name"]
        return render_template("general_table_display.html", result=records, header=headers)


@app.route("/query2", methods=['POST', 'GET'])
def query_2():
    if request.method == 'GET':
        return render_template('Query_2.html')
    else:
        StartsWith = request.form['StartsWith']
        year = request.form['year']
        queryString = "SELECT per.primary_name " \
                      "FROM persons per, surrogate_person sur " \
                      "WHERE per.primary_name= sur.primary_name " \
                      "AND per.birth_year = sur.birth_year " \
                      "AND per.death_year " \
                      "IS NULL AND per.primary_name " \
                      "LIKE '" + StartsWith + "%' " \
                                              "AND sur.nconst " \
                                              "NOT IN( " \
                                              "SELECT act.nconst " \
                                              "FROM movie mov, acts act " \
                                              "WHERE mov.movie_tconst = act.tconst " \
                                              "AND mov.release_year = 2014) " \
                                              "AND sur.nconst NOT IN( SELECT par.nconst " \
                                              "FROM participates par, movie mov " \
                                              "WHERE mov.movie_tconst = par.tconst " \
                                              "AND mov.release_year = " + year + ");"
        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.execute(queryString)
        records = cursor.fetchall()
        headers = ["Producer Name"]
        return render_template("general_table_display.html", result=records, header=headers)

#Ri - 3.List the average runtime for movies whose original title contain a given keyword such as (“star”) and were written by somebody who is still alive.
@app.route("/query3", methods=['POST', 'GET'])
def query_3():
    if request.method == 'GET':
        return render_template('Query_3.html')
    else:
        keyword = request.form['keyword']
        queryString = "SELECT AVG(gen.runtime) " \
                      "FROM general_movies gen " \
                      "WHERE title LIKE '%"+keyword+"%' " \
                      "AND gen.type = 'movie' " \
                      "AND gen.tconst IN ( SELECT tconst " \
                      "FROM writers w, personx per " \
                      "WHERE per.death_year IS NULL " \
                      "AND per.nconst = w.nconst );"
        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.execute(queryString)
        records = cursor.fetchall()
        headers = ["Runtime"]
        return render_template("general_table_display.html", result=records, header=headers)

#Ri - 4.List the names of alive producers with the greatest number of long-run movies produced (runtime greater than 120 min).
@app.route("/query4", methods=['POST', 'GET'])
def query_4():
    if request.method == 'GET':
        return render_template('Query_4.html')
    else:
        queryString = "select primary_name , max(runtime) " \
                      "from producer_movie_person " \
                      "where runtime > 120 and death_year is null " \
                      "group by nconst, primary_name;"
        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.execute(queryString)
        records = cursor.fetchall()
        headers = ["Runtime"]
        return render_template("general_table_display.html", result=records, header=headers)

#Aj - 5.List the unique name pairs of actors who have acted together in more than a given number (such as 2) movies and sort them by average movie rating (of those they acted together).
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
        headers = ["Actor Name pairs"]
        return render_template("general_table_display.html", result=records, header=headers)


#Aj - 6.List the tv series with x number of episodes and which has a rating above 4 for the last 5 years.
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
        headers = ["Title"]
        return render_template("general_table_display.html", result=records, header=headers)

#Aj - 7.List all the movies with actor (actor name ) and which are in language (English, Spanish etc).
@app.route("/query7", methods=['POST', 'GET'])
def query_7():
    if request.method == 'GET':
        return render_template('Query_7.html')
    else:
        language = request.form["language"]
        actor_name = request.form["actor_name"]
        print(actor_name)
        # queryString = "Select g.title, p.act_name, loc.lang  " \
        #               "from movie m " \
        #               "LEFT JOIN general_movies g on " \
        #               "(g.tconst = m.movie_tconst) " \
        #               "JOIN participates p on (g.tconst = p.movie_tconst) " \
        #               "JOIN localize loc on (loc.tconst = m.movie_tconst) " \
        #               "where loc.lang = '"+language+"' and p.act_name like '"+actor_name+"%';"
        queryString = "Select g.title, surr.primary_name, loc.lang  " \
                      "from movie m " \
                      "LEFT JOIN general_movies g on (g.tconst = m.movie_tconst) " \
                      "JOIN participates p on (g.tconst = p.tconst) " \
                      "JOIN surrogate_person surr on (p.nconst = surr.nconst) " \
                      "JOIN localize loc on (loc.tconst = m.movie_tconst) " \
                      "where loc.lang = '"+language+"' " \
                      "and p.category = 'actor' " \
                      "and surr.primary_name like '"+actor_name+"%';"
        print(queryString)
        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.execute(queryString.format(language, actor_name))
        records = cursor.fetchall()
        headers = ["Title", "Name", "Language"]
        return render_template("general_table_display.html", result=records, header=headers)

#Aj - 8.List all the actors and producers who died before their movie was released.
@app.route("/query8", methods=['POST', 'GET'])
def query_8():
    if request.method == 'GET':
        return render_template('Query_8.html')
    else:
        queryString = "Select m.release_year, g.title, p.act_name, per.death_year " \
                      "from movie m " \
                      "LEFT JOIN general_movies g on (g.tconst = m.movie_tconst) " \
                      "JOIN participates p on (g.tconst = p.movie_tconst) " \
                      "JOIN persons per on (p.act_name = per.primary_name) " \
                      "where m.release_year > per.death_year;"
        print(queryString)
        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.execute(queryString)
        records = cursor.fetchall()
        headers = ["Realease Year", "Title", "Actor/Producer Name", "Death Year"]
        return render_template("general_table_display.html", result=records, header=headers)


#Ri - 9.List all the movies where the actor and director both had the same birth year contributed to the same movie.
@app.route("/query9", methods=['POST', 'GET'])
def query_9():
    if request.method == 'GET':
        return render_template('Query_8.html')
    else:
        queryString = "SELECT mov.title FROM general_movies mov, participates par, surrogate_person sur1, persons per1 "\
                      "WHERE mov.type='movie' " \
                      "AND par.category = 'director' " \
                      "AND mov.tconst = par.tconst " \
                      "AND par.nconst = sur1.nconst " \
                      "AND per1.primary_name = sur1.primary_name " \
                      "AND per1.birth_year = sur1.birth_year " \
                      "AND per1.birth_year IN ( 	" \
                      "SELECT per2.birth_year 	" \
                      "FROM acts act, surrogate_person sur2, persons per2 	" \
                      "WHERE mov.tconst = act.tconst " \
                      "AND act.nconst = sur2.nconst " \
                      "AND per2.primary_name = sur2.primary_name " \
                      "AND per2.birth_year = sur2.birth_year)"
        print(queryString)
        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.execute(queryString)
        records = cursor.fetchall()
        headers = ["Title"]
        return render_template("general_table_display.html", result=records, header=headers)


#Ri - 11. List all the shows which have a total run time less than a particular value
@app.route("/query10", methods=['POST', 'GET'])
def query_10():
    if request.method == 'GET':
        return render_template('Query_10.html')
    else:
        length = request.form["length"]
        length = int(length) * 60
        queryString = "select title, runtime, " \
                      "count(tvSeries.series_tconst) * runtime from group3_movies.general_movies as gMovies, " \
                      "group3_movies.tvSeries as tvSeries, group3_movies.has as has " \
                      "where gMovies.tconst = tvSeries.series_tconst and has.series_tconst = tvSeries.series_tconst " \
                      "group by (tvSeries.series_tconst) having count(has.episode_tconst) * runtime < {};"
        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.execute(queryString.format(length))
        records = cursor.fetchall()
        headers = ["Title", "Runtime"]
        return render_template("general_table_display.html", result=records, header=headers)


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
