## server.R ##

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
    table <- "user_data"
    db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host,
                    port = options()$mysql$port, user = options()$mysql$user,
                    password = options()$mysql$password)
    query <- sprintf(paste0(
      "SELECT user_id FROM greenbook.user_data
      WHERE user_username = '", input$username, "' AND user_password = '", input$password, "';"),
      table, 
      paste(names(data), collapse = ", "))
    data <- dbGetQuery(db, query)
    dbDisconnect(db)
    if((is.na(data$user_id[1])) == TRUE){
      shinyalert("Uh oh!", "Please enter a valid username and password", type = "error")
    }
    else{
      shinyjs::show("userForm")
      shinyjs::hide(id = "loginForm")
      loggedIn <- TRUE
      loggedInUsername <- input$username
      loggedInUserID <- data$user_id

      output$userpanel <- renderUI({
        if(loggedIn == TRUE){
          sidebarUserPanel(
            span("Logged in as ", loggedInUsername),
            subtitle = a(icon("sign-out"), "Logout", href="__logout__")
          )
        }
      })
    }
  })
  
## DASHBOARD UPDATES ##
  toListen <- reactive({
    list(input$submitLogin,input$incidentSubmit,input$dailyReportSubmit)
  })
  
  observeEvent(toListen(), {
      databaseName <- "greenbook"
      db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host, 
                      port = options()$mysql$port, user = options()$mysql$user, 
                      password = options()$mysql$password)
      # Querey's for TAC if the current time is BEFORE 1700 #
      if(substring(Sys.time(), 12) < '17:00:00'){
        query1 <- sprintf(paste0(
          "SELECT cadet_lname, incident_type, incident_date, incident_time FROM greenbook.incident_report WHERE incident_date = '", Sys.Date() - 1, "' AND incident_time > '17:00:00'
          OR incident_date = '", Sys.Date(), "'"),
          "incident_report")
        query2 <- sprintf(paste0(
          "SELECT daily_event_type, daily_date, daily_time FROM greenbook.daily_report WHERE daily_date = '", Sys.Date() - 1, "' AND daily_time > ' 17:00:00 '
          OR daily_date = '", Sys.Date(), "'"),
          "daily_report")
      }
      # Querey's for TAC if the current time is AFTER 1700 #
      else{
        query1 <- sprintf(paste0(
          "SELECT cadet_lname, incident_type, incident_date, incident_time FROM greenbook.incident_report WHERE incident_date = '", Sys.Date(), "' AND incident_time  > ' 17:00:00 '"),
          "incident_report")
        query2 <- sprintf(paste0(
          "SELECT daily_event_type, daily_date, daily_time FROM greenbook.daily_report WHERE daily_date = '", Sys.Date(), "' AND daily_time  > ' 17:00:00 '"),
          "daily_report")
      }
      incidentData <- dbGetQuery(db, query1)
      output$dahboardIncident <- renderTable(incidentData)
      dailyData <- dbGetQuery(db, query2)
      output$dahboardDaily <- renderTable(dailyData)
      dbDisconnect(db)
  })
  
  
## INCIDENT REPORT, DIALY REPORT, SEARCH QUERYS ##
  
  # Incident Report Query #
  observeEvent(input$incidentSubmit,{
    # dataCheck <- reactive({
    #   validate(
    #     need(input$firstName != "", "Please enter a First Name"),
    #     need(input$lastName != "", "Please enter a Last Name"),
    #     need(input$time != "", "Please enter a valid time"),
    #     need(input$date != "", "Please enter a valid date"),
    #     need(input$eventTag != "", "Please enter a event type")
    #   )
    #   #get(input$data)
    # }
    
    db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host,
                    port = options()$mysql$port, user = options()$mysql$user,
                    password = options()$mysql$password)
    
    on.exit(dbDisconnect(db))
    sql <- sprintf("INSERT INTO `greenbook`.`incident_report` (`cadet_fname`, `cadet_minitial`, `cadet_lname`, `cadet_room`, `incident_time`, `incident_date`, `incident_type`, `officer_narrative`, `incident_attachment`)
    VALUES('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');", input$firstName, input$midName, input$lastName, input$roomNum, substring(gsub(":00 ", "", input$time), 11), input$date, input$eventTag, input$narrative, input$file)
    rs <- dbSendQuery(db, sql)
    dbClearResult(rs)

    #dbGetQuery(db, query)
    reset("incidentForm")
    # dbDisconnect(db)
    shinyalert("Success!", "You have submitted your incident report.", type = "success")
  })

  # Daily Report Query #
  observeEvent(input$dailyReportSubmit,{
    table <- "daily_report"
    db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host,
                    port = options()$mysql$port, user = options()$mysql$user,
                    password = options()$mysql$password)
    
    query <- sprintf(paste0(
      "INSERT INTO `greenbook`.`daily_report` (`officer_id`, `daily_date`, `daily_time`, `daily_event_type`, `daily_event_narrative`) 
      VALUES('", input$dailyOfficer, "', ", "'", input$dailyDate, "', ", "'", substring(gsub(":00 ", "", input$dailyTime), 11), "', ", "'", input$dailyEventTag, "', ", "'", input$dailyNarrative,"')"),
      table, 
      paste(names(data), collapse = ", "),
      paste(names(data), collapse = "', '"))
    
    dbGetQuery(db, query)
    dbDisconnect(db)
    reset("dailyReportForm")
    shinyalert("Success!", "You have submitted your daily report.", type = "success")
  })
  
  # Searching Query #
  observeEvent(input$searchButton, {
    
    if((input$searchFirstName == "") == TRUE){a <- NA}
    else{a <- paste0("'", input$searchFirstName, "'")}
    
    if((input$searchMidName == "") == TRUE){b <- NA}
    else{b <- paste0("'", input$searchMidName, "'")}
    
    if((input$searchLastName == "") == TRUE){c <- NA}
    else{c <- paste0("'", input$searchLastName, "'")}
    
    if((input$searchRoomNum == "") == TRUE){
      d <- NA
    }
    else{
      d <- paste0("'", input$searchRoomNum, "'")
    }
    
    if((input$searchEventTag == "") == TRUE){e <- NA}
    else{e <- paste0("'", input$searchEventTag, "'")}
    
    
    
    table <- "incident_report"
    db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host, 
                    port = options()$mysql$port, user = options()$mysql$user, 
                    password = options()$mysql$password)
    
    query <- sprintf(paste0(
      "SELECT * FROM greenbook.incident_report
      WHERE (incident_date BETWEEN '", input$fromSearchDate, "' AND '", input$toSearchDate, "')
        AND (", a, " IS NULL OR cadet_fname = ", a, ")
        AND (", b, " IS NULL OR cadet_minitial = ", b, ")
        AND (", c, " IS NULL OR cadet_lname = ", c, ")
        AND (", d, " IS NULL OR cadet_room = ", d, ")
        AND (", e, " IS NULL OR incident_type = ", e, ")"),
        table,
        paste(names(data), collapse = ", "),
        paste(names(data), collapse = "', '"))
    data <- dbGetQuery(db, query)
    dbDisconnect(db)
    output$table <- renderTable(data)
  })
  
  
## CLEAR FORM BUTTONS ##
  observeEvent(input$incidentReset, {
    reset("incidentForm")
  })
  
  observeEvent(input$incidentReset, {
    reset("dailyReportForm")
  })
  
  observeEvent(input$SearchReset, {
    reset("searchForm")
  })
  
}
