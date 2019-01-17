# Explicit events (in addition to reactive variables, see main.R)

# Initial tab status: block critical tabs
setTabInitialState(critTabsId)

# Initial button show/hide status
setBtnInitState()

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
    unlink(tmpFolder, recursive=TRUE)
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

# General tab observers - default transition events
observeEvent(input$steps, {
  if (input$steps == 'design') {
    resetStepsAndInfo() 
    showNotification("Resetting project options...", type='warning', duration=3)
  }
})

# Calculation using buttons and events
#-------------------------

# DESIGN events

observeEvent(input$designReq, {
  updateNavlistPanel(session, 'steps', selected = 'name')
})

observeEvent(input$designNext, {
  infoPairs <- interStepAndUpdate(tmpDataScriptVec)
  piplInfo$currFeatures <<- infoPairs[1]
  piplInfo$currSamples <<- infoPairs[2]
  origPairs <<- infoPairs

  updateNavlistPanel(session, 'steps', selected = 'outliers')
})

observeEvent(input$designDown, {
  # infoPairs <- interStepAndUpdate(tmpDataScriptVec)
  # piplInfo$currFeatures <<- infoPairs[1]
  # piplInfo$currSamples <<- infoPairs[2]
  # origPairs <<- infoPairs
  updateNavlistPanel(session, 'steps', selected = 'process')
})


# OUTLIER events

# <Apply> observe event
observeEvent(input$outlierApply, {

  applyAction <- function() {
    # Perform anaisys
    infoPairs <- interStepAndUpdate(tmpDataScriptVec)
    piplInfo$currFeatures <<- infoPairs[1]
    piplInfo$currSamples <<- infoPairs[2]
    # Show "continue/tofinal" buttons
    shinyjs::show("outlierNext")
    shinyjs::show("outlierDown")
    shinyjs::hide("outlierSkip")
    shinyjs::hide("outlierApply")
  }

  outlierStatus <- (input$outlierEnabled && input$outlierFile != notSelOpt && outlFileExists()) || !input$outlierEnabled
  transStatus <- (input$transEnabled && input$cctFile != notSelOpt && cctFileExists()) || !input$transEnabled 
  if (outlierStatus && transStatus) applyAction()
})

# <Skip> observe event
observeEvent(input$outlierSkip, {
  # Reset current tab
  reset ('outlierEnabled')
  reset ('outlierFile')
  reset ('outlierFileReport')
  reset ('transEnabled')
  reset ('cctFile')
  reset ('transFileReport')
  shinyjs::show("outlierNext")
  shinyjs::hide("outlierApply")
  updateTextAreaInput(session, "outlierDescr", value = '')

  # Move to the next tab
  updateNavlistPanel(session, 'steps', selected = 'corr')
})

# <Continue> observe event
observeEvent(input$outlierNext, {
  # Move to the next tab
  updateNavlistPanel(session, 'steps', selected = 'corr')
})

# <To final> observe event
observeEvent(input$outlierDown, {
  # Move to the last tab
  updateNavlistPanel(session, 'steps', selected = 'process')
})

# <Changes on page> observe event
observeEvent({
  input$outlierEnabled
  input$outlierFile
  input$transEnabled
  input$cctFile
  }, {
    # Show "apply/skip" buttons
    shinyjs::hide("outlierNext")
    shinyjs::hide("outlierDown")
    # shinyjs::show("outlierSkip")
    shinyjs::show("outlierApply")
  }
)

observeEvent(input$outlierReq, {
  updateNavlistPanel(session, 'steps', selected = 'design')
})

# observeEvent(input$outlierBack, {
#   updateNavlistPanel(session, 'steps', selected = 'design')
# })


# BackgrCorr events

# <Apply> observe event
observeEvent(input$corrApply, {

  applyAction <- function() {
    # Perform anaisys
    infoPairs <- interStepAndUpdate(tmpDataScriptVec)
    piplInfo$currFeatures <<- infoPairs[1]
    piplInfo$currSamples <<- infoPairs[2]
    # Show "continue/tofinal" buttons
    shinyjs::show("corrNext")
    shinyjs::show("corrDown")
    shinyjs::hide("corrSkip")
    shinyjs::hide("corrApply")
  }

  corrStatus <- input$corrEnabled || !input$corrEnabled
  if (corrStatus) applyAction()
})

# <Skip> observe event
observeEvent(input$corrSkip, {
  # Reset current tab
  reset ('corrEnabled')
  shinyjs::show("corrNext")
  shinyjs::hide("corrApply")
  # Move to the next tab
  updateNavlistPanel(session, 'steps', selected = 'filter')
})

# <Continue> observe event
observeEvent(input$corrNext, {
  # Move to the next tab
  updateNavlistPanel(session, 'steps', selected = 'filter')
})

# <To final> observe event
observeEvent(input$corrDown, {
  # Move to the last tab
  updateNavlistPanel(session, 'steps', selected = 'process')
})

# <Changes on page> observe event
observeEvent({
  input$corrEnabled
  }, {
    # Show "apply/skip" buttons
    shinyjs::hide("corrNext")
    shinyjs::hide("corrDown")
    # shinyjs::show("corrSkip")
    shinyjs::show("corrApply")
  }
)

