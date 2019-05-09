# Natural Language Processing

<img width = "300" src="https://github.com/victoria-yang/natural-language-processing/blob/master/word_cloud.png">


### Description

The purpose of this project is to see the popularity of word in each class by week. We collected the class notes from students in a data mining course and use natural language processing to find out some thing interesting.

### Prerequisites

**R Packages**
	-You will need these r packages to run this RMarkdown file.
```
install.packages("tm")
install.packages("SnowballC")
install.packages("wordcloud")
install.packages("ggplot2")
install.packages("dplyr")
install.packages("tidyr")
install.packages("topicmodels")
install.packages("stringr")
```

## Datasets Info
The documents we will be using will be student notes that a TC course made last semester.

## Procedure
* Import the documents from folder *calss-notes*
* Create a list of all the files by week
* Data cleaning and wrangling
* Find the most common words by using tm package
* Generate a Word Cloud
* Sentiment Analysis
* LDA Topic Modelling
* Output sentiment level as well as important topic for each week



## Tools
* [R](https://www.r-project.org)
* [RStudio](https://www.rstudio.com)



## Author
[Chieh-An (Victoria) Yang](https://www.linkedin.com/in/victoria-chieh-an-yang/) - Learning Analytics MS student at Teachers College, Columbia University


## Acknowledgments
**Charles Lang** - Visiting Assistant Professor at Teachers College, Columbia University
* This project is an assignment for HUDK 4051: Learning Analytics: Process and Theory, an educational data mining course taught by Dr.Lang in Teachers College. 
