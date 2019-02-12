rm(list = ls())
library(shiny)

Logged = FALSE;
my_username <- "test"
my_password <- "test"

ui1 <- function(){
  tagList(
    div(id = "login",
        wellPanel(textInput("userName", "Username"),
                  passwordInput("passwd", "Password"),
                  br(),actionButton("Login", "Log in"))),
    tags$style(type="text/css", "#login {font-size:10px;   text-align: left;position:absolute;top: 40%;left: 50%;margin-top: -100px;margin-left: -150px;}")
  )}

ui2 <- function(){tagList(tabPanel("Test"))}

ui = (htmlOutput(
  
  ui3 = dashboardPage(
    dashboardHeader(),
    dashboardSidebar(),
    dashboardBody(),
    title = "Dashboard example"
    ),
  
  ui3 <- dashboardPage(
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
                  title = "Who", solidHeader = TRUE,
                  textInput("firstName", "First Name:", width = '400px', placeholder = "First Name"),
                  textInput("midName", "Middle Initial:", width = '400px', placeholder = "Middle Initial"),
                  textInput("lastName", "Last Name:", width = '400px', placeholder = "Last Name"),
                  textInput("roomNum", "Room Number:", width = '400px', placeholder = "Room Number")
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
        ),
        tabItem(tabName = "dailyReport",
                h2("Daily Report")
        ),
        tabItem(tabName = "searchReports",
                h2("Search Reports"),
                textId = "searchText", buttonId = "searchButton",
                label = "Search..."
        )
      )
    )
  )
  
))
server = (function(input, output,session) {
  
  USER <- reactiveValues(Logged = Logged)
  
  observe({ 
    if (USER$Logged == FALSE) {
      if (!is.null(input$Login)) {
        if (input$Login > 0) {
          Username <- isolate(input$userName)
          Password <- isolate(input$passwd)
          Id.username <- which(my_username == Username)
          Id.password <- which(my_password == Password)
          if (length(Id.username) > 0 & length(Id.password) > 0) {
            if (Id.username == Id.password) {
              USER$Logged <- TRUE
            } 
          }
        } 
      }
    }    
  })
  observe({
    if (USER$Logged == FALSE) {
      
      output$page <- renderUI({
        div(class="outer",do.call(bootstrapPage,c("",ui1())))
      })
    }
    if (USER$Logged == TRUE) 
    {
      output$page <- renderUI({
        div(class="outer",do.call(navbarPage,c(inverse=TRUE,ui2())))
      })
      print(ui)
    }
  })
})

runApp(list(ui = ui, server = server))