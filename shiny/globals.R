# globals, all sessions

# pipeline: basics
basics <- list(
  appName = 'Pippeline',
  title = 'Biobank Dataset Processing Script & Report',
  optionsFile = 'options.csv',
  docFormat = 'html'  # see documentation for rmarkdown::render() # fixme
)

# strings
procMsg <- 'First, you need to enter basic information and make your choices.'
notSelOpt <- 'Not selected'

# determine options for basic choices
options <- read.csv( basics$optionsFile)
dsgs <- c( notSelOpt, levels( options[ , 'Design'] ) )
locs <- c( notSelOpt, levels( options[ , 'Location'] ) )
mats <- c( notSelOpt, levels( options[ , 'Material'] ) )
anas <- c( notSelOpt, levels( options[ , 'Analysis'] ) )
nmeths <- c( notSelOpt, 'fixme')  # trenger navn fra Marit

# JavaScript
jscode <- 'shinyjs.closeWindow = function() { window.close() }'  # works only in RStudio, not external browser