ui <- fluidPage(
  
    dashboardBody(
      tabItems(
        tabItem(tabName = "Report",
                h2("Report"),
                box(
                  title = "Who", solidHeader = TRUE,
                  textInput("firstName", "First Name:", width = '400px', placeholder = "First Name"),
                  textInput("midName", "Middle Initial:", width = '400px', placeholder = "Middle Initial"),
                  textInput("lastName", "Last Name:", width = '400px', placeholder = "Last Name"),
                  numericInput("roomNum", "Room Number:", value = '109', width = '400px', min = 100, max = 3440 )
                ),
                box(
                  title = "When", solidHeader = TRUE,
                  dateInput("date", "Date of event:", width = '400px', value = Sys.Date()),
                  timeInput("time", "Time of event:", seconds = FALSE,  value = Sys.time())
                ),
                box(
                  title = "What", solidHeader = TRUE,
                  selectInput("eventTag", "Event Type:", 
                              c("Choose one",
                                "1" = "1",
                                "2" = "2",
                                "3" = "3",
                                "4" = "4"
                              )
                  ),
                  textAreaInput(
                    "narrative", "Narrative:", width = '400px'
                  ),
                  fileInput("file", "Attach Picture(s)", multiple = TRUE)
                ),
                
                actionButton("doTheButtonThing", "Submit")
        )
      )
    )
  )


server <- function(input, output, session) {
  
  options(mysql = list(
    "host" = "this",
    "port" = "is",
    "user" = "not",
    "password" = "real"
  ))
  
  databaseName <- "mydatabase"
  table <- "report"
  observeEvent(input$doTheButtonThing,{
    
    #saveData <- function(data) {
    # Connect to the database
    db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host,
                    port = options()$mysql$port, user = options()$mysql$user,
                    password = options()$mysql$password)
    # Construct the update query by looping over the data fields
    query <- sprintf(
      "INSERT INTO `greenbook`.`incident_report` (`fname`, `minitial`, `lname`, `room`, `time`, `date`, `type`, `narrative`, `file`) 
      VALUES('input$firstName', 'input$midName', 'input$lastName', 'input$roomNum', input$time, 'input$date', 'input$eventTag', 'input$narrative', 'input$file')",
      table, 
      paste(names(data), collapse = ", "),
      paste(data, collapse = "', '"))   
    
    # Submit the update query and disconnect
    dbGetQuery(db, query)
    dbDisconnect(db)
  })
  
}

shinyApp(ui, server)