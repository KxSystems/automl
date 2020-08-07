// Function for the ingestion of the target dataset based on user defined input, this should allow
// a user to load data from their process or from alternative datasources, using loading.q in Auto_Testing?
\d .automl

nodekeys:`function`inputs`outputs
i.Target_Data_inputs  :"!"
i.Target_Data_outputs :"F"
i.Target_Data_function:{[cfg]100?1f}
Target_Data:nodekeys!(i.Target_Data_function;i.Target_Data_inputs;i.Target_Data_outputs)
