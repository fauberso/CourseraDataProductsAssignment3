library(shiny)
library(googleVis)

stationen <- read.csv("stationen.txt", sep = ";", header = FALSE, encoding = "UTF-8", strip.white = TRUE)
choices <- as.list(as.character(stationen[,2]))
names(choices) <- stationen[,1]

shinyUI(fluidPage(

  # Application title
  titlePanel("Weather Trends in Switzerland"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
       tags$head(tags$style("#myplot{height:600px !important;}")),
      
       selectInput("station", label = h3("Weather Station:"), 
                  choices = choices, 
                  selected = 1),
      
       sliderInput("years",
                   "Years:",
                   min = 1864,
                   max = 2050,
                   value = c(1850, 2017), 
                   sep="")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
       htmlOutput("plot")
    )
  )
))
