#' Wrapper for running the Shiny app locally.
#' 
#' @example 
#' source('pippeline.R')

# includes
library(shiny)

#https://shiny.rstudio.com/reference/shiny/1.0.3/shiny-options.html
options(shiny.port=4104)

# run app in the given directory
runApp( 'shiny')
