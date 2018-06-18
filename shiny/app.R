# includes
library(shinyjs, quietly = TRUE)
library(rmarkdown)

# globals, common resources
source('globals.R', local = TRUE)
source(file.path('client', 'tabs.R'), local = TRUE)

# client: GUI
ui <- fluidPage(
  # external CSS
  includeCSS(file.path('www', 'pippeline.css') ),
  # window title
  title = basics$appName,

  fluidRow(
    column(9,
      "", # tabs
      source( file.path( 'client', 'main.R'), local = TRUE)$value
    ),
    column(3,
      h2("Project information:"),
      # helpText("..."),
      htmlOutput("infoVar") # textOutput
    )
  ),

  # logo
  img(src='logo-uit.svg', width = 200, height = 'auto', class='logo'),
  # javascript, for closing the window
  useShinyjs(),
  extendShinyjs(text = jscode, functions = c('closeWindow', 'disableTab', 'enableTab'))
)

# server: interaction & logic, session
server <- function( input, output, session) {
  # global variables
  
  source(file.path('server', 'functions.R'), local = TRUE)
  source(file.path('server', 'main.R'), local = TRUE) # name different from 'server.R' to avoid RStudio bug
  source(file.path('server', 'events.R'), local = TRUE)
}

# run app, build UI, start webserver
shinyApp(ui, server)
