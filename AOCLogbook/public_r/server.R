## server.R ##

server <- function(input, output, session) {

  observeEvent(input$incidentReset, {
    reset("incidentForm")
  })
  
  observeEvent(input$incidentReset, {
    reset("dailyReportForm")
  })
  
  options(mysql = list(
    "host" = "localhost",
    "port" = 3306,
    "user" = "root",
    "password" = "root"
  ))
  
  databaseName <- "greenbook"
  
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
}
