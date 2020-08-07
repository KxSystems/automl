// Select the 'most promising' model from the list of provided models for the user defined problem
// this is done in a cross validated manner with the best model selected based on its generalizability
// prior to the application of grid/random/sobol search optimization
\d .automl

nodekeys:`function`inputs`outputs
i.Run_Models_inputs  :`Config`tts_obj`Models!"! +"
i.Run_Models_outputs :`Best_Model`Best_Scoring_Name!"<s"
i.Run_Models_function:{[cfg;tts;mdls]`Best_Model`Best_Scoring_Name!(`embedpymdl;`RandomForestRegressor)}
Run_Models:nodekeys!(i.Run_Models_function;i.Run_Models_inputs;i.Run_Models_outputs)
