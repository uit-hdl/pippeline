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

# tabs
critTabsId <- c('outliers', 'corr', 'filter', 'norm', 'quest', 'process', 'divd')

# strings
procMsg <- 'First, you need to enter basic information and make your choices.'
notSelOpt <- 'Not selected'
notEnablOpt <- 'Not enabled'
notProcMsg <- 'Dataset is not processed'

# Slurm job id (can be SLURM_JOBID)
jobID <- Sys.getenv("SLURM_JOB_ID")

pipFolder <- '/project/tice/pippelinen'
nowacleanFolder <- file.path(pipFolder, 'nowaclean_outliers')
cctransFolder <- file.path(pipFolder, 'transition_information')

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

outls <- list.files(nowacleanFolder, pattern='\\.rds$')
outls <- c(notSelOpt, outls)

outls_rprts <- list.files(nowacleanFolder, pattern='\\.html$')
outls_rprts <- c(notSelOpt, outls_rprts)

trns <- list.files(cctransFolder, pattern='\\.rds$')
trns <- c(notSelOpt, trns)

trns_rprts <- list.files(cctransFolder, pattern='\\.html$')
trns_rprts <- c(notSelOpt, trns_rprts)

quests <- NULL
tryCatch( {
  quests <- readLines( basics$questsFile)
}, error = function( err){
  showNotification( paste0( 'Error while loading file ', basics$questsFile, '. (Wrong format?) Error code #6.', type = 'error', duration = basics$msgDuration) )
} )
quests <- c(notSelOpt, quests)
qvars <- NULL

nmeths <- c(notSelOpt, 'vstQuantileNorm', 'ComBat')

# JavaScript
jscode <- "
shinyjs.closeWindow = function() { window.close(); }

shinyjs.disableTab = function(name) {
  var tab = $('.nav li a[data-value=' + name + ']');
  tab.bind('click.tab', function(e) {
    e.preventDefault();
    return false;
  });
  tab.addClass('disabled');
}

shinyjs.enableTab = function(name) {
  var tab = $('.nav li a[data-value=' + name + ']');
  tab.unbind('click.tab');
  tab.removeClass('disabled');
}
"