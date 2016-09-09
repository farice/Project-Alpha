
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(glmnet)


shinyServer(function(input, output) {
  
  cog_data <- reactive({
    in_cog <- input$cog_input
    
    shiny::validate(
      need(input$cog_input != "", "Please upload cognitive data")
    )
    
    if (is.null(in_cog)){
      return(NULL)
    }
    else{
      withProgress(message = "CONVERTING CSV...", value = 0.4, {
        read.csv(in_cog$datapath, header = T, sep = ',')
      })
      
      
  }
    
  })
  
  eeg_data <- reactive({
    in_eeg <- input$eeg_input
    
    shiny::validate(
      need(input$eeg_input != "", "Please upload EEG data")
    )
    
    if (is.null(in_eeg)){
      return(NULL)
    }
    else{
      withProgress(message = "CONVERTING CSV...", value = 0.4, {
        read.csv(in_eeg$datapath, header = T, sep = ',')
      })
    }
    
  })
  
  cog_eeg_proc <- reactive ({
    
      data_eeg <- eeg_data()
      data_cog <- cog_data() 
      
      if(is.null(data_cog) || is.null(data_eeg)) return(NULL)
      
      fr_eeg <-  filter(data_eeg, elec == 'Fp1' | elec == 'Fp2' | elec == '9' | elec == '10' | elec == '11' | elec == '12')
      oc_eeg <-  filter(data_eeg, elec == '39' | elec == '40' | elec == '41' | elec == '42' | elec == '43' | elec == '44')
      
      eeg_grouped <- group_by(fr_eeg, test.studyno)
      fr_eeg <- mutate(eeg_grouped, fr_alpha = mean(mean(V8, na.rm = T), mean(V9, na.rm = T), mean(V10, na.rm = T), mean(V11, na.rm = T), mean(V12, na.rm = T)))
      
      eeg_grouped <- group_by(oc_eeg, test.studyno)
      oc_eeg <- mutate(eeg_grouped, oc_alpha = mean(mean(V8, na.rm = T), mean(V9, na.rm = T), mean(V10, na.rm = T), mean(V11, na.rm = T), mean(V12, na.rm = T)))
      
      eeg_grouped <- group_by(fr_eeg, test.studyno)
      fr_eeg <- mutate(eeg_grouped, fr_delta = mean(mean(V1, na.rm = T), mean(V2, na.rm = T), mean(V3, na.rm = T)) )
      
      eeg_grouped <- group_by(oc_eeg, test.studyno)
      oc_eeg <- mutate(eeg_grouped, oc_delta = mean(mean(V1, na.rm = T), mean(V2, na.rm = T), mean(V3, na.rm = T)))
      
      eeg_grouped <- group_by(fr_eeg, test.studyno)
      fr_eeg <- mutate(eeg_grouped, fr_theta = mean(mean(V4, na.rm = T), mean(V5, na.rm = T), mean(V6, na.rm = T), mean(V7, na.rm = T)))
      
      eeg_grouped <- group_by(oc_eeg, test.studyno)
      oc_eeg <- mutate(eeg_grouped, oc_theta = mean(mean(V4, na.rm = T), mean(V5, na.rm = T), mean(V6, na.rm = T), mean(V7, na.rm = T)))
      
      eeg_grouped <- group_by(fr_eeg, test.studyno)
      fr_eeg <- mutate(eeg_grouped, fr_beta = 1)
      
      eeg_grouped <- group_by(oc_eeg, test.studyno)
      oc_eeg <- mutate(eeg_grouped, oc_beta = 1)
      
      data_eeg <- left_join(oc_eeg, fr_eeg, by ='test.studyno')
      
      data <- distinct(data_eeg, test.studyno, .keep_all = T)
      
      #data_cog$test.factor_1_delta <- as.numeric(as.character(data_cog$test.factor_1_delta))
      #data_cog$test.factor_2_delta <- as.numeric(as.character(data_cog$test.factor_2_delta))
      #data_cog$test.factor_3_delta <- as.numeric(as.character(data_cog$test.factor_3_delta))
      #data_cog$test.factor_4_delta <- as.numeric(as.character(data_cog$test.factor_4_delta))
      
      data_cog$mean_cog <- rowMeans(data_cog[,6:9])
      data <- left_join(data, data_cog, by= 'test.studyno')
      
      data
    
  })
  
  output$cog_eeg_summary <- renderPrint ({
    data <- cog_eeg_proc()
    summary(data)
  })
  
  output$cog_eeg_str <- renderPrint ({
    data <- cog_eeg_proc()
    str(data)
  })
  
  output$cog_pairs <- renderPlot ({
    shiny::validate(
      need(input$sc_columns != "", "Waiting for data...")
    )
    
    data <- cog_eeg_proc()
    if(is.null(data) ) return(NULL)
    pairs(as.formula(paste("~", paste(input$sc_columns, collapse = "+"))) ,data = data)
  })
  
  output$choose_columns <- renderUI ({
    data <- cog_eeg_proc()
    if(is.null(data)) return(NULL)
    
    colnames <- names(data)
    
    checkboxGroupInput("sc_columns", "Choose Scatter Regressors", choices = colnames, selected = c('mean_cog', 'test.factor_1_delta', 'test.factor_2_delta', 'test.factor_3_delta', 'test.factor_4_delta', 'oc_alpha', 'oc_delta', 'oc_theta', 'fr_delta','fr_alpha','fr_theta'  ))
  })

})
