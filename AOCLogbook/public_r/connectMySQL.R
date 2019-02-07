# Package to connect MySQL
# video on https://www.youtube.com/watch?v=nSkIpCDlFH4
# video for MySQL workbench https://www.youtube.com/watch?v=u6p2OU491Ss
library(RMySQL)
library(dbConnect)

# Create a database connection
con = dbConnect(MySQL(), 
       user='root',
       password='Oprunner97',
       dbname='greenbook',
       host='localhost')
       #port=3306)
dbListTables(con)

# Listing table and fields
myQuery <- "select * from mytable;"
df <- dbGetQuery(con, myQuery)
str(df)

# Calling queery with dynamic value in query
# st_age <- 700
# end_age <- 750
# my_d_query <- paste("select * from mytable where GRE between", st_age, " and", end_age )
# out_df <- dbGetQuery(con, my_d_query)