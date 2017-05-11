# includes
require( shinyjs, quietly = TRUE)
require( rmarkdown)

# globals, common resources
source( 'globals.R', local = TRUE)
source( file.path( 'client', 'tabs.R'), local = TRUE)

# client: GUI
ui <- fluidPage(
  # external CSS
  includeCSS( file.path( 'www', 'pippeline.css') ),
  # window title
  title = basics$appName,
  # tabs
  source( file.path( 'client', 'main.R'), local = TRUE)$value,
  # logo
  img( src='logo-uit.svg', width = 200, height = 'auto', class='logo'),
  # javascript, for closing the window
  useShinyjs(),
  extendShinyjs( text = jscode, functions = c( 'closeWindow') )
)

# server: interaction & logic, session
server <- function( input, output, session) {
  source( file.path( 'server', 'functions.R'), local = TRUE)
  source( file.path( 'server', 'main.R'), local = TRUE) # name different from 'server.R' to avoid RStudio bug
  source( file.path( 'server', 'events.R'), local = TRUE)
}

# run app, build UI, start webserver
shinyApp( ui, server, options = list( display.mode = 'showcase', width = 1000) ) # fixme
