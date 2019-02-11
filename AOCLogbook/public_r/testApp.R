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
                #numericInput("time", "Room Number:", value = '109', width = '400px', min = 100, max = 3440 )
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
              
              #("incidentButton", "Submit")
              actionButton("doTheButtonThing", "Submit")
      )
    )
  )
))


server <- function(input, output, session) {
  
  observeEvent(input$doTheButtonThing, {
    session$sendCustomMessage(type = 'testmessage',
    message = 'You clicked the button. Congrats you moron.')
  })
  
   options(mysql = list(
    "host" = "localhost",
    "port" = 3306,
    "user" = "root",
    "password" = "root"
  ))
  
  databaseName <- "greenbook"
  table <- "incident_report"
  observeEvent(input$doTheButtonThing,{
  
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
}

shinyApp(ui, server)


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

#   
#   query <- sprintf(
#     "INSERT INTO %s (%s) VALUES ('%s')",
#     table, 
#     paste(names(data), collapse = ", "),
#     paste(data, collapse = "', '"))
#   

#   query <- sprintf(
#     "INSERT INTO `greenbook`.`incident_report` (`cadet_fname`, `cadet_minitial`, `cadet_lname`, `cadet_room`, `incident_time`, `incident_date`, `incident_type`, `officer_narrative`) 
#     VALUES('input$firstName', 'input$midName', 'input$lastName', 'input$roomNum', input$time, 'input$date', 'input$eventTag', 'input$narrative', 'input$file')",
#     table, 
#     paste(names(data), collapse = ", "),
#     paste(data, collapse = "', '"))   

# query <- sprintf("INSERT INTO `greenbook`.`incident_report` (
#       `cadet_fname`,
#       `cadet_minitial`,
#       `cadet_lname`,
#       `cadet_room`,
#       `incident_time`,
#       `incident_date`,
#       `incident_type`,
#       `officer_narrative`,
#       `incident_attachment`)
#       VALUES (
#       'Ryan',
#       'Logan',
#       'Russell',
#       '109',
#       '0045',
#       '2/10/2019',
#       'alcohol',
#       'Why is he doing this to himself??',
#       ''
#       )" )
