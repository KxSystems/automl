\d .automl

// Utility functions for optimizeModels

// @kind function
// @category optimizeModelsUtility
// @fileoverview Extract the hyperparameter dictionaries based on the applied model
// @param bestModel  {<} Fitted best Model
// @param cfg        {dict} Configuration information assigned 
//   by the user and related to the current run
// @return {dict} The hyperparameters appropriate for the model being used
optimizeModels.i.extractdict:{[bestModel;cfg]
  hyperParam:cfg`hyperparameterSearchType;
  // Get grid/random hyperparameter file name
  hyperTyp:$[`grid=hyperParam;`gs;
    hyperParam in`random`sobol;`rs;
    '"Unsupported hyperparameter generation method"
    ];
  // Load in table of hyperparameters to dictionary with (hyperparameter!values)
  hyperParamsDir:path,"/code/customization/hyperParameters/";
  hyperParamFile:string[hyperTyp],"HyperParameters.json";
  hyperParams:.j.k raze read0`$hyperParamsDir,hyperParamFile;
  extractParams:hyperParams bestModel;
  typeConvert:`$extractParams[`meta;`typeConvert];
  n:where `symbol=typeConvert;
  typeConvert[n]:`;
  extractParams:$[`gs~hyperTyp;
    optimizeModels.i.gridParams;
    optimizeModels.i.randomParams] . (extractParams;typeConvert);
  `hyperTyp`hyperDict!(hyperTyp;extractParams)
  }

// @kind function
// @category optimizeModelsUtility
// @fileoverview Convert hyperparameters from json to the correct types
// @param extractParams {dict} Hyperparameters for the given model type (class/reg)
//   initially parsed with '.j.k' from 'gsHyperParameters.json'
// @param typeConvert   {str}  List of appropriate types to convert the hyperparameters to
// @return {dict} Hyperparameters cast to appropriate representation
optimizeModels.i.gridParams:{[extractParams;typeConvert]
  typeConvert$'extractParams[`Parameters]
  }

// @kind function
// @category optimizeModelsUtility
// @fileoverview Parse the correct structure for random/sobol search from
//   JSON format provided 
// @param extractParams {dict} Hyperparameters for the given model type (class/reg)
//   initially parsed with '.j.k' from 'rsHyperParameters.json'
// @param typeConvert   {str} List of appropriate types to convert the hyperparameters to
// @return {dict} Hyperparameters converted to an appropriate representation
optimizeModels.i.randomParams:{[extractParams;typeConvert]
  randomType:`$extractParams[`meta;`randomType];
  paramDict:extractParams`Parameters;
  params:typeConvert$'paramDict;
  // Generate the structure required for random/sobol search
  paramsJoin:randomType,'value[params],'typeConvert;
  key[paramDict]!paramsJoin
  }

