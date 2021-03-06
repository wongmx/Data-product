
if (!require(PerformanceAnalytics)) {
  stop("This app requires the PerformanceAnalytics package. To install it, run 'install.packages(\"PerformanceAnalytics\")'.\n")
}

if (!require(quantmod)) {
  stop("This app requires the quantmod package. To install it, run 'install.packages(\"quantmod\")'.\n")
}

# Download data for a stock, if needed
require_symbol <- function(symbol) {
  if (!exists(symbol))
    getSymbols(symbol, from = "1900-01-01", src="google")
}

library(shiny)

# Define server logic required to summarize and view the selected dataset
shinyServer(function(input, output) {
  make_chart <- function(symbol="FB") {
    # get price data if does not exist
    require_symbol(symbol)
    
    #would hope not to recalculate each time but for now will leave messy
    price.monthly <- to.monthly(get(symbol))[,4]
    ret.monthly <- ROC(price.monthly, type="discrete", n=1)
    
    #calculate system returns
    systemRet <- merge(
      ifelse(lag(price.monthly > runMean(price.monthly, n=input$nmonths), k=1), 1, 0) * ret.monthly,
      ret.monthly)
    colnames(systemRet) <- c(paste(input$nmonths,"MASys",sep=""), symbol)
    
    charts.PerformanceSummary(systemRet, ylog=TRUE)
  }
  
  make_table <- function(symbol="FB") {
    # get price data if does not exist
    require_symbol(symbol)
    
    #would hope not to recalculate each time but for now will leave messy
    price.monthly <- to.monthly(get(symbol))[,4]
    ret.monthly <- ROC(price.monthly, type="discrete", n=1)
    
    #calculate system returns
    systemRet <- merge(
      ifelse(lag(price.monthly > runMean(price.monthly, n=input$nmonths), k=1), 1, 0) * ret.monthly,
      ret.monthly)
    colnames(systemRet) <- c(paste(input$nmonths,"MASys",sep=""), symbol)
    
    table.Stats(systemRet)
  }
  
  # Generate a plot of the system and buy/hold benchmark given nmonths parameter
  # include outliers if requested
  output$systemPlot <- renderPlot(function() {
    make_chart()
  })
  
  # Generate a summary stats table of the dataset
  output$view <- renderTable(function() {
    make_table()
  })
  
})
