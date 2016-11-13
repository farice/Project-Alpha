# Project-Alpha
Open Source EEG Analysis Software

## Shiny Suite

The app.R and server.R files can be compiled on a Shiny Server or RStudio to provide a functional interface for EEG and Cognitive data analysis.

One can visualize regressors in a scatter plot matrix, perform logistic regressions, and reactively adjust parameters.

Features are automatically extracted from data that is uploaded with the defined structure.  

### Required data

The cognitive data must be formatted with a unique identifier in each row.

The EEG data must contain an identically named unique identifier column. Furthermore, a column with electrode positions must exist to aggregate frontal and occipital frequency bands.

# BIS Processing

BIS data stored in a .bin datatype can be converted to a standard MATLAB data structure and then preprocessed automatically using EEGLAB. Ensure EEGLAB has already been installed before use.  
