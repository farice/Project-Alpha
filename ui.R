
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinythemes)

shinyUI(fluidPage(theme = shinytheme("cosmo"),

  # Application title
  titlePanel("Project Alpha"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      fileInput('cog_input', 'Choose Cog Data CSV', accept=c('text/csv', 'text/comma-separated-values/plain')),
      fileInput('eeg_input', 'Choose EEG Data CSV', accept=c('text/csv', 'text/comma-separated-values/plain')),
      uiOutput("choose_columns"),
      uiOutput("choose_spear")
    ),
    

    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel("Scatter Matrix", plotOutput("cog_pairs")),
        tabPanel("Regress", plotOutput("cog_log"), verbatimTextOutput("cog_log_summary")),
        tabPanel("Summary",verbatimTextOutput("cog_eeg_spear"), verbatimTextOutput("cog_eeg_summary"), verbatimTextOutput("cog_eeg_str") )
      )
      )
  )
))
