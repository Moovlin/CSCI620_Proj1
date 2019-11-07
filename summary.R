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


#credits <- as.data.frame(fread("tmdb_5000_movies.csv", quote = ""))
#movies <- as.data.frame(fread("tmdb_5000_credits.csv", quote = ""))
#episodes <- as.data.frame(fread("title.episode.tsv", quote = ""))
#name <- as.data.frame(fread("name.basics.tsv", quote = ""))
#principals <- as.data.frame(fread("title.principals.tsv", quote=""))
#rating <- as.data.frame(fread("title.ratings.tsv", quote=""))
#titleAkas <- as.data.frame(fread("title.akas.tsv", quote=""))
#titleBasic <- as.data.frame(fread("title.basics.tsv", quote=""))

# titleBasicQuantize <-
#   titleBasic %>%
#   mutate(titleType = case_when(
#     titleType == "tvMiniSeries" ~ 0,
#     titleType == "tvSpecial" ~ 1,
#     titleType == "tvEpisode" ~ 2,
#     titleType == "tvSeries" ~ 3,
#     titleType == "tvShort" ~ 4,
#     titleType == "tvMovie" ~ 5,
#     titleType == "videoGame" ~ 6,
#     titleType == "video" ~ 7,
#     titleType == "movie" ~ 8,
#     titleType == "short" ~ 9,
#     TRUE ~ -1
#   ))
# 

# titleBasicQuantize <-
#   titleBasicQuantize %>%
#   mutate(startYear = case_when(
#     TRUE ~ strtoi(startYear)
#   ))
# 
# titleBasicQuantize <-
#   titleBasicQuantize %>%
#   mutate(endYear = case_when(
#     TRUE ~ strtoi(endYear)
#   ))
# 
# titleBasicQuantize <-
#   titleBasicQuantize %>%
#   mutate(runtimeMinutes = case_when(
#     TRUE ~ strtoi(runtimeMinutes)
#   ))
# 
# 
# 
# titleAkasQuantize <-
#   titleAkas %>%
#   mutate(isOriginalTitle = case_when(
#     TRUE ~ strtoi(isOriginalTitle),
#   ))
# 
# 
# 
# name <-
#   name %>%
#   mutate(birthYear = case_when(
#     TRUE ~ strtoi(birthYear)
#   ))
# 
# name <-
#   name %>%
#   mutate(deathYear = case_when(
#     TRUE ~ strtoi(deathYear)
#   ))
# 
# 
# episodes <-
#   episodes %>%
#   mutate(seasonNumber = case_when(
#     TRUE ~ strtoi(seasonNumber),
# 
#   ))
# 
# episodes <-
#   episodes %>%
#   mutate(episodeNumber = case_when(
#     TRUE ~ strtoi(episodeNumber)
#   ))
# 
# 
# 
# 
# basicAkasMerge <- merge(titleBasicQuantize, titleAkasQuantize, by.x="tconst", by.y="titleId")
# basicAkasRating <- merge(basicAkasMerge, rating, by.x="tconst", by.y="tconst")
# basicAkasRatingEpisode <- merge(basicAkasRating, episodes, by.x="tconst", by.y="tconst")
# basicAkasRatingEpisodeNames <- merge(basicAkasRatingEpisode, name, by.x="tconst", by.y="knownForTitles")
# 
# names(basicAkasRatingEpisodeNames)
# summary(basicAkasRatingEpisodeNames)
# attach(basicAkasRatingEpisodeNames)
# 
# hist(isAdult)
# hist(averageRating)
# plot(startYear, averageRating)
# plot(averageRating, runtimeMinutes)
# pairs(~ averageRating + numVotes + isOriginalTitle + isAdult + runtimeMinutes + ordering + titleType + episodeNumber + seasonNumber + startYear, basicAkasRatingEpisode)
