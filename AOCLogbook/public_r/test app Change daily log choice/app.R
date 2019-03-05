library(shiny)

ui <- dashboardPage(
  
  skin = "green",
  dashboardHeader(title = "VMI Green Book"),
  dashboardSidebar(
    uiOutput("userpanel"),
      sidebarMenu(
        menuItem("Daily Report", tabName = "dailyReport", icon = icon("globe"))
    )
    ),
  dashboardBody(
    div(id = "loginForm",
        textInput("username", "Username:"),
        passwordInput("password", "Password:"),
        actionButton("submitLogin", "Submit")), 
    div(id = "userForm",
        tabItems(
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
                               ), br(), p(id="insertDailyType"),
                               actionButton("dailyReportReset", "Clear", class="btn-lg"),
                               useShinyalert(),
                               actionButton("dailyReportSubmit", "Submit", class="btn-lg"),
                               br(), br()
                        )
                      )
                  )
          )
        )
    )
  )
  )

server <- function(input, output, session) {
  
  ## DATABASE SETUP ##
  # FOR AWS #
  # options(mysql = list(
  #   "host" = "vmigreenbook.cd0e9wwmxm8h.us-east-1.rds.amazonaws.com",
  #   "port" = 3306,
  #   "user" = "greenbookadmin",
  #   "password" = "~L7pPw}UZ;8*"
  # ))
  
  # FOR LOCAL #
  options(mysql = list(
    "host" = "localhost",
    "port" = 3306,
    "user" = "root",
    "password" = "root"
  ))
  
  ## LOGIN SETUP ##
  shinyjs::hide("userForm")
  loggedIn <- FALSE
  observeEvent(input$submitLogin,{
    databaseName <- "greenbook"
    table <- "user"
    db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host,
                    port = options()$mysql$port, user = options()$mysql$user,
                    password = options()$mysql$password)
    query <- sprintf(paste0("SELECT * FROM greenbook.user
                            WHERE username = '", input$username, "' AND password = '", input$password, "';"), table, paste(names(data), collapse = ", "))
    data <- dbGetQuery(db, query)
    dbDisconnect(db)
    if((is.na(data$id[1])) == TRUE){
      shinyalert("Uh oh!", "Please enter a valid username and password", type = "error")
    }
    else{
      shinyjs::show("userForm")
      shinyjs::hide(id = "loginForm")
      loggedIn <- TRUE
      loggedInUsername <- input$username
      
      output$userpanel <- renderUI({
        if(loggedIn == TRUE){
          sidebarUserPanel(
            span("Logged in as ", loggedInUsername),
            subtitle = a(icon("sign-out"), "Logout", href="")
          )
        }
      })
      
      if(data$permission == 1){
        session$sendCustomMessage(type = "manipulateMenuItem", message = list(action = "hide", tabName = "searchReports"))
        session$sendCustomMessage(type = "manipulateMenuItem", message = list(action = "hide", tabName = "incidentReport"))
        session$sendCustomMessage(type = "manipulateMenuItem", message = list(action = "hide", tabName = "dataAnalysis"))
        shinyjs::hide("tacBox")
      }else{
        session$sendCustomMessage(type = "manipulateMenuItem", message = list(action = "show", tabName = "searchReports"))
        session$sendCustomMessage(type = "manipulateMenuItem", message = list(action = "show", tabName = "incidentReport"))
        session$sendCustomMessage(type = "manipulateMenuItem", message = list(action = "show", tabName = "dataAnalysis"))
        shinyjs::show("tacBox")
      }
      
      # Daily Report Query #
      ###################################################################################################################
      ###################################################################################################################
      
      # if(data$permission != 1){
      #   insertUI(
      #     selector = "#submitLogin",
      #     where = "testingBox",
      #     ui = selectInput("dailyEventTag", "Event Type: (REQUIRED)", 
      #                      c("Choose one" = "TESTING")
      #     ))
          
        if(data$permission == 1){
            insertUI(
              selector = "#insertDailyType",
              where = "afterEnd",
              ui = box(
                 title = "What", status = "primary", solidHeader = TRUE, width = NULL,
                 selectInput("dailyEventTag", "Event Type: (REQUIRED)",
                   c("Choose one" = "", "Cadet Things")
                 ),
                 textAreaInput(
                   "dailyNarrative", "Narrative:", width = NULL, height = '170px'
                 )
              )
            )
        } else{
          insertUI(
            selector = "#insertDailyType",
            where = "afterEnd",
            ui = box(
              title = "What", status = "primary", solidHeader = TRUE, width = NULL,
              selectInput("dailyEventTag", "Event Type: (REQUIRED)",
                          c("Choose one" = "", "Officer Things")
              ),
              textAreaInput(
                "dailyNarrative", "Narrative:", width = NULL, height = '170px'
              )
            )
          )
          }

      
      ###################################################################################################################
      ###################################################################################################################
      
      observeEvent(input$dailyReportSubmit,{
        if((input$dailyEventTag != "" && is.na(input$dailyDate) == FALSE) == TRUE){
          table <- "daily_report"
          db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host,
                          port = options()$mysql$port, user = options()$mysql$user,
                          password = options()$mysql$password)
          query <- sprintf(
            "INSERT INTO `greenbook`.`daily_report` (`daily_date`, `daily_time`, `daily_event_type`, `daily_event_narrative`, `userName`) 
            VALUES('%s', '%s', '%s', '%s', '%s');", input$dailyDate, substring(gsub(":00 ", "", input$dailyTime), 11), input$dailyEventTag, input$dailyNarrative, loggedInUsername)
          dbGetQuery(db, query)
          dbDisconnect(db)
          reset("dailyReportForm")
          shinyalert("Success!", "You have submitted your daily report.", type = "success")
        } else{
          shinyalert("Hold on!", "You have not filled all required fields: Date and Event Type", type = "warning")
        }
      })
      
      observeEvent(input$incidentReset, {
        reset("dailyReportForm")
      })
      }
  })
  }
  
  
  shinyApp(ui = ui, server = server)



# ui <- fluidPage(
#   checkboxGroupInput("inCheckboxGroup", "Input checkbox",
#     c("Item A", "Item B", "Item C")),
#   selectInput("inSelect", "Select input",
#     c("Item A", "Item B", "Item C"))
# )
# 
# 
# 
# server <- function(input, output, session) {
#   observe({
#     x <- input$inCheckboxGroup
#     
#     if(is.null(x))
#       x <- character(0)
#     
#     userType <- 3
#     print(userType)
#     #userType <- 1
#     
#     updateSelectInput(session, "inSelect",
#         label = paste("Select input label", length(x)),
#         choices = x,
#         selected = tail(x, 1))
#   })
# }