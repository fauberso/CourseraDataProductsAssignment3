library(shiny)
library(googleVis)
library(memoise)

shinyServer(function(input, output) {
   
  output$plot <- renderGvis({
    dataframe <- getData(station = input$station, as.numeric(input$order))
    # General Examples: https://cran.r-project.org/web/packages/googleVis/vignettes/googleVis_examples.html
    # Using Roles: https://cran.r-project.org/web/packages/googleVis/vignettes/Using_Roles_via_googleVis.html
    # Intervals: https://developers.google.com/chart/interactive/docs/gallery/intervals
    lineplot <- gvisLineChart(dataframe, "Year", 
                             c("Temperature","Temperature.interval.1","Temperature.interval.2","Temperature.certainty","Precipitation","Precipitation.interval.1", "Precipitation.interval.2", "Precipitation.certainty"),
                             options=list(
                             series="[{targetAxisIndex:0, color:'red'},
                                      {targetAxisIndex:1, color:'blue'}]",
                             intervals="{ style:'area' }",
                             vAxes="[{title:'Temperature (Degrees Celcius)', viewWindowMode:'explicit', viewWindow:{min:-15, max:25}, format: 'decimal'}, 
                                     {title:'Precipitation (mm)', viewWindowMode:'explicit', viewWindow:{min:0, max:800}, format: 'decimal'}]",
                             hAxes=paste("[{title:'Date', viewWindowMode:'explicit', viewWindow:{min:",input$years[1],", max:",input$years[2],"}, format: '####'}]"),
                             width=1200, height=800
                           ))
    lineplot
  })
  
  getDataInternal <- function(station, predOrder) {
    url <- "http://www.meteoschweiz.admin.ch/product/output/climate-data/homogenous-monthly-data-processing/data/"
    url <- paste(url, "homog_mo_", station, ".txt", sep = "")
    print(paste("Getting data from", url))
    widths <- c(4, 7, 19, 19)
    col.names <- c("Year","Month", "Temperature", "Precipitation")
    colClasses <- rep("numeric", 4)
    na.strings <- c("NA")
    dataset <- read.fwf(file = url, widths = widths, header = FALSE, col.names = col.names, colClasses=colClasses, na.strings=na.strings, skip = 28)
    dataset <- na.omit(dataset[max(c(0,which(!complete.cases(dataset))))+1:nrow(dataset),])
    
    dataYears <- data.frame(Year=seq(from=min(dataset$Year), to=max(dataset$Year)))
    dataframe <- data.frame(
      aggregate(Temperature~Year, data=dataset, mean),
      aggregate(Temperature~Year, data=dataset, min)[2],
      aggregate(Temperature~Year, data=dataset, max)[2],
      rep(TRUE,nrow(dataYears)),
      aggregate(Precipitation~Year, data=dataset, mean)[2],
      aggregate(Precipitation~Year, data=dataset, min)[2],
      aggregate(Precipitation~Year, data=dataset, max)[2],
      rep(TRUE,nrow(dataYears))
    )
    colnames(dataframe)<-c("Year","Temperature","Temperature.interval.1","Temperature.interval.2","Temperature.certainty","Precipitation","Precipitation.interval.1", "Precipitation.interval.2", "Precipitation.certainty")
    
    predYears <- data.frame(Year=seq(from=max(dataframe$Year)+1, to=2064))
    predictions <- data.frame(
      predYears,
      predict(lm(Temperature~poly(Year,predOrder), data=dataframe), newdata = predYears),
      predict(lm(Temperature.interval.1~poly(Year,predOrder), data=dataframe), newdata = predYears),
      predict(lm(Temperature.interval.2~poly(Year,predOrder), data=dataframe), newdata = predYears),
      rep(FALSE,nrow(predYears)),
      predict(lm(Precipitation~poly(Year,predOrder), data=dataframe), newdata = predYears),
      predict(lm(Precipitation.interval.1~poly(Year,predOrder), data=dataframe), newdata = predYears),
      predict(lm(Precipitation.interval.2~poly(Year,predOrder), data=dataframe), newdata = predYears),
      rep(FALSE,nrow(predYears))
    )
    colnames(predictions)<-colnames(dataframe)
    
    rbind(dataframe, predictions)
  }
  
  getData <- memoise(getDataInternal)
  
})

