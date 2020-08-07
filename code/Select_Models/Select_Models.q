// Sub select models based on limitations imposed by the dataset, this includes the selecting
// removal of poorly scaling models and the refusal to run Keras models if sufficient samples of each
// class are not present across the folds of the dataset
\d .automl

nodekeys:`function`inputs`outputs
i.Select_Models_inputs  :`Config`tts_obj`Models!"! +"
i.Select_Models_outputs :`Models`tts_obj!"+ "
i.Select_Models_function:{[cfg;tts;mdls]`tts_obj`Models!(tts;mdls)}
Select_Models:nodekeys!(i.Select_Models_function;i.Select_Models_inputs;i.Select_Models_outputs)
