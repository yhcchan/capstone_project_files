library(shiny)
library(wordcloud)

source("predictionFunction.R")

shinyServer(function(input, output) {
        dataInput <- reactive({
                predictionFunction(input$entry, input$numSuggestions)
        })


        output$prediction1 <- renderText({
                res <- dataInput()$names[1]
                paste(input$entry, res, sep = " ")
        })

        output$prediction2 <- renderText({
                p <- paste(input$entry, dataInput()$names[2], sep = "\n")
                if(length(dataInput()$names) > 2) {
                        for(i in 3:length(dataInput()$names)) {
                                r <- paste(input$entry, dataInput()$names[i], sep = " ")
                                p <- paste(p, r , sep = ", ")
                        }
                }
                p
        })
      
        output$inputted <- renderText({
                input$entry
        })

        output$plot <- renderPlot({
                wordcloud_rep <- repeatable(wordcloud)
                words <- dataInput()$names
                wordcloud_rep(words, dataInput()$freq, scale=c(4,1),
                min.freq = 0, max.words=input$numSuggestions,
                colors=brewer.pal(8, "Dark2"))
        })
})