# includes
library(shiny)
library(shinyjs)

# globals, common resources
source( 'globals.R', local = TRUE)

# client: GUI
source( 'gui.R', local = TRUE)

# server: interaction & logic, session
source( 'webserver.R', local = TRUE) # name different from 'server.R' to avoid RStudio bug

# run app, build UI, start webserver
shinyApp( ui, server, options = list( display.mode = 'showcase', width = 1000) ) # fixme
