# This is the app wrapper which invokes the both the server and client scripts.

# includes
library(shiny)

# globals
appName <- 'Pippeline'
prereqMsg <- 'First, you need to select a source.'
# UI elements
sourceTab <- list( 
  p( 'Please select a data source and design.'),
  selectInput( inputId = 'src', label = 'Choose', choices = c(
    'No source' = 'src0',
    'Source 1' = 'src1',
    'Source 2' = 'src2',
    'Source 3' = 'src3'
  ) ),
  conditionalPanel( 
    condition = 'input.src != "src0"',
    actionButton( 'srcNext', label = 'Next step') 
  )
)
sampleTab = list(
  conditionalPanel( 
    condition = 'input.src == "src0"',
    p( prereqMsg)
  ),
  conditionalPanel( 
    condition = 'input.src != "src0"',
    p( 'Select the sample type of the source.')
  )
)
downloadTab = list(
  conditionalPanel( 
    condition = 'input.src == "src0"',
    p( prereqMsg)
  ),
  conditionalPanel( 
    condition = 'input.src != "src0"',
    list( 
      p( 'Get analysis ready data as CSV file.'),
      downloadButton( 'data', 'Download data'),
      p( 'Get detailed documentation of each processing step as PDF.'),
      downloadButton( 'doc', 'Download documentation')
    )
  )
)

# client: definition of UI
ui <- fluidPage(
   
   # window title
   title = appName,
   
   # tabs defined through list
   navlistPanel(
     appName, # page title
     widths = c( 3, 9), # 25% width
     tabPanel( 'Source',  # list item
               value = 'source',
               sourceTab),  # tab content
     tabPanel( 'Sample type',
               value = 'type',
               sampleTab),
     tabPanel( 'Analysis',
               p( 'Choose the analysis type')
     ),
     tabPanel( 'Questionnaire',
               p( 'Connect questionnaire responses')
     ),
     tabPanel( 'Case control',
               p( 'Check cases and controls')
     ),
     tabPanel( 'Gene expression',
               p( 'Fetch probes')
     ),
     tabPanel( 'Illumina',
               p( 'Process data in Illumina')
     ),
     tabPanel( 'Outliers',
               p( 'Remove single data points')
     ),
     tabPanel( 'Corrections',
               p( 'Reduce noise and negative probes')
     ),
     tabPanel( 'Statistics',
               p( 'Calculate summary')
     ),
     tabPanel( 'Normalization',
               p( 'Correct batches')
     ),
     tabPanel( 'Download',
               value = 'download',
               downloadTab),
     id = 'steps'
   ),
   img( src='logo-uit.svg', width = 200, height = 'auto', style='float:right')
)

# server: interaction & logic
server <- function( input, output, session) {
  # data and documentation
  data <- NULL
  doc <- NULL

    # next-step button
  observeEvent( input$srcNext, {
    updateNavlistPanel( session, 'steps', selected = 'type')
  } )
  
  # download filenames
  output$data <- downloadHandler(
    filename = function() {
      paste( 'data-', Sys.Date(), '.csv', sep = '')
    },
    content = function( file) {
      write.csv( data, file)
    }
  )
  output$doc <- downloadHandler(
    filename = function() {
      paste( 'documentation-', Sys.Date(), '.pdf', sep = '')
    },
    content = function( file) {
      # fixme: produce PDF
    }
  )
}

# now put client and server together and run app
shinyApp( ui, server)
