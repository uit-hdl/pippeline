ui <- fluidPage(
  # external CSS
  includeCSS( 'www/pippeline.css'),
  # window title
  title = appName,
  # tabs defined through list
  navlistPanel(
    appName, # page title
    widths = c( 3, 9), # 25% width
    selected = 'design', # fixme
    tabPanel( 'About', value = 'about', aboutTab),  # list item, ID, tab content
    tabPanel( 'Naming', value = 'name', nameTab),
    tabPanel( 'Choices', value = 'design', designTab),
    tabPanel( 'Outliers', value = 'outliers', outlierTab),
    tabPanel( 'Correction', value = 'corr', corrTab),
    tabPanel( 'Filtering', value = 'filter', filterTab),
    tabPanel( 'Normalization', value = 'norm', normTab),
    tabPanel( 'Questionnaires', value = 'quest', questTab),
    tabPanel( 'Download & quit', value = 'download', downloadTab),
    id = 'steps'
  ),
  img( src='logo-uit.svg', width = 200, height = 'auto', class='logo'),
  useShinyjs(),
  extendShinyjs( text = jscode, functions = c( 'closeWindow') )
)