// Retrieve and generate required configuration information including save paths
\d .automl

nodekeys:`function`inputs`outputs
i.Config_inputs  :"!"
i.Config_outputs :"!"
i.Config_function:{[cfg]
  cfg,`startDate`startTime!(.z.D;.z.T)
  }

Configuration:nodekeys!(i.Config_function;i.Config_inputs;i.Config_outputs)
