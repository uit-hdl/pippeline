#' Wrapper for running the Shiny app locally.
#' 
#' @example 
#' source('pippeline.R')

# includes
require(shiny)
require(shinyjs, quietly = TRUE)

# run app in the given directory
runApp( 'shiny')