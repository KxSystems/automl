// Following the initial selection of the most promising model apply the user defined optimization
// grid/random/sobol if feasible (ignore for keras/pytorch etc)
\d .automl

optimizeModels.node.inputs  :`config`models`bestModel`bestScoringName`ttsObject!"!+<s!"
optimizeModels.node.outputs :`bestModel`hyperParams`testScore`predictions!"<!fF"
optimizeModels.node.function:{[cfg;mdls;bmdl;bname;tts]
  `bestModel`hyperParams`testScore`predictions!(`epymdl;()!();0.8;10?1f)
  }
