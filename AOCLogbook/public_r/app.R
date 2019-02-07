library(shiny)
library(shinydashboard)
library(shinyTime)

ui <- dashboardPage(
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


server <- function(input, output) {
  
  output$value <- renderText({ input$caption })
  
}

shinyApp(ui, server)