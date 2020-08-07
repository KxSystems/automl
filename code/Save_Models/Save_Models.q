// Save an encoded representation of the best model retrieved during the automl process
\d .automl

nodekeys:`function`inputs`outputs
i.Save_Models_inputs  :"!"
i.Save_Models_outputs :"!"
i.Save_Models_function:{x}
Save_Models:nodekeys!(i.Save_Models_function;i.Save_Models_inputs;i.Save_Models_outputs)
