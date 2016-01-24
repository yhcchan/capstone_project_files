library(rJava)
library(tm)
library(NLP)
library(openNLP)
library(RWeka)

## We read in the original files here
setwd("~/R Programming Working Directory/Capstone/")

news_text <- readLines("final/en_US/en_US.news.txt")
twit_text <- readLines("final/en_US/en_US.twitter.txt")
blog_text <- readLines("final/en_US/en_US.blogs.txt")

## We then create new files that consist of a random sample of the original files
## Each sample is a tenth of the size of the original files
set.seed(12345)
sampleNews <- sample(news_text, length(news_text)*0.05)
write.table(sampleNews, "final/en_samples/samplenews.txt", row.names = FALSE, col.names = FALSE)

set.seed(12345)
sampleTweet <- sample(twit_text, length(twit_text)*0.05)
write.table(sampleTweet, "final/en_samples/sampletweet.txt", row.names = FALSE, col.names = FALSE)

set.seed(12345)
sampleBlog <- sample(blog_text, length(blog_text)*0.05)
write.table(sampleBlog, "final/en_samples/sampleblog.txt", row.names = FALSE, col.names = FALSE)

## After creating the sample files, we incorporate them into a single corpus
en_corpus <- Corpus(DirSource(directory = "final/en_samples/"))

## Finally, we perform cleanup of the large text files that we initially imported into the R environment
rm(news_text, twit_text, blog_text)

##These remove non-salient elements of the dataset.
en_corpus <- tm_map(en_corpus, content_transformer(tolower))
en_corpus <- tm_map(en_corpus, removeNumbers)
en_corpus <- tm_map(en_corpus, stripWhitespace)

removetweetsandemail <- function(x) gsub("#|@[[:alnum:]]*", "", x)
en_corpus_clean <- tm_map(en_corpus, content_transformer(removetweetsandemail))

en_corpus_clean <- tm_map(en_corpus, removePunctuation)

removelinks <- function(x) gsub("#|@|http|www[[:alnum:]]*", "", x)
en_corpus_clean <- tm_map(en_corpus_clean, content_transformer(removelinks)) 

## I also remove profanity for the purposes of this analysis. 
naughty <- readLines("naughty.txt")
en_corpus_clean <- tm_map(en_corpus_clean, removeWords, naughty)

#We run stripWhitespace one more time to clear the spaces created by removed words
en_corpus_clean <- tm_map(en_corpus_clean, stripWhitespace)

## n-gram creation

tokenise <- function(x, n) {
      xgram <- function(x) NGramTokenizer(x, Weka_control(min = n, max = n))
      tdm <- TermDocumentMatrix(en_corpus_clean, control = list(tokenize = xgram))
      tdm
      }

unigrams <- tokenise(en_corpus_clean, 1)
bigrams <- tokenise(en_corpus_clean, 2)
trigrams <- tokenise(en_corpus_clean, 3)
quadgrams <- tokenise(en_corpus_clean, 4)

#Sort the ngrams and convert to data frames

sortOut <- function(df) {
  colnames(df)[1] <- "freq"
  df$names <- rownames(df)
  df
}

unigram.freq <- sortOut(as.data.frame(sort(rowSums(as.matrix(unigrams)), decreasing = TRUE)))
bigram.freq <- sortOut(as.data.frame(sort(rowSums(as.matrix(bigrams)), decreasing = TRUE)))
trigram.freq <- sortOut(as.data.frame(sort(rowSums(as.matrix(trigrams)), decreasing = TRUE)))
quadgram.freq <- sortOut(as.data.frame(sort(rowSums(as.matrix(quadgrams)), decreasing = TRUE)))

unigram.freq <- unigram.freq[1:100,]
quadgram.freq <- quadgram.freq[quadgram.freq$freq > 1, ]
trigram.freq <- trigram.freq[trigram.freq$freq > 1, ]
bigram.freq <- bigram.freq[bigram.freq$freq > 1, ]