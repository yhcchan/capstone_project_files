library(tm)
load("ngrams.RData")

# Cleans up input and tokenises into words for easier manipulation

parseInput <- function(input) {
        input <- removePunctuation(input)
        input <- removeNumbers(input)
        input <- tolower(input)
        input <- rev(unlist(strsplit(input, split = " ")))
        input
}

# Truncates and rejoins the string based on how many words are needed

truncateInput <- function(input, factor) {
        input <- input[1:factor]
        input <- rev(input)
        input <- paste(input, collapse = " ")
        input
}

# Prediction function

predictWords <- function(input, factor, ngram.freq) {
        input <- truncateInput(input, factor)
        r <- ngram.freq[grepl(paste("^", input, "( |$)", sep = ""), ngram.freq$names), ]
        r
}

predictionFunction <- function(input, numSuggestions) {
        input <- parseInput(input)
        if (length(input) == 0) return("Please enter input...")
        if (length(input) >= 3) {
                results <- predictWords(input, 3, quadgram.freq)
                if(nrow(results) == 0) results <- predictWords(input, 2, trigram.freq)
                if(nrow(results) == 0) results <- predictWords(input, 1, bigram.freq)
                if(nrow(results) == 0) results <- head(unigram.freq)
        } else if (length(input) == 2) {
                results <- predictWords(input, 2, trigram.freq)
                if(nrow(results) == 0) results <- predictWords(input, 1, bigram.freq)
                if(nrow(results) == 0) results <- head(unigram.freq)
        } else if (length(input) == 1) {
                  results <- predictWords(input, 1, bigram.freq)
                 if(nrow(results) == 0) results <- head(unigram.freq)
        }
        
        if(nrow(results) < numSuggestions) {
                 return(extractWords(results))
        } else { 
                 return(extractWords(results[1:numSuggestions, ])) 
        }
}

extractWords <- function(df) {
        num <- nrow(df)
        for (i in 1:nrow(df)) {
                df$names[i] <- rev(unlist(strsplit(df$names[i], split = " ")))[1]
        }
        df
}