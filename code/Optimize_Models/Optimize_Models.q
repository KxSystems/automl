// Following the initial selection of the most promising model apply the user defined optimization
// grid/random/sobol if feasible (ignore for keras/pytorch etc)
\d .automl

nodekeys:`function`inputs`outputs
i.Optimize_inputs  :`Config`Models`Best_Model`Best_Scoring_Name`tts_obj!"!+<s "
i.Optimize_outputs :`Best_Model`Test_Score`Predictions!"<fF"
i.Optimize_function:{[cfg;mdls;bmdl;bname;tts]`Best_Model`Test_Score`Predictions!(`epymdl;0.8;10?1f)}
Optimize_Models:nodekeys!(i.Optimize_function;i.Optimize_inputs;i.Optimize_outputs)
