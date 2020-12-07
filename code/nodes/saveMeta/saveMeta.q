\d .automl

// Save relevant metadata information for the use of a persisted model on new data

// @kind function
// @category node
// @fileoverview Save all metadata information needed to predict on new data
// @param params {dict} All data generated during the preprocessing and
//  prediction stages
// @return {dict} All metadata information needed to generate predict function
saveMeta.node.function:{[params]
  saveOpt:params[`config]`saveOption;
  if[0~saveOpt;:(::)];
  mdlMeta:saveMeta.extractMdlMeta params;
  saveMeta.saveMeta[mdlMeta;params];
  initConfig:params`config;
  runOutput :mdlkeys!params mdlkeys:`sigFeats`symEncode`bestModel`modelName;
  initConfig,runOutput,mdlMeta
  }

// Input information
saveMeta.node.inputs  :"!"

// Output information
saveMeta.node.outputs :"!"
