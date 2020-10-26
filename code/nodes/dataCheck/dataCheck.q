\d .automl

// Update configuration to include default parameters. Check that various aspects of the
// dataset and configuration are suitable for running with AutoML

// @kind function
// @category node
// @fileoverview Ensure that the data and configuration provided are suitable for the application
//   of AutoML, in the case that there are issues error as appropriate or augment the data to 
//   be suitable for the use case in question
// @param cfg  {dict} Configuration information assigned by the user and related to the current run
// @param feat {tab} The feature data as a table 
// @param tgt  {(num[];sym[])} numerical or symbol vector containing the target dataset
// @return     {dict} modified configuration, feature and target datasets.
//   Error on issues with configuration, setup, target or feature dataset
dataCheck.node.function:{[cfg;feat;tgt]
  cfg:dataCheck.updateConfig[feat;cfg];
  dataCheck.functions[cfg];
  dataCheck.length[feat;tgt;cfg];
  dataCheck.target[tgt];
  dataCheck.ttsSize[cfg];
  dataCheck.NLPLoad[cfg];
  dataCheck.NLPSchema[cfg;feat];
  feat:dataCheck.featureTypes[feat;cfg];
  `config`features`target!(cfg;feat;tgt)
  }

// Input information
dataCheck.node.inputs   :`config`features`target!"!+F"

// Output information
dataCheck.node.outputs  :`config`features`target!"!+F"

