#' Starts the Shiny app called Pippeline.
#'
#' fixme: currently it does not work
#' @examples
#' `library(pippeline)`
#' or alternatively (in the directory containing the DESCRIPTION file)
#' `library(shiny)`
#' `library(shinyjs)`
#' `runApp( 'shiny')`
.onLoad <- function( libname, pkgname) {
  library(shiny)
  runApp( system.file( package = pkgname, mustWork=TRUE) )
}