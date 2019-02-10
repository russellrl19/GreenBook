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
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Data Analysis", tabName = "dataAnalysis", icon = icon("anchor")),
      menuItem("Incident Report", tabName = "incidentReport", icon = icon("book")),
      menuItem("Daily Report", tabName = "dailyReport", icon = icon("globe")),
      menuItem("Search Reports", tabName = "searchReports", icon = icon("search"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
              h2("Dashboard")
      ),
      tabItem(tabName = "dataAnalysis",
              h2("Data Analysis"),
              box(
                title = "Histogram", status = "primary", solidHeader = TRUE,
                collapsible = TRUE,
                plotOutput("plot3", height = 250)
              ),
              box(
                title = "Inputs", status = "warning", solidHeader = TRUE,
                "Box content here", br(), "More box content",
                sliderInput("slider", "Slider input:", 1, 100, 50),
                textInput("text", "Text input:")
              )
      ),
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
      tabItem(tabName = "dailyReport",
              h2("Daily Report"),
              box(
                title = "Who", status = "primary", solidHeader = TRUE, width = '250px',
                textInput("dailyOfficer", "Officer Name:", width = '400px', placeholder = "Last Name")
              ),
              box(
                title = "When", status = "primary", solidHeader = TRUE, width = '250px',
                dateInput("dailyDate", "Date of event:", width = '400px', value = Sys.Date()),
                timeInput("dailyTime", "Time of event:", seconds = FALSE,  value = Sys.time())
              ),
              box(
                title = "What", status = "primary", solidHeader = TRUE, width = '250px',
                selectInput("dailyEventTag", "Event Type:", 
                            c("Choose one",
                              "Example 1" = "exm1",
                              "Example 2" = "exm2",
                              "Example 3" = "exm3",
                              "Example 4" = "exm4"
                            )
                ),
                textAreaInput(
                  "dailyNarrative", "Narrative:", width = '450px', height = '170px'
                )
              ),
              
              actionButton("dailyReportSubmit", "Submit")
      ),
      tabItem(tabName = "searchReports",
              h2("Search Reports"),
              textId = "searchText", buttonId = "searchButton",
              label = "Search..."
      )
    )
  )
)
)

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
  
  observeEvent(input$dailyReportSubmit,{
    table <- "daily_report"
    
    db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host,
                    port = options()$mysql$port, user = options()$mysql$user,
                    password = options()$mysql$password)
    
    query <- sprintf(paste(
      "INSERT INTO `greenbook`.`daily_report` (`officer_id`, `daily_date`, `daily_time`, `daily_event_type`, `daily_event_narrative`) 
      VALUES('", input$dailyOfficer, "', ", "'", input$dailyDate, "', ", "'", input$dailyTime, "', ", "'", input$dailyEventTag, "', ", "'", input$dailyNarrative,"')"),

      table, 
      paste(names(data), collapse = ", "))
    
    dbGetQuery(db, query)
    dbDisconnect(db)
  })
  
}

shinyApp(ui, server)