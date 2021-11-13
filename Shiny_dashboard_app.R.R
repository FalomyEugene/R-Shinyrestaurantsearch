# Load required libraries
#install.packages("DT")
library(shiny)
library(shinydashboard)
library(leaflet)
library(DBI)
library(odbc)
library(DT)


# Read database credentials
# source("./03_shiny_HW1/credentials_v3.R")
source("./credentials_v4.R")


ui <- fluidPage(
  
  
  dashboardPage(
    
    dashboardHeader(title = "ITOM6265-HW1" ),
    #Sidebar content
    dashboardSidebar(
      #Add sidebar menus here
      sidebarMenu(
        menuItem("App's Intro", tabName = "HWSummary", icon = icon("dashboard")),
        menuItem("Restaurant Search Tab", tabName = "dbquery", icon = icon("dashboard")),
        menuItem("Restaurant's Location", tabName = "leaflet", icon = icon("th"))
      )
    ),
    dashboardBody(
      
      
      tabItems(
        # Add contents for first tab
        tabItem(tabName = "HWSummary",
                #h3("This HW was submitted by Falomy Eugene of ITOM6265"),
                p("This App was developed by Falomy Eugene of ITOM6265", style = "color:green ; font-size: 32px"),
                
                p("Users of this app are allowed to select restaurants based on number of votes a restaurant
              receieves. Also, users can search for their restaurants using the (Enter the name of your desired restaurant )  under the Restaurant Search Tab.
                 ",style="color:purple; font-size: 24px"),
                
                p(" Morverover, users can see different restaurants' locations on the map.
                  under the Restaurant Location Tab.
              
                ",style="color:purple; font-size: 24px" )
        ),
        
        # Add contents for second tab
        
        tabItem(tabName = "dbquery",
                textInput("rest_name", label = h3("Enter the name of your desired restaurant")),
                sliderInput("rest_votes", label = h3("Select the vote range:"), min = 0, 
                            max = 100, value = c(0, 100)),
                actionButton("Go", label = "Get Results"),
                hr(),
                DT::dataTableOutput("mytable")
        ),
        #  Add contents for third tab
        tabItem(tabName = "leaflet",
                h1("Restaurant's Location"),
                leafletOutput("mymap")
        )
      ),
      tags$img(
        src = "https://static.onecms.io/wp-content/uploads/sites/35/2019/05/21181957/women-eating-food-hashtag.jpg",
        style = 'position: absolute'
      )
      
    )
    
  )
  
  
)

#browser()

server <- function(input, output) {
  
  #Develop your server side code (Model) here
  
  # open DB connection
  observeEvent(input$Go, {
    
    output$mytable <- DT::renderDataTable({
      
      db <- dbConnector(
        server   = getOption("database_server"),
        database = getOption("database_name"),
        uid      = getOption("database_userid"),
        pwd      = getOption("database_password"),
        port     = getOption("database_port")
      )
      on.exit(dbDisconnect(db), add = TRUE)
      
      #rest_votes <- 100
      
      # browser()
      
      #query <- paste("SELECT name, votes, city FROM zomato_rest where name like '%", input$rest_name, "%'",
      #                 "and", votes, between, input$rest_votes[1], "and", input$rest_votes[2] ";")
      query <- paste0 ("Select
                      name,
                      votes,
                      city
                     from
                      zomato_rest 
                     where
                      name like '%",input$rest_name,"' and 
                      votes between " ,input$rest_votes[1], " and " ,input$rest_votes[2], ";"
      )
      
      #query2 <- paste0("SELECT name, votes, city FROM zomato_rest where name like '%", input$rest_name, "%' order by votes desc;")
      
      
      print(query)
      
      data <- dbGetQuery(db, query)
      
      #output$mytable <- DT::renderDataTable({
      
      data
    })
    
  })
  
  output$mymap <- renderLeaflet({
    
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
    
    #rest_votes <- 100
    
    # browser()
    #titlePanel("Map of restaurants in London. Click on teardrop to check names.")
    query <- paste0("select name, Longitude, Latitude From zomato_rest where Longitude is not null and Latitude is not null;")
    data <- dbGetQuery(db,query)
    leaflet(data) %>%
      addProviderTiles(providers$Stamen.TonerLit) %>%
      addMarkers(lng=~Longitude, lat=~Latitude, popup=data$name)
  })
}

shinyApp(ui, server)
