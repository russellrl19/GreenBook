# VMI Capstone Project: GreenBook

GreenBook is an online data sorage and analytical tool written in R Shiny.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

R Studio

Optional: MySQL Workbench

### Installing

A step by step series of examples that tell you how to get a development env running

Clone the Master Branch onto your local machine
```
https://github.com/russellrl19/GreenBook.git
```
Install the R packages in R Studio's Console

```
install.packages(c("shiny","shinydashboard","shinyTime","RMySQL","dbConnect","DBI","gWidgets","shinyjs","shinyalert","shinyBS","plotly","ggplot2","scales","glue","grid","RColorBrewer","rmarkdown","png","jpeg","sodium"))
```

Open server.R and ensure that the AWS server access is NOT commented out and that the local server access is commented out.
```
  # FOR AWS #
  options(
    mysql = list(
      "host" = "greenbook.cd0e9wwmxm8h.us-east-1.rds.amazonaws.com",
      "port" = 3306,
      "user" = "greenbookadmin",
      "password" = "~L7pPw}UZ;8*"
    )
  )

  # FOR LOCAL #
  # options(
  #   mysql = list(
  #     "host" = "localhost",
  #     "port" = 3306,
  #     "user" = "root",
  #     "password" = "root"
  #   )
  # )
```
## Known Bugs
* Uploading Images are being stored on ShinyApps.io Server. This is not ideal and they are reset every time the server sleeps or the application is republished.
* Registration needs to be restricted so that any person cannot just get on and start posting things. Future work: Make registrations requests rather than direct registration.

## Built With

* [R Shiny](https://shiny.rstudio.com/) - The application development language
* [ShinyApps.io](https://www.shinyapps.io/) - The application hosting server
* [MySQL](https://www.mysql.com/) - Database Management
* [AWS](https://console.aws.amazon.com/rds/home?region=us-east-1) - Used form communication between ShinyApps.io and MySQL Database

## Authors

* **Madison Curran** - [GitHub](https://github.com/curryrann)
* **Ryan Russell** - [GitHub](https://github.com/russellrl19)

## Help Received

* All Libraries listed
