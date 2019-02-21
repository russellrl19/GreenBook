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
    query <- sprintf(paste0("SELECT user_id FROM greenbook.user_data
      WHERE user_username = '", input$username, "' AND user_password = '", input$password, "';"), table, paste(names(data), collapse = ", "))
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
  
## ANALYTICS TAB ##
  observeEvent(input$trendSubmit,{
  db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host,
                  port = options()$mysql$port, user = options()$mysql$user,
                  password = options()$mysql$password)
  trendQuery <- paste0("SELECT * FROM greenbook.incident_report
        WHERE (incident_date BETWEEN '", input$fromTrendDate, "' AND '", input$toTrendDate, "') 
        AND (incident_type = '", input$trendType, "');")
  trendData <- dbGetQuery(db, trendQuery)
  dbDisconnect(db)
  output$trendPlot <- renderPlot({
    # plot(trendData$incident_date, 
    #      trendData$incident_time, 
    #      xlim = (c("2019-01-01", "2019-02-21")), 
    #      ylim = (c(00, 24)),
    #      xlab = "Date",
    #      ylab = "Time"
    # )
    plot(trendData$incident_date, trendData$incident_time,
         ylim=c(as.POSIXct('00:00:00', format="%H:%M:%S"),
                as.POSIXct('24:00:00', format="%H:%M:%S")),
         # xlim=c(as.POSIXct('2019-01-01', format="%Y-%m-%d"),
         #        as.POSIXct('2019-02-22', format="%Y-%m-%d")),
         xlim=c(max(trendData$incident_date),min(trendData$incident_date)),
         # xlim=as.Date(c('2019-02-00', '2019-02-22')),
         xlab="Date of incident",
         ylab="Time of incident"
    )
    #xlim=as.Date(c("2014-06-09", "2014-08-30"))
  })
})
  
  #  output$text1 <- renderText({ 
  #    paste("The chart is showing fiscal stimulus and real economy growthYou have selected ", input$radio)
  #  })
  
  # output$lineChart <- renderPlot({
  #   chartData <- switch(input$radio,
  #                       "World" = list(dat$gr_w,dat$re_w),
  #                       "All countries except China" = list(dat$gr_noChina,dat$re_noChina),
  #                       "Advanced Economies only" = list(dat$gr_advanced,dat$re_advanced),
  #                       "Eurozone" = list(dat$gr_euro,dat$re_euro) 
  #   )  
  #   
  #   chartTitle <- switch(input$radio,
  #                        "World" = "the world",
  #                        "All countries except China" = "all countries except China",
  #                        "Advanced Economies only" = "the advanced economies",
  #                        "Eurozone" = "the euro area" 
  #   )
  #   
  #   yrange <- c(-4,12)
  #   xrange <- range(year)
  #   plot(xrange,yrange,type="n",xlab="",ylab="Growth rate (percent)",cex.lab=1.5,
  #        main=paste("GDP-weighted averages shown for", chartTitle),
  #        sub=c("Data: IMF WEO (10/2015). Chart J. Zilinsky \n Note: Data for 2016 are IMF projections"))
  #   lines(year,chartData[[1]],col="aquamarine4",lwd=3)
  #   lines(year[2:12],na.omit(chartData[[2]]),col="firebrick3",lwd=3)
  #   abline(v=input$vertical,lty=2) 
  #   legend(2012,8,c("Real government spending","Real GDP"), 
  #          col=c('firebrick3','aquamarine4'),pch=15,ncol=1,bty ="n",cex=1.1)
  #   
  #   if (input$hor) {
  #     abline(h=0)  
  #   } 
  # },height = 500, width = 600)
  
## INCIDENT REPORT, DIALY REPORT, SEARCH QUERYS ##
  
  # Incident Report Query #
  observeEvent(input$incidentSubmit,{
    if((is.na(input$roomNum))){roomNumber <- (paste(""))} else{roomNumber <- input$roomNum}
    if((input$midName == "") == FALSE){middleName <- input$midName} else{middleName <- (paste0(""))}
    if(is.null(input$file)){fileUpload <- (paste(""))} else{fileUpload <- paste(input$file)}
    db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host,
                    port = options()$mysql$port, user = options()$mysql$user,
                    password = options()$mysql$password)
    query <- sprintf("INSERT INTO `greenbook`.`incident_report` (`cadet_fname`, `cadet_minitial`, `cadet_lname`, `cadet_room`, `incident_time`, `incident_date`, `incident_type`, `officer_narrative`, `incident_attachment`)
        VALUES('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');", input$firstName, middleName, input$lastName, roomNumber, substring(gsub(":00 ", "", input$time), 11), input$date, input$eventTag, input$narrative, fileUpload)
    dbGetQuery(db, query)
    reset("incidentForm")
    dbDisconnect(db)
    shinyalert("Success!", "You have submitted your incident report.", type = "success")
  })

  # Daily Report Query #
  observeEvent(input$dailyReportSubmit,{
    table <- "daily_report"
    db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host,
                    port = options()$mysql$port, user = options()$mysql$user,
                    password = options()$mysql$password)
    query <- sprintf(
      "INSERT INTO `greenbook`.`daily_report` (`officer_id`, `daily_date`, `daily_time`, `daily_event_type`, `daily_event_narrative`) 
      VALUES('%s', '%s', '%s', '%s', '%s');", input$dailyOfficer, input$dailyDate, substring(gsub(":00 ", "", input$dailyTime), 11), input$dailyEventTag, input$dailyNarrative)
    dbGetQuery(db, query)
    dbDisconnect(db)
    reset("dailyReportForm")
    shinyalert("Success!", "You have submitted your daily report.", type = "success")
  })
  
  # Searching Query #
  observeEvent(input$searchButton, {
    if((input$searchFirstName == "") == FALSE){a <- (paste0(" AND (cadet_fname = '", input$searchFirstName, "')"))} else{a <- (paste0(""))}
    if((input$searchMidName == "") == FALSE){b <- (paste0(" AND (cadet_minitial = '", input$searchMidName, "')"))} else{b <- (paste0(""))}
    if((input$searchLastName == "") == FALSE){c <- (paste0(" AND (cadet_lname = '", input$searchLastName, "')"))} else{c <- (paste0(""))}
    if((is.na(input$searchRoomNum))){d <- (paste0(""))} else{d <- (paste0(" AND (cadet_room = '", input$searchRoomNum, "')"))}
    if((input$searchEventTag == "") == FALSE){e <- (paste0(" AND (incident_type = '", input$searchEventTag, "')"))} else{e <- (paste0(""))}
    table <- "incident_report"
    db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host, 
                    port = options()$mysql$port, user = options()$mysql$user, 
                    password = options()$mysql$password)
    query <- paste0("SELECT * FROM greenbook.incident_report
        WHERE (incident_date BETWEEN '", input$fromSearchDate, "' AND '", input$toSearchDate, "')", a, b, c, d, e)
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
