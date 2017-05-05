# globals, all sessions

# pipeline: basics
basics <- list(
  appName = 'Pippeline',
  appVersion = '0.9',
  appDescr = 'Pipeline for processing high-dimensional multi-omics biobank datasets',
  title = 'Biobank Dataset Processing Script & Report',
  docFormat = 'pdf'  # see documentation for rmarkdown::render()
)

# strings
procMsg <- 'First, you need to enter basic information and make your choices.'
notSelOpt <- 'Not selected'

# determine options for basic choices
options <- read.csv( 'options.csv')
dsgs <- c( notSelOpt, levels( options[ , 'Design'] ) )
locs <- c( notSelOpt, levels( options[ , 'Location'] ) )
mats <- c( notSelOpt, levels( options[ , 'Material'] ) )
anas <- c( notSelOpt, levels( options[ , 'Analysis'] ) )

# JavaScript
jscode <- 'shinyjs.closeWindow = function() { window.close() }'