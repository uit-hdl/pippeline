# reactive variables
prereqsAreValid <- reactive( {
  input$author != '' && 
    input$name != ''
} )
output$prereqsAreValid <- reactive( { 
  prereqsAreValid()
} )
outputOptions( output, 'prereqsAreValid', suspendWhenHidden = FALSE)
choicesAreValid <- reactive( { 
  input$dsg != notSelOpt && 
    input$loc != notSelOpt && 
    input$mat != notSelOpt && 
    input$ana != notSelOpt
} )
output$choicesAreValid <- reactive( { 
  choicesAreValid()
} )
outputOptions( output, 'choicesAreValid', suspendWhenHidden = FALSE)
files <- reactive( {
  if( choicesAreValid() ) {
    getDataFiles()
  } else {
    NULL
  }
} )
output$procIsAllowed <- reactive( { 
  prereqsAreValid() && 
    choicesAreValid() #&& 
  !is.null( files() )
} )
outputOptions( output, 'procIsAllowed', suspendWhenHidden = FALSE)

# download files
output$download <- downloadHandler(
  filename = function() {
    # setting the filename works currently only when run in an external browser window, 
    # but not in Rstudio window/viewer pane
    paste( 'data-', format( Sys.time(), '%Y-%m-%d_%H-%M-%S'), '.csv', sep = '')
  },
  content = function( filename) {
    # fixme: need to remove all ID and running numbers
    fileName <- tempfile( paste0(appName, '-'), fileext = '.rmd')
    writeLines( c( 'foo'), fileName)
    'bar'
    #write.csv( data, filename)
  }
)