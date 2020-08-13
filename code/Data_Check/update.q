\d .automl

// Update configuration based on feature dataset and default parameters
/* t       = tabular information
/* cfg     = path to flat file containing configuration dictionary based on user input, augmented with start date/time,
/*           
/. returns > full configuration info needed augmenting cfg with default info
/.           retrieve 
update.config:{[t;cfg]
  typ:cfg`featExtractType;
  // Retrieve boiler plate additions at run start s.t. they can be ignored in custom additions
  standardCfg:`startDate`startTime`featExtractType`problemType # cfg;
  // Retrieve any custom configuration information used to update default parameters
  customCfg:$[`configPath in key[cfg];
              cfg`configPath;
              `startDate`startTime`featExtractType`problemType _ cfg
            ];
  // Retrieve default parameters and replace defaults with any custom configuration defined
  updateCfg:$[typ in `normal`nlp`fresh;
              i.getCustomConfig[t;customCfg;typ];
              '`$"Inappropriate feature extraction type"
            ];
  config:standardCfg,updateCfg;
  // If applicable add save path information to configuration dictionary
  savePaths:$[0<config`saveopt;i.pathConstruct[config];()!()];
  config,savePaths
  }

