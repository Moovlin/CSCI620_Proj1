library(plyr)             #For Data transformation
library(tidyverse)        #For data cleaning
library(jsonlite)         #For manipulating JSON data
library(wordcloud)        #For generating Word Cloud
library(RColorBrewer)     #For further formatting
library(ggplot2)          #Extension of ggplot2
library(tm)               #For text mining
library(zoo)              #For handling irregular time series of numeric vectors/matrices and factors


setwd("~/Documents/IntroToBigData/Data_Mining/tmdb-movie-metadata")

movie = read_csv("tmdb_5000_movies.csv",col_names = TRUE, na = "NA")
credits = read_csv("tmdb_5000_credits.csv",col_names = TRUE,na = "NA")

glimpse(movie)
glimpse(credits)

#data cleaning

# movie
## removing spurious characters
movie$title <- (sapply(movie$title,gsub,pattern = "\\Â",replacement = ""))

## deleting duplicate rows
movie <- movie[!duplicated(movie$title), ]
dim(movie)

## transformation of "keywords" column into tibble
keywords <- movie %>%    
  filter(nchar(keywords) > 2) %>%                 # fiter out blank keywords field
  mutate(                                         # create a new field 
    js = lapply(keywords, fromJSON)               # containing a LIST of keyword and value pairs
  ) %>%                                           # called id and name
  unnest(js,.names_repair = "check_unique") %>%   # turn each keyword/value pairs in the LIST into a row
  select(id, title, keywords = name)

## Combining the keywords of a movie in a single column
keywords <- aggregate(keywords ~.,data = keywords, paste, collapse = ",")

#Combining the genres of a movie in a single column
genres <- movie %>% filter(nchar(genres) > 2) %>%                   
  mutate( js = lapply(genres, fromJSON)) %>%                                           
  unnest(js,.names_repair = "check_unique") %>%                                  
  select(id, title, genres = name) 

genres <- aggregate(genres ~.,data = genres, paste, collapse = ",")

# Combining production_companies
production_companies <- movie %>% filter(nchar(production_companies) > 2) %>%                   
  mutate( js = lapply(production_companies, fromJSON)) %>%                                           
  unnest(js,.names_repair = "check_unique") %>%                                  
  select(id, title, production_companies = name) 

production_companies <- aggregate(production_companies ~.,data = production_companies, paste, collapse = ",")

# Combining production countries
production_countries <- movie %>%    
  filter(nchar(production_countries) > 2) %>%     
  mutate(                                         
    js = lapply(production_countries, fromJSON)   
  ) %>%                                          
  unnest(js) %>%                                  
  select(id, title, production_countries = name)

countries <- movie %>%    
  filter(nchar(production_countries) > 2) %>%     
  mutate(                                         
    js = lapply(production_countries, fromJSON)   
  ) %>%                                          
  unnest(js,.names_repair = "check_unique") %>%                                  
  select(id, title, production_countries = name)

production_countries <- aggregate(production_countries ~.,data = production_countries, paste, collapse = ",")

# combining spoken languages
spoken_languages <- movie %>%    
  filter(nchar(spoken_languages) > 2) %>%        
  mutate(                                         
    js = lapply(spoken_languages, fromJSON)      
  ) %>%                                          
  unnest(js,.names_repair = "check_unique") %>%                                 
  select(id, title, spoken_languages = iso_639_1) 

spoken_languages <- aggregate(spoken_languages ~.,data = spoken_languages, paste, collapse = ",")

movies <- subset(movie, select = -c(genres, keywords, production_companies, production_countries,spoken_languages))
glimpse(movies)

# Dropped existing unformatted columns in the main dataset, creating a new dataset "movies"
movies <- subset(movie, select = -c(genres, keywords, production_companies, production_countries, spoken_languages))


movies <- movies %>%
  full_join(keywords, by = c("id", "title")) %>%
  full_join(genres, by = c("id", "title")) %>%
  full_join(production_companies, by = c("id", "title")) %>%
  full_join(production_countries, by = c("id", "title")) %>%
  full_join(spoken_languages, by = c("id", "title"))

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
datatable(head(cast, 10))
datatable(head(crew, 10))

#analysis by average vote
ggplot(movies,aes(vote_average)) +
  geom_histogram(bins = 100) +
  geom_vline(xintercept = mean(movie$vote_average,na.rm = TRUE),colour = "red") + 
  ylab("Count of Movies") + 
  xlab("Average Vote") + 
  ggtitle("Histogram for average vote rating")

movies %>% select(title,vote_average,vote_count, budget) %>% 
  filter(vote_count > 500 ) %>% arrange(desc(vote_average)) %>% head(20) %>%
  ggplot(aes(x = title,y = vote_average,fill = budget )) + geom_bar(stat = "identity") + coord_flip(ylim = c(7, 9)) +
  scale_fill_continuous()

movies %>% select(title,vote_average,vote_count, popularity) %>% 
  filter(vote_count > 300 ) %>%  head(30) %>%
  ggplot(aes(x = title,y = popularity, fill = vote_count)) + geom_bar(stat = "identity") + coord_flip() +
  scale_fill_continuous()

movies %>% select(original_language,vote_average, title) %>% 
  filter(original_language == 'af' ) %>%  head(30) %>%
  ggplot(aes(x =vote_average ,y = original_language)) + geom_bar(stat = "identity") + coord_flip() +
  scale_fill_continuous()


plot(movies$vote_average, movies$original_language)

original_language <- movies$original_language
original_language <- as.data.frame(table(original_language))

plot(movies$vote_average , factor(original_language))

language <- movies$original_language
ggplot(movies[movies$original_language=='en',],aes(x=vote_average))+geom_histogram(binwidth=1)
ggplot(movies[movies$original_language=='fr',],aes(x=vote_average))+geom_histogram(binwidth=1)
ggplot(movies[movies$original_language=='zh',],aes(x=vote_average))+geom_histogram(binwidth=1)
ggplot(movies[movies$original_language=='es',],aes(x=vote_average))+geom_histogram(binwidth=1)
ggplot(movies[movies$original_language=='de',],aes(x=vote_average))+geom_histogram(binwidth=1)

