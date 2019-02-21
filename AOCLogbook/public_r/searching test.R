# Searching Query #
observeEvent(input$searchButton, {

  if((input$searchFirstName == "") == FALSE){a <- paste0("AND (cadet_fname = '", input$searchFirstName, "')")}
  else{a <- paste0("")}
  
  if((input$searchMidName == "") == FALSE){b <- paste0("AND (cadet_minitial = '", input$searchMidName, "')")}
  else{b <- paste0("")}
  
  if((input$searchLastName == "") == FALSE){c <- paste0("AND (cadet_lname = '", input$searchLastName, "')")}
  else{c <- paste0("")}
  
  if((input$searchRoomNum == "") == FALSE){d <- paste0("AND (cadet_room = '", input$searchRoomNum, "')")}
  else{d <- paste0("")}
  
  if((input$searchEventTag == "") == FALSE){e <- paste0("AND (incident_type = '", input$searchEventTag, "')")}
  else{e <- paste0("")}  
  
  table <- "incident_report"
  db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host, 
                  port = options()$mysql$port, user = options()$mysql$user, 
                  password = options()$mysql$password)
  
  on.exit(dbDisconnect(db))
  query <- sprintf(
    "SELECT * FROM greenbook.incident_report
    WHERE (incident_date BETWEEN '", input$fromSearchDate, "' AND '", input$toSearchDate, "')", a, b, c, d, e)
  data <- dbGetQuery(db, query)
  output$table <- renderTable(data)
  dbClearResult(data)
})





if((input$searchFirstName == "") == FALSE){a <- paste0("AND (cadet_fname = '", input$searchFirstName, "')")}
else{a <- paste0("")}

if((input$searchMidName == "") == FALSE){b <- paste0("AND (cadet_minitial = '", input$searchMidName, "')")}
else{b <- paste0("")}

if((input$searchLastName == "") == FALSE){c <- paste0("AND (cadet_lname = '", input$searchLastName, "')")}
else{c <- paste0("")}

if((input$searchRoomNum == "") == FALSE){d <- paste0("AND (cadet_room = '", input$searchRoomNum, "')")}
else{d <- paste0("")}

if((input$searchEventTag == "") == FALSE){e <- paste0("AND (incident_type = '", input$searchEventTag, "')")}
else{e <- paste0("")}


query <- sprintf(
  "SELECT * FROM greenbook.incident_report
    WHERE (incident_date BETWEEN '", input$fromSearchDate, "' AND '", input$toSearchDate, "')", a, b, c, d, e)










