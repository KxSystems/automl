// Sub select models based on limitations imposed by the dataset, this includes the selecting
// removal of poorly scaling models and the refusal to run Keras models if sufficient samples of each
// class are not present across the folds of the dataset
\d .automl

// @kind function
// @category node
// @fileoverview Delect models based on limitations imposed by the dataset and users environment
// @param tts     {dict} Feature and target data split into training and testing set
// @param target  {(num[];sym[])} Target data as a numeric/symbol vector 
// @param mdl     {tab}  Potential models to be applied to feature data
// @return {tab} Appropriate models to be applied to feature data
selectModels.node.function:{[tts;target;mdls]
  models:selectModels.targetKeras[mdls;tts;target];
  selectModels.targetLimit[models;target]
  }

// Input information
selectModels.node.inputs  :`ttsObject`target`models!"!F+"

// Output information
selectModels.node.outputs :"+"