observeEvent(input$corrReq, {
  updateNavlistPanel(session, 'steps', selected = 'design')
})

observeEvent(input$corrBack, {
  updateNavlistPanel(session, 'steps', selected = 'outliers')
})


# Filter events

# <Apply> observe event
observeEvent(input$filtApply, {

  applyAction <- function() {
    # Perform anaisys
    infoPairs <- interStepAndUpdate(tmpDataScriptVec)
    piplInfo$currFeatures <<- infoPairs[1]
    piplInfo$currSamples <<- infoPairs[2]
    # Show "continue/tofinal" buttons
    shinyjs::show("filtNext")
    shinyjs::show("filtDown")
    shinyjs::hide("filtSkip")
    shinyjs::hide("filtApply")
  }

  filtStatus <- input$filtEnabled || !input$filtEnabled
  if (filtStatus) {
    applyAction()
  }
})

# <Skip> observe event
observeEvent(input$filtSkip, {
  # Reset current tab
  reset ('filtEnabled')
  shinyjs::show("filtNext")
  shinyjs::hide("filtApply")
  # Move to the next tab
  updateNavlistPanel(session, 'steps', selected = 'norm')
})

# <Continue> observe event
observeEvent(input$filtNext, {
  # Move to the next tab
  updateNavlistPanel(session, 'steps', selected = 'norm')
})

# <To final> observe event
observeEvent(input$filtDown, {
  # Move to the last tab
  updateNavlistPanel(session, 'steps', selected = 'process')
})

# <Changes on page> observe event
observeEvent({
  input$filtEnabled
  input$pval
  input$plimit
  }, {
    # Show "apply/skip" buttons
    shinyjs::hide("filtNext")
    shinyjs::hide("filtDown")
    # shinyjs::show("filtSkip")
    shinyjs::show("filtApply")
  }
)

observeEvent(input$filtReq, {
  updateNavlistPanel(session, 'steps', selected = 'design')
})

observeEvent(input$filtBack, {
  updateNavlistPanel(session, 'steps', selected = 'corr')
})


# NORMALIZATION events

# <Apply> observe event
observeEvent(input$normApply, {

  applyAction <- function() {
    # Perform anaisys
    infoPairs <- interStepAndUpdate(tmpDataScriptVec)
    piplInfo$currFeatures <<- infoPairs[1]
    piplInfo$currSamples <<- infoPairs[2]
    # Show "continue/tofinal" buttons
    shinyjs::show("normNext")
    shinyjs::show("normDown")
    shinyjs::hide("normSkip")
    shinyjs::hide("normApply")
  }

  # normStatus <- FALSE
  # if (input$nmeth == 'vstQuantileNorm') normStatus <- (input$normEnabled && input$nmeth != notSelOpt) || !input$normEnabled
  # if (input$nmeth == 'ComBat') normStatus <- 
  #   (input$normEnabled && input$nmeth != notSelOpt && input$batchTab != notSelOpt && input$batchVar != notSelOpt) || !input$normEnabled
  # if (normStatus) applyAction()
  if (methodIsValid()) applyAction()
})

# <Skip> observe event
observeEvent(input$normSkip, {
  # Reset current tab
  reset ('normEnabled')
  reset ('nmeth')
  reset ('batchTab')
  reset ('batchSampleID')
  reset ('batchVar')
  shinyjs::show("normNext")
  shinyjs::hide("normApply")

  # Move to the next tab
  updateNavlistPanel(session, 'steps', selected = 'quest')
})

# <Continue> observe event
observeEvent(input$normNext, {
  # Move to the next tab
  updateNavlistPanel(session, 'steps', selected = 'quest')
})

# <To final> observe event
observeEvent(input$normDown, {
  # Move to the last tab
  updateNavlistPanel(session, 'steps', selected = 'process')
})

# <Changes on page> observe event
observeEvent({
  input$normEnabled
  input$nmeth
  input$batchTab
  input$batchSampleID
  input$batchVar
  input$batchSampleID
  }, {
    # Show "apply/skip" buttons
    shinyjs::hide("normNext")
    shinyjs::hide("normDown")
    # shinyjs::show("normSkip")
    shinyjs::show("normApply")
  }
)

# Populating batchTab
observeEvent(input$nmeth, {
  if (input$steps == 'norm' && input$nmeth == 'ComBat') {
    btchtab <<- c(notSelOpt, getPkgDataSetNames('nowac'))
    updateSelectInput(session, "batchTab", choices = btchtab, selected = notSelOpt)
  }
})

# Populating batchVar
observeEvent(input$batchTab, {
  if (input$batchTab != notSelOpt) btchvar <<- c(btchvar, getDSColNames(input$batchTab))
  else btchvar <<- c(notSelOpt)
  updateSelectInput(session, "batchVar", choices = btchvar, selected = notSelOpt)
})