// @kind function
// @category optimizeModelsUtility
// @fileoverview Split the training data into a representation of the breakdown of data for 
//  the hyperparameter search. This is used to ensure that if a hyperparameter search is done 
//  on KNN that there are sufficient, data points in the validation set for all hyperparameter 
//  nearest neighbour calculations.
// @param hyperFunc {sym} Hyperparameter function to be used
// @param numFolds  {int} Number of folds to use
// @param tts       {dict} Feature and target data split into training and testing set
// @param cfg       {dict} Configuration information assigned by the user and related to the current run
// @return {dict} The hyperparameters appropriate for the model being used
optimizeModels.i.splitCount:{[hyperFunc;numFolds;tts;cfg]
 $[hyperFunc in`mcsplit`pcsplit;
   1-numFolds;
   (numFolds-1)%numFolds
   ]*count[tts`xtrain]*1-cfg`holdoutSize
  }

// @kind function
// @category optimizeModelsUtility
// @fileoverview Alter hyperParameter dictionary depending on bestModel and type
//  of hyperopt to be used
// @param modelName {sym} Name of best model
// @param hyperTyp  {sym} Type of hyperparameter to be used
// @param splitCnt  {int} How data shoudl be split for hyperParam search
// @param hyperDict {dict} HyperParameters used for hyperParam search  
// @param cfg       {dict} Configuration information assigned by the user and related to the current run
// @return {dict} The hyperparameters appropriate for the model being used
optimizeModels.i.updDict:{[modelName;hyperTyp;splitCnt;hyperDict;cfg]
  knModel:modelName in`KNeighborsClassifier`KNeighborsRegressor;
  if[knModel&hyperTyp~`gs;
    n:splitCnt<hyperDict`n_neighbors;
    if[0<count where n;
      hyperDict[`n_neighbors]@:where not n
      ]
    ];
  if[hyperTyp~`rs;
    if[knModel;
      if[splitCnt<hyperDict[`n_neighbors;2];
        hyperDict[`n_neighbors;2]:"j"$splitCnt
        ]
      ];
    hyperDict:`typ`random_state`n`p!(cfg`hyperparameterSearchType;cfg`seed;cfg`numberTrials;hyperDict)
    ];
  hyperDict
  }

// @kind function
// @category optimizeModelsUtilitity
// @fileoverview Show true and predicted values from confusion matrix
// @param confMatrix {dict} Confusion matric
// @return {dict} Confusion matrix with true and predicted values
optimizeModels.i.confTab:{[confMatrix]
  keyMatrix:string key confMatrix;
  predVals:`$"pred_",/:keyMatrix;
  trueVals:`$"true_",/:keyMatrix;
  predVals!flip trueVals!flip value confMatrix
  }

// @kind function
// @category optimizeModelsUtilitity
// @fileoverview Save down confusionMatrix
// @param modelDict   {dict}  Library and function of model
// @param bestModel {<} Fitted best model
// @param tts       {dict} Feature and target data split into training and testing set
// @param scoreFunc {<} Scoring metric applied to evaluate the model
// @param seed      {int} Random seed to use
// @param idx       {int} Index of column that is being shuffled
// return {float} Score returned from predicted values using shuffled data 
optimizeModels.i.predShuffle:{[modelDict;bestModel;tts;scoreFunc;seed;idx]
  tts[`xtest]:optimizeModels.i.shuffle[tts`xtest;idx];
  preds:$[modelDict[`modelLib] in key models;
    [customModel:"." sv string modelDict`modelLib`modelFunc;
     predFunc:get".automl.models.",customModel,".predict";
     predFunc[tts;bestModel]];
    bestModel[`:predict][tts`xtest]`
    ];
  scoreFunc[preds;tts`ytest]
  }

// @kind function
// @category optimizeModelsUtility
// @fileoverview Shuffle column within the data
// @param data {float[]} Data to shuffle
// @param col  {int} Column in data to shuffle
// @return {float[]} The original data shuffled 
optimizeModels.i.shuffle:{[data;col]
  countData:count data;
  idx:neg[countData]?countData;
  $[98h~type data;
    data:data[col]idx;
    data[;col]:data[;col]idx
    ];
  data
  }

// @kind function
// @category optimizeModelsUtility
// @fileoverview Create dictionary of impact of each column in ascending order
// @param scores    {float[]} Impact score of each column
// @param countCols {int} Number of columns in the feature data
// @param ordFunc   {func} Ordeing of scores 
// @return {dict} Impact score of each column in ascending order 
optimizeModels.i.impact:{[scores;countCols;ordFunc]
  scores:$[any 0>scores;.ml.minMaxScaler.fitPredict;]scores;
  scores:$[ordFunc~desc;1-;]scores;
  keyDict:til countCols;
  asc keyDict!scores%max scores
  }


// Updated cross validation functions necessary for the application of hyperparameter search ordering correctly.
// Only change is expected input to the t variable of the function, previously this was a simple
// floating point values -1<x<1 which denotes how the data is to be split for the train-test split.
// Expected input is now at minimum t:enlist[`val]!enlist num, while for testing on the holdout sets this
// should be include the scoring function and ordering the model requires to find the best model
// `val`scf`ord!(0.2;`.ml.mse;asc) for example

// @kind function
// @category optimizeModelsUtility
// @fileoverview Modified hyperparameter search with option to test final model 
// @param scoreFunc {func} Scoring function
// @param k {int} Number of folds
// @param n {int} Number of repetitions
// @param features {#any[][]} Matrix of features
// @param target {#any[]} Vector of targets
// @param dataFunc {func} Function which takes data as input
// @param hyperparams {dict} Dictionary of hyperparameters
// @param testType {float} Size of the holdout set used in a fitted grid 
//   search, where the best model is fit to the holdout set. If 0 the function 
//   will return scores for each fold for the given hyperparameters. If 
//   negative the data will be shuffled prior to designation of the holdout set
// @return {table/(table;dict;float)} Either validation or testing results from 
//   hyperparameter search with (full results;best set;testing score)
hp.i.search:{[scoreFunc;k;n;features;target;dataFunc;hyperparams;testType]
  if[0=testType`val;:scoreFunc[k;n;features;target;dataFunc;hyperparams]];
  dataShuffle:$[0>testType`val;xv.i.shuffle;til count@]target;
  i:(0,floor count[target]*1-abs testType`val)_dataShuffle;
  r:scoreFunc[k;n;features i 0;target i 0;dataFunc;hyperparams];
  func:get testType`scf;
  res:$[type[func]in(100h;104h);
    dataFunc[pykwargs pr:first key testType[`ord]each func[;].''];
    dataFunc[pykwargs pr:first key desc avg each r](features;target)@\:/:i
    ];
  (r;pr;res)
  }

// @kind data
// @category optimizeModelsUtility
// @fileoverview All possible gs/rs functions
xvKeys:`kfSplit`kfShuff`kfStrat`tsRolls`tsChain`pcSplit`mcSplit

// @kind function
// @category optimizeModelsUtility
// @fileoverview Update gs functions with automl `hp.i.search` function
gs:xvKeys!{hp.i.search last value x}each .ml.gs xvKeys

// @kind data
// @category optimizeModelsUtility
// @fileoverview Update rs functions with automl `hp.i.search` function
rs:xvKeys!{hp.i.search last value x}each .ml.rs xvKeys
