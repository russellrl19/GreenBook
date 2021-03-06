## server.R ##

server <- function(input, output, session) {

## DATABASE SETUP ##

  # FOR AWS #
  # options(
  #   mysql = list(
  #     "host" = "greenbook.cd0e9wwmxm8h.us-east-1.rds.amazonaws.com",
  #     "port" = 3306,
  #     "user" = "greenbookadmin",
  #     "password" = "~L7pPw}UZ;8*"
  #   )
  # )

  # FOR LOCAL #
  options(
    mysql = list(
      "host" = "localhost",
      "port" = 3306,
      "user" = "root",
      "password" = "root"
    )
  )

  ## REGISTER A USER ##
  observeEvent(input$userSubmit,{
    table <- "user"
    db <- dbConnect(
      MySQL(), dbname = databaseName, host = options()$mysql$host,
      port = options()$mysql$port, user = options()$mysql$user,
      password = options()$mysql$password
    )
    query <- paste0(
      "SELECT * FROM greenbook.user"
    )
    data <- as.data.frame(dbGetQuery(db, query))
    dbDisconnect(db)
    
    if((input$userUserName != "" && is.na(input$userPermissionLevel) == FALSE && input$userPassword1 != "" && input$userPassword1 == input$userPassword2) == TRUE){
      
      hashedPassword <- hash(charToRaw(input$userPassword1), size = 32)
      str <- bin2hex(hashedPassword)
      
      table <- "user"
      db <- dbConnect(
        MySQL(), dbname = databaseName, host = options()$mysql$host,
        port = options()$mysql$port, user = options()$mysql$user,
        password = options()$mysql$password
      )
      query <- sprintf(
        "INSERT INTO `greenbook`.`user` (`username`, `password`, `user_firstName`, `user_lastName`, `permission`)
            VALUES('%s', '%s', '%s', '%s', '%s');", input$userUserName, str, input$userFirstName, input$userLastName, input$userPermissionLevel
      )
      dbGetQuery(db, query)
      dbDisconnect(db)
      reset("registerForm")
      shinyalert("Success!", "You have submitted your daily report.", type = "success")
    }else{
      shinyalert("Hold on!", "You have not filled all required fields: username, and password confirmation", type = "warning")
    }
  })
  
  observeEvent(input$userReset, {
    reset("registerForm")
  })
  
## LOGIN SETUP ##
  loggedIn <- FALSE
  observeEvent(input$submitLogin,{
    
    hashedPassword <- hash(charToRaw(input$password), size = 32)
    str <- bin2hex(hashedPassword)
    
    databaseName <- "greenbook"
    table <- "user"
    db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host,
      port = options()$mysql$port, user = options()$mysql$user,
      password = options()$mysql$password
    )
    query <- sprintf(
      paste0(
        "SELECT * FROM greenbook.user
        WHERE username = '", input$username, "' AND password = '", str, "';"
      ),
      table,
      paste(names(data), collapse = ", ")
    )
    data <- dbGetQuery(db, query)
    dbDisconnect(db)
    if((is.na(data$id[1])) == TRUE){
      shinyalert("Uh oh!", "Please enter a valid username and password", type = "error")
    }
    else{
      show("userForm")
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

      ## DASHBOARD UPDATES ##
      toListen <- reactive({
        c(input$submitLogin,input$incidentSubmit,input$dailyReportSubmit)
      })

      observeEvent(
        toListen(), delay(600, {
          db <- dbConnect(
            MySQL(), dbname = databaseName, host = options()$mysql$host,
            port = options()$mysql$port, user = options()$mysql$user,
            password = options()$mysql$password
          )

          # Querey's for TAC if the current time is BEFORE 1700 #
          if(data$permission == 1){
            cadet <- "="
          } else{
            cadet <- "!="
          }

          if(substring(Sys.time(), 12) < '17:00:00'){
            query1 <- sprintf(
              paste0(
                "SELECT cadet_lname, incident_type, incident_date, incident_time, image_path FROM greenbook.incident_report WHERE officer = '", loggedInUsername, "' AND incident_date = '", Sys.Date() - 1, "' AND incident_time > '17:00:00'
                OR incident_date = '", Sys.Date(), "'"
              ),
              "incident_report"
            )
            query2 <- sprintf(
              paste0(
                "SELECT daily_event_type, daily_date, daily_time, daily_event_narrative, userName FROM greenbook.daily_report WHERE userName = '", loggedInUsername, "' AND daily_date = '", Sys.Date() - 1, "' AND daily_time > ' 17:00:00 '
                OR userName = '", loggedInUsername, "' AND daily_date = '", Sys.Date(), "'"
              ),
              "daily_report"
            )
            if(data$permission > 1){
              query3 <- sprintf(
                paste0(
                  "SELECT daily_event_type, daily_date, daily_time, daily_event_narrative, userName FROM greenbook.daily_report WHERE userName != '", loggedInUsername, "' AND daily_date = '", Sys.Date() - 1, "' AND daily_time > ' 17:00:00 '
                  OR userName ",cadet," '", loggedInUsername, "' AND daily_date = '", Sys.Date(), "'"
                ),
                "daily_report"
              )
            }else{
              query3 <- sprintf(
                paste0(
                  "SELECT daily_event_type, daily_date, daily_time, daily_event_narrative, userName FROM greenbook.daily_report WHERE userName = '", loggedInUsername, "' AND daily_date = '", Sys.Date() - 1, "' AND daily_time > ' 17:00:00 '
                  OR userName ",cadet," '", loggedInUsername, "' AND daily_date = '", Sys.Date(), "'"
                ),
                "daily_report"
              )
            }
          }
          # Querey's for TAC if the current time is AFTER 1700 #
          else{
            query1 <- sprintf(
              paste0(
                "SELECT cadet_lname, incident_type, incident_date, incident_time, image_path FROM greenbook.incident_report WHERE officer = '", loggedInUsername, "' AND incident_date = '", Sys.Date(), "' AND incident_time  > ' 17:00:00 '"
              ),
              "incident_report"
            )
            query2 <- sprintf(
              paste0(
                "SELECT daily_event_type, daily_date, daily_time, daily_event_narrative, userName FROM greenbook.daily_report WHERE userName = '", loggedInUsername, "' AND daily_date = '", Sys.Date(), "' AND daily_time  > ' 17:00:00 '"
              ),
              "daily_report"
            )
            if(data$permission > 1){
              query3 <- sprintf(
                paste0(
                  "SELECT daily_event_type, daily_date, daily_time, daily_event_narrative, userName FROM greenbook.daily_report WHERE userName ",cadet, " '", loggedInUsername, "' AND daily_date = '", Sys.Date(), "' AND daily_time  > ' 17:00:00 '"
                ),
                "daily_report"
              )
            }else{
              query3 <- sprintf(
                paste0(
                  "SELECT daily_event_type, daily_date, daily_time, daily_event_narrative, userName FROM greenbook.daily_report WHERE userName ", cadet, " '", loggedInUsername, "' AND daily_date = '", Sys.Date(), "' AND daily_time  > ' 17:00:00 '"
                ),
                "daily_report"
              )
            }
          }

          incidentData <- as.data.frame(dbGetQuery(db, query1))
          names(incidentData) <- c("Cadet Last Name", "Incident Type", "Date", "Time", "Image")
          if(nrow(incidentData) == 0){} else if(is.null(incidentData$Image) == FALSE){
            incidentData$Image <- paste0("<a href='",incidentData$Image,"' target='_blank'>",substring(incidentData$Image,51),"</a>")
          }else{incidentData$Image <- ""}
          output$dahboardIncident <- renderDataTable({incidentData}, escape = FALSE)

          incidentReportData <- as.data.frame(dbGetQuery(db, query1))
          names(incidentReportData) <- c("Cadet Last Name", "Incident Type", "Date", "Time")

          dailyData <- as.data.frame(dbGetQuery(db, query2))
          names(dailyData) <- c("Event Type","Date", "Time", "Notes", "User")
          output$dahboardDaily <- renderDataTable({dailyData}, escape = FALSE)

          cadetData <- as.data.frame(dbGetQuery(db, query3))
          names(cadetData) <- c("Event Type", "Date", "Time", "Notes", "User")
          output$dahboardCadet <- renderDataTable({cadetData}, escape = FALSE)
          dbDisconnect(db)
        }))

          observeEvent(input$reportDateInput, {
            temp_folder <- tempfile()
            dir.create(temp_folder)
            
            db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host,port = options()$mysql$port, user = options()$mysql$user,password = options()$mysql$password)
            
            if(data$permission == 1){
              cadet <- "="
            } else{
              cadet <- "!="
            }
            
            if(substring(Sys.time(), 12) < '17:00:00'){
              query4 <- sprintf(paste0("SELECT cadet_lname, incident_type, incident_date, incident_time, image_path FROM greenbook.incident_report WHERE officer = '", loggedInUsername, "' AND incident_date = '", input$reportDateInput - 1, "' AND incident_time > '17:00:00' OR incident_date = '", input$reportDateInput, "'"),"incident_report")
              query5 <- sprintf(paste0("SELECT daily_event_type, daily_date, daily_time, daily_event_narrative, userName FROM greenbook.daily_report WHERE userName = '", loggedInUsername, "' AND daily_date = '", input$reportDateInput - 1, "' AND daily_time > ' 17:00:00 ' OR userName = '", loggedInUsername, "' AND daily_date = '", input$reportDateInput, "'"),"daily_report")
              query6 <- sprintf(paste0("SELECT daily_event_type, daily_date, daily_time, daily_event_narrative, userName FROM greenbook.daily_report WHERE userName != '", loggedInUsername, "' AND daily_date = '", input$reportDateInput - 1, "' AND daily_time > ' 17:00:00 ' OR userName ",cadet," '", loggedInUsername, "' AND daily_date = '", input$reportDateInput, "'"),"daily_report")
            } else{
              query4 <- sprintf(paste0("SELECT cadet_lname, incident_type, incident_date, incident_time, image_path FROM greenbook.incident_report WHERE officer = '", loggedInUsername, "' AND incident_date = '", input$reportDateInput, "' AND incident_time  > ' 17:00:00 '"),"incident_report")
              query5 <- sprintf(paste0("SELECT daily_event_type, daily_date, daily_time, daily_event_narrative, userName FROM greenbook.daily_report WHERE userName = '", loggedInUsername, "' AND daily_date = '", input$reportDateInput, "' AND daily_time  > ' 17:00:00 '"),"daily_report")
              query6 <- sprintf(paste0("SELECT daily_event_type, daily_date, daily_time, daily_event_narrative, userName FROM greenbook.daily_report WHERE userName ", cadet, " '", loggedInUsername, "' AND daily_date = '", input$reportDateInput, "' AND daily_time  > ' 17:00:00 '"),"daily_report")
            }
            formalReportData1 <- as.data.frame(dbGetQuery(db, query4))
            names(formalReportData1) <- c("Cadet Last Name", "Incident Type", "Date", "Time")
            formalReportData2 <- as.data.frame(dbGetQuery(db, query5))
            names(formalReportData2) <- c("Event Type","Date", "Time", "Notes", "User")
            formalReportData3 <- as.data.frame(dbGetQuery(db, query6))
            names(formalReportData3) <- c("Event Type", "Date", "Time", "Notes", "User")
            
            dbDisconnect(db)
            
            output$downloadReport <- downloadHandler(
              filename = paste("Formal Report ", input$reportDateInput, ".docx", sep = ""),
              content = function(file) {
                tempReport <- file.path(temp_folder, "report.Rmd")
                tempTemplate <- file.path(temp_folder, "report_template.docx")
                file.copy("report.Rmd", tempReport, overwrite = TRUE)
                file.copy("report_template.docx", tempTemplate, overwrite = TRUE)
                rmarkdown::render(
                  tempReport, 'word_document', output_file = file, params = list(officerIncidentData = formalReportData1, officerDailyData = formalReportData2, cadetDailyData = formalReportData3)
                )
              }
            )
          })

    ## ANALYTICS TAB ##
      observeEvent(c(input$trendType, input$fromTrendDate, input$toTrendDate),{
      db <- dbConnect(
        MySQL(), dbname = databaseName, host = options()$mysql$host,
        port = options()$mysql$port, user = options()$mysql$user,
        password = options()$mysql$password
      )
      trendQuery <- paste0(
        "SELECT cadet_fname, cadet_minitial, cadet_lname, incident_time, incident_date, officer_narrative FROM greenbook.incident_report
        WHERE (incident_date BETWEEN '", input$fromTrendDate, "' AND '", input$toTrendDate, "')
        AND (incident_type = '", input$trendType, "');"
      )
      trendData <- dbGetQuery(db, trendQuery)
      dbDisconnect(db)
      
      output$trendPlot <- renderPlot({
        trend <- as.data.frame(table(as.Date(trendData$incident_date, "%Y-%m-%d")))
        names(trend) <- c("Date", "Freq")
        df <- data.frame(
          Date = as.Date(trend$Date, "%Y-%m-%d"),
          Frequency = trend$Freq
        )
        ggplot(df, aes(x=Date, y=Frequency)) +
          geom_bar(stat = "identity") + theme_bw() + stat_smooth(method = lm) +
          labs(x = "Date", y = "Frequency") +
          scale_x_date(labels = date_format("%m-%d-%Y")) +
          theme(axis.text.x = element_text(size = 16, hjust = .5, vjust = .5, face = "plain"),
                axis.text.y = element_text(size = 16, hjust = 1, vjust = 0, face = "plain"),
                axis.title.x = element_text(size = 16, hjust = .5, vjust = 0, face = "plain"),
                axis.title.y = element_text(size = 16, hjust = .5, vjust = .5, face = "plain"))
      })
      
      output$trendDataTable <- renderDataTable({trendData}, escape = FALSE)
        
    })

    ## INCIDENT REPORT, DIALY REPORT, SEARCH QUERYS ##

      # Incident Report insert and remove cadets #
      inserted <- list(c())
      observeEvent(input$insertBtn, {
        btn <- input$insertBtn
        Id <- paste0('keydet', (length(inserted) + 1))
        if(length(inserted) < 5) {
          insertUI(
            selector = "#insertCadetBox",
            ui = tags$div(
              box(
                title = sprintf("Cadet %s", length(inserted)), status = "warning", solidHeader = TRUE, width = NULL,
                textInput(sprintf("firstName%s", length(inserted)), "First Name: (REQUIRED)", width = NULL, placeholder = "First Name"),
                textInput(sprintf("midName%s", length(inserted)), "Middle Initial:", width = NULL, placeholder = "Middle Initial"),
                textInput(sprintf("lastName%s", length(inserted)), "Last Name: (REQUIRED)", width = NULL, placeholder = "Last Name"),
                numericInput(sprintf("roomNum%s", length(inserted)), "Room Number:", value = "", width = NULL, min = 100, max = 3440 )
              ), Id = Id)
          )
          inserted <<- c(Id, inserted)
        }
      })

      observeEvent(input$removeBtn, {
        removeUI(
          selector = paste0('#', inserted)
        )
        if(length(inserted) > 1){
          inserted <<- inserted[-1]
        }
      })

      # Incident Report Query #
      observeEvent(input$incidentSubmit,{
        if(input$firstName != "" && input$lastName != "" && input$eventTag != "" && (is.null(input$date) == FALSE)){
          narrativeString <- gsub("'","''",input$narrative)
          if((is.na(input$roomNum))){roomNumber <- (paste(""))} else{roomNumber <- input$roomNum}
          inFile <- input$file
          file.copy(inFile$datapath, file.path("www/images", inFile$name))
          if(is.null(input$file)){fileUpload <- (paste(""))} else{
            fileUpload <- paste0("https://vmigreenbook.shinyapps.io/public_r/images/", input$file)
            file.copy(inFile$datapath, file.path("www/images", inFile$name))
          }

          db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host,
                          port = options()$mysql$port, user = options()$mysql$user,
                          password = options()$mysql$password)
          str <- (length(inserted) - 1)
          if(str != 0){
            for(i in 1:str){
              fName = ""
              mName = ""
              lName = ""
              roomNum = ""
              if(i == 1){
                fName <- input$firstName1
                mName <- input$midName1
                lName <- input$lastName1
                roomNum <- input$roomNum1
              }else if(i == 2){
                fName <- input$firstName2
                mName <- input$midName2
                lName <- input$lastName2
                roomNum <- input$roomNum2
              }else if(i == 3){
                fName <- input$firstName3
                mName <- input$midName3
                lName <- input$lastName3
                roomNum <- input$roomNum3
              }else if(i == 4){
                fName <- input$firstName4
                mName <- input$midName4
                lName <- input$lastName4
                roomNum <- input$roomNum4
              }

              if(is.null(roomNum) || is.na(roomNum)){roomNum = (paste(""))}

              query <- sprintf(
                "INSERT INTO `greenbook`.`incident_report` (`cadet_fname`, `cadet_minitial`, `cadet_lname`, `cadet_room`, `incident_time`, `incident_date`, `incident_type`, `officer_narrative`, `image_path`, `officer`)
                VALUES('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');",
                fName, mName, lName, roomNum, substring(gsub(":00 ", "", input$time), 11), input$date, input$eventTag, narrativeString, fileUpload, loggedInUsername
              )
              dbGetQuery(db, query)
            }
          }

          query <- sprintf(
            "INSERT INTO `greenbook`.`incident_report` (`cadet_fname`, `cadet_minitial`, `cadet_lname`, `cadet_room`, `incident_time`, `incident_date`, `incident_type`, `officer_narrative`, `image_path`, `officer`)
            VALUES('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s');",
            input$firstName, input$midName, input$lastName, roomNumber, substring(gsub(":00 ", "", input$time), 11), input$date, input$eventTag, narrativeString, fileUpload, loggedInUsername
          )
          dbGetQuery(db, query)
          reset("incidentForm")
          dbDisconnect(db)
          shinyalert("Success!", "You have submitted your incident report.", type = "success")
        }else{
          shinyalert("Hold on!", "You have not filled all required fields: First Name, Last Name, Incident Type, and Date", type = "warning")
        }
      })

      # Daily Report Query #
      observeEvent(input$dailyReportSubmit,{
        if((input$dailyEventTag != "" && is.na(input$dailyDate) == FALSE) == TRUE){
          dailyNarrativeString <- gsub("'","''",input$dailyNarrative)
          table <- "daily_report"
          db <- dbConnect(
            MySQL(), dbname = databaseName, host = options()$mysql$host,
            port = options()$mysql$port, user = options()$mysql$user,
            password = options()$mysql$password
          )
          query <- sprintf(
            "INSERT INTO `greenbook`.`daily_report` (`daily_date`, `daily_time`, `daily_event_type`, `daily_event_narrative`, `userName`)
            VALUES('%s', '%s', '%s', '%s', '%s');", input$dailyDate, substring(gsub(":00 ", "", input$dailyTime), 11), input$dailyEventTag, dailyNarrativeString, loggedInUsername
          )
          dbGetQuery(db, query)
          dbDisconnect(db)
          reset("dailyReportForm")
          shinyalert("Success!", "You have submitted your daily report.", type = "success")
        }else{
          shinyalert("Hold on!", "You have not filled all required fields: Date and Event Type", type = "warning")
        }
      })

      # Daily Report Distinguished Choices #
      if(data$permission == 1){
        insertUI(
          selector = "#insertDailyType",
          where = "afterEnd",
          ui = box(
            title = "What", status = "primary", solidHeader = TRUE, width = NULL,
            selectInput("dailyEventTag", "Event Type: (REQUIRED)",
              c("Choose one" = "", "Cadet Things 1", "Cadet Things 2", "Cadet Things 3", "Cadet Things 4", "Cadet Things 5")
            ),
            textAreaInput(
              "dailyNarrative", "Narrative:", width = NULL, height = '170px'
            )
          )
        )
      }else{
        insertUI(
          selector = "#insertDailyType",
          where = "afterEnd",
          ui = box(
            title = "What", status = "primary", solidHeader = TRUE, width = NULL,
            selectInput("dailyEventTag", "Event Type: (REQUIRED)",
              c("Choose one" = "", "Officer Things 1", "Officer Things 2", "Officer Things 3", "Officer Things 4", "Officer Things 5")
            ),
            textAreaInput(
              "dailyNarrative", "Narrative:", width = NULL, height = '170px'
            )
          )
        )
      }

      # Searching Query #
      observeEvent(input$searchButton, {
        if((input$searchFirstName == "") == FALSE){a <- (paste0(" AND (cadet_fname = '", input$searchFirstName, "')"))} else{a <- (paste0(""))}
        if((input$searchMidName == "") == FALSE){b <- (paste0(" AND (cadet_minitial = '", input$searchMidName, "')"))} else{b <- (paste0(""))}
        if((input$searchLastName == "") == FALSE){c <- (paste0(" AND (cadet_lname = '", input$searchLastName, "')"))} else{c <- (paste0(""))}
        if((is.na(input$searchRoomNum))){d <- (paste0(""))} else{d <- (paste0(" AND (cadet_room = '", input$searchRoomNum, "')"))}
        if((input$searchEventTag == "") == FALSE){e <- (paste0(" AND (incident_type = '", input$searchEventTag, "')"))} else{e <- (paste0(""))}
        table <- "incident_report"
        db <- dbConnect(
          MySQL(), dbname = databaseName, host = options()$mysql$host,
          port = options()$mysql$port, user = options()$mysql$user,
          password = options()$mysql$password
        )
        query <- paste0(
          "SELECT `cadet_fname`, `cadet_minitial`, `cadet_lname`, `cadet_room`, `incident_time`, `incident_date`, `incident_type`, `officer_narrative`, `officer` FROM greenbook.incident_report
          WHERE (incident_date BETWEEN '", input$fromSearchDate, "' AND '", input$toSearchDate, "')", a, b, c, d, e
        )
        data <- as.data.frame(dbGetQuery(db, query))
        dbDisconnect(db)
        names(data) <- c("First Name", "Middile Initial", "Last Name", "Room", "Time", "Date", "Event Type", "Narrative", "User")
        output$table <- renderTable(data)
      })

    ## CLEAR FORM BUTTONS ##
      observeEvent(input$incidentReset, {
        reset("incidentForm")
      })

      observeEvent(input$dailyReportReset, {
        reset("dailyReportForm")
      })

      observeEvent(input$SearchReset, {
        reset("searchForm")
      })
      
    }
  })
}
