# Package to connect MySQL
# video on https://www.youtube.com/watch?v=nSkIpCDlFH4
# video for MySQL workbench https://www.youtube.com/watch?v=u6p2OU491Ss

library(RMySQL)
library(dbConnect)
library(DBI)
library(gWidgets)
library(dplyr)
library(dbplyr)
library(pool)

# Create a database connection
con = dbConnect(MySQL(), 
       user='root',
       password='root',
       dbname='greenbook',
       host='localhost')
       #port=3306)

dbListTables(con)
dbExistsTable(con, 'user')