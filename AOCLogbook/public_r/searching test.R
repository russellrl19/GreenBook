# Searching Query #
observeEvent(input$searchButton, {

  table <- "incident_report"
  db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host, 
                  port = options()$mysql$port, user = options()$mysql$user, 
                  password = options()$mysql$password)
  
  on.exit(dbDisconnect(db))
  query <- sprintf(      
    "SELECT * FROM greenbook.incident_report
      WHERE (incident_date BETWEEN '", input$fromSearchDate, "' AND '", input$toSearchDate, "')
      VALUES('%s', '%s', '%s', '%s', '%s');", input$searchFirstName, input$searchMidName, input$searchLastName, input$searchRoomNum, input$searchEventTag)
  data <- dbGetQuery(db, query)
  output$table <- renderTable(data)
  dbClearResult(data)
})


a <- input$searchFirstName
b <- input$searchMidName
c <- input$searchLastName
d <- input$searchRoomNum
e <- input$searchEventTag
if((a == "") == TRUE){
  paste0("AND cadet_fname = ", a, ")")
}


"SELECT * FROM greenbook.incident_report
      WHERE (incident_date BETWEEN '", input$fromSearchDate, "' AND '", input$toSearchDate, "')

        AND (", a, " IS NULL OR cadet_fname = ", a, ")
        AND (", b, " IS NULL OR cadet_minitial = ", b, ")
        AND (", c, " IS NULL OR cadet_lname = ", c, ")
        AND (", d, " IS NULL OR cadet_room = ", d, ")
        AND (", e, " IS NULL OR incident_type = ", e, ")"),