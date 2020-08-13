// Update configuration to include default parameters. Check that various aspects of the
// dataset and configuration are suitable for running with AutoML
\d .automl

// Update configuration to include and overwrite default behaviour
// check that the configuration supplied and data provided is sufficient to
// apply machine learning in the context the user is attempting to
/* cfg     = configuration dictionary
/* feat    = feature dataset
/* tgt     = target dataset
/. returns > dictionary containing modified configuration, feature and target datasets
dataCheck.node.function:{[cfg;feat;tgt]
  cfg:dataCheck.config[feat;cfg];
  dataCheck.functions[cfg];
  dataCheck.length[feat;tgt;cfg];
  dataCheck.target[tgt];
  dataCheck.NLPLoad[cfg];
  dataCheck.NLPSchema[cfg;feat];
  feat:dataCheck.featureTypes[feat;cfg];
  `config`features`target!(cfg;feat;tgt)
  }

dataCheck.node.inputs   :`config`features`target!"!+F"
dataCheck.node.outputs  :`config`features`target!"!+F"

