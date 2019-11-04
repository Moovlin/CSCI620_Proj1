from flask import Flask, render_template, request
from flaskext.mysql import MySQL

app = Flask(__name__)
mysql = MySQL()
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = 'root' # replace **** with your local mysql password.
app.config['MYSQL_DATABASE_DB'] = 'proj1'
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
        startsWith = request.form['StartsWith']
        year = request.form['year']
        queryString = "SELECT per.`primary_name` " \
                        "FROM personx per " \
                        "WHERE per.`death_year` IS NULL " \
                        "AND per.`primary_name` LIKE '" + startsWith +"%' " \
                        "AND NOT EXISTS( " \
                        "SELECT * " \
                        "FROM movie_participate par " \
                        "where par.nconst = per.nconst " \
                        "AND par.`release_year` = "+ year +") and exists( "\
                        "select * from acts a " \
                        "where a.nconst = per.nconst); "
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
        name = request.form['name']
        number = request.form['number']
        year = request.form['year']
        queryString = "select per.primary_name " \
                      "FROM personx per " \
                      "WHERE " \
                      "per.death_year " \
                      "IS NULL AND per.primary_name " \
                      "LIKE '%" + name + "%' " \
                                              "AND per.nconst " \
                                              "IN( " \
                                              "SELECT pro.nconst " \
                                              "FROM producers pro, talkshow tak " \
                                              "WHERE pro.tconst = tak.tconst " \
                                              "AND tak.show_year = " + year + \
                                              " group by pro.nconst " \
                                              " having count(*) > "+ number +");"

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
        headers = ["primary_name","Runtime"]
        return render_template("general_table_display.html", result=records, header=headers)

#Aj - 5.List the unique name pairs of actors who have acted together in more than a given number (such as 2) movies and sort them by average movie rating (of those they acted together).
@app.route("/query5", methods=['POST', 'GET'])
def query_5():
    if request.method == 'GET':
        return render_template('Query_5.html')
    else:
        print("In query5")
        Number_Movies = request.form["Number_Movies"]
        queryString = "select distinct a.a1, a.a2, p.rating " \
                      "from act_act a, previous_rating p " \
                      "where p.tconst = a.tconst " \
                      "group by a.a1, a.a2, p.rating " \
                      "having count(*) > "+Number_Movies+" order by p.rating desc;"

        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.execute(queryString.format(Number_Movies))
        records = cursor.fetchall()
        headers = ["Actor Name 1", "Actor Name 2", "Rating"]
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
        queryString = "select gen.title " \
                      "from has h, tvEpisode epi, general_movies gen " \
                      "where h.episode_tconst = epi.episode_tconst and gen.tconst = h.series_tconst and gen.runtime > {} " \
                      "and exists (select * " \
                      "from previous_rating previous " \
                      "where h.series_tconst = previous.tconst and rating > {}) " \
                      "group by h.series_tconst, gen.title " \
                      "having count(*) > {};"
        print(queryString.format(running_time, mini_rating, number_episodes))
        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.execute(queryString.format(running_time, mini_rating, number_episodes))
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
        queryString = "Select distinct lo.local_name, per.primary_name, lo.lang " \
                        "from general_movies m, personx per, localize lo, acts act   " \
                        "where act.nconst = per.nconst and lo.tconst = m.tconst and m.tconst = act.tconst " \
                        "and m.type = 'movie' and lo.lang = '"+ language + "' "\
                        " and per.primary_name like '%" + actor_name+ "%' limit 0,100;"

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
        queryString = "select distinct per.primary_name " \
                    "from producers pro, personx per " \
                    "where pro.nconst = per.nconst " \
                    "and exists (select * " \
                    "from movie mov " \
                    "where pro.tconst = mov.movie_tconst " \
                    "and mov.release_year > per.death_year);"
        print(queryString)
        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.execute(queryString)
        records = cursor.fetchall()
        headers = ["Producer Name"]
        return render_template("general_table_display.html", result=records, header=headers)


#Ri - 9.List all the movies where the actor and director both had the same birth year contributed to the same movie.
@app.route("/query9", methods=['POST', 'GET'])
def query_9():
    if request.method == 'GET':
        return render_template('Query_8.html')
    else:
        queryString = "select distinct gen.title " \
                        "from dir_act_mov a, general_movies gen " \
                        "where a.dir_birth = a.act_birth " \
                        "and gen.tconst = a.tconst and not a.dir_nconst = a.act_nconst;"
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
        queryString = "select mov.title, mov.runtime " \
                      "from general_movies mov , generes gen " \
                      "where mov.tconst = gen.tconst " \
                      "and gen.genre like '%show%'" \
                      "and mov.runtime < {}";

        conn = mysql.connect()
        cursor = conn.cursor()
        cursor.execute(queryString.format(length))
        records = cursor.fetchall()
        headers = ["Title", "Runtime(Minutes)"]
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
