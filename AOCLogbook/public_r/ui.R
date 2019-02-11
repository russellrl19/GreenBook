## ui.R ##

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
library(shinyjs)
library(shinyalert)

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
                useShinyjs(),
                div(id = "incidentForm", 
                box(
                  title = "Who", status = "primary", solidHeader = TRUE, width = '250px',
                  textInput("firstName", "First Name:", width = '400px', placeholder = "First Name"),
                  textInput("midName", "Middle Initial:", width = '400px', placeholder = "Middle Initial"),
                  textInput("lastName", "Last Name:", width = '400px', placeholder = "Last Name", value = NULL),
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
                )),
                actionButton("incidentReset", "Clear"),
                useShinyalert(),
                actionButton("incidentSubmit", "Submit")
        ),
        tabItem(tabName = "dailyReport",
                h2("Daily Report"),
                useShinyjs(),
                div(id = "dailyReportForm", 
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
                )),
                actionButton("dailyReportReset", "Clear"),
                useShinyalert(),
                actionButton("dailyReportSubmit", "Submit")
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