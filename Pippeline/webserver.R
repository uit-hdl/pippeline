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
    updateNavlistPanel( session, 'steps', selected = 'read')
  } )
  observeEvent( input$readReq, {
    updateNavlistPanel( session, 'steps', selected = 'design')
  } )
  observeEvent( input$readNext, {
    updateNavlistPanel( session, 'steps', selected = 'outliers')
  } )
  observeEvent( input$readDown, {
    updateNavlistPanel( session, 'steps', selected = 'download')
  } )
  observeEvent( input$outlierReq, {
    updateNavlistPanel( session, 'steps', selected = 'read')
  } )
  observeEvent( input$outlierNext, {
    updateNavlistPanel( session, 'steps', selected = 'corr')
  } )
  observeEvent( input$outlierDown, {
    updateNavlistPanel( session, 'steps', selected = 'download')
  } )
  observeEvent( input$corrReq, {
    updateNavlistPanel( session, 'steps', selected = 'read')
  } )
  observeEvent( input$corrNext, {
    updateNavlistPanel( session, 'steps', selected = 'filter')
  } )
  observeEvent( input$corrDown, {
    updateNavlistPanel( session, 'steps', selected = 'download')
  } )
  observeEvent( input$filtReq, {
    updateNavlistPanel( session, 'steps', selected = 'read')
  } )
  observeEvent( input$filtNext, {
    updateNavlistPanel( session, 'steps', selected = 'norm')
  } )
  observeEvent( input$filtDown, {
    updateNavlistPanel( session, 'steps', selected = 'download')
  } )
  observeEvent( input$normReq, {
    updateNavlistPanel( session, 'steps', selected = 'read')
  } )
  observeEvent( input$normNext, {
    updateNavlistPanel( session, 'steps', selected = 'quest')
  } )
  observeEvent( input$normDown, {
    updateNavlistPanel( session, 'steps', selected = 'download')
  } )
  observeEvent( input$questReq, {
    updateNavlistPanel( session, 'steps', selected = 'read')
  } )
  observeEvent( input$questNext, {
    updateNavlistPanel( session, 'steps', selected = 'download')
  } )
  observeEvent( input$downloadReq, {
    updateNavlistPanel( session, 'steps', selected = 'read')
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
  
  # fixme: data
  data <- eventReactive( input$read, {
    'fixme'
  } )
  # fixme: documentation
  
  # variables to pass to the client
  prereqsAreValid <- reactive( {
    input$author != '' && input$name != ''
  } )
  output$prereqsAreValid <- reactive( { 
    prereqsAreValid()
  } )
  outputOptions( output, 'prereqsAreValid', suspendWhenHidden = FALSE)
  choicesAreValid <- reactive( { 
    input$design != "design0" && input$loc != "loc0" && input$mat != "mat0" && input$ana != "ana0"
  } )
  output$choicesAreValid <- reactive( { 
    choicesAreValid()
  } )
  outputOptions( output, 'choicesAreValid', suspendWhenHidden = FALSE)
  output$procIsAllowed <- reactive( { 
    prereqsAreValid() && choicesAreValid() && !is.null( data() )
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