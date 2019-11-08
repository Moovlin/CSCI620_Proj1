library(plyr)             #For Data transformation
library(tidyverse)        #For data cleaning
library(jsonlite)         #For manipulating JSON data
library(wordcloud)        #For generating Word Cloud
library(RColorBrewer)     #For further formatting
library(ggplot2)          #Extension of ggplot2
library(tm)               #For text mining
library(zoo)              #For handling irregular time series of numeric vectors/matrices and factors


setwd("~/Downloads/tmdb-movie-metadata")

movie = read_csv("tmdb_5000_movies.csv",col_names = TRUE, na = "NA")
credits = read_csv("tmdb_5000_credits.csv",col_names = TRUE,na = "NA")

glimpse(movie)
glimpse(credits)

#data cleaning
# movie
diffGenre = movie %>% filter(nchar(genres) > 2) %>% mutate(js = lapply(genres,fromJSON)) %>% unnest(js,.names_repair = "check_unique") %>% select(id,title,genre = name)
productionCompanies = movie %>% filter(nchar(production_companies) > 2) %>% mutate(js = lapply(production_companies,fromJSON)) %>% unnest(js,.names_repair = "check_unique") %>% select(id,budget,revenue,production_companies = name)
productionCountries = movie %>% filter(nchar(production_countries) > 2) %>% mutate(js = lapply(production_countries,fromJSON)) %>% unnest(js) %>% select(production_countries = name)
SpokenLang = movie %>% filter(nchar(spoken_languages) > 2) %>% mutate(js = lapply(spoken_languages,fromJSON)) %>% unnest(js) %>% select(iso_639_1,spoken_languages = name)
movies <- subset(movie, select = -c(genres, keywords, production_companies, production_countries,spoken_languages))
glimpse(movies)

# credit
all_crew <- credits %>%      # start with the raw tibble 
  filter(nchar(crew) > 2) %>%        # filter out movies with empty crew  
  mutate(                                 
    js  =  lapply(crew, fromJSON)  # turn the JSON into a list
  )  %>%                           #
  unnest(js) 

all_cast <- credits %>%      # start with the raw tibble 
  filter(nchar(cast) > 2) %>%        # filter out movies with empty crew  
  mutate(                          #       
    js  =  lapply(cast, fromJSON)  # turn the JSON into a list
  )  %>%                           #
  unnest(js) 
cast <- subset(all_cast, select = -c(movie_id, title, cast, crew))
crew <- subset(all_cast, select = -c(movie_id, title, cast, crew))

library(DT)
datatable(head(movies,30))
datatable(head(productionCompanies,10))
datatable(head(cast, 10))
datatable(head(crew, 10))

