# globals, all sessions

# pipeline: basics
basics <- list(
  appName = 'Pippeline',
  title = 'Biobank Dataset Processing Script & Report',
  optionsFile = 'options.csv',
  questsFile = 'questionnaires.txt', # questionnaires
  # note: pandoc'ing with target PDF is buggy in R 3.2.3, rmarkdown 1.4, pandoc 1.16.0.2
  docFormat = 'html',  # see documentation for rmarkdown::render()
  msgDuration = 7,  # see documentation of shiny::showNotification()
  ids = c(  # ID labels to remove before data are written
    'lpnr',
    'labnr',
    'serienr'
  )
)

# strings
procMsg <- 'First, you need to enter basic information and make your choices.'
notSelOpt <- 'Not selected'

# determine options for basic choices
options <- NULL
tryCatch( {
  options <- read.csv( basics$optionsFile)
}, error = function( err){
  showNotification( paste0( 'Error while loading file ', basics$optionsFile, '. (Wrong format?) Error code #5.', type = 'error', duration = basics$msgDuration) )
} )
dsgs <- c( notSelOpt, levels( options[ , 'Design'] ) )
locs <- c( notSelOpt, levels( options[ , 'Location'] ) )
mats <- c( notSelOpt, levels( options[ , 'Material'] ) )
anas <- c( notSelOpt, levels( options[ , 'Analysis'] ) )

quests <- NULL
tryCatch( {
  quests <- readLines( basics$questsFile)
}, error = function( err){
  showNotification( paste0( 'Error while loading file ', basics$questsFile, '. (Wrong format?) Error code #6.', type = 'error', duration = basics$msgDuration) )
} )
quests <- c( notSelOpt, quests)
qvars <- NULL

nmeths <- c( notSelOpt, 'vstQuantileNorm')

# JavaScript
jscode <- "shinyjs.closeWindow = function() { window.close(); }"  # works only in RStudio, not external browser

# Info summary list
dinfo <- list(
  dName=notSelOpt,
  numPairs=list(ge=NULL,nc=NULL),
  numPairsInfo=notSelOpt,
  outlierR=notSelOpt,
  bCorr=notSelOpt,
  filterP=notSelOpt,
  filterLimit=notSelOpt,
  normMethod=notSelOpt,
  questVars=notSelOpt
)