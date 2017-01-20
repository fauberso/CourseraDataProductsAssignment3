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
      p(paste("This small demo shows how to mix time series data with forecasted data, and",
            "visualise it using Google Chart.")),
      p(paste("It will load historic weather data from the Swiss Office of Meterology's open data page",
              "(http://www.meteoswiss.admin.ch/home/climate/past/homogenous-monthly-data.html),",
              "then fit a regression model to the existing",
              "data to forecast a number of future years. The type of model (i.e. its order)",
              "can be selected, allowing us to compare the different results of the forecasting",
              "model (and the main purpose here is educational, the forecasts are not to be",
              "understood as a serious attempt at forecasting the effects of global warming,",
              "for example).")),
      p(paste("Data is available for several weather stations. The weather station can be selected",
              "from a drop-down list, which will also show which region and height the station is ",
              "located at. Note in particular the differences in temperature and precipitations",
              "depending on the station's location.")),
      p(paste("The years to display in the chart can be selected using the slider. This allows you",
              "to zoom in and out, and to show additional years of forecasting up to the year 2064",
              "(a full 200 years after the time series start).")),
      p(paste("The data displayed is the yearly average temperature and precipitation, with the highest",
              "and lowest monthly average shown as a shaded area.")),
      
       tags$head(tags$style("#myplot{height:600px !important;}")),
      
       selectInput("station", label = "Weather Station:", 
                  choices = choices, 
                  selected = 1),
      
       sliderInput("years",
                   "Years:",
                   min = 1864,
                   max = 2064,
                   value = c(1925, 2025), 
                   sep=""),
       
       radioButtons("order", "Forcasting model:",
                    c("Linear (1st Order)" = 1,
                      "Quadratic (2nd Order)" = 2,
                      "Cubic (3rd Order)" = 3,
                      "Quartic (4th Order)" = 4,
                      "Quintic (5th Order)" = 5),
                    selected = 2)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
       htmlOutput("plot")
    )
  )
))
