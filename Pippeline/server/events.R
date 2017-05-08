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
  updateNavlistPanel( session, 'steps', selected = 'download')
} )
observeEvent( input$outlierReq, {
  updateNavlistPanel( session, 'steps', selected = 'design')
} )
observeEvent( input$outlierNext, {
  updateNavlistPanel( session, 'steps', selected = 'corr')
} )
observeEvent( input$outlierDown, {
  updateNavlistPanel( session, 'steps', selected = 'download')
} )
observeEvent( input$corrReq, {
  updateNavlistPanel( session, 'steps', selected = 'design')
} )
observeEvent( input$corrNext, {
  updateNavlistPanel( session, 'steps', selected = 'filter')
} )
observeEvent( input$corrDown, {
  updateNavlistPanel( session, 'steps', selected = 'download')
} )
observeEvent( input$filtReq, {
  updateNavlistPanel( session, 'steps', selected = 'design')
} )
observeEvent( input$filtNext, {
  updateNavlistPanel( session, 'steps', selected = 'norm')
} )
observeEvent( input$filtDown, {
  updateNavlistPanel( session, 'steps', selected = 'download')
} )
observeEvent( input$normReq, {
  updateNavlistPanel( session, 'steps', selected = 'design')
} )
observeEvent( input$normNext, {
  updateNavlistPanel( session, 'steps', selected = 'quest')
} )
observeEvent( input$normDown, {
  updateNavlistPanel( session, 'steps', selected = 'download')
} )
observeEvent( input$questReq, {
  updateNavlistPanel( session, 'steps', selected = 'design')
} )
observeEvent( input$questNext, {
  updateNavlistPanel( session, 'steps', selected = 'download')
} )
observeEvent( input$downloadReq, {
  updateNavlistPanel( session, 'steps', selected = 'name')
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

# download (assembly, computation, documentation)
output$download <- downloadHandler(
  # setting the filename works currently only when run in an external browser window, 
  # but not in Rstudio window/viewer pane
  filename = function() {
    # timestamp
    ts <<- Sys.time()
    paste0( basics$appName, '-', format( ts, '%Y-%m-%d_%H-%M-%S'), '.zip')  # archive
  },
  content = function( arFile) {
    # point out 3 files to be zipped together
    dir <- tempdir()
    scriptFile <- file.path( dir, 'pipeline.R')
    dataFile <- file.path( dir, 'data.csv')
    docFile <- file.path( dir, paste0( 'pipeline.', basics$docFormat) )  # documentation
    pipeline <- generatePipeline( list(
      sourceFiles = sourceFiles(),
      targetFile = dataFile
    ) )
    # fill files with content
    writeScript( pipeline, scriptFile)
    #produceDocumenationAndData( scriptFile, docFile) fixme
#    files <- c( scriptFile, docFile, dataFile) fixme
    # now create archive
    files <- c( scriptFile)
    zip( arFile, files, '-j')  # only files, no directories fixme?: move zipping into script
  }
)