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

objsExist <- reactive( { 
  !is.null( sourceObjs() )
} )
output$objsExist <- reactive( { objsExist() } )
outputOptions( output, 'objsExist', suspendWhenHidden = FALSE)

outlFileExists <- reactive( { 
  !is.null( input$outlierFile)
} )
output$outlFileExists <- reactive( { outlFileExists() } )
outputOptions( output, 'outlFileExists', suspendWhenHidden = FALSE)

# questionnaire variables
questIsValid <- reactive( { input$questObj != notSelOpt} )
output$questIsValid <- reactive( { questIsValid() } )
outputOptions( output, 'questIsValid', suspendWhenHidden = FALSE)

output$qvarPicker <- renderUI( {
  if( exists( input$questObj) ) {
    availQVars <- colnames( get( input$questObj) )
    removeNotification( 'quest')
  } else {
    showNotification( paste0( 'No questionnaire available. (Check file "', basics$questsFile, '" or load object.) Error code #9.'), type = 'error', duration = NULL, id = 'quest')
    availQVars <- c()
  }
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
  if( as.logical(input$normEnabled) )
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

# updating dataset information
output$info_var <- renderText( { 
    dinfo$dName = input$dsg
    #dinfo$numPairs=getDataObjs()
    dinfo$outlierR=ifelse(input$outlierEnabled,toString("Enabled with file:", input$dsg), "Not enabled")
    dinfo$bCorr=ifelse(input$corrEnabled,"Enabled", "Not enabled")
    dinfo$filterP=input$pval
    dinfo$filterLimit=input$plimit
    dinfo$normMethod=ifelse(input$normEnabled, as.character("Enabled -", input$nmeth), "Not enabled") 
    #dinfo$questVars=input$questObj

    paste(#"<b>", 
      "Dataset: ", dinfo$dName, "<br>",
      "Number of pairs: ", dinfo$numPairs, "<br>",
      "Outlier removal: ", dinfo$outlierR, "<br>",
      "Background correction: ", dinfo$bCorr, "<br>",
      "P value:", dinfo$filterP, "<br>",
      "Filtering limit: ", dinfo$filterLimit, "<br>",
      "Normalization method: ", dinfo$normMethod, "<br>",
      "Questionnaire variables:", dinfo$questVars
      #, "<br>","</b>"
      )
} )
