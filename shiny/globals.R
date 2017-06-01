# globals, all sessions

# pipeline: basics
basics <- list(
  appName = 'Pippeline',
  title = 'Biobank Dataset Processing Script & Report',
  optionsFile = 'options.csv',
  # note: pandoc'ing with target PDF is buggy in R 3.2.3, rmarkdown 1.4, pandoc 1.16.0.2
  docFormat = 'html'  # see documentation for rmarkdown::render()
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
nmeths <- c( notSelOpt, 'vstQuantileNorm')

# JavaScript
jscode <- 'shinyjs.closeWindow = function() { window.close() }'  # works only in RStudio, not external browser