# globals
appName <- 'Pippeline'
procMsg <- 'First, you need to enter basic information and make your choices.'
notSelOpt <- 'Not selected'

# determine options for basic choices
options <- read.csv( 'options.csv')
dsgs <- c( notSelOpt, levels( options[ , 'Design'] ) )
locs <- c( notSelOpt, levels( options[ , 'Location'] ) )
mats <- c( notSelOpt, levels( options[ , 'Material'] ) )
anas <- c( notSelOpt, levels( options[ , 'Analysis'] ) )

# UI elements: tabs
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
  h2( 'Design & basic choices'),
  conditionalPanel( 
    condition = '!output.prereqsAreValid',
    p( 'First you must provide some basic information.'),
    actionButton( 'designReq', label = 'Go there') 
  ),
  conditionalPanel( 
    condition = 'output.prereqsAreValid',
    p( 'Please select a design and make your choices.'),
    selectInput( 'dsg', label = 'Design', selected = 'Nested matched case-control - prospective', choices = dsgs), # fixme
    selectInput( 'loc', label = 'Probe location', selected = 'Ovaria', choices = locs), # fixme
    selectInput( 'mat', label = 'Biological material', selected = 'Blood', choices = mats), # fixme
    selectInput( 'ana', label = 'Genomic analysis', selected = 'mRNA', choices = anas), # fixme
    checkboxInput( 'trans', label = 'Exclude control-case transitions', value = TRUE),
    hr(),
    conditionalPanel( 
      condition = 'output.procIsAllowed',
      actionButton( 'designNext', label = 'Continue'),
      span( 'or', class='or'),
      actionLink( 'designDown', 'download')
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
  h2( 'Download & quit'),
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

# JavaScript
jscode <- 'shinyjs.closeWindow = function() { window.close() }'
