# title: "NLP"
# author: "Chieh-An Yang"


library(tm)
library(SnowballC)
library(wordcloud)
library(ggplot2)
library(dplyr)
library(tidyr)
library(topicmodels)
library(stringr)

#IF USING A MAC PLEASE RUN THIS CODE
Sys.setlocale("LC_ALL", "C")

## Import all document files and the list of weeks file

#Create a list of all the files
file.list <- list.files(path="~/Desktop/LA at TC/2019Spring/HUDK 4051 LA RrocTheory/Projects/natural-language-processing/class-notes", pattern=".csv", full.names = TRUE)
#Loop over file list importing them and binding them together
D1 <- do.call("rbind", lapply(grep(".csv", file.list, value = TRUE), read.csv, header = TRUE, stringsAsFactors = FALSE))

D2 <- read.csv("~/Desktop/LA at TC/2019Spring/HUDK 4051 LA RrocTheory/Projects/natural-language-processing/week-list.csv", header = TRUE)


# Clean the htlm tags from text
D1$Notes2 <- gsub("<.*?>", "", D1$Notes)
D1$Notes2 <- gsub("nbsp", "" , D1$Notes2)
D1$Notes2 <- gsub("nbspnbspnbsp", "" , D1$Notes2)

## Process text using the tm package
#Convert the data frame to the corpus format that the tm package uses
corpus <- VCorpus(VectorSource(D1$Notes2))
#Remove spaces
corpus <- tm_map(corpus, stripWhitespace)
#Convert to lower case
corpus <- tm_map(corpus, tolower)
#Remove pre-defined stop words ('the', 'a', etc)
corpus <- tm_map(corpus, removeWords, stopwords('english'))
#Convert words to stems ("education" = "edu") for analysis, for more info see  http://tartarus.org/~martin/PorterStemmer/
corpus <- tm_map(corpus, stemDocument)
#Remove numbers
corpus <- tm_map(corpus, removeNumbers)
#remove punctuation
corpus <- tm_map(corpus, removePunctuation)
#Convert to plain text for mapping by wordcloud package
corpus <- tm_map(corpus, PlainTextDocument, lazy = TRUE)

#Convert corpus to a term document matrix - so each word can be analyzed individuallly
tdm.corpus <- TermDocumentMatrix(corpus)

## Alternative processing - Code has been altered to account for changes in the tm package

#Convert the data frame to the corpus format that the tm package uses
corpus <- Corpus(VectorSource(D1$Notes2))
#Remove spaces
corpus <- tm_map(corpus, stripWhitespace)
#Convert to lower case
corpus <- tm_map(corpus, content_transformer(tolower))
#Remove pre-defined stop words ('the', 'a', etc)
corpus <- tm_map(corpus, removeWords, stopwords('english'))
#Convert words to stems ("education" = "edu") for analysis, for more info see  http://tartarus.org/~martin/PorterStemmer/
corpus <- tm_map(corpus, stemDocument, lazy=TRUE)
#Remove numbers
corpus <- tm_map(corpus, removeNumbers, lazy=TRUE)
#remove punctuation
corpus <- tm_map(corpus, removePunctuation, lazy=TRUE)


## Find common words
#The tm package can do some simple analysis, like find the most common words
findFreqTerms(tdm.corpus, lowfreq=50, highfreq=Inf)
#We can also create a vector of the word frequencies
word.count <- sort(rowSums(as.matrix(tdm.corpus)), decreasing=TRUE)
word.count <- data.frame(word.count)

# Generate a Word Cloud
col=brewer.pal(6,"Dark2")
wordcloud(corpus, min.freq=80, scale=c(5,2),rot.per = 0.25,
          random.color=T, max.word=45, random.order=F,colors=col)


#Create a Term Document Matrix
tdm.corpus <- TermDocumentMatrix(corpus)


## Sentiment Analysis
#Upload positive and negative word lexicons
positive <- readLines("positive-words.txt")
negative <- readLines("negative-words.txt")

#Search for matches between each word and the two lexicons
D1$positive <- tm_term_score(tdm.corpus, positive)
D1$negative <- tm_term_score(tdm.corpus, negative)

#Generate an overall pos-neg score for each line
D1$score <- D1$positive - D1$negative

# Merge with week list so you have a variable representing weeks for each entry 
D3 <- merge(D1, D2, by.x="Title", by.y="Title")

# Generate a visualization of the sum of the sentiment score over weeks
D4 <- select(D3, week, score)
D5 <- D4 %>% 
    group_by(week) %>% 
    summarise(sentiment_week = sum(score))

ggplot(data=D5, aes(x=week, y=sentiment_week)) + geom_col()

## LDA Topic Modelling
#Term Frequency Inverse Document Frequency
dtm.tfi <- DocumentTermMatrix(corpus, control = list(weighting = weightTf))

#Remove very uncommon terms (term freq inverse document freq < 0.1)
dtm.tfi <- dtm.tfi[,dtm.tfi$v >= 0.1]

#Remove non-zero entries
rowTotals <- apply(dtm.tfi , 1, sum) #Find the sum of words in each Document
dtm.tfi   <- dtm.tfi[rowTotals> 0, ] #Divide by sum across rows

lda.model = LDA(dtm.tfi, k = 5, seed = 123)

#Which terms are most common in each topic
terms(lda.model)

#Which documents belong to which topic
topics(lda.model)

## Generate a visualization showing:
# Sentiment for each week and 
# One important topic for that week

D6 <- data.frame(topics(lda.model))
D6$ID <- row.names(D6)
D1$ID <- row.names(D1)
D7 <- merge(D1, D6, by.x="ID", by.y="ID")
D8 <- merge(D7, D2, by.x="Title", by.y="Title")
D9 <- select(D8, week, score, topics.lda.model.)
D10 <- D9 %>%
    group_by(week) %>%
    slice(which.max(table(topics.lda.model.))) %>%
    select(-score)
names(D10) <- c("week", "topics")

D11 <- merge(D10, D5, by.x="week", by.y="week")
D12 <- data.frame(terms(lda.model))
names(D12) <-c("topic_name")
D12$topics<- seq.int(nrow(D12))
D13 <- merge(D11, D12, by.x="topics", by.y="topics")
ggplot(data=D13, aes(x=week, y=sentiment_week, label = topic_name)) + geom_col() +geom_text()

