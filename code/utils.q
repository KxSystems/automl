\d .automl

// The purpose of this file is to house utilities that are useful across more
// than one node or as part of the AutoML fit functionality and graph.

// @kind function
// @category utility
// @fileoverview List of models to exclude
utils.excludeList:`GaussianNB`LinearRegression

// @kind function
// @category utility
// @fileoverview Defaulted fitting and prediction functions for AutoML cross
//   validation and hyperparameter search. Both models fit on a training set
//   and return the predicted scores based on supplied scoring function.
// @param func {<} Scoring function that takes parameters and data as input, 
//   returns appropriate score
// @param hyperParam {dict} Hyperparameters to be searched
// @param data {float[]} Data split into training and testing sets of format
//   ((xtrn;ytrn);(xval;yval))
// @return {(bool[];float[])} Predicted and true validation values
utils.fitPredict:{[func;hyperParam;data]
  predicts:$[0h~type hyperParam;
    func[data;hyperParam 0;hyperParam 1];
    @[.[func[][hyperParam]`:fit;data 0]`:predict;data[1]0]`
    ];
  (predicts;data[1]1)
  }

// @kind function
// @category utility
// @fileoverview Load function from q. If function not found, try Python.
// @param funcName {sym} Name of function to retrieve
// @return {<} Loaded function
utils.qpyFuncSearch:{[funcName]
  func:@[get;funcName;()];
  $[()~func;.p.get[funcName;<];func]
  }

// @kind function
// @category utility
// @fileoverview Load NLP library if requirements met
// This function takes no arguments and returns nothing. Its purpose is to load
//   the NLP library if requirements are met. If not, a statement printed to 
//   terminal.
utils.loadNLP:{
  notSatisfied:"Requirements for NLP models are not satisfied. gensim must be",
    " installed. NLP module will not be available.";
  $[(0~checkimport 3)&(::)~@[{system"l ",x};"nlp/nlp.q";{0b}];
    .nlp.loadfile`:init.q;
    -1 notSatisfied;
    ];
  }

// @kind function
// @category utility
// @fileoverview Used throughout the library to convert linux/mac file names to
//   windows equivalent
// @param path {str} Linux style path
// @return {str} Path modified to be suitable for windows systems
utils.ssrWindows:{[path]
  $[.z.o like "w*";ssr[;"/";"\\"];]path
  }

// Python plot functionality
utils.plt:.p.import`matplotlib.pyplot;

// @kind function
// @category utility
// @fileoverview Split data into training and testing sets without shuffling
// @param features {tab} Unkeyed tabular feature data
// @param target {num[]} Numerical target vector
// @param size {float} Percentage of data in testing set
// @return {dict} Data separated into training and testing sets
utils.ttsNonShuff:{[features;target;size]
  `xtrain`ytrain`xtest`ytest!
    raze(features;target)@\:/:(0,floor n*1-size)_til n:count features
  }

// @kind function
// @category utility
// @fileoverview Return column value based on best model
// @param modelTab {tab} Models to apply to feature data
// @param modelName {sym} Name of current model
// @param col {sym} Column to search
// @return {sym} Column value
utils.bestModelDef:{[modelTab;modelName;col]
  first?[modelTab;enlist(=;`model;enlist modelName);();col]
  }

// @kind function
// @category automl
// @fileoverview Retrieve feature and target data using information contained
//   in user-defined JSON file
// @param method {dict} Retrieval methods for command line data. i.e.
//   `featureData`targetData!("csv";"ipc")
// @return {dict} Feature and target data retrieved based on user instructions
utils.getCommandLineData:{[method]
  methodSpecification:cli.input`retrievalMethods;
  dict:key[method]!methodSpecification'[value method;key method];
  if[count idx:where`ipc=method;dict[idx]:("J";"c";"c")$/:3#'dict idx];
  dict:dict,'([]typ:value method);
  featureData:.ml.i.loaddset dict`featureData;
  featurePath:dict[`featureData]utils.dataType method`featureData;
  targetPath:dict[`targetData]utils.dataType method`targetData;
  targetName:`$dict[`targetData]`targetColumn;
  // If data retrieval methods are the same for both feature and target data, 
  // only load data once and retrieve the target from the table. Otherwise,
  // retrieve target data using .ml.i.loaddset
  data:$[featurePath~targetPath;
    (flip targetName _ flip featureData;featureData targetName);
    (featureData;.ml.i.loaddset[dict`targetData]$[`~targetName;::;targetName])
    ];
  `features`target!data
  }

