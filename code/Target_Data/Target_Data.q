// Loading of the target dataset, data can be loaded from in process or alternative data sources
\d .automl

nodekeys:`function`inputs`outputs
i.Target_Data_inputs  :"!"
i.Target_Data_outputs :"F"
i.Target_Data_function:.ml.i.loaddset
Target_Data:nodekeys!(i.Target_Data_function;i.Target_Data_inputs;i.Target_Data_outputs)
