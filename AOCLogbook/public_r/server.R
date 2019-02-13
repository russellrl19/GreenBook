## server.R ##

server <- function(input, output, session) {

  observeEvent(input$incidentReset, {
    reset("incidentForm")
  })
  
  observeEvent(input$incidentReset, {
    reset("dailyReportForm")
  })
  
  observeEvent(input$SearchReset, {
    reset("searchForm")
  })
  
  options(mysql = list(
    "host" = "vmigreenbook.cd0e9wwmxm8h.us-east-1.rds.amazonaws.com",
    "port" = 3306,
    "user" = "greenbookadmin",
    "password" = "~L7pPw}UZ;8*"
  ))
  
  databaseName <- "greenbook"
  
  ##Dashboard SQL HERE##
  
  # Get all recent daily and incident reports
  # save variables to get today's date and time
  
  # if current time is before 1700, get everything from yesterday @1701 until now
  # if current time is after 1700, get everyhting posted from today @1701 until now
  
  # SELECT * 
  #   FROM TABLE_NAME
  # WHERE
  # dob BETWEEN '1/21/2012' AND '2/22/2012'
  
  observeEvent(input$incidentSubmit,{
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
    reset("incidentForm")
    dbDisconnect(db)
    shinyalert("Success!", "You have submitted your daily report.", type = "success")
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
    reset("dailyReportForm")
    shinyalert("Success!", "You have submitted your daily report.", type = "success")
  })
  
  observeEvent(input$searchButton, {
    table <- "incident_report"
    # Connect to the database
    db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host, 
                    port = options()$mysql$port, user = options()$mysql$user, 
                    password = options()$mysql$password)
    # Construct the fetching query
    query <- sprintf(paste(
      #"SELECT * FROM greenbook.incident_report WHERE cadet_fname = ", "'", input$searchFirstName, "'"),
      "SELECT * FROM greenbook.incident_report WHERE cadet_fname = '", input$searchFirstName, "'"),
      table)
    # Submit the fetch query and disconnect
    data <- dbGetQuery(db, query)
    dbDisconnect(db)
    output$table <- renderTable(data)
  })
  
}
