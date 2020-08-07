// Function for the retrieval and consolidation of configuration information required for AutoML
\d .automl

nodekeys:`function`inputs`outputs
i.Config_inputs  :"!"
i.Config_outputs :"!"
i.Config_function:{[cfg]cfg}
Configuration:nodekeys!(i.Config_function;i.Config_inputs;i.Config_outputs)
