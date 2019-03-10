library(shiny)
library(shinydashboard)

ui <- fluidPage( 
  actionButton('insertBtn', 'Insert'), 
  actionButton('removeBtn', 'Remove'), 
  tags$div(id = 'placeholder') 
)


server <- function(input, output, session) {
  
  ## keep track of elements inserted and not yet removed
  inserted <- c()
  
  observeEvent(input$insertBtn, {
    btn <- input$insertBtn
    id <- paste0('keydet', length(inserted))
    
    
    insertUI(
      selector = "#placeholder",
      #where = "afterEnd",
      ui = tags$div(
        box(
          title = sprintf("Cadet %s", length(inserted)), status = "primary", solidHeader = TRUE, width = NULL,
          textInput(sprintf("firstName%s", length(inserted)), "First Name: (REQUIRED)", width = NULL, placeholder = "First Name"),
          textInput(sprintf("midName%s", length(inserted)), "Middle Initial:", width = NULL, placeholder = "Middle Initial"),
          textInput(sprintf("lastName%s", length(inserted)), "Last Name: (REQUIRED)", width = NULL, placeholder = "Last Name"),
          numericInput(sprintf("roomNum%s", length(inserted)), "Room Number:", value = "", width = NULL, min = 100, max = 3440 )
        ), id = id)
    )
    inserted <<- c(id, inserted)
    print(id)
  })
  
  observeEvent(input$removeBtn, {
    removeUI(
      selector = paste0('#', inserted)
    )
    if(length(inserted) > 1){
      inserted <<- inserted[-1]
    }
  })
}

shinyApp(ui, server)
