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
    tabPanel( 'Name', value = 'name', nameTab),
    tabPanel( 'Design & other choices', value = 'design', designTab),
    tabPanel( 'Outliers', value = 'outliers', outlierTab),
    tabPanel( 'Background correction', value = 'corr', corrTab),
    tabPanel( 'Probe filtering', value = 'filter', filterTab),
    tabPanel( 'Normalization', value = 'norm', normTab),
    tabPanel( 'Questionnaires', value = 'quest', questTab),
    tabPanel( 'Download & quit', value = 'download', downloadTab),
    id = 'steps'
  ),
  img( src='logo-uit.svg', width = 200, height = 'auto', class='logo'),
  useShinyjs(),
  extendShinyjs( text = jscode, functions = c( 'closeWindow') )
)