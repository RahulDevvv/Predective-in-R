sms_raw <- read.csv(file.choose(), stringsAsFactors = FALSE)
str(sms_raw)
sms_raw
sms_raw$type <- factor(sms_raw$type)
str(sms_raw$type)
table(sms_raw$type)


#text mining

install.packages("tm")
library(tm)
sms_corpus<-iconv(sms_raw$text)
sms_corpus<-Corpus((VectorSource(sms_corpus)))
print(sms_corpus)
inspect(sms_corpus[1:2])
as.character(sms_corpus[[1]])
lapply(sms_corpus[1:4], as.character)


sms_corpus_clean<-tm_map(sms_corpus,
                          content_transformer(tolower))
as.character(sms_corpus[[1]])
as.character(sms_corpus_clean[[1]])
sms_corpus_clean<-tm_map(sms_corpus_clean, removeNumbers)
sms_corpus_clean<-tm_map(sms_corpus_clean,
                         removeWords, stopwords())
sms_corpus_clean<-tm_map(sms_corpus_clean, removePunctuation)
sms_corpus_clean
inspect(sms_corpus_clean[1:5])

#stemming-reducing
install.packages("SnowballC")
library(SnowballC)
wordStem(c("learn","learned","learning","learns"))
sms_corpus_clean<-tm_map(sms_corpus_clean, stemDocument)

sms_corpus_clean<tm_map(sms_corpus_clean, stripWhitespace)
sms_dtm<-DocumentTermMatrix(sms_corpus_clean)
sms_dtm_train<-sms_dtm[1:4169, ]
sms_dtm_test<-sms_dtm[4170:5559, ]
sms_train_labels<-sms_raw[1:4169, ]$type
sms_test_labels<-sms_raw[4170:5559, ]$type


install.packages("wordcloud")
library(wordcloud)
wordcloud(sms_corpus_clean, min.freq = 50,
          random.order = FALSE,colors=brewer.pal(5,"Dark2"))

install.packages("tm")
library(tm)
findFreqTerms(sms_dtm_train, 5)
sms_freq_words<-findFreqTerms(sms_dtm_train, 5)
str(sms_freq_words)
sms_dtm_freq_train<-sms_dtm_train[ , sms_freq_words]
sms_dtm_freq_test<-sms_dtm_test[ , sms_freq_words]

convert_counts<-function(x) {
  x<- ifelse(x>0, "Yes","No")
}
sms_train<-apply(sms_dtm_freq_train, MARGIN = 2,
                 convert_counts)
sms_test<-apply(sms_dtm_freq_test, MARGIN = 2,
                convert_counts)

install.packages("e1071")
library(e1071)
sms_classifier<-naiveBayes(sms_train, sms_train_labels)
sms_test_pred<-predict(sms_classifier, sms_test)

library(gmodels)
CrossTable(sms_test_pred, sms_test_labels,
           prop.chisq = FALSE, prop.t = FALSE,
           dnn = c('predicted','actual'))
