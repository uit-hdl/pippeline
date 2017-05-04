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

# JavaScript
jscode <- 'shinyjs.closeWindow = function() { window.close() }'