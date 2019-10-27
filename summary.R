require(data.table)
require(gWQS)
require(qgcomp)
require(dplyr)

setwd("~/PycharmProjects/CSCI620_Proj1/")

episodes <- as.data.frame(fread("episode.tsv", quote = ""))
name <- as.data.frame(fread("name.tsv", quote = ""))
principals <- as.data.frame(fread("principals.tsv", quote=""))
rating <- as.data.frame(fread("rating.tsv", quote=""))
titleAkas <- as.data.frame(fread("titleAkas.tsv", quote=""))
titleBasic <- as.data.frame(fread("titleBasic.tsv", quote=""))

titleBasicQuantize <-
  titleBasic %>%
  mutate(titleType = case_when(
    titleType == "tvMiniSeries" ~ 0,
    titleType == "tvSpecial" ~ 1,
    titleType == "tvEpisode" ~ 2,
    titleType == "tvSeries" ~ 3,
    titleType == "tvShort" ~ 4,
    titleType == "tvMovie" ~ 5,
    titleType == "videoGame" ~ 6,
    titleType == "video" ~ 7,
    titleType == "movie" ~ 8,
    titleType == "short" ~ 9,
    TRUE ~ -1
  ))


titleBasicQuantize <-
  titleBasicQuantize %>%
  mutate(startYear = case_when(
    TRUE ~ strtoi(startYear)
  ))

titleBasicQuantize <-
  titleBasicQuantize %>%
  mutate(endYear = case_when(
    TRUE ~ strtoi(endYear)
  ))

titleBasicQuantize <-
  titleBasicQuantize %>%
  mutate(runtimeMinutes = case_when(
    TRUE ~ strtoi(runtimeMinutes)
  ))



titleAkasQuantize <-
  titleAkas %>%
  mutate(isOriginalTitle = case_when(
    TRUE ~ strtoi(isOriginalTitle),
  ))



name <-
  name %>%
  mutate(birthYear = case_when(
    TRUE ~ strtoi(birthYear)
  ))

name <-
  name %>%
  mutate(deathYear = case_when(
    TRUE ~ strtoi(deathYear)
  ))


episodes <-
  episodes %>%
  mutate(seasonNumber = case_when(
    TRUE ~ strtoi(seasonNumber),
    
  ))

episodes <-
  episodes %>%
  mutate(episodeNumber = case_when(
    TRUE ~ strtoi(episodeNumber)
  ))




basicAkasMerge <- merge(titleBasicQuantize, titleAkasQuantize, by.x="tconst", by.y="titleId")
basicAkasRating <- merge(basicAkasMerge, rating, by.x="tconst", by.y="tconst")
basicAkasRatingEpisode <- merge(basicAkasRating, episodes, by.x="tconst", by.y="tconst")
basicAkasRatingEpisodeNames <- merge(basicAkasRatingEpisode, name, by.x="tconst", by.y="knownForTitles")

names(basicAkasRatingEpisodeNames)
summary(basicAkasRatingEpisodeNames)
attach(basicAkasRatingEpisodeNames)

hist(isAdult)
hist(averageRating)
plot(startYear, averageRating)
plot(averageRating, runtimeMinutes)
pairs(~ averageRating + numVotes + isOriginalTitle + isAdult + runtimeMinutes + ordering + titleType + episodeNumber + seasonNumber + startYear, basicAkasRatingEpisode)
