require(dplyr)
require(readr)
require(lubridate)
require(stringr)
require(tidyr)
require(sqldf)

setwd("~/Documents/IntroToBigData/Data_Mining/tmdb-movie-metadata")

tmdb_5000_movies <- read.csv("tmdb_5000_movies.csv")
moviedata<-tmdb_5000_movies

Quantitivedata<-sqldf("select budget, homepage, id, original_language, original_title, overview, popularity, production_companies, production_countries, release_date, revenue, runtime, spoken_languages, status, vote_average, vote_count from moviedata")
Textualdata<-sqldf("select homepage, original_title, overview, tagline from moviedata")

plot(moviedata$vote_average, moviedata$budget)
plot(moviedata$vote_average, moviedata$genres)
plot(moviedata$vote_average, moviedata$original_language)
plot(moviedata$vote_average, moviedata$popularity)
plot(moviedata$vote_average, moviedata$revenue)
plot(moviedata$vote_average, moviedata$runtime)
plot(moviedata$vote_average, moviedata$vote_count)
