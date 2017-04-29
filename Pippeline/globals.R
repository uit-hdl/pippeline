# globals
appName <- 'Pippeline'
procMsg <- 'First, you need to enter basic information, make your choices, and read in the data.'

# UI elements
aboutTab <- list( 
  h2( 'About'),
  p( paste0( 'This is ', appName, ', a pipeline for processing high-dimensional multi-omics biobank datasets.') ),
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
  h2( 'Basic choices'),
  conditionalPanel( 
    condition = '!output.prereqsAreValid',
    p( 'First you must provide some basic information.'),
    actionButton( 'designReq', label = 'Go there') 
  ),
  conditionalPanel( 
    condition = 'output.prereqsAreValid',
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

readTab <- list(
  h2( 'Your choices'),
  conditionalPanel( 
    condition = '!output.prereqsAreValid || !output.choicesAreValid',
    p( 'First you need to enter basic information and make your choices.'),
    actionButton( 'readReq', label = 'Go there') 
  ),
  conditionalPanel( 
    condition = 'output.prereqsAreValid && output.choicesAreValid',
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

outlierTab <- list(
  h2( 'Outlier removal'),
  conditionalPanel( 
    condition = '!output.procIsAllowed',
    p( procMsg),
    actionButton( 'outlierReq', label = 'Go there') 
  ),
  conditionalPanel( 
    condition = 'output.procIsAllowed',
    list( 
      p( 'Here you can delete outliers from the dataset.'),
      checkboxInput( 'outlierEnabled', 'Enabled'),
      # conditionalPanel(
      #   condition = 'input.outlierEnabled'
      # ),
      hr(),
      actionButton( 'outlierNext', label = 'Continue'),
      span( 'or', class='or'),
      actionLink( 'outlierDown', 'download')
    )
  )
)

corrTab <- list(
  h2( 'Background correction'),
  conditionalPanel( 
    condition = '!output.procIsAllowed',
    p( procMsg),
    actionButton( 'corrReq', label = 'Go there') 
  ),
  conditionalPanel( 
    condition = 'output.procIsAllowed',
    list( 
      p( 'Here you can do a background correction by means of negative control probes.'),
      checkboxInput( 'corrEnabled', 'Enabled'),
      # conditionalPanel(
      #   condition = 'input.corrEnabled'
      # ),
      hr(),
      actionButton( 'corrNext', label = 'Continue'),
      span( 'or', class='or'),
      actionLink( 'corrDown', 'download')
    )
  )
)

filterTab <- list(
  h2( 'Probe filtering'),
  conditionalPanel( 
    condition = '!output.procIsAllowed',
    p( procMsg),
    actionButton( 'filtReq', label = 'Go there') 
  ),
  conditionalPanel( 
    condition = 'output.procIsAllowed',
    list( 
      p( 'Here you can filter the probes with regard to p-value and limit.'),
      checkboxInput( 'filtEnabled', 'Enabled'),
      conditionalPanel(
        condition = 'input.filtEnabled',
        sliderInput( 'pval', 'P-value', min = 0, max = 1, value = 0.05),
        sliderInput( 'plimit', 'Filtering limit', min = 0, max = 1, value = 0.7)
      ),
      hr(),
      actionButton( 'filtNext', label = 'Continue'),
      span( 'or', class='or'),
      actionLink( 'filtDown', 'download')
    )
  )
)

normTab <- list(
  h2( 'Normalization'),
  conditionalPanel( 
    condition = '!output.procIsAllowed',
    p( procMsg),
    actionButton( 'normReq', label = 'Go there') 
  ),
  conditionalPanel( 
    condition = 'output.procIsAllowed',
    list( 
      p( 'Here you can normalize the current dataset.'),
      checkboxInput( 'normEnabled', 'Enabled'),
      conditionalPanel(
        condition = 'input.normEnabled',
        selectInput( 'normMethod', label = 'Method', choices = c( # fixme
          'Not selected' = 'nmeth0',
          'Method 1' = 'nmeth1'
        ) )
      ),
      hr(),
      conditionalPanel( 
        condition = '!input.normEnabled || input.normMethod != "nmeth0"',
        actionButton( 'normNext', label = 'Continue'),
        span( 'or', class='or'),
        actionLink( 'normDown', 'download')
      )
    )
  )
)

questTab <- list(
  h2( 'Questionnaires'),
  conditionalPanel( 
    condition = '!output.procIsAllowed',
    p( procMsg),
    actionButton( 'questReq', label = 'Go there')
  ),
  conditionalPanel( 
    condition = 'output.procIsAllowed',
    list( 
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

downloadTab <- list(
  h2( 'Download'),
  conditionalPanel( 
    condition = '!output.procIsAllowed',
    p( procMsg),
    actionButton( 'downloadReq', label = 'Go there') 
  ),
  conditionalPanel( 
    condition = 'output.procIsAllowed',
    list( 
      p( 'Here you can download an archive (a .zip file) containing the processed dataset (.csv file), documentation of all processing steps (.pdf file), and the source (.R file).'),
      p( 'The datset consists of genes if not chosen otherwise.'),
      checkboxInput( 'wantProbes', 'Probes instead of genes'),
      downloadButton( 'download', 'Download archive')
    )
  ),
  hr(),
  actionLink( 'quit', 'Quit')
)

jscode <- 'shinyjs.closeWindow = function() { window.close() }'
