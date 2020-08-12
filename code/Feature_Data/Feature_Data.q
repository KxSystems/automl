// Loading of the feature dataset, this can be from in process or several alternative datasources
\d .automl

nodekeys:`function`inputs`outputs
i.Feature_Data_inputs  :"!"
i.Feature_Data_outputs :"+"
i.Feature_Data_function:.ml.i.loaddset
Feature_Data:nodekeys!(i.Feature_Data_function;i.Feature_Data_inputs;i.Feature_Data_outputs)
