## ui.R ##

library(shiny)
library(shinydashboard)
library(shinyTime)
library(RMySQL)
library(dbConnect)
library(DBI)
library(gWidgets)
library(shinyjs)
library(shinyalert)
library(plotly)
library(ggplot2)
library(scales)
library(grid)
library(RColorBrewer)
library(shinyBS)

ui <- dashboardPage(
  
    skin = "green",
    dashboardHeader(title = "VMI Green Book"),
    dashboardSidebar(
      uiOutput("userpanel"),
      tags$head(tags$script(HTML("
      Shiny.addCustomMessageHandler('manipulateMenuItem', function(message){
        var aNodeList = document.getElementsByTagName('a');
                                 
        for (var i = 0; i < aNodeList.length; i++) {
          if(aNodeList[i].getAttribute('data-value') == message.tabName) {
            if(message.action == 'hide'){
              aNodeList[i].setAttribute('style', 'display: none;');
            } else {
              aNodeList[i].setAttribute('style', 'display: block;');
            };
          };
        }
      });"))),
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
          fluidRow(id ="tacBox",
            column(width = 1),
            column(width = 6,
            h2("Recent TAC Data"),
            box(
              title = "Your Submissions: Incident Reports", status = "primary", solidHeader = TRUE, width = NULL,
              column(12, tableOutput('dahboardIncident'))
            ),
            box(
              title = "Your Submissions: Daily Reports", status = "primary", solidHeader = TRUE, width = NULL,
              column(12, tableOutput('dahboardDaily'))
            ))),
          fluidRow(
                   column(width = 1),
                   column(width = 6,
            br(), br(), h2("Recent Cadet Data"),
            box(
              title = "Cadet Guard Team Submissions: Daily Reports", status = "primary", solidHeader = TRUE, width = NULL,
              column(12, tableOutput('dahboardCadet'))
            ))
          )
        ),
        ## DATA ANALYSIS ##
        tabItem(tabName = "dataAnalysis",
          h2("Data Analysis"), br(), br(),
          box(title = "Choose trend:", status = "warning", solidHeader = TRUE, width = 4,
            selectInput("trendType", "Trend:", 
                        c("Choose one" = "",
                          "Absence Barracks/Post",
                          "Weapons",
                          "Assault",
                          "Conduct",
                          "Civilian Clothing",
                          "Vandalizing",
                          "Disturbance/Dispute",
                          "Alcohol",
                          "Unauthorized Ratline Activity",
                          "Improper Dress (C)",
                          "Loss/Misuse Institute Property (C)",
                          "Evading OC/Guard (C)",
                          "Neglect of Duty - Guard",
                          "Neglect of Duty - General",
                          "Visiting Unauthorized - Off Post",
                          "Visiting Unauthorized - On Post",
                          "Visiting Unauthorized - In Barracks",
                          "Visitors Unauthorized",
                          "Fire",
                          "EMT/Rescue",
                          "Police Emergency",
                          "Police Arrest",
                          "Police Barracks",
                          "Police Post",
                          "Emergency General",
                          "Physical Plant",
                          "Title IX",
                          "Suicide Attempt",
                          "Suicide Thoughts",
                          "Sick/Injured",
                          "Room/Stoop",
                          "Other"
                        )
            ),
            dateInput("fromTrendDate", "From:", format = "mm-dd-yyyy", value = NULL, width = '400px'),
            dateInput("toTrendDate", "To:", format = "mm-dd-yyyy", value = NULL, width = '400px'),
            actionButton("trendSubmit", "Submit", class="btn-lg")
          ),
          box(title = "Trends!", status = "primary", solidHeader = TRUE,
            plotOutput("trendPlot")
            #tableOutput("trendTable")
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
                  textInput("firstName", "First Name: (REQUIRED)", width = NULL, placeholder = "First Name"),
                  textInput("midName", "Middle Initial:", width = NULL, placeholder = "Middle Initial"),
                  textInput("lastName", "Last Name: (REQUIRED)", width = NULL, placeholder = "Last Name"),
                  numericInput("roomNum", "Room Number:", value = "", width = NULL, min = 100, max = 3440 )
                ), actionButton("insertBtn", "Add cadet"), actionButton("removeBtn", "Remove cadet"), br(), br(), tags$div(id = 'insertCadetBox'),
                br(),
                box(
                  title = "When", status = "primary", solidHeader = TRUE, width = NULL,
                  dateInput("date", "Date of event: (REQUIRED)", format = "mm-dd-yyyy", width = '400px', value = Sys.Date()),
                  timeInput("time", "Time of event:", seconds = FALSE,  value = Sys.time())
                ),
                box(
                  title = "What", status = "primary", solidHeader = TRUE, width = NULL,
                  selectInput("eventTag", "Event Type: (REQUIRED)", 
                    c("Choose one" = "",
                      "Absence Barracks/Post",
                      "Weapons",
                      "Assault",
                      "Conduct",
                      "Civilian Clothing",
                      "Vandalizing",
                      "Disturbance/Dispute",
                      "Alcohol",
                      "Unauthorized Ratline Activity",
                      "Improper Dress (C)",
                      "Loss/Misuse Institute Property (C)",
                      "Evading OC/Guard (C)",
                      "Neglect of Duty - Guard",
                      "Neglect of Duty - General",
                      "Visiting Unauthorized - Off Post",
                      "Visiting Unauthorized - On Post",
                      "Visiting Unauthorized - In Barracks",
                      "Visitors Unauthorized",
                      "Fire",
                      "EMT/Rescue",
                      "Police Emergency",
                      "Police Arrest",
                      "Police Barracks",
                      "Police Post",
                      "Emergency General",
                      "Physical Plant",
                      "Title IX",
                      "Suicide Attempt",
                      "Suicide Thoughts",
                      "Sick/Injured",
                      "Room/Stoop",
                      "Other"
                    )
                  ),
                  textAreaInput("narrative", "Narrative:", width = NULL, height = '170px'),
                  fileInput("file", "Attach Picture:", width = NULL)
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
                  title = "When", status = "primary", solidHeader = TRUE, width = NULL,
                  dateInput("dailyDate", "Date of event: (REQUIRED)", format = "mm-dd-yyyy", width = NULL, value = Sys.Date()),
                  timeInput("dailyTime", "Time of event:", seconds = FALSE,  value = Sys.time())
                ), p(id="insertDailyType"),
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
                  textInput("searchFirstName", "First Name:", width = NULL, placeholder = "First Name"),
                  textInput("searchMidName", "Middle Initial:", width = NULL, placeholder = "Middle Initial"),
                  textInput("searchLastName", "Last Name:", width = NULL, placeholder = "Last Name"),
                  numericInput("searchRoomNum", "Room Number:", value = NULL, width = NULL, max = 3440 )
                ),
                box(
                  title = "When", status = "primary", solidHeader = TRUE, width = NULL,
                  dateInput("fromSearchDate", "From:", format = "mm-dd-yyyy", value = Sys.Date() - 1, width = NULL),
                  dateInput("toSearchDate", "To:", format = "mm-dd-yyyy", value = NULL, width = NULL)
                ),
                box(
                  title = "What", status = "primary", solidHeader = TRUE, width = NULL,
                  selectInput("searchEventTag", "Event Type:", 
                    c("Choose one" = "",
                      "Absence Barracks/Post",
                      "Weapons",
                      "Assault",
                      "Conduct",
                      "Civilian Clothing",
                      "Vandalizing",
                      "Disturbance/Dispute",
                      "Alcohol",
                      "Unauthorized Ratline Activity",
                      "Improper Dress (C)",
                      "Loss/Misuse Institute Property (C)",
                      "Evading OC/Guard (C)",
                      "Neglect of Duty - Guard",
                      "Neglect of Duty - General",
                      "Visiting Unauthorized - Off Post",
                      "Visiting Unauthorized - On Post",
                      "Visiting Unauthorized - In Barracks",
                      "Visitors Unauthorized",
                      "Fire",
                      "EMT/Rescue",
                      "Police Emergency",
                      "Police Arrest",
                      "Police Barracks",
                      "Police Post",
                      "Emergency General",
                      "Physical Plant",
                      "Title IX",
                      "Suicide Attempt",
                      "Suicide Thoughts",
                      "Sick/Injured",
                      "Room/Stoop",
                      "Other"
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
                    bsModal("Search", "Search Results", "searchButton", size = "large", tableOutput('table'))
                  # box(
                  #   title = "Search", status = "primary", solidHeader = TRUE, width = '250px',
                  #   column(12, tableOutput('table'))
                  # )
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
