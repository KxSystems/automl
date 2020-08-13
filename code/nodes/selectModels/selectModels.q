// Sub select models based on limitations imposed by the dataset, this includes the selecting
// removal of poorly scaling models and the refusal to run Keras models if sufficient samples of each
// class are not present across the folds of the dataset
\d .automl

selectModels.node.inputs  :`config`ttsObject`models!"! +"
selectModels.node.outputs :`models`ttsObject!"+ "
selectModels.node.function:{[cfg;tts;mdls]`ttsObject`models!(tts;mdls)}
