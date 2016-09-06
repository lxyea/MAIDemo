# This is the user-interface of a maintenance analytics application.
# 

library(shiny)

shinyUI(fluidPage(
  # Application name: MAI Dynamic
  titlePanel("Maintenance Analysis"),

  # Sidebar with a few inputs for choices
  sidebarLayout(
    sidebarPanel(
            
        selectInput("select", label = h3("Choose a chart to display"), 
                choices = c("Maintenance Analysis by Operations", 
                               "Maintenance Analysis by Trucks"))
        
    ),

    # Show a plot of the generated distribution
    mainPanel(
            htmlOutput("view")
            
    )
  )
)
)