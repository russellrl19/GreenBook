## ui.R ##

library(shiny)
library(shinydashboard)
library(shinyTime)
library(RMySQL)
library(dbConnect)
library(DBI)
library(gWidgets)
library(dplyr)   # Get to work in putty
library(dbplyr)  # Get to work in putty
library(pool)    # Get to work in putty
library(shinyjs)
library(shinyalert)
library(plotly)

ui <- dashboardPage(
    skin = "green",
    dashboardHeader(title = "VMI Green Book"),
    dashboardSidebar(
      uiOutput("userpanel"),
      sidebarMenu(
        menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
        menuItem("Data Analysis", tabName = "dataAnalysis", icon = icon("anchor")),
        menuItem("Incident Report", tabName = "incidentReport", icon = icon("book")),
        menuItem("Daily Report", tabName = "dailyReport", icon = icon("globe")),
        menuItem("Search Reports", tabName = "searchReports", icon = icon("search"))
      )
    ),
    dashboardBody(
      div(id = "loginForm",
      textInput("username", "Username:"),
      passwordInput("password", "Password:"),
      actionButton("submitLogin", "Submit")), 
      div(id = "userForm",
      tabItems(
        ## DASHBOARD ##
        tabItem(tabName = "dashboard",
          h2("Dashboard"),
          h2("Recent TAC Data"),
          fluidRow(
            box(
              title = "Your Submissions: Incident Reports", status = "primary", solidHeader = TRUE, width = 6,
              column(12, tableOutput('dahboardIncident'))
            ),
            box(
              title = "Your Submissions: Daily Reports", status = "primary", solidHeader = TRUE, width = 6,
              column(12, tableOutput('dahboardDaily'))
            )
          ),
          br(), h2("Recent Cadet Data"),
          fluidRow(
            box(
              title = "Cadet Guard Team Submissions: Daily Reports", status = "primary", solidHeader = TRUE, width = 6,
              column(12, tableOutput('dahboardCadet'))
            )
          )
        ),
        ## DATA ANALYSIS ##
        tabItem(tabName = "dataAnalysis",
          h2("Data Analysis"), br(), br(),
          box(title = "Choose trend:", status = "warning", solidHeader = TRUE, width = 3,
            selectInput("trendType", "Trend:", 
                        c("Choose one" = "",
                          "Alcohol" = "alc",
                          "Medical" = "emt",
                          "Emergency" = "emg",
                          "Other" = "other"
                        )
            ),
            dateInput("fromTrendDate", "From:", format = "mm-dd-yyyy", value = NULL, width = '400px'),
            dateInput("toTrendDate", "To:", format = "mm-dd-yyyy", value = NULL, width = '400px')
          ),
          box(title = "Trends!", status = "primary", solidHeader = TRUE, width = NULL,
            plotOutput("trendPlot")
          )
        ),
        ## INCIDENT REPORT ##
        tabItem(tabName = "incidentReport",
          h2("Incident Report"),
          useShinyjs(),
          div(id = "incidentForm",
            fluidRow(
              column(width = 1),
              column(width = 6,
                box(
                  title = "Who", status = "primary", solidHeader = TRUE, width = NULL,
                  textInput("firstName", "First Name:", width = NULL, placeholder = "First Name"),
                  textInput("midName", "Middle Initial:", width = NULL, placeholder = "Middle Initial"),
                  textInput("lastName", "Last Name:", width = NULL, placeholder = "Last Name"),
                  numericInput("roomNum", "Room Number:", value = "", width = NULL, min = 100, max = 3440 )
                ),
                box(
                  title = "When", status = "primary", solidHeader = TRUE, width = NULL,
                  dateInput("date", "Date of event:", format = "mm-dd-yyyy", width = '400px', value = Sys.Date()),
                  timeInput("time", "Time of event:", seconds = FALSE,  value = Sys.time())
                ),
                box(
                  title = "What", status = "primary", solidHeader = TRUE, width = NULL,
                  selectInput("eventTag", "Event Type:", 
                    c("Choose one" = "",
                      "Alcohol offense" = "alc",
                      "Medical" = "emt",
                      "Emergency" = "emg",
                      "Other" = "other"
                    )
                  ),
                  textAreaInput("narrative", "Narrative:", width = NULL, height = '170px'),
                  fileInput("file", "Attach Picture", width = NULL)
                ),
                actionButton("incidentReset", "Clear", class="btn-lg"),
                useShinyalert(),
                actionButton("incidentSubmit", "Submit", class="btn-lg"),
                br(), br()
              )
            )
          )
        ),
        ## DAILY REPORT ##
        tabItem(tabName = "dailyReport",
          h2("Daily Report"), useShinyjs(),
          div(id = "dailyReportForm", 
            fluidRow(
              column(width = 1),
              column(width = 6,
                box(
                  title = "Who", status = "primary", solidHeader = TRUE, width = NULL,
                  textInput("dailyOfficer", "Officer Name:", width = NULL, placeholder = "Last Name")
                ),
                box(
                  title = "When", status = "primary", solidHeader = TRUE, width = NULL,
                  dateInput("dailyDate", "Date of event:", format = "mm-dd-yyyy", width = NULL, value = Sys.Date()),
                  timeInput("dailyTime", "Time of event:", seconds = FALSE,  value = Sys.time())
                ),
                box(
                  title = "What", status = "primary", solidHeader = TRUE, width = NULL,
                  selectInput("dailyEventTag", "Event Type:", 
                    c("Choose one",
                      "Example 1" = "exm1",
                      "Example 2" = "exm2",
                      "Example 3" = "exm3",
                      "Example 4" = "exm4"
                    )
                  ),
                  textAreaInput(
                  "dailyNarrative", "Narrative:", width = NULL, height = '170px'
                  )
                ),
                actionButton("dailyReportReset", "Clear", class="btn-lg"),
                useShinyalert(),
                actionButton("dailyReportSubmit", "Submit", class="btn-lg"),
                br(), br()
              )
            )
          )
        ),
        ## SEARCH REPORTS ##
        tabItem(tabName = "searchReports",
          h2("Search Reports"), useShinyjs(),
          div(id = "searchForm",
            fluidRow(
              column(width = 1),
              column(width = 6,
                box(
                  title = "Who", status = "primary", solidHeader = TRUE, width = '250px',
                  textInput("searchFirstName", "First Name:", width = '400px', placeholder = "First Name"),
                  textInput("searchMidName", "Middle Initial:", width = '400px', placeholder = "Middle Initial"),
                  textInput("searchLastName", "Last Name:", width = '400px', placeholder = "Last Name"),
                  numericInput("searchRoomNum", "Room Number:", value = NULL, width = '400px', max = 3440 )
                ),
                box(
                  title = "When", status = "primary", solidHeader = TRUE, width = '250px',
                  dateInput("fromSearchDate", "From:", format = "mm-dd-yyyy", value = NULL, width = '400px'),
                  dateInput("toSearchDate", "To:", format = "mm-dd-yyyy", value = NULL, width = '400px')
                ),
                box(
                  title = "What", status = "primary", solidHeader = TRUE, width = '250px',
                  selectInput("searchEventTag", "Event Type:", 
                    c("Choose one" = "",
                      "Alcohol offense" = "alc",
                      "Medical" = "emt",
                      "Emergency" = "emg",
                      "Other" = "other"
                    )
                  )
                ),
                actionButton("SearchReset", "Clear", class="btn-lg"),
                actionButton("searchButton", "Submit", class="btn-lg"),
                br(), br()
              )
            ),
            fluidRow(
              column(width = 1),
              column(width = 12,
                div(id = "searchResults",
                  box(
                    title = "Search", status = "primary", solidHeader = TRUE, width = '250px',
                    column(12, tableOutput('table'))
                  )
                ),
                br(), br()
              )
            )
          )
        )
      )
      )
    )
  )
