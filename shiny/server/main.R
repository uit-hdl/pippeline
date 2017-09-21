# reactive variables
prereqsAreValid <- reactive( {
  input$author != '' && 
    input$descr != ''
} )
output$prereqsAreValid <- reactive( { prereqsAreValid() } )
outputOptions( output, 'prereqsAreValid', suspendWhenHidden = FALSE)

choicesAreValid <- reactive( { 
  input$dsg != notSelOpt && 
    input$loc != notSelOpt && 
    input$mat != notSelOpt && 
    input$ana != notSelOpt
} )
output$choicesAreValid <- reactive( { choicesAreValid() } )
outputOptions( output, 'choicesAreValid', suspendWhenHidden = FALSE)

sourceObjs <- reactive( {
  if( choicesAreValid() ) {
    getDataObjs()
  } else {
    NULL
  }
} )

# questionnaire variables
questIsValid <- reactive( { input$questObj != notSelOpt} )
output$questIsValid <- reactive( { questIsValid() } )
outputOptions( output, 'questIsValid', suspendWhenHidden = FALSE)

output$qvarPicker <- renderUI( {
  availQVars <- colnames( get( input$questObj) )
  selectizeInput( 'questVars', 'Variables', multiple = T, choices = availQVars, selected = availQVars)
} )

procIsAllowed <- reactive( { 
  prereqsAreValid() &&
    choicesAreValid() && 
    !is.null( sourceObjs() )
} )
output$procIsAllowed <- reactive( { procIsAllowed() } )
outputOptions( output, 'procIsAllowed', suspendWhenHidden = FALSE)

allInputIsValid <- reactive( {
  if( input$normEnabled)
    input$nmeth != notSelOpt
  else
    TRUE
} )

output$downlIsAllowed <- reactive( { 
  prereqsAreValid() && 
    procIsAllowed() &&
    allInputIsValid()
} )
outputOptions( output, 'downlIsAllowed', suspendWhenHidden = FALSE)

# normal variables
# timestamp
ts <- NULL