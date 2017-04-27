# This is the app wrapper which invokes both the server and client scripts.

# includes
library(shiny)
library(shinyjs)

# globals
appName <- 'Pippeline' # fixme: needed?
procMsg = 'First, you need to enter basic information, make your choices, and read in the data.'

# UI elements
aboutTab <- list( 
  h2( 'About'),
  p( 'This is Pippeline, a pipeline for processing high-dimensional multi-omics biobank datasets.'),
  p( 'Navigate by following buttons/links, or pick an item from the list of processing steps.'),
  hr(),
  actionButton( 'aboutNext', label = 'Continue') 
)
nameTab <- list( 
  h2( 'Naming'),
  p( 'Please enter the basic information below.'),
  textInput( inputId = 'author', label = 'Your name/initals', value = 'tha'), # fixme
  textInput( inputId = 'name', label = 'Pipeline name', value = 'foo'), # fixme
  textAreaInput( inputId = 'descr', label = 'Description of processing (optional)', value = ''),
  hr(),
  conditionalPanel( 
    condition = 'output.prereqsAreValid',
    actionButton( 'nameNext', label = 'Continue') 
  )
)
designTab <- list( 
  conditionalPanel( 
    condition = '!output.prereqsAreValid',
    p( 'First you must provide some basic information.'),
    actionButton( 'designReq', label = 'Go there') 
  ),
  conditionalPanel( 
    condition = 'output.prereqsAreValid',
    h2( 'Basic choices'),
    p( 'Please select a design and make your choices.'),
    selectInput( inputId = 'design', label = 'Design', selected = 'design1', choices = c( # fixme
      'Not selected' = 'design0',
      'Design 1' = 'design1',
      'Design 2' = 'design2',
      'Design 3' = 'design3'
    ) ),
    selectInput( 'loc', label = 'Probe location', selected = 'loc2', choices = c( # fixme
      'Not selected' = 'loc0',
      'Location 1' = 'loc1',
      'Location 2' = 'loc2',
      'Location 3' = 'loc3'
    ) ),
    selectInput( 'mat', label = 'Biological material', selected = 'mat3', choices = c( # fixme
      'Not selected' = 'mat0',
      'Material 1' = 'mat1',
      'Material 2' = 'mat2',
      'Material 3' = 'mat3'
    ) ),
    selectInput( 'ana', label = 'Genomic analysis', selected = 'ana1', choices = c( # fixme
      'Not selected' = 'ana0',
      'Analysis 1' = 'ana1',
      'Analysis 2' = 'ana2',
      'Analysis 3' = 'ana3'
    ) ),
    checkboxInput( 'trans', label = 'Exclude control-case transitions', value = T),
    hr(),
    conditionalPanel( 
      condition = 'output.choicesAreValid',
      actionButton( 'designNext', label = 'Continue')
    )
  )
)
readTab = list(
  conditionalPanel( 
    condition = '!output.prereqsAreValid || !output.choicesAreValid',
    p( 'First, you need to enter basic information and make your choices.'),
    actionButton( 'readReq', label = 'Go there') 
  ),
  conditionalPanel( 
    condition = 'output.prereqsAreValid && output.choicesAreValid',
    h2( 'Input'),
    p( 'Here you can read in the data based on your previous choices.'),
    actionButton( 'read', label = 'Read in data'),
    br(), br(),
    conditionalPanel( 
      condition = '!output.procIsAllowed',
      p( 'No data available so far.')
    ),
    conditionalPanel( 
      condition = 'output.procIsAllowed',
      p( 'Data successfully read and available for further processing or immediate download.'),
      hr(),
      actionButton( 'readNext', label = 'Continue'),
      span( 'or', class='or'),
      actionLink( 'readDown', 'download')
    )
  )
)
outlierTab = list(
  conditionalPanel( 
    condition = '!output.procIsAllowed',
    p( procMsg),
    actionButton( 'outlierReq', label = 'Go there') 
  ),
  conditionalPanel( 
    condition = 'output.procIsAllowed',
    list( 
      h2( 'Outlier removal'),
      p( 'Here you can delete outliers from the dataset.'),
      checkboxInput( 'outlierEnabled', 'Enabled'),
      conditionalPanel(
        condition = 'input.outlierEnabled',
        p( 'Fixme')
      ),
      hr(),
      actionButton( 'outlierNext', label = 'Continue'),
      span( 'or', class='or'),
      actionLink( 'outlierDown', 'download')
    )
  )
)
corrTab = list(
  conditionalPanel( 
    condition = '!output.procIsAllowed',
    p( procMsg),
    actionButton( 'corrReq', label = 'Go there') 
  ),
  conditionalPanel( 
    condition = 'output.procIsAllowed',
    list( 
      h2( 'Background correction'),
      p( 'Here you can do a background correction by means of negative control probes.'),
      checkboxInput( 'corrEnabled', 'Enabled'),
      conditionalPanel(
        condition = 'input.corrEnabled',
        p( 'Fixme')
      ),
      hr(),
      actionButton( 'corrNext', label = 'Continue'),
      span( 'or', class='or'),
      actionLink( 'corrDown', 'download')
    )
  )
)
filterTab = list(
  conditionalPanel( 
    condition = '!output.procIsAllowed',
    p( procMsg),
    actionButton( 'filtReq', label = 'Go there') 
  ),
  conditionalPanel( 
    condition = 'output.procIsAllowed',
    list( 
      h2( 'Probe filtering'),
      p( 'Here you can filter the probes with regard to p-value and limit.'),
      checkboxInput( 'filtEnabled', 'Enabled'),
      conditionalPanel(
        condition = 'input.filtEnabled',
        p( 'Fixme')
      ),
      hr(),
      actionButton( 'filtNext', label = 'Continue'),
      span( 'or', class='or'),
      actionLink( 'filtDown', 'download')
    )
  )
)
normTab = list(
  conditionalPanel( 
    condition = '!output.procIsAllowed',
    p( procMsg),
    actionButton( 'normReq', label = 'Go there') 
  ),
  conditionalPanel( 
    condition = 'output.procIsAllowed',
    list( 
      h2( 'Normalization'),
      p( 'Here you can fixme'),
      checkboxInput( 'normEnabled', 'Enabled'),
      conditionalPanel(
        condition = 'input.normEnabled',
        p( 'Fixme')
      ),
      hr(),
      actionButton( 'normNext', label = 'Continue'),
      span( 'or', class='or'),
      actionLink( 'normDown', 'download')
    )
  )
)
questTab = list(
  conditionalPanel( 
    condition = '!output.procIsAllowed',
    p( procMsg),
    actionButton( 'questReq', label = 'Go there')
  ),
  conditionalPanel( 
    condition = 'output.procIsAllowed',
    list( 
      h2( 'Questionnaires'),
      p( 'Here you can fixme'),
      checkboxInput( 'questEnabled', 'Enabled'),
      conditionalPanel(
        condition = 'input.questEnabled',
        p( 'Fixme')
      ),
      hr(),
      actionButton( 'questNext', label = 'Continue')
    )
  )
)
downloadTab = list(
  conditionalPanel( 
    condition = '!output.procIsAllowed',
    p( procMsg),
    actionButton( 'downloadReq', label = 'Go there') 
  ),
  conditionalPanel( 
    condition = 'output.procIsAllowed',
    h2( 'Download'),
    list( 
      p( 'Here you can download an archive (a .zip file) containing the processed dataset (.csv file), documentation of all processing steps (.pdf file), and the source (.R file).'),
      p( 'The datset consists of genes if not chosen otherwise.'),
      downloadButton( 'download', 'Download archive'),
      span( 'or', class='or'),
      actionLink( 'quit', 'quit')
    )
  )
)
jscode <- 'shinyjs.closeWindow = function() { window.close() }'

# client: definition of UI
ui <- fluidPage(
  # external CSS
  includeCSS( 'www/pippeline.css'),
  # window title
  title = appName,
  # tabs defined through list
  navlistPanel(
    appName, # page title
    widths = c( 3, 9), # 25% width
    selected = 'download', # fixme
    tabPanel( 'About', value = 'about', aboutTab),  # list item, ID, tab content
    tabPanel( 'Name', value = 'name', nameTab),
    tabPanel( 'Design & other choices', value = 'design', designTab),
    tabPanel( 'Read in datasets', value = 'read', readTab),
    tabPanel( 'Outliers', value = 'outliers', outlierTab),
    tabPanel( 'Background correction', value = 'corr', corrTab),
    tabPanel( 'Probe filtering', value = 'filter', filterTab),
    tabPanel( 'Normalization', value = 'norm', normTab),
    tabPanel( 'Questionnaires', value = 'quest', questTab),
    tabPanel( 'Download & quit', value = 'download', downloadTab),
    id = 'steps'
  ),
  img( src='logo-uit.svg', width = 200, height = 'auto', style='float:right'),  # fixme
  useShinyjs(),
  extendShinyjs( text = jscode, functions = c( 'closeWindow') )
)

# server: interaction & logic
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
    js$closeWindow()
    stopApp()
  })
  
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

# now put client and server together and run app
shinyApp( ui, server, options = list( 'display.mode' = 'showcase') ) # fixme
