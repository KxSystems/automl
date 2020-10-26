// Select the 'most promising' model from the list of provided models for the user defined problem
// this is done in a cross validated manner with the best model selected based on its generalizability
// prior to the application of grid/random/sobol search optimization
\d .automl

runModels.node.inputs  :`config`ttsObject`models!"!!+"
runModels.node.outputs :`bestModel`modelMetaData`bestScoringName!"<!s"
runModels.node.function:{[cfg;tts;mdls]
  `bestModel`modelMetaData`bestScoringName!(`embedpymdl;()!();`RandomForestRegressor)
  }