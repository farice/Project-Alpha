
#MIT License

#Copyright (c) 2016 Faris Sbahi

#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
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
