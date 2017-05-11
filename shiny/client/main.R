# tabs defined through list
navlistPanel(
  basics$appName, # page title
  widths = c( 3, 9), # 25% width
  selected = 'design', # fixme
  tabPanel( 'About', value = 'about', aboutTab),  # list item, ID, tab content
  tabPanel( 'Description', value = 'name', descrTab),
  tabPanel( 'Choices', value = 'design', designTab),
  tabPanel( 'Outliers', value = 'outliers', outlierTab),
  tabPanel( 'Correction', value = 'corr', corrTab),
  tabPanel( 'Filtering', value = 'filter', filterTab),
  tabPanel( 'Normalization', value = 'norm', normTab),
  tabPanel( 'Questionnaires', value = 'quest', questTab),
  tabPanel( 'Download & quit', value = 'download', downloadTab),
  id = 'steps'
)