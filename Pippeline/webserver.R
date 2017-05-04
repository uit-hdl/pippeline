server <- function( input, output, session) {
  # navigation buttons bindings
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
    updateNavlistPanel( session, 'steps', selected = 'design')
  } )
  observeEvent( input$quit, {
    showModal( modalDialog(
      title = 'Quit',
      paste0( 'Really quit ', appName, '?'),
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
  
  # helper functions
  getDataFiles <- function() {
    row <- which( ( options[ , 'Design'] == input$dsg &
                      options[ , 'Location'] == input$loc &
                      options[ , 'Material'] == input$mat &
                      options[ , 'Analysis'] == input$ana ) )
    if( row < 1) {
      showNotification( 'No data found. (Check file with available options?) Error code #1.', type = 'error')
      return( NULL)
    }
    ## fixme: trengs Subfile?
    files <- as.vector( unname( unlist( options[ row, c( 'File1', 'File2', 'File3') ] ) ) )
    files <- files[ files != '']
    areReadable = ( file.access( files, 4) > -1)
    if( sum( areReadable) != length( areReadable) ) {
      showNotification( 'Data source not readable. (Check file with available options?) Error code #2.', type = 'error')
      return( NULL)
    }
    return( files)
  } # function getDataFiles

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
}