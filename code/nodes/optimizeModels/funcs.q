\d .automl

// Definitions of the main callable functions used in the application of .automl.optimizeModels

// @kind function
// @category optimizeModels
// @fileoverview Optimize models using hyperparmeter search procedures if appropriate, 
//   otherwise predict on test data
// @param mdlDict   {dict}  Library and function for best model
// @param mdls      {tab} Information about models applied to the data
// @param bestModel {<} Fitted best model
// @param modelName {sym} Name of best model
// @param tts       {dict} Feature and target data split into training and testing set 
// @param scoreFunc {func} Scoring function
// @param orderFunc {func} Ordering function
// @param cfg       {dict} Configuration information relating to the current run of AutoML
// @return {dict} Score, prediction and best model
optimizeModels.hyperSearch:{[mdlDict;mdls;bestModel;modelName;tts;scoreFunc;orderFunc;cfg]
  custom :mdlDict[`mdlLib] in key models;
  exclude:modelName in utils.excludeList; 
  predDict:$[custom|exclude;
    optimizeModels.scorePred[custom;mdlDict;bestModel;tts;cfg];
    optimizeModels.paramSearch[mdls;modelName;tts;scoreFunc;orderFunc;cfg]
    ];
  score:get[scoreFunc][predDict`predictions;tts`ytest];
  printScore:utils.printDict[`score],string score;
  cfg[`logFunc]printScore;
  predDict,`modelName`testScore!(modelName;score)
  }

// @kind function
// @category optimizeModels
// @fileoverview Predict sklearn and custom models on test data
// @param custom     {bool} Whether it is a custom model or not
// @param mdlDict    {dict}  Library and function for best model
// @param bestModel  {<} Fitted best model
// @param tts        {dict} Feature and target data split into training and testing set
// @param cfg       {dict} Configuration information relating to the current run of AutoML
// @return {(float[];bool[];int[])} Predicted values  
optimizeModels.scorePred:{[custom;mdlDict;bestModel;tts;cfg]
  cfg[`logFunc] utils.printDict`modelFit;
  pred:$[custom;
    optimizeModels.scoreCustom[mdlDict];
    optimizeModels.scoreSklearn
    ][bestModel;tts];
  `bestModel`hyperParams`predictions!(bestModel;()!();pred)
  }

// @kind function
// @category optimizeModels
// @fileoverview Predict custom models on test data
// @param mdlDict   {dict}  Library and function for best model
// @param bestModel {<} Fitted best model
// @param tts       {dict} Feature and target data split into training and testing set
// @return {(float[];bool[];int[])} Predicted values  
optimizeModels.scoreCustom:{[mdlDict;bestModel;tts]
   customName:"." sv string value mdlDict;
   get[".automl.models.",customName,".predict"][tts;bestModel]
   }

// @kind function
// @category optimizeModels
// @fileoverview Predict sklearn models on test data
// @param bestModel  {<} Fitted best model
// @param tts        {dict} Feature and target data split into training and testing set
// @return {(float[];bool[];int[])} Predicted scores
optimizeModels.scoreSklearn:{[bestModel;tts]
  bestModel[`:predict][tts`xtest]`
  }

// @kind function
// @category optimizeModels
// @fileoverview Predict custom models on test data
// @param mdls       {tab} Information about models applied to the data
// @param modelName  {sym} Name of best model
// @param tts        {dict} Feature and target data split into training and testing set
// @param scoreFunc  {func} Scoring function
// @param orderFunc  {func} Order function
// @param cfg        {dict} Configuration information relating to the current run of AutoML
// @return {(float[];bool[];int[])} Predicted values 
optimizeModels.paramSearch:{[mdls;modelName;tts;scoreFunc;orderFunc;cfg]
  cfg[`logFunc]utils.printDict`hyperParam;
  // Hyperparameter (HP) search inputs
  hyperParams:optimizeModels.i.extractdict[modelName;cfg];
  hyperTyp:$[`gs=hyperParams`hyperTyp;"gridSearch";"randomSearch"];
  numFolds:cfg`$hyperTyp,"Argument";
  numReps:1;
  xTrain:tts`xtrain;
  yTrain:tts`ytrain;
  mdlFunc:utils.bestModelDef[mdls;modelName;`minit];
  scoreCalc:get[cfg`predictionFunction]mdlFunc;
  // Extract HP dictionary
  hyperDict:hyperParams`hyperDict;
  embedPyMdl:(exec first minit from mdls where model=modelName)[];
  hyperFunc:cfg`$hyperTyp,"Function";
  splitCnt:optimizeModels.i.splitCount[hyperFunc;numFolds;tts;cfg];
  hyperDict:optimizeModels.i.updDict[modelName;hyperParams`hyperTyp;splitCnt;hyperDict;cfg];
  // Final parameter required for result ordering and function definition
  params:`val`ord`scf!(cfg`holdoutSize;orderFunc;scoreFunc);
  // Perform HP search and extract best HP set based on scoring function
  results:get[hyperFunc][numFolds;numReps;xTrain;yTrain;scoreCalc;hyperDict;params];
  bestHPs:first key first results;
  bestMdl:embedPyMdl[pykwargs bestHPs][`:fit][xTrain;yTrain];
  preds:bestMdl[`:predict][tts`xtest]`;
  `bestModel`hyperParams`predictions!(bestMdl;bestHPs;preds)
  }

// @kind function
// @category optimizeModels
// @fileoverview Create confusion matrix
// @param pred     {dict} All data generated during the process
// @param tts       {dict} Feature and target data split into training and testing set
// @param modelName {str} Name of best model
// @param cfg       {dict} Configuration information relating to the current run of AutoML
// return {dict} Confusion matrix created from predictions and true values
optimizeModels.confMatrix:{[pred;tts;modelName;cfg]
  if[`reg~cfg`problemType;:()!()];
  yTest:tts`ytest;
  if[not type[pred]~type yTest;
    pred :`long$pred;
    yTest:`long$yTest
    ];
  confMatrix:.ml.confmat[pred;yTest];
  confTable:optimizeModels.i.confTab[confMatrix];
  cfg[`logFunc]each (utils.printDict`confMatrix;confTable);
  confMatrix
  }

// @kind function
// @category optimizeModels
// @fileoverview Create impact dictionary
// @param mdlDict     {dict}  Library and function for best model
// @param hyperSearch {dict} Values returned from hyperParameter search
// @param modelName   {str} Name of best model
// @param tts         {dict} Feature and target data split into training and testing set
// @param cfg         {dict} Configuration information relating to the current run of AutoML
// @param scoreFunc   {func} Scoring function
// @param orderFunc   {func} Ordering function
// @param mdls        {tab} Information about models applied to the data
// return {dict} Impact of each column in the data set 
optimizeModels.impactDict:{[mdlDict;hyperSearch;modelName;tts;cfg;scoreFunc;orderFunc;mdls]
  bestModel:hyperSearch`bestModel;
  countCols:count first tts`xtest;
  scores:optimizeModels.i.predShuffle[mdlDict;bestModel;tts;scoreFunc;cfg`seed]each til countCols;
  optimizeModels.i.impact[scores;countCols;orderFunc]
  }

// @kind function
// @category optimizeModels
// @fileoverview Get residuals for regression models
// @param hyperSearch {dict} Values returned from hyperParameter search
// @param tts         {dict} Feature and target data split into training and testing set
// @param cfg         {dict} Configuration information relating to the current run of AutoML
// return {dict} Residual errors and true values
optimizeModels.residuals:{[hyperSearch;tts;cfg]
  if[`class~cfg`problemType;()!()];
  true:tts`ytest;
  pred:hyperSearch`predictions;
  `residuals`preds!(true-pred;pred)
  }
  
// @kind function
// @category optimizeModels
// @fileoverview Consolidate all parameters created from node
// @param hyperSearch {dict} Values returned from hyperParameter search
// @param confMatrix  {dict} Confusion matrix created from model
// @param impactDict  {dict} Impact of each column in data
// @param residuals   {dict} Residual errors for regression problems
// @return {dict} All parameters created during node
optimizeModels.consolidateParams:{[hyperSearch;confMatrix;impactDict;residuals]
  analyzeDict:`confMatrix`impact`residuals!(confMatrix;impactDict;residuals);
  (`predictions _hyperSearch),enlist[`analyzeModel]!enlist analyzeDict
  }
