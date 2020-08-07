// Save relevant metadata information for the use of a persisted model on new data
\d .automl

nodekeys:`function`inputs`outputs
i.Save_Meta_inputs  :"!"
i.Save_Meta_outputs :"!"
i.Save_Meta_function:{x}
Save_Meta:nodekeys!(i.Save_Meta_function;i.Save_Meta_inputs;i.Save_Meta_outputs)
