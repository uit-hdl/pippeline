#' Starts the Shiny app called Pippeline.
#'
#' fixme: does it work??
#' @examples
#' `library(pippeline)`
#' or alternatively (in the directory containing the DESCRIPTION file)
#' `library(shiny)`
#' `library(shinyjs)`
#' `runApp( 'shiny')`
.onLoad <- function( libname, pkgname) {
  runApp( system.file( package = pkgname, mustWork=TRUE) )
}