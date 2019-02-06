## ui.R ##
library(shiny)
library(shinydashboard)
library(shinyTime)

ui <- fluidPage( dashboardPage(
  #
  skin = "green",
  
  dashboardHeader(title = "VMI Green Book"),
  
  ## Sidebar content
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Data Analysis", tabName = "dataAnalysis", icon = icon("anchor")),
      menuItem("Incident Report", tabName = "incidentReport", icon = icon("book")),
      menuItem("Daily Report", tabName = "dailyReport", icon = icon("globe")),
      menuItem("Search Reports", tabName = "searchReports", icon = icon("search"))
    )
  ), 
  
  ## Body content
  dashboardBody(
    tabItems(
      
      # First tab content
      tabItem(tabName = "dashboard"
          #fluidRow()
      ),
      
      # Second tab content
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
      
      # Third tab content
      tabItem(tabName = "incidentReport",
          h2("Incident Report"),
          #textInput(inputId, label, value = "", width = NULL, placeholder = NULL)
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
              "narrative", "Narrative:", width = '750px', height = '200px'
            ),
            fileInput("file", "Attach Picture(s)", multiple = TRUE)
          ),
          
          submitButton("Submit")
      ),
      
      # Fourth tab content
      tabItem(tabName = "dailyReport",
          h2("Daily Report")
      ),
      
      # Fifth tab content
      tabItem(tabName = "searchReports",
          h2("Search Reports"),
            textId = "searchText", buttonId = "searchButton",
            label = "Search..."
      )
    )
  )
))


server <- function(input, output) {
  
  output$value <- renderText({ input$caption })
  
}

shinyApp(ui, server)