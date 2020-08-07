// Function used for validity checking of parameters custom and otherwise, the suitability of data 
// for machine learning wrt target vs data lengths
\d .automl

nodekey:`function`inputs`outputs
i.Data_Check_input   :`Config`Features`Target!"!+F"
i.Data_Check_output  :`Config`Features`Target!"!+F"
i.Data_Check_function:{[cfg;feat;tgt]`Config`Features`Target!(cfg;feat;tgt)}
Data_Check:nodekey!(i.Data_Check_function;i.Data_Check_input;i.Data_Check_output)
