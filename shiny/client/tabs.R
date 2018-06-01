# UI elements: tabs
aboutTab <- list( 
  h2('About'),
  p(paste0('This is ', basics$appName, ', a ', tolower(read.dcf(file.path('..', 'DESCRIPTION'), fields = 'Title')[1,1] ), '.')),
  p('Navigate by the following buttons through the pipeline with advised processing steps.'),
  hr(),
  actionButton('aboutNext', label = 'Continue') 
)

descrTab <- list( 
  h2('Description'),
  p('Please enter the information below, i.e. your name, project and processing description.'),
  p('This information will be used in the generated report for the project.'),
  textInput( inputId = 'author', label = 'Your name/initals'),
  textInput( inputId = 'projname', label = 'Project name'),
  textAreaInput( inputId = 'descr', label = 'Processing description'),
  hr(),
  conditionalPanel( 
    condition = 'output.prereqsAreValid',
    actionButton('descrNext', label = 'Continue') 
  )
)

designTab <- list( 
  h2('Dataset description & project design'),
  conditionalPanel( 
    condition = '!output.prereqsAreValid',
    p('First you must provide right user information.'),
    actionButton('designReq', label = 'Go there') 
  ),
  conditionalPanel( 
    condition = 'output.prereqsAreValid',
    p('Please state the experiment design, which specify the dataset.'),
    p('These values will be used for choosing right dataset and report generation.'),
    selectInput('dsg', label = 'Experiment design', choices = dsgs),
    selectInput('loc', label = 'Probe location', choices = locs),
    selectInput('mat', label = 'Biological material', choices = mats),
    selectInput('ana', label = 'Genomic analysis', choices = anas),
    hr(),
    conditionalPanel( 
      condition = 'output.procIsAllowed && output.objsExist',
      div(class='row-btn',
        actionButton('designNext', label = 'Continue'),
        div(class='divider'),
        actionButton('designDown', 'To final step')
      )
    )
  )
)

