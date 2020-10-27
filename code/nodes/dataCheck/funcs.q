\d .automl

// Definitions of the main callable functions used in the application of .automl.dataCheck


// Configuration update

// @kind function
// @category dataCheck
// @fileoverview Update configuration based on feature dataset and default parameters
// @param feat {tab} The feature data as a table
// @param cfg  {(dict;char[])} Path to flat file containing configuration dictionary or a dictionary 
//   containing relevant information for the update of augmented with start date/time,
// @return     {dict} full configuration info needed augmenting cfg with any default information
dataCheck.updateConfig:{[feat;cfg]
  typ:cfg`featExtractType;
  // Retrieve boiler plate additions at run start s.t. they must be ignored in custom additions
  standardCfg:`startDate`startTime`featExtractType`problemType # cfg;
  // Retrieve any custom configuration information used to update default parameters
  customCfg:$[`configPath in key cfg;
              cfg`configPath;
              `startDate`startTime`featExtractType`problemType _ cfg
            ];
  // Retrieve default parameters and replace defaults with any custom configuration defined
  updateCfg:$[typ in `normal`nlp`fresh;
              dataCheck.i.getCustomConfig[feat;customCfg;typ];
              '`$"Inappropriate feature extraction type"
            ];
  config:standardCfg,updateCfg;
  // If applicable add save path information to configuration dictionary
  savePaths:$[0<config`saveopt;dataCheck.i.pathConstruct[config];()!()];
  if[`rand_val~config[`seed];config[`seed]:"j"$.z.t];
  config,savePaths
  }


// Data and configuration checking 

// @kind function
// @category dataCheck
// @fileoverview Ensure that any non default functions a user wishes to use 
//   exist within the current process such that they are callable
// @param cfg {dict} configuration information relating to the current run of AutoML
// @return    {(Null;err)} error indicating invalid fuctions otherwise generic null on success
dataCheck.functions:{[cfg]
  // List of possible objects where user may input a custom function
  function:raze cfg[`funcs`prf`tts`sigFeats],value[cfg`scf],first each cfg`xv`gs;
  // Ensure the custom inputs are suitably typed
  locs:@[{$[not type[utils.qpyFuncSearch x]in(99h;100h;104h;105h);'err;0b]};;{[err]err;1b}]each function;
  if[0<cnt:sum locs;
     functionList:{$[2>x;" ",raze[y]," is";"s ",sv[", ";y]," are"]}[cnt]string function where locs;
    '`$"The function",functionList," not defined in your process\n"
  ]
  }

// @kind function
// @category dataCheck
// @fileoverview Ensure that NLP functionality is available if a user needs to call it
// @param cfg {dict} configuration information relating to the current run of AutoML
// @return    {(Null;err)} error indicating unsufficient requirements on issue otherwise generic null
dataCheck.NLPLoad:{[cfg]
  if[not `nlp~cfg`featExtractType;:()];
  if[not (0~checkimport[3]) & ((::)~@[{system"l ",x};"nlp/nlp.q";{0b}]);
    '"User attempting to run NLP models with insufficient requirements, see documentation"];
  if[""~getenv`PYTHONHASHSEED;
    -1"For full reproducibility between q processes of the NLP word2vec implementation,",
    " the PYTHONHASHSEED environment variable must be set upon initialization of q. See ",
    "https://code.kx.com/q/ml/automl/ug/options/#seed for details.";
    ];
  }

// @kind function
// @category dataCheck
// @fileoverview Ensure the data contains an appropriate type for application of NLP
// @param cfg  {dict} configuration information relating to the current run of AutoML
// @param feat {tab} the feature data as a table
// @return     {(Null;err)} error indicating inappropriate data or generic null on success
dataCheck.NLPSchema:{[cfg;feat]
  if[not `nlp~cfg`featExtractType;:()];
  if[0~count .ml.i.fndcols[feat;"C"];
    '`$"User wishing to apply nlp functionality must pass a table containing a character column."];
  }

// @kind function
// @category dataCheck
// @fileoverview Remove columns from the feature dataset which do not fit conform to allowed schema
// @param feat {tab} the feature data as a table
// @param cfg  {dict} configuration information relating to the current run of AutoML
// @return     {tab}  feature dataset with inappropriate columns removed and highlighted to user
dataCheck.featureTypes:{[feat;cfg]
  typ:cfg`featExtractType;
  $[typ in `tseries`normal;
    [fCols:.ml.i.fndcols[feat;"sfihjbepmdznuvt"];
     tab:flip fCols!feat fCols
    ];
    typ=`fresh;
    // ignore the aggregating columns for FRESH as these can be of any type
    [apprCols:flip(aggCols:cfg[`aggcols])_ flip feat;
      cls:.ml.i.fndcols[apprCols;"sfiehjb"];
      // restore the aggregating columns
      tab:flip(aggCols!feat aggCols,:()),cls!feat cls;
      fCols:cols tab
    ];
    typ=`nlp;
    [fCols:.ml.i.fndcols[feat;"sfihjbepmdznuvtC"];
     tab:flip fCols!feat fCols];
    '`$"This form of feature extraction is not currently supported"];
  dataCheck.i.errColumns[cols feat;fCols;typ];
  tab
  }

// @kind function
// @category dataCheck
// @fileoverview Ensure that the target data and final feature dataset are of the same length
// @param feat {tab} the feature data as a table
// @param tgt  {(num[];sym[])} the target data as a numeric/symbol vector 
// @param cfg  {dict} configuration information relating to the current run of AutoML
// @return     {(Null;err)} error on length check between target and feature otherwise generic null
dataCheck.length:{[feat;tgt;cfg]
  typ:cfg`featExtractType;
  $[-11h=type typ;
    $[`fresh=typ;
      // Check that the number of unique aggregating sets is the same as number of targets
      if[count[tgt]<>count distinct $[1=count cfg`aggcols;feat[cfg`aggcols];(,'/)feat cfg`aggcols];
         '`$"Target count must equal count of unique agg values for fresh"
      ];
      typ in`normal`nlp;
      if[count[tgt]<>count feat;'"Must have the same number of targets as values in table"];
      '"Input for typ must be a supported type"
    ];
    '"Input for typ must be a supported symbol"
  ]
  }

// @kind function
// @category dataCheck
// @fileoverview Ensure target data contains more than one unique value
// @param tgt {(num[];sym[])} the target data as a numeric/symbol vector
// @return    {(Null;err)} error on unsuitable target otherwise generic null
dataCheck.target:{[tgt]
  if[1=count distinct tgt;'"Target must have more than one unique value"]
  }

// @kind function
// @category dataCheck
// @fileoverview Checks that the traintestsplit size provided in cfg is a floating value between
//   0 and 1
// @param cfg  {dict} configuration information relating to the current run of AutoML
// @return {(Null;err)} error on unsuitable target otherwise generic null
dataCheck.ttsSize:{[cfg]
  if[(sz<0.)|(sz>1.)|-9h<>type sz:cfg`sz;'"Testing size must be in range 0-1"]
  }