// @kind function
// @category utility
// @fileoverview Create a prediction function to be used when applying a 
//   previously fit model to new data. The function calls the predict method
//   of the defined model and passes in new feature data to make predictions.
// @param config {dict} Information about a previous run of AutoML including
//   the feature extraction procedure used and the best model produced
// @param features {tab} Tabular feature data to make predictions on
// @returns {num[]} Predictions
utils.generatePredict:{[config;features]
  original_print:utils.printing;
  utils.printing:0b;
  bestModel:config`bestModel;
  features:utils.featureCreation[config;features];
  modelLibrary:config`modelLib;
  utils.printing:original_print;
  $[`sklearn~modelLibrary;
      bestModel[`:predict;<]features;
    modelLibrary in`keras`torch`theano;
      [features:enlist[`xtest]!enlist features;
       customName:"." sv string config`modelLib`modelFunc;
       get[".automl.models.",customName,".predict"][features;bestModel]
	   ];
    '"NotYetImplemented"
	]
  }

// @kind function
// @category utility
// @fileoverview Apply feature extraction/creation and selection on provided 
//   data based on a previous run
// @param config {dict} Information about a previous run of AutoML including
//   the feature extraction procedure used and the best model produced
// @param features {tab} Tabular feature data to make predictions on
// @returns {tab} Features produced using config feature extraction procedures
utils.featureCreation:{[config;features]
  sigFeats:config`sigFeats;
  extractType:config`featureExtractionType;
  if[`nlp~extractType;config[`savedWord2Vec]:1b];
  if[`fresh~extractType;
    relevantFuncs:raze`$distinct{("_" vs string x)1}each sigFeats;
    appropriateFuncs:1!select from 0!.ml.fresh.params where f in relevantFuncs;
    config[`functions]:appropriateFuncs
	];
  features:dataPreprocessing.node.function[config;features;config`symEncode];
  features:featureCreation.node.function[config;features]`features;
  if[not all newFeats:sigFeats in cols features;
    n:count newColumns:sigFeats where not newFeats;
    features:flip flip[features],newColumns!((n;count features)#0f),()];
  flip value flip sigFeats#"f"$0^features
  }

// @kind function
// @category utility
// @fileoverview Retrieve previous generated model from disk
// @param config {dict} Information about a previous run of AutoML including
//   the feature extraction procedure used and the best model produced
// @returns {tab} Features produced using config feature extraction procedures
utils.loadModel:{[config]
  modelLibrary:config`modelLib;
  loadFunction:$[modelLibrary~`sklearn;
      .p.import[`joblib][`:load];
    modelLibrary~`keras;
      $[check.keras[];
        .p.import[`keras.models][`:load_model];
        '"Keras model could not be loaded"
        ];
    modelLibrary~`torch;
      $[0~checkimport 1;
       .p.import[`torch][`:load];
       '"Torch model could not be loaded"
       ];
    modelLibrary~`theano;
      $[0~checkimport 5;
        .p.import[`joblib][`:load];
        '"Theano model could not be loaded"
        ];
    '"Model Library must be one of 'sklearn', 'keras' or 'torch'"
    ];
  modelPath:config[`modelsSavePath],string config`modelName;
  modelFile:$[modelLibrary~`sklearn`theano;
      modelPath;
    modelLibrary in`keras;
      modelPath,".h5";
    modelLibrary~`torch;
      modelPath,".pt";
    '"Unsupported model type provided"
    ];
  loadFunction modelFile
  }

// @kind function
// @category utility
// @fileoverview Generate the path to a model based on user-defined dictionary
//   input. This assumes no knowledge of the configuration, rather this is the 
//   gateway to retrieve the configuration and models.
// @param dict {dict} Configuration detailing where to retrieve the model which
//   must contain one of the following:
//     1. Dictionary mapping `startDate`startTime to the date and time 
//       associated with the model run.
//     2. Dictionary mapping `savedModelName to a model named for a run 
//       previously executed.
// @returns {char[]} Path to the model information
utils.modelPath:{[dict]
  pathStem:path,"/outputs/";
  keyDict:key dict;
  pathStem,$[all`startDate`startTime in keyDict;
      $[all(-14h;-19h)=type each dict`startDate`startTime;
        ssr[string[dict`startDate],"/run_",string[dict`startTime],"/";":";"."];
        '"Types for date/time retrieval must be date and time respectively"
        ];
    `savedModelName in keyDict;
      $[10h=type dict`savedModelName;
        "namedModels/",dict[`savedModelName],"/";
        '"Types provided for model name based retrieval must be a string"
        ];
    '"A user must define model start date/time or model name.";
    ]
  }

// @kind function
// @category utility
// @fileoverview Extract model meta while checking that the directory for the
//    specified model exists
// @param modelDetails {dict} Details of current model
// @param pathToMeta {hsym} Path to previous model metadata
// @returns {dict} Returns either extracted model metadata or errors out
utils.extractModelMeta:{[modelDetails;pathToMeta]
  details:raze modelDetails;
  modelName:$[10h=type raze value modelDetails;;{sv[" - ";string x]}]details;
  errFunc:{[modelName;err]'"Model ",modelName," does not exist\n"}modelName;
  @[get;pathToMeta;errFunc]
  }

// @kind function
// @category utility
// @fileoverview Dictionary outlining the keys which must be equivalent for 
//   data retrieval in order for a dataset not to be loaded twice (assumes 
//   tabular return under equivalence)
utils.dataType:`ipc`binary`csv!
  (`port`select;`directory`fileName;`directory`fileName)

// @kind function
// @category Utility
// @fileoverview Dictionary with console print statements to reduce clutter
utils.printDict:(!) . flip(
  (`describe;"The following is a breakdown of information for each of the ",
    "relevant columns in the dataset");
  (`errColumns;"The following columns were removed due to type restrictions",
    " for ");
  (`preproc;"Data preprocessing complete, starting feature creation");
  (`sigFeat;"Feature creation and significance testing complete");
  (`totalFeat;"Total number of significant features being passed to the ",
    "models = ");
  (`select;"Starting initial model selection - allow ample time for large",
    " datasets");
  (`scoreFunc;"Scores for all models using ");
  (`bestModel;"Best scoring model = ");
  (`modelFit;"Continuing to final model fitting on testing set");
  (`hyperParam;"Continuing to hyperparameter search and final model fitting ",
    "on testing set");
  (`kerasClass;"Test set does not contain examples of each class removing ",
    "multi-class keras models");
  (`torchModels;"Attempting to run Torch models without Torch installed, ",
    "removing Torch models");
  (`theanoModels;"Attempting to run Theano models without Theano installed, ",
    "removing Theano models");
  (`latexError;"The following error occurred when attempting to run latex",
     " report generation:\n");
  (`score;"Best model fitting now complete - final score on testing set = ");
  (`confMatrix;"Confusion matrix for testing set:");
  (`graph;"Saving down graphs to ");
  (`report;"Saving down procedure report to ");
  (`meta;"Saving down model parameters to ");
  (`model;"Saving down model to "))

// @kind function
// @category Utility
// @fileoverview Dictionary of warning print statements that can be turned 
//   on/off. If two elements are within a key,first element is the warning 
//   given when ignoreWarnings=2, the second is the warning given when 
//   ignoreWarnings=1.
utils.printWarnings:(!) . flip(
  (`configExists;("A configuration file of this name already exists, this run",
    " will be exited";"A configuration file of this name already exists and ",
    "will be overwritten"));
  (`savePathExists;("The savePath chosen already exists, this run will be",
     " exited";"The savePath chosen already exists and will be overwritten"));
  (`loggingPathExists;("The logging path chosen already exists, this run will",
    " be overwritten";"The logging path chosen already exists and will be ",
    "overwritten"));
  (`printDefault;"If saveOption is 0, logging or printing to screen must be ",
     "enabled. Defaulting to .automl.utils.printing:1b");
  (`pythonHashSeed;"For full reproducibility between q processes of the NLP ",
    "word2vec implementation, the PYTHONHASHSEED environment variable must ",
    "be set upon initialization of q. See ",
    "https://code.kx.com/q/ml/automl/ug/options/#seed for details.");
  (`neuralNetWarning;("Limiting the models being applied. No longer running ",
    "neural networks or SVMs. Upper limit for number of targets set to: ";
    "It is advised to remove any neural network or SVM based models from ",
    "model evaluation. Currently running with in a number of data points in",
    " excess of: "))
  )


// @kind function
// @category Utility
// @fileoverview Decide how warning statements should be handles.
//   0=No warning or action taken
//   1=Warning given but no action taken.
//   2=Warning given and appropriate action taken.
utils.ignoreWarnings:2

// @kind function
// @category utility
// @fileoverview Default printing and logging functionality
utils.printing:1b
utils.logging :0b

// @kind function
// @category api
// @fileoverview
// @param filename {sym} Filename to apply to log of outputs to file
// @param val {str} Item that is to be displayed to standard out of any type
// @param nline1 {int} Number of new line breaks before the text that are 
//   needed to 'pretty print' the display
// @param nline2 {int} Number of new line breaks after the text that are needed
//   to 'pretty print' the display
utils.printFunction:{[filename;val;nline1;nline2]
  if[not 10h~type val;val:.Q.s val];
  newLine1:nline1#"\n";
  newLine2:nline2#"\n";
  printString:newLine1,val,newLine2;
  if[utils.logging;
    h:hopen hsym`$filename;
    h printString;
    hclose h;
    ];
  if[utils.printing;-1 printString];
  }
