// Collect all the parameters relevant for the generation of reports/graphs etc in the prediction step
// such they can be consolidated into a single node later in the workflow
\d .automl

nodekeys:`function`inputs`outputs
i.Predict_Params_inputs  :`Best_Model`Test_Score`Predictions!"<fF"
i.Predict_Params_outputs :"!"
i.Predict_Params_function:{[bmdl;tscore;preds]`best_model`test_score`predictions!(bmdl;tscore;preds)}
Predict_Params:nodekeys!(i.Predict_Params_function;i.Predict_Params_inputs;i.Predict_Params_outputs)
