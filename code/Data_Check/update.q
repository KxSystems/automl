\d .automl

// Update info from Configuration node based on feature dataset
/* t       = tabular information
/* cfg     = configuration dictionary based on user input and start date/time
/. returns > full configuration info needed augmenting cfg with default info
update.config:{[t;cfg]
  typ:cfg`featExtractType;
  // Retrieve any dictionary inputs which are not
  standardCfg:`startDate`startTime`featExtractType`problemType # cfg;
  customCfg:$[`configPath in key[cfg];
              cfg`configPath;
              `startDate`startTime`featExtractType`problemType _ cfg
            ];
  updateCfg:$[typ=`fresh ;i.getCustomConfig[t;customCfg;typ];
              typ=`normal;i.getCustomConfig[t;customCfg;typ];
              typ=`nlp   ;i.getCustomConfig[t;customCfg;typ];
              '`$"Inappropriate feature extraction type"
            ];
  config:standardCfg,updateCfg;
  savePaths:$[0<config`saveopt;i.pathConstruct[config];()!()];
  config,savePaths
  }
