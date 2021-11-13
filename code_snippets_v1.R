

## server code for observer for an action button with the id/name "Go". This was the class exercise we did to dynamically build a SQL based on a user input for # of votes stored in the variable input$rest_votes. Use this code to modify the SQL that suits the needs of this HW1.
observeEvent(input$Go, {
  # open DB connection
  db <- dbConnector(
    server   = getOption("database_server"),
    database = getOption("database_name"),
    uid      = getOption("database_userid"),
    pwd      = getOption("database_password"),
    port     = getOption("database_port")
  )
  on.exit(dbDisconnect(db), add = TRUE)
  
  # browser()
  query <- paste("select name,Votes,city from zomato_rest where votes =", input$rest_votes,";")
  print(query)
  # Submit the fetch query and disconnect
  data <- dbGetQuery(db, query)
  
  output$mytable = DT::renderDataTable({
    data
  })
  
})



