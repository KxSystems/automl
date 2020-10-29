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
// @param cfg       {dict} Configuration information relating to the current run of AutoML
// @return {dict} Score, prediction and best model
optimizeModels.hyperSearch:{[mdlDict;mdls;bestModel;modelName;tts;scoreFunc;cfg]
  custom :mdlDict[`mdlLib] in key models;
  exclude:modelName in utils.excludeList; 
  predDict:$[custom|exclude;
    optimizeModels.scorePred[custom;mdlDict;bestModel;tts];
    optimizeModels.paramSearch[mdls;modelName;tts;scoreFunc;cfg]
    ];
  score:get[scoreFunc][predDict`predictions;tts`ytest];
  predDict,`modelName`testScore!(modelName;score)
  }

// @kind function
// @category optimizeModels
// @fileoverview Predict sklearn and custom models on test data
// @param custom     {bool} Whether it is a custom model or not
// @param mdlDict    {dict}  Library and function for best model
// @param bestModel  {<} Fitted best model
// @param tts        {dict} Feature and target data split into training and testing set
// @return {(float[];bool[];int[])} Predicted values  
optimizeModels.scorePred:{[custom;mdlDict;bestModel;tts]
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
// @param cfg        {dict} Configuration information relating to the current run of AutoML
// @return {(float[];bool[];int[])} Predicted values 
optimizeModels.paramSearch:{[mdls;modelName;tts;scoreFunc;cfg]
  // Hyperparameter (HP) search inputs
  hyperParams:optimizeModels.i.extractdict[modelName;cfg];
  hyperTyp:hyperParams`hyperTyp;
  numFolds:cfg[hyperTyp]1;
  numReps:1;
  xTrain:tts`xtrain;
  yTrain:tts`ytrain;
  mdlFunc:utils.bestModelDef[mdls;modelName;`minit];
  scoreCalc:cfg[`prf]mdlFunc;
  // Extract HP dictionary
  hyperDict:hyperParams`hyperDict;
  txtPath:utils.txtParse[;"/code/customization/"];
  module:` sv 2#txtPath[cfg`problemType]modelName;
  embedPyMdl:.p.import[module]hsym modelName;
  hyperFunc:cfg[hyperTyp]0;
  splitCnt:optimizeModels.i.splitCount[hyperFunc;numFolds;tts;cfg];
  hyperDict:optimizeModels.i.updDict[modelName;hyperTyp;splitCnt;hyperDict;cfg];
  // Final parameter required for result ordering and function definition
  orderFunc:get string first txtPath[`score]scoreFunc;
  params:`val`ord`scf!(cfg`hld;orderFunc;scoreFunc);
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
  -1"\nConfusion matrix for testing set:\n";
  confMatrix:.ml.confmat[pred;yTest];
  show optimizeModels.i.confTab[confMatrix];
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
// @param mdls        {tab} Information about models applied to the data
// return {dict} Impact of each column in the data set 
optimizeModels.impactDict:{[mdlDict;hyperSearch;modelName;tts;cfg;scoreFunc;mdls]
  bestModel:hyperSearch`bestModel;
  countCols:count first tts`xtest;
  scores:optimizeModels.i.predShuffle[mdlDict;bestModel;tts;scoreFunc;cfg`seed]each til countCols;
  ordFunc:get string first utils.txtParse[`score;"/code/customization/"]scoreFunc;
  optimizeModels.i.impact[scores;countCols;ordFunc]
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
