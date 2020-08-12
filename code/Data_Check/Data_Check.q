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
i.Data_Check_function:{[cfg;feat;tgt]
  cfg:update.config[feat;cfg];
  check.functions[cfg];
  check.length[feat;tgt;cfg];
  check.target[tgt];
  check.NLPType[cfg;feat];
  check.NLPLib[cfg];
  feat:check.featureTypes[feat;cfg];
  `Config`Features`Target!(cfg;feat;tgt)
  }

i.Data_Check_input   :`Config`Features`Target!"!+F"
i.Data_Check_output  :`Config`Features`Target!"!+F"

nodekey:`function`inputs`outputs
Data_Check:nodekey!(i.Data_Check_function;i.Data_Check_input;i.Data_Check_output)
