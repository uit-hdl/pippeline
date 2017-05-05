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

sourceFiles <- reactive( {
  if( choicesAreValid() ) {
    getDataFiles()
  } else {
    NULL
  }
} )

output$procIsAllowed <- reactive( { 
  prereqsAreValid() && 
    choicesAreValid() #&& 
  !is.null( sourceFiles() )
} )
outputOptions( output, 'procIsAllowed', suspendWhenHidden = FALSE)

# normal variables
# timestamp
ts = NULL