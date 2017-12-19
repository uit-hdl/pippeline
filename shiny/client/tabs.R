# UI elements: tabs
aboutTab <- list( 
  h2( 'About'),
  p( paste0( 'This is ', basics$appName, ', a ', tolower( read.dcf( file.path( '..', 'DESCRIPTION'), fields = 'Title')[1,1] ), '.') ),
  p( 'Navigate by following buttons/links, or pick an item from the list of processing steps.'),
  hr(),
  actionButton( 'aboutNext', label = 'Continue') 
)

descrTab <- list( 
  h2( 'Description'),
  p( 'Please enter the information below.'),
  textInput( inputId = 'author', label = 'Your name/initals'),
  textAreaInput( inputId = 'descr', label = 'Processing description'),
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
    selectInput( 'dsg', label = 'Design', choices = dsgs),
    selectInput( 'loc', label = 'Probe location', choices = locs),
    selectInput( 'mat', label = 'Biological material', choices = mats),
    selectInput( 'ana', label = 'Genomic analysis', choices = anas),
    checkboxInput( 'trans', label = 'Exclude control-case transitions'),
    hr(),
    conditionalPanel( 
      condition = 'output.procIsAllowed && output.objsExist',
      actionButton( 'designNext', label = 'Continue'),
      span( 'or', class='or'),
      actionLink( 'designDown', 'process')
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
      p( 'Outliers can be found by means of the ', a( 'nowaclean', href='https://github.com/3inar/nowaclean'), ' R package.'),
      checkboxInput( 'outlierEnabled', 'Enabled'),
      conditionalPanel(
        condition = 'input.outlierEnabled',
        p( 'Identify outliers as described in the vignette of nowaclean and save them like so:', code( 'saveRDS(outliers, file="outliers.rds")'), '. You can then import this file here.'),
        fileInput( 'outlierFile', 'RData file with outliers'),
        textAreaInput( inputId = 'outlierDescr', label = 'Outlier description (optional)', value = '')
      ),
      hr(),
      conditionalPanel(
        condition = '!input.outlierEnabled || output.outlFileExists',
        actionButton( 'outlierNext', label = 'Continue'),
        span( 'or', class='or'),
        actionLink( 'outlierDown', 'process')
      )
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
      p( paste0( 'Background correction is carried out by means of negative control probes as specified in the file "', basics$optionsFile, '".') ),
      checkboxInput( 'corrEnabled', 'Enabled'),
      hr(),
      actionButton( 'corrNext', label = 'Continue'),
      span( 'or', class='or'),
      actionLink( 'corrDown', 'process')
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
      actionLink( 'filtDown', 'process')
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
        selectInput( 'nmeth', label = 'Method', choices = nmeths, selected = 'vstQuantileNorm')
      ),
      hr(),
      conditionalPanel( 
        condition = sprintf( '!input.normEnabled || input.nmeth != "%s"', notSelOpt),
        actionButton( 'normNext', label = 'Continue'),
        span( 'or', class='or'),
        actionLink( 'normDown', 'process')
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
      p( 'Here you can link questionnaires to the biobank datasets.'),
      checkboxInput( 'questEnabled', 'Enabled'),
      conditionalPanel(
        condition = 'input.questEnabled',
        p( 'Choose a questionnaire first, then select the available variables.'),
        selectInput( 'questObj', label = 'Questionnaire', choices = quests),
        conditionalPanel(
          condition = 'output.questIsValid',
          p( 'Add variables to (by typing names or picking from the list) or delete from the list of questionnaire variables.'),
          uiOutput( 'qvarPicker')
        )
      ),
      hr(),
      conditionalPanel( 
        condition = sprintf( '!input.questEnabled || input.questObj != "%s"', notSelOpt),
        actionButton( 'questNext', label = 'Continue')
      )
    )
  )
)

downloadTab <- list(
  h2( 'Process & quit'),
  conditionalPanel( 
    condition = '!output.downlIsAllowed',
    p( 'Processing is not allowed.'),
    p( 'This could be due to incomplete or invalid input in any of the processing steps.'),
    actionButton( 'downloadReq', label = 'Go there') 
  ),
  conditionalPanel( 
    condition = 'output.downlIsAllowed',
    list( 
      p( paste0( 'Here you can process dataset (.rds format), documentation of all processing steps (.', basics$docFormat,' file) and the source (.R file).') ),
      p( 'The datset consists of probes if not chosen otherwise.'),
      checkboxInput( 'wantGenes', 'Genes instead of probes'),
      actionButton( 'download', 'Compute and assemble files')
    )
  ),
  hr(),
  actionLink( 'quit', 'Quit')
)
