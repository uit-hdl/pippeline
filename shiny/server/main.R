# reactive variables
prereqsAreValid <- reactive( {
  input$author != '' && 
  input$descr != '' &&
  input$projname != ''
} )
output$prereqsAreValid <- reactive( { prereqsAreValid() } )
outputOptions( output, 'prereqsAreValid', suspendWhenHidden = FALSE)

choicesAreValid <- reactive( {
  if (
    input$dsg != notSelOpt && 
    input$loc != notSelOpt && 
    input$mat != notSelOpt && 
    input$ana != notSelOpt
    )
  {
    return (TRUE)
  }
  else return (FALSE)
} )
output$choicesAreValid <- reactive( { choicesAreValid() } )
outputOptions( output, 'choicesAreValid', suspendWhenHidden = FALSE)

sourceObjs <- reactive( {
  if(choicesAreValid()){
    tryCatch({
      getDataObjs()
      }, warning = function(wrn){
      NULL
      }, error = function(err){
      NULL
      })
  } else {
    NULL
  }
} )

objsExist <- reactive( { 
  !is.null( sourceObjs() )
} )
output$objsExist <- reactive( { objsExist() } )
outputOptions( output, 'objsExist', suspendWhenHidden = FALSE)

# Outlier file reactive
outlFileExists <- reactive( { 
  if (input$outlierFile != notSelOpt){
    if (typeof(readRDS(file.path(nowacleanFolder, input$outlierFile))) == 'character'){
      return (TRUE)
    }
    else {
      showNotification(paste0('Loaded file "', input$outlierFile, '" should contain vector of characters. Error code #12.'), 
        type = 'error', duration = 7)
      return (FALSE)
    }
  }
  else 
    return (FALSE)
})

output$outlFileExists <- reactive( { outlFileExists() } )
outputOptions( output, 'outlFileExists', suspendWhenHidden = FALSE)

# Transitions file reactive
cctFileExists <- reactive( { 
  if (input$cctFile != notSelOpt){
    if (typeof(readRDS(file.path(cctransFolder, input$cctFile))) == 'character'){
      return (TRUE)
    }
    else {
      showNotification(paste0('Loaded file "', input$cctFile, '" should contain vector of characters. Error code #12.1.'), 
        type = 'error', duration = 7)
      return (FALSE)
    }
  }
  else 
    return (FALSE)
})

output$cctFileExists <- reactive( { cctFileExists() } )
outputOptions(output, 'cctFileExists', suspendWhenHidden = FALSE)

# method valid reactive
methodIsValid <- reactive( { 
  if ((input$normEnabled && input$nmeth == 'vstQuantileNorm') || 
    (input$normEnabled && input$nmeth == 'ComBat' && input$batchTab != notSelOpt && input$batchVar != notSelOpt)) 
    return (TRUE)
  else return (FALSE)
})

output$methodIsValid <- reactive( { methodIsValid() } )
outputOptions(output, 'methodIsValid', suspendWhenHidden = FALSE)

# questionnaire variables
questIsValid <- reactive( { input$questObj != notSelOpt} )
output$questIsValid <- reactive( { questIsValid() } )
outputOptions( output, 'questIsValid', suspendWhenHidden = FALSE)

output$qvarPicker <- renderUI( {
  if (exists(input$questObj)) {
    availQVars <- colnames(get(input$questObj))
    removeNotification('quest')
  } else {
    if (input$questObj != notSelOpt) {
      showNotification(paste0('No questionnaire available. (Check file "', basics$questsFile, '" or load object.) Error code #9.'), type = 'error', duration = 2, id = 'quest')
    }
    availQVars <- c()
  }
  selectizeInput('questVars', 'Variables', multiple = T, choices = availQVars, selected = availQVars[1:5])
})

procIsAllowed <- reactive( { 
  prereqsAreValid() &&
    choicesAreValid() && 
    !is.null( sourceObjs() )
} )
output$procIsAllowed <- reactive( { procIsAllowed() } )
outputOptions( output, 'procIsAllowed', suspendWhenHidden = FALSE)

####################
# allInputIsValid <- reactive( {
#   if( as.logical(input$normEnabled) )
#     input$nmeth != notSelOpt
#   else
#     TRUE
# } )
####################

output$procIsAllowed <- reactive( { 
  prereqsAreValid() && procIsAllowed() # && allInputIsValid()
})
outputOptions( output, 'procIsAllowed', suspendWhenHidden = FALSE)

# global variables for events
# normal variables
ts <- NULL
startTime <- NULL
origPairs <- NULL
# paths
procFolder <- NULL
tmpFolder <- NULL
tmpDataScriptVec <- NULL

# Info summary list
piplInfo <- reactiveValues(data = list(
  dNameStr="No dataset is chosen",
  origInfoStr=notProcMsg,
  outlierRemB=notEnablOpt,
  exclCCB=notEnablOpt,
  bCorrB=notEnablOpt,
  filterPStr=notEnablOpt,
  filterLimitStr=notEnablOpt,
  normMethodStr=notEnablOpt,
  questVarsStr=notEnablOpt,
  # reactive values for dynamic
  currSamples=notProcMsg,
  currFeatures=notProcMsg
))

# # Reactive optionsInfo 
# optionsInfo <- reactiveValues(data = list( # backbtn issue (save states, fast info updates)
# outlRemovalEn=FALSE,
# backgrCorrEn=FALSE,
# filt=FALSE,
# normEn=FALSE,
# questEn=FALSE
# ))

# Updating dataset information
output$infoVar <- renderText({ 
    piplInfo$dNameStr=ifelse(choicesAreValid(), input$dsg, "No dataset is chosen")
    piplInfo$origInfoStr=ifelse((input$designNext || input$designDown) && choicesAreValid() && !is.null(origPairs), 
      paste(origPairs[2], "samples with", origPairs[1], "features"), "Dataset not processed")
    piplInfo$outlierRemB=ifelse(input$outlierEnabled && outlFileExists(), "Enabled", notEnablOpt)
    piplInfo$exclCCB=ifelse(input$transEnabled && cctFileExists(), "Enabled", notEnablOpt)
    piplInfo$bCorrB=ifelse(input$corrEnabled,"Enabled", notEnablOpt)
    piplInfo$filterPStr=ifelse(input$filtEnabled, input$pval, notEnablOpt)
    piplInfo$filterLimitStr=ifelse(input$filtEnabled, input$plimit, notEnablOpt)
    piplInfo$normMethodStr=ifelse(methodIsValid(), as.character(input$nmeth), notEnablOpt) 
    piplInfo$questVarsStr=ifelse((input$questEnabled && input$questObj != notSelOpt && length(input$questVars) != 0), "Enabled", notEnablOpt)

    piplInfo$currFeatures=ifelse(piplInfo$currFeatures != notProcMsg && choicesAreValid(), piplInfo$currFeatures, notProcMsg)
    piplInfo$currSamples=ifelse(piplInfo$currSamples != notProcMsg && choicesAreValid(), piplInfo$currSamples, notProcMsg)

    paste0(
      "<hr>",
      "<b>", "Primary dataset information ", "</b>", "<br>",
      "Dataset: ", piplInfo$dNameStr, "<br>",
      piplInfo$origInfoStr, "<br>",
      "<hr>",
      "<b>", "Settings ", "</b>", "<br>", 
      "Outlier removal: ", piplInfo$outlierRemB, "<br>",
      "Exclude control-case transitions: ", piplInfo$exclCCB, "<br>",
      "Background correction: ", piplInfo$bCorrB, "<br>",
      "P value: ", piplInfo$filterPStr, "<br>",
      "Filtering limit: ", piplInfo$filterLimitStr, "<br>",
      "Normalization method: ", piplInfo$normMethodStr, "<br>",
      "Include questionnaire variables: ", piplInfo$questVarsStr, "<br>",
      "<hr>",
      "<b>", "Dataset properties after processing ", "</b>", "<br>",
      "<u>", "Samples", "</u>", ": ", piplInfo$currSamples, "<br>",
      "<u>", "Features", "</u>", ": ", piplInfo$currFeatures, "<br>",
      # Number of pairs((geneExpr + negCtlr)/2)
      "<hr>"
      )
})
