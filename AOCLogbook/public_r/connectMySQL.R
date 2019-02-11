library(shiny)
library(shinydashboard)
library(shinyTime)
library(RMySQL)
library(dbConnect)
library(DBI)
library(gWidgets)
library(dplyr)
library(dbplyr)
library(pool)

ui <- fluidPage(
  tags$head(tags$script(src = "message-handler.js")), 
  dashboardPage(
    skin = "green",
    dashboardHeader(title = "VMI Green Book"),
    dashboardSidebar(
      sidebarMenu(
        menuItem("Incident Report", tabName = "incidentReport", icon = icon("book")),
        menuItem("Search Reports", tabName = "searchReports", icon = icon("search"))
      )
    ),
    dashboardBody(
      tabItems(
        tabItem(tabName = "incidentReport",
                h2("Incident Report"),
                box(
                  title = "Who", status = "primary", solidHeader = TRUE, width = '250px',
                  textInput("firstName", "First Name:", width = '400px', placeholder = "First Name"),
                  textInput("midName", "Middle Initial:", width = '400px', placeholder = "Middle Initial"),
                  textInput("lastName", "Last Name:", width = '400px', placeholder = "Last Name"),
                  numericInput("roomNum", "Room Number:", value = '109', width = '400px', min = 100, max = 3440 )
                ),
                box(
                  title = "When", status = "primary", solidHeader = TRUE, width = '250px',
                  dateInput("date", "Date of event:", width = '400px', value = Sys.Date()),
                  timeInput("time", "Time of event:", seconds = FALSE,  value = Sys.time())
                ),
                box(
                  title = "What", status = "primary", solidHeader = TRUE, width = '250px',
                  selectInput("eventTag", "Event Type:", 
                              c("Choose one",
                                "Alcohol offense" = "alc",
                                "Medical" = "emt",
                                "Emergency" = "emg",
                                "Other" = "other"
                              )
                  ),
                  textAreaInput(
                    "narrative", "Narrative:", width = '450px', height = '170px'
                  ),
                  fileInput("file", "Attach Picture(s)", multiple = TRUE)
                ),
                
                actionButton("doTheButtonThing", "Submit")
        ),
        tabItem(tabName = "searchReports",
                h2("Search Reports"),
                box(
                  title = "Who", status = "primary", solidHeader = TRUE, width = '250px',
                  textInput("searchFirstName", "First Name:", width = '400px', placeholder = "First Name"),
                  textInput("searchMidName", "Middle Initial:", width = '400px', placeholder = "Middle Initial"),
                  textInput("searchLastName", "Last Name:", width = '400px', placeholder = "Last Name"),
                  numericInput("searchRoomNum", "Room Number:", value = '100', width = '400px', min = 100, max = 3440 )
                ),
                box(
                  title = "When", status = "primary", solidHeader = TRUE, width = '250px',
                  dateInput("searchDate", "Date of event:", width = '400px')
                ),
                box(
                  title = "What", status = "primary", solidHeader = TRUE, width = '250px',
                  selectInput("searchEventTag", "Event Type:", 
                              c("Choose one",
                                "Alcohol offense" = "alc",
                                "Medical" = "emt",
                                "Emergency" = "emg",
                                "Other" = "other"
                              )
                  ),
                  textAreaInput(
                    "searchNarrative", "Narrative:", width = '450px', height = '170px'
                  )
                ),
                
                actionButton("searchButton", "Submit"),
                
              box(
                title = "Search", status = "primary", solidHeader = TRUE, width = '250px',
                tableOutput('tbl')
              )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  
  observeEvent(input$doTheButtonThing, {
    session$sendCustomMessage(type = 'testmessage', message = 'You clicked the button. Congrats you moron.')
  })
  
  observeEvent(input$searchButton, {
    session$sendCustomMessage(type = 'testmessage', message = 'You clicked the button. Congrats you moron.')
  })
  
  options(mysql = list(
    "host" = "localhost",
    "port" = 3306,
    "user" = "root",
    "password" = "root"
  ))
  
  databaseName <- "greenbook"
  
  
  
  observeEvent(input$doTheButtonThing,{
    table <- "incident_report"
    # Connect to the database
    db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host,
                    port = options()$mysql$port, user = options()$mysql$user,
                    password = options()$mysql$password)
    # Construct the update query by looping over the data fields
    query <- sprintf(paste(
      "INSERT INTO `greenbook`.`incident_report` (`cadet_fname`, `cadet_minitial`, `cadet_lname`, `cadet_room`, `incident_time`, `incident_date`, `incident_type`, `officer_narrative`, `incident_attachment`) 
      VALUES('", input$firstName, "', ", "'", input$midName, "', ", "'", input$lastName, "', ", "'", input$roomNum, "', ", "'", input$time, "', ", "'", input$date, "', ", "'", input$eventTag, "', ", "'", input$narrative, "', ", "'", input$file, "')"),
      table, 
      paste(names(data), collapse = ", "))
    # Submit the update query and disconnect
    dbGetQuery(db, query)
    dbDisconnect(db)
  })
  
  observeEvent(input$searchButton, {
    table <- "incident_report"
    # Connect to the database
    db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host, 
                    port = options()$mysql$port, user = options()$mysql$user, 
                    password = options()$mysql$password)
    # Construct the fetching query
    query <- sprintf("SELECT * FROM greenbook.incident_report", table)
    # Submit the fetch query and disconnect
    data <- dbGetQuery(db, query)
    dbDisconnect(db)
    data
    output$tbl <- renderDataTable(data)
  })
  
  
  
}

shinyApp(ui, server)