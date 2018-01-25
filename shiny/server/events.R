# Explicit events (in addition to reactive variables, see main.R)

# Initial tab status: block critical tabs
setTabInitialState(critTabsId)

# Navigation buttons bindings and event handling

observeEvent(input$aboutNext, {
  updateNavlistPanel(session, 'steps', selected = 'name')
} )

observeEvent(input$descrNext, {
  updateNavlistPanel(session, 'steps', selected = 'design')
  startTime <<- Sys.time()
  tmpFolder <<- gsub('//', '/', file.path(pipFolder, tempdir()))
  tmpDataScriptVec <<- c(file.path(tmpFolder, 'tmpData.rds'), file.path(tmpFolder, 'tmpPipeline.R'))

  tryCatch({
    unlink(file.path(tmpFolder), recursive=TRUE)
    showNotification('Cleaned old folder.', type = 'warning', duration = 4)
  }, warning = function(wrn){
    NULL
  })
  
  tryCatch({
    dir.create(tmpFolder, recursive=TRUE)
    showNotification('Temporary files will be written to: ', toString(tmpFolder), type = 'message', duration = 8)
  }, warning = function(wrn){
    NULL
  })
})

# Design tab observer for reset
observeEvent(input$steps, {
  if (input$steps == 'design'){
    resetCheckboxValues() 
    showNotification("Resetting project options...", type='warning', duration=3)
  }
})

# Design
observeEvent(input$designReq, {
  updateNavlistPanel(session, 'steps', selected = 'name')
})

observeEvent(input$designNext, {
  # info update
  infoPairs <- interStepAndUpdate(tmpDataScriptVec)
  piplInfo$currFeatures <<- infoPairs[1]
  piplInfo$currSamples <<- infoPairs[2]
  origPairs <<- infoPairs

  updateNavlistPanel(session, 'steps', selected = 'outliers')
})

observeEvent(input$designDown, {
  # info update
  infoPairs <- interStepAndUpdate(tmpDataScriptVec)
  piplInfo$currFeatures <<- infoPairs[1]
  piplInfo$currSamples <<- infoPairs[2]
  origPairs <<- infoPairs
  
  updateNavlistPanel(session, 'steps', selected = 'process')
})

# Outlier
observeEvent(input$outlierReq, {
  updateNavlistPanel(session, 'steps', selected = 'design')
})

observeEvent(input$outlierSkip, {
  updateNavlistPanel(session, 'steps', selected = 'corr')
})

# observeEvent(input$outlierBack, {
#   updateNavlistPanel(session, 'steps', selected = 'design')
# })

observeEvent(input$outlierNext,{
  # info update
  infoPairs <- interStepAndUpdate(tmpDataScriptVec)
  piplInfo$currFeatures <<- infoPairs[1]
  piplInfo$currSamples <<- infoPairs[2]

  updateNavlistPanel(session, 'steps', selected = 'corr')
})

observeEvent(input$outlierDown, {
  # info update
  infoPairs <- interStepAndUpdate(tmpDataScriptVec)
  piplInfo$currFeatures <<- infoPairs[1]
  piplInfo$currSamples <<- infoPairs[2]

  updateNavlistPanel(session, 'steps', selected = 'process')
})

# Background correction
observeEvent(input$corrReq, {
  updateNavlistPanel(session, 'steps', selected = 'design')
})

observeEvent(input$corrSkip, {
  updateNavlistPanel(session, 'steps', selected = 'filter')
})

observeEvent(input$corrBack, {
  updateNavlistPanel(session, 'steps', selected = 'outliers')
})

observeEvent(input$corrNext, {
  # info update
  infoPairs <- interStepAndUpdate(tmpDataScriptVec)
  piplInfo$currFeatures <<- infoPairs[1]
  piplInfo$currSamples <<- infoPairs[2]

  updateNavlistPanel(session, 'steps', selected = 'filter')
})

observeEvent(input$corrDown, {
  # info update
  infoPairs <- interStepAndUpdate(tmpDataScriptVec)
  piplInfo$currFeatures <<- infoPairs[1]
  piplInfo$currSamples <<- infoPairs[2]

  updateNavlistPanel(session, 'steps', selected = 'process')
})

# Filtering
observeEvent(input$filtReq, {
  updateNavlistPanel(session, 'steps', selected = 'design')
})

observeEvent(input$filtSkip, {
  updateNavlistPanel(session, 'steps', selected = 'norm')
})

observeEvent(input$filtBack, {
  updateNavlistPanel(session, 'steps', selected = 'corr')
})

observeEvent(input$filtNext, {
  # info update
  infoPairs <- interStepAndUpdate(tmpDataScriptVec)
  piplInfo$currFeatures <<- infoPairs[1]
  piplInfo$currSamples <<- infoPairs[2]

  updateNavlistPanel(session, 'steps', selected = 'norm')
})
observeEvent(input$filtDown, {
  # info update
  infoPairs <- interStepAndUpdate(tmpDataScriptVec)
  piplInfo$currFeatures <<- infoPairs[1]
  piplInfo$currSamples <<- infoPairs[2]

  updateNavlistPanel(session, 'steps', selected = 'process')
})

# Normalization
observeEvent(input$normReq, {
  updateNavlistPanel(session, 'steps', selected = 'design')
})

observeEvent(input$normSkip, {
  updateNavlistPanel(session, 'steps', selected = 'quest')
})

observeEvent(input$normBack, {
  updateNavlistPanel(session, 'steps', selected = 'filter')
})

observeEvent(input$normNext, {
  # info update
  infoPairs <- interStepAndUpdate(tmpDataScriptVec)
  piplInfo$currFeatures <<- infoPairs[1]
  piplInfo$currSamples <<- infoPairs[2]

  updateNavlistPanel(session, 'steps', selected = 'quest')
})

observeEvent(input$normDown, {
  # info update
  infoPairs <- interStepAndUpdate(tmpDataScriptVec)
  piplInfo$currFeatures <<- infoPairs[1]
  piplInfo$currSamples <<- infoPairs[2]

  updateNavlistPanel(session, 'steps', selected = 'process')
})

# Questionaries
observeEvent(input$questReq, {

  updateNavlistPanel(session, 'steps', selected = 'design')
})

observeEvent(input$questSkip, {
  updateNavlistPanel(session, 'steps', selected = 'process')
})

observeEvent(input$questBack, {
  updateNavlistPanel(session, 'steps', selected = 'norm')
})

observeEvent(input$questNext, {
  # info update
  infoPairs <- interStepAndUpdate(tmpDataScriptVec)
  piplInfo$currFeatures <<- infoPairs[1]
  piplInfo$currSamples <<- infoPairs[2]

  updateNavlistPanel(session, 'steps', selected = 'process')
})

# Process
observeEvent(input$processReq, {
  updateNavlistPanel(session, 'steps', selected = 'name')
})

observeEvent(input$processBack, {
  updateNavlistPanel(session, 'steps', selected = 'quest')
})

observeEvent(input$newStart, {
  resetStepsAndInfo()
  updateNavlistPanel(session, 'steps', selected = 'name')
})

observeEvent(input$wantGenes, {
  if(as.logical(input$wantGenes) &&
      !as.logical(input$normEnabled)) 
  showNotification('Conversion to samples implies taking the average of multiple probes. 
    You may thus want to consider to enable normalization.', type = 'warning')
})

# Quit
observeEvent( input$quit, {
  showModal( modalDialog(
    title = 'Quit',
    paste0( 'Really quit ', basics$appName, '?'),
    size = 's',
    footer = tagList(
      actionButton( 'reallyQuit', 'Yes, quit'),
      modalButton( 'No, continue')
    )
  ) )
})

observeEvent(input$reallyQuit, {
  tryCatch({
    unlink(file.path(tmpFolder), recursive=TRUE)
  }, warning = function(wrn){
    NULL
  })
  js$closeWindow()
  stopApp()
})

session$onSessionEnded(stopApp)

# produce and save (assembly, computation, documentation)
observeEvent(input$process, {
  # setting the filename works currently only when run in an external browser window, 
  # but not in Rstudio window/viewer pan
    ts <<- Sys.time()
    showNotification('Processing. This may take some time. Please stand by ..', duration = NULL, id = 'wait')  
    
    procFolder <<- gsub('//', '/', file.path(pipFolder, paste0(basics$appName, '-', input$projname, '-', format(startTime, "%d%m%Y-%H%M%OS3"))))
    dir.create(procFolder, recursive=TRUE)

    tmpDir <- procFolder
    scriptFile <- file.path(tmpDir, 'pipeline.R')
    dataFile <- file.path(tmpDir, 'data.rds')
    docFile <- file.path(tmpDir, paste0( 'documentation.', basics$docFormat) )  # documentation

    pipeline <- generatePipeline(list(
      sourceObjs = sourceObjs(),
      targetFile = dataFile
    ))
    # fill files with content
    tryCatch({
      writeScript(pipeline, scriptFile)
      render(scriptFile, paste0(basics$docFormat, '_document'), docFile, quiet = TRUE)
      #render( scriptFile)
      #showNotification('Successful render', scriptFile, type='message', duration = NULL)

      # Copy outliers report
      if (file.exists(file.path(nowacleanFolder, input$outlierFileReport)) && input$outlierFileReport != notSelOpt && input$outlierEnabled) {
        reportFile <<- file.path(nowacleanFolder, input$outlierFileReport)
        file.copy(reportFile, file.path(tmpDir, input$outlierFileReport))
      }

      removeNotification('wait')
      showNotification('All files successfully written.', type = 'message', duration = 8)
      
    }, error = function(err){
      removeNotification('wait')
      showNotification('Could not produce data/documentation. (Error while sourcing script.) Error code #3.', type = 'error', duration = NULL)
      showNotification('Error info: ', toString(err), type = 'error', duration = NULL)
    })
    
    # tryCatch({
    #   unlink(file.path(tmpFolder), recursive=TRUE) 
    # }, warning = function(wrn){
    #   NULL
    # })

    showNotification('Process ended.')
})

