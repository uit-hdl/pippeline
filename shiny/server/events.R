# explicite events (in addition to reactive variables, see main.R)

# navigation buttons bindings and event handling
observeEvent( input$aboutNext, {
  updateNavlistPanel( session, 'steps', selected = 'name')
} )
observeEvent( input$nameNext, {
  updateNavlistPanel( session, 'steps', selected = 'design')
} )
observeEvent( input$designReq, {
  updateNavlistPanel( session, 'steps', selected = 'name')
} )
observeEvent( input$designNext, {
  updateNavlistPanel( session, 'steps', selected = 'outliers')
} )
observeEvent( input$designDown, {
  updateNavlistPanel( session, 'steps', selected = 'process')
} )
observeEvent( input$outlierReq, {
  updateNavlistPanel( session, 'steps', selected = 'design')
} )
observeEvent( input$outlierNext, {
  updateNavlistPanel( session, 'steps', selected = 'corr')
} )
observeEvent( input$outlierDown, {
  updateNavlistPanel( session, 'steps', selected = 'process')
} )
observeEvent( input$corrReq, {
  updateNavlistPanel( session, 'steps', selected = 'design')
} )
observeEvent( input$corrNext, {
  updateNavlistPanel( session, 'steps', selected = 'filter')
} )
observeEvent( input$corrDown, {
  updateNavlistPanel( session, 'steps', selected = 'process')
} )
observeEvent( input$filtReq, {
  updateNavlistPanel( session, 'steps', selected = 'design')
} )
observeEvent( input$filtNext, {
  updateNavlistPanel( session, 'steps', selected = 'norm')
} )
observeEvent( input$filtDown, {
  updateNavlistPanel( session, 'steps', selected = 'process')
} )
observeEvent( input$normReq, {
  updateNavlistPanel( session, 'steps', selected = 'design')
} )
observeEvent( input$normNext, {
  updateNavlistPanel( session, 'steps', selected = 'quest')
} )
observeEvent( input$normDown, {
  updateNavlistPanel( session, 'steps', selected = 'process')
} )
observeEvent( input$questReq, {
  updateNavlistPanel( session, 'steps', selected = 'design')
} )
observeEvent( input$questNext, {
  updateNavlistPanel( session, 'steps', selected = 'process')
} )
observeEvent( input$processReq, {
  updateNavlistPanel( session, 'steps', selected = 'name')
  } )
observeEvent( input$wantGenes, {
  if( as.logical(input$wantGenes) &&
      !as.logical(input$normEnabled) ) 
  showNotification( 'Conversion to samples implies taking the average of multiple probes. You may thus want to consider to enable normalization.', type = 'warning')
} )

# quit
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
} )
observeEvent( input$reallyQuit, {
  js$closeWindow()
  stopApp()
} )
session$onSessionEnded( stopApp)

# produce and save (assembly, computation, documentation)
observeEvent( input$process, {
  # setting the filename works currently only when run in an external browser window, 
  # but not in Rstudio window/viewer pan
    ts <<- Sys.time()
    showNotification( 'Processing. This may take some time. Please stand by ..', duration = NULL, id = 'wait')  
    
    # make directory according to jobID (can be SLURM_JOBID)
    jobid <- Sys.getenv("SLURM_JOB_ID")
    jobDir <- gsub('//', '/', file.path( '/project/tice/pippelinen', jobid, paste0( basics$appName, '-', format( ts, "%d%m%Y-%H%M%OS3") ) ) )
    #jobDir <- file.path( '/project/tice/pippelinen', jobid, paste0( basics$appName, '-', as.numeric( as.POSIXct ( ts) ) )

    # make temporary directory
    tmpDir <- file.path( tempdir(), paste0( basics$appName, '-', format( ts, "%d%m%Y%H%M%OS3") ) )
   
    #tmpDir <- file.path( tempdir(), paste0( basics$appName, '-', as.numeric( as.POSIXct( ts) ) ) )
    tmpDirOld <- tmpDir
    tmpDir <- jobDir

    dir.create( tmpDir, recursive=TRUE)
    scriptFile <- file.path( tmpDir, 'pipeline.R')
    dataFile <- file.path( tmpDir, 'data.rds')
    docFile <- file.path( tmpDir, paste0( 'documentation.', basics$docFormat) )  # documentation

    pipeline <- generatePipeline( list(
      sourceObjs = sourceObjs(),
      targetFile = dataFile
    ) )
    # fill files with content
    tryCatch( {
      writeScript( pipeline, scriptFile)
      render( scriptFile, paste0( basics$docFormat, '_document'), docFile, quiet = TRUE)
      #render( scriptFile)
      #showNotification('Successful render', scriptFile, type='message', duration = NULL)
      removeNotification( 'wait')
      showNotification( 'All files successfully written.', type = 'message', duration = NULL)
    }, error = function( err){
      removeNotification( 'wait')
      showNotification( 'Could not produce data/documentation. (Error while sourcing script.) Error code #3.', type = 'error', duration = NULL)
      showNotification( 'Error info: ', toString(err), type = 'error', duration = NULL)
    } )

    showNotification( 'Process ended.')
    }
)
