// Join together all information collected during preprocessing, processing and configuration creation
// in order to provide all information required for the generation of report/meta/graph/model saving
\d .automl

nodekeys:`function`inputs`outputs
i.Param_Consol_inputs  :`Preproc_Params`Prediction_Store!"!!"
i.Param_Consol_outputs :"!"
i.Param_Consol_function:{[prep;pred]prep,pred}
Param_Consolidate:nodekeys!(i.Param_Consol_function;i.Param_Consol_inputs;i.Param_Consol_outputs)