outlierTab <- list(
  h2('Outlier removal'),
  conditionalPanel( 
    condition = '!output.procIsAllowed',
    p(procMsg),
    actionButton('outlierReq', label = 'Go there') 
  ),
  conditionalPanel( 
    condition = 'output.procIsAllowed',
    list( 
      p('Here you can delete outliers from the dataset.'),
      p('Outliers can be found by means of the ', a('nowaclean', href='https://github.com/3inar/nowaclean'), ' R package.'),
      checkboxInput('outlierEnabled', label = 'Enabled'),
      conditionalPanel(
        condition = 'input.outlierEnabled',
        #p('Identify outliers as described in the vignette of nowaclean and save them like so:', code('saveRDS(outliers, file="outliers.rds")'), '. You can then import this file here.'),
        p('Here you can choose outlier file from premade ones or save your own by sourcing "report_nowaclean.R" script or by providing outlier definition by your own with:', code('saveRDS(outliers, file="outliers.rds")'), 
          '. Outliers object should be a vector of sample names. Place your file to pippeline/nowaclean_outliers folder. 
          You can then choose this file here. Report will be available in generated folder for this pipeline run.'),
        #fileInput('outlierFile', 'RData file with outliers', accept = c(".rds")),
        selectInput('outlierFile', label = 'Outliers file', choices = outls),
        selectInput('outlierFileReport', label = 'Outliers report (optional)', choices = outls_rprts),
        textAreaInput(inputId = 'outlierDescr', label = 'Outlier description (optional) ', value = '')
      ),
      hr(),
      checkboxInput('transEnabled', label = 'Exclude control-case transitions'),
      conditionalPanel(
        condition = 'input.transEnabled',
        selectInput('cctFile', label = 'Transitions to remove', choices = trns),
        selectInput('transFileReport', label = 'Transitions report (optional)', choices = trns_rprts)
      ),
      hr(),
      div(class = 'row-btn', 
        actionButton('outlierApply', label = 'Apply'),
        actionButton('outlierNext', label = 'Continue'),
        div(class='divider'),
        # actionButton('outlierBack', label = 'Previous step'),
        actionButton('outlierSkip', label = 'Skip'),
        actionButton('outlierDown', label = 'To final step')
      )
    )
  )
)

corrTab <- list(
  h2('Background correction'),
  conditionalPanel( 
    condition = '!output.procIsAllowed',
    p( procMsg),
    actionButton('corrReq', label = 'Go there') 
  ),
  conditionalPanel( 
    condition = 'output.procIsAllowed',
    list( 
      p(paste0( 'Background correction is carried out by means of negative control probes as specified in the file "', basics$optionsFile, '".') ),
      p('This procedure includes processing of lumi object and negative control probes files, using limma', code('nec'), 'function and removing of extracted bad probes.'),
      checkboxInput('corrEnabled', 'Enabled'),
      hr(),
      div(class = 'row-btn', 
        actionButton('corrApply', label = 'Apply'),
        actionButton('corrNext', label = 'Continue'),
        div(class='divider'),
        actionButton('corrBack', label = 'Previous step'),
        div(class='divider'),
        actionButton('corrDown', label = 'To final step'),
        actionButton('corrSkip', label = 'Skip')
      )
    )
  )
)

filterTab <- list(
  h2('Probe filtering'),
  conditionalPanel( 
    condition = '!output.procIsAllowed',
    p(procMsg),
    actionButton('filtReq', label = 'Go there') 
  ),
  conditionalPanel( 
    condition = 'output.procIsAllowed',
    list( 
      p('Here you can filter the probes with regard to p-value and limit.'),
      p('This is done by lumi function', code('detectionCall'), 'with Th parameter as p-value and filtering this data by limit value.'),
      checkboxInput('filtEnabled', 'Enabled'),
      conditionalPanel(
        condition = 'input.filtEnabled',
        p('Default values are 0.05 for p-value and 0.7 for filtering limit.'),
        sliderInput('pval', 'P-value', min = 0, max = 1, value = 0.05),
        sliderInput('plimit', 'Filtering limit', min = 0, max = 1, value = 0.7)
      ),
      hr(),
      div(class = 'row-btn', 
        actionButton('filtApply', label = 'Apply'),
        actionButton('filtNext', label = 'Continue'),
        div(class='divider'),
        actionButton('filtBack', label = 'Previous step'),
        div(class='divider'),
        actionButton('filtDown', label = 'To final step'),
        actionButton('filtSkip', label = 'Skip')
      )
    )
  )
)


normTab <- list(
  h2( 'Normalization'),
  conditionalPanel( 
    condition = '!output.procIsAllowed',
    p(procMsg),
    actionButton('normReq', label = 'Go there') 
  ),
  conditionalPanel( 
    condition = 'output.procIsAllowed',
    list( 
      p('Here you can normalize the current dataset.'),
      checkboxInput( 'normEnabled', 'Enabled'),
      conditionalPanel(
        condition = 'input.normEnabled',
        p('VST-quantile method(VST transformation followed by quantile-normalization).'),
        p('ComBat (adjusts batch effects in datasets).'),
        selectInput('nmeth', label = 'Method', choices = nmeths, selected = notSelOpt),
        conditionalPanel(
          condition = 'input.nmeth == "ComBat"',
          selectInput('batchTab', label = 'Table for batching', choices = btchtab),
          conditionalPanel(
            condition = sprintf('input.batchTab != "%s"', notSelOpt),
            selectInput('batchVar', label = 'Batch variable (Note: using <Plate> variable is recommended)', choices = btchvar)
          ),
          conditionalPanel(
            condition = sprintf('input.batchTab != "%s"', notSelOpt),
            selectInput('batchSampleID', label = 'Sample ID variable (Note: using <Sample_ID> variable is recommended)', choices = btchvar)
          )
        )
      ),
      hr(),
      div(class = 'row-btn', 
        actionButton('normApply', label = 'Apply'),
        actionButton('normNext', label = 'Continue'),
        div(class='divider'),
        actionButton('normBack', label = 'Previous step'),
        div(class='divider'),
        actionButton('normDown', label = 'To final step'),
        actionButton('normSkip', label = 'Skip')
      )
    )
  )
)

questTab <- list(
  h2( 'Questionnaires'),
  conditionalPanel( 
    condition = '!output.procIsAllowed',
    p(procMsg),
    actionButton('questReq', label = 'Go there')
  ),
  conditionalPanel( 
    condition = 'output.procIsAllowed',
    list( 
      p('Here you can link questionnaires to the biobank datasets.'),
      p('Results will be combined with questionaire variables.'),
      checkboxInput( 'questEnabled', 'Enabled'),
      conditionalPanel(
        condition = 'input.questEnabled',
        p('Choose a questionnaire first, then select the available variables.'),
        selectInput('questObj', label = 'Questionnaire', choices = quests),
        conditionalPanel(
          condition = 'output.questIsValid',
          p('Add variables to (by typing names or picking from the list) or delete from the list of questionnaire variables.'),
          uiOutput('qvarPicker')
        )
      ),
      hr(),
      div(class = 'row-btn', 
        actionButton('questApply', label = 'Apply'),
        actionButton('questNext', label = 'Continue'),
        div(class='divider'),
        actionButton('questBack', label = 'Previous step'),
        div(class='divider'),
        actionButton('questSkip', label = 'Skip')
      )
    )
  )
)

processTab <- list(
  h2('Process & quit'),
  conditionalPanel( 
    condition = '!output.procIsAllowed',
    p('Processing is not allowed.'),
    p('This could be due to incomplete or invalid input in any of the processing steps.'),
    actionButton( 'processReq', label = 'Go there') 
  ),
  conditionalPanel( 
    condition = 'output.procIsAllowed',
    list( 
      p(paste0( 'Here you can process dataset (.rds format), documentation of all processing steps (.', 
        basics$docFormat,' file) and the source (.R file).') ),
      p('The datset consists of probes if not chosen otherwise.'),
      p('All prosessing options, stated in "Project info" panel, will be applied.'),
      checkboxInput('wantGenes', 'Genes instead of probes'),
      hr(),
      div(class = 'row-btn', 
        actionButton('process', label = 'Process and assemble files'),
        div(class='divider'),
        actionButton ('processBack', label = 'Previous step'),
        div(class='divider'),
        actionButton ('newStart', label = 'Start new')
      )
    )
  ),
  hr(),
  actionLink('quit', 'Quit')
)
