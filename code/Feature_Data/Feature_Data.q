// Function for the ingestion of the feature dataset based on user defined input, this should allow
// a user to load data from their process or from alternative datasources, using loading.q in Auto_Testing?
\d .automl

nodekeys:`function`inputs`outputs
i.Feature_Data_inputs  :"!"
i.Feature_Data_outputs :"+"
i.Feature_Data_function:{[cfg]([]100?1f;100?1f)}
Feature_Data:nodekeys!(i.Feature_Data_function;i.Feature_Data_inputs;i.Feature_Data_outputs)