# Populating batchSampleID
observeEvent(input$batchTab, {
  if (input$batchTab != notSelOpt) btchvar <<- c(btchvar, getDSColNames(input$batchTab))
  else btchvar <<- c(notSelOpt)
  updateSelectInput(session, "batchSampleID", choices = btchvar, selected = notSelOpt)
})

observeEvent(input$normReq, {
  updateNavlistPanel(session, 'steps', selected = 'design')
})

observeEvent(input$normBack, {
  updateNavlistPanel(session, 'steps', selected = 'filter')
})


# Questionairee events

# <Apply> observe event
observeEvent(input$questApply, {

  applyAction <- function() {
    # Perform anaisys
    infoPairs <- interStepAndUpdate(tmpDataScriptVec)
    piplInfo$currFeatures <<- infoPairs[1]
    piplInfo$currSamples <<- infoPairs[2]
    # Show "continue/tofinal" buttons
    shinyjs::show("questNext")
    shinyjs::hide("questSkip")
    shinyjs::hide("questApply")
  }

  questStatus <- (input$questEnabled && input$questObj != notSelOpt && length(input$questVars)>0) || !input$questEnabled
  if (questStatus) applyAction()
})

# <Skip> observe event
observeEvent(input$questSkip, {
  # Reset current tab
  reset ('questEnabled')
  reset ('questObj')
  reset ('questVars')

  shinyjs::show("questNext")
  shinyjs::hide("questApply")

  # Move to the next tab
  updateNavlistPanel(session, 'steps', selected = 'process')
})

# <Continue> observe event
observeEvent(input$questNext, {
  # Move to the next tab
  updateNavlistPanel(session, 'steps', selected = 'process')
})

# <Changes on page> observe event
observeEvent({
  input$questEnabled
  input$questObj
  input$questVars
  }, {
    # Show "apply/skip" buttons
    shinyjs::hide("questNext")
    # shinyjs::show("questSkip")
    shinyjs::show("questApply")
  }
)

observeEvent(input$questReq, {
  updateNavlistPanel(session, 'steps', selected = 'design')
})

observeEvent(input$questBack, {
  updateNavlistPanel(session, 'steps', selected = 'norm')
})

# # Processing state

# observeEvent(input$steps, {
#   if (input$steps == 'process') {
#     infoPairs <- interStepAndUpdate(tmpDataScriptVec)
#     piplInfo$currFeatures <<- infoPairs[1]
#     piplInfo$currSamples <<- infoPairs[2]
#     if (input$designDown) origPairs <<- infoPairs
#   }
# }
# #-------------------------

observeEvent(input$processReq, {
  updateNavlistPanel(session, 'steps', selected = 'name')
})

observeEvent(input$processBack, {
  updateNavlistPanel(session, 'steps', selected = 'quest')
})

observeEvent(input$newStart, {
  updateSelectInput(session, "dsg", selected = notSelOpt)
  updateSelectInput(session, "loc", selected = notSelOpt)
  updateSelectInput(session, "mat", selected = notSelOpt)
  updateSelectInput(session, "ana", selected = notSelOpt)

  resetStepsAndInfo()
  # TODO: check cleaning
  rm (list = ls())
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
    unlink(tmpFolder, recursive=TRUE)
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
    
    procFolder <<- gsub('//', '/', file.path(pipProjects, paste0(input$projname, '-', format(startTime, "%d%m%Y-%H%M%OS3"))))
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
      # Copy outliers report
      if (file.exists(file.path(nowacleanReports, input$outlierFileReport)) && input$outlierFileReport != notSelOpt && input$outlierEnabled) {
        reportFile <- file.path(nowacleanReports, input$outlierFileReport)
        file.copy(reportFile, file.path(tmpDir, input$outlierFileReport))
      }

      # Copy transitions report
      if (file.exists(file.path(cctransReports, input$transFileReport)) && input$transFileReport != notSelOpt && input$transEnabled) {
        reportFile <- file.path(cctransReports, input$transFileReport)
        file.copy(reportFile, file.path(tmpDir, input$transFileReport))
      }

      writeScript(pipeline, scriptFile)
      render(scriptFile, paste0(basics$docFormat, '_document'), docFile, quiet = TRUE)
      #render( scriptFile)
      #showNotification('Successful render', scriptFile, type='message', duration = NULL)

      removeNotification('wait')
      showNotification('All files successfully written.', type = 'message', duration = NULL)
      
    }, error = function(err){
      removeNotification('wait')
      showNotification('Could not produce data/documentation. (Error while sourcing script.) Error code #3.', type = 'error', duration = NULL)
      showNotification('Error info: ', toString(err), type = 'error', duration = NULL)
    })
    
    # tryCatch({
    #   unlink(tmpFolder, recursive=TRUE) 
    # }, warning = function(wrn){
    #   NULL
    # })

    # Create git repo
    tryCatch({
      setwd(tmpDir)
      system('git init')
      system('git add .')
      system(sprintf("git commit -m'%s'", paste0("First commit for pippelinen repo - ", format(startTime, "%d%m%Y-%H%M%OS3"))))

      print (tmpDir)
      # Add R-project file?
     }, warning = function(wrn) {
      NULL
    })

    showNotification('Process ended.')
})

