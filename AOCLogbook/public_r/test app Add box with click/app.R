## Only run this example in interactive R sessions
library(shiny)

  # Define UI
  ui <- fluidPage(
    actionButton("add", "Add cadet"),
    actionButton("reset", "Remove cadet")
  )
  
  # Server logic
  server <- function(input, output, session) {
    
    
    counter <- reactiveValues(countervalue = 0) # Defining & initializing the reactiveValues object
    
    observeEvent(input$add, {
      counter$countervalue <- counter$countervalue + 1     # if the add button is clicked, increment the value by 1 and update it
    })
    
    
    observeEvent(input$add, {
      insertUI(
        selector = "#add",
        where = "afterEnd",
        # ui = textInput(paste0("txt", input$add), paste0("Cadet: ", counter$countervalue, ""))
        ui = textInput(paste0("txt", input$add), sprintf("Cadet%s", counter$countervalue))
      )
      
      observeEvent(input$reset, {
        removeUI(
          selector = paste0("#", sprintf("Cadet%s", counter$countervalue)),
          print(paste0("#", sprintf("Cadet%s", counter$countervalue)))
        )
      })

    })
    
  }
  
  # Complete app with UI and server components
  shinyApp(ui, server)
