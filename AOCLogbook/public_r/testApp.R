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

ui <- dashboardPage(
  skin = "green",
  dashboardHeader(title = "VMI Green Book"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Incident Report", tabName = "incidentReport", icon = icon("book"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "incidentReport",
              h2("Incident Report"),
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
                              "Alcohol offense" = "alc",
                              "Medical" = "emt",
                              "Emergency" = "emg",
                              "Other" = "other"
                            )
                ),
                textAreaInput(
                  "narrative", "Narrative:", width = '400px'
                ),
                fileInput("file", "Attach Picture(s)", multiple = TRUE)
              ),
              
              submitButton("Submit")
      )
    )
  )
)


server <- function(input, output) {
  
  # saveData <- function(data) {
  #   # Connect to the database
  #   db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host, 
  #                   port = options()$mysql$port, user = options()$mysql$user, 
  #                   password = options()$mysql$password)
  #   # Construct the update query by looping over the data fields
  #   query <- sprintf(
  #     "INSERT INTO %s (%s) VALUES ('%s')",
  #     table, 
  #     paste(names(data), collapse = ", "),
  #     paste(data, collapse = "', '")
  #   )
  #   # Submit the update query and disconnect
  #   dbGetQuery(db, query)
  #   dbDisconnect(db)
  # }
  
  # VALUES ('3', 'ryan', 'russell', '109', '0142', '2/8/2019', 'bad boi');

  # query <- sprintf("INSERT INTO `greenbook`.`incident_report` (`incident_id`, `cadet_fname`, `cadet_lname`, `cadet_room`, `incident_time`, `incident_date`, `officer_narrative`) VALUES ('4', 'ryan', 'russell', '109', '0142', '2/8/2019', 'bad boi')")
 
   options(mysql = list(
    "host" = "localhost",
    "port" = 3306,
    "user" = "root",
    "password" = "root"
  ))
  
  databaseName <- "greenbook"
  table <- "incident_report"
  
  saveData <- function(data) {
    # Connect to the database
    db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host,
                    port = options()$mysql$port, user = options()$mysql$user,
                    password = options()$mysql$password)
    # Construct the update query by looping over the data fields
    query <- sprintf("INSERT INTO `greenbook`.`incident_report` "("
                       `incident_id`,
                       `cadet_fname`,
                       `cadet_lname`,
                       `cadet_room`,
                       `incident_time`,
                       `incident_date`,
                       `officer_narrative`,
                       `officer_id`", ), "
                       VALUES  (", 
                          '5',
                         "'", input$firstName, "', ",
                         "'", input$lastName, "', ", 
                         "'", input$roomNum, "', ", 
                         "'", input$time, "', ", 
                         "'", input$date, "', ", 
                         "'", input$narrative, "', ", 
                         "'", input$eventTag, "', ", 
                         "'", input$file, "'", 
                           ";)", )
    # Submit the update query and disconnect
    dbGetQuery(db, query)
    dbDisconnect(db)
  }
  
}

shinyApp(ui, server)
