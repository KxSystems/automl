\d .automl

// Following the initial selection of the most promising model apply the user defined optimization
// grid/random/sobol if feasible (ignore for keras/pytorch etc)

/ @kind function
// @category node
// @fileoverview Optimize models using hyperparmeter search procedures if appropriate, 
//  otherwise predict on test data
// @param cfg       {dict} Configuration information assigned by the user and related to the current run
// @param mdls      {tab} Information about models applied to the data
// @param bestModel {<} Fitted best model
// @param modelName {sym} Name of best model
// @param tts       {dict} Feature and target data split into training and testing set 
// @param orderFunc {func} Function used to order scores
// @return {dict} Score, prediction and best model
optimizeModels.node.function:{[cfg;mdls;bestModel;modelName;tts;orderFunc]
  ptype:$[`reg=cfg`problemType;"Regression";"Classification"];
  scoreFunc:cfg`$"scoringFunction",ptype;
  mdlDict  :`mdlLib`mdlFunc!utils.bestModelDef[mdls;modelName]each`lib`fnc;
  hyperSearch :optimizeModels.hyperSearch[mdlDict;mdls;bestModel;modelName;tts;scoreFunc;orderFunc;cfg];
  confMatrix  :optimizeModels.confMatrix[hyperSearch`predictions;tts;modelName;cfg];
  impactReport:optimizeModels.impactDict[mdlDict;hyperSearch;modelName;tts;cfg;scoreFunc;orderFunc;mdls];
  residuals   :optimizeModels.residuals[hyperSearch;tts;cfg];
  optimizeModels.consolidateParams[hyperSearch;confMatrix;impactReport;residuals] 
  }

// Input information
optimizeModels.node.inputs  :`config`models`bestModel`bestScoringName`ttsObject`orderFunc!"!+<s!<"

// Output information
optimizeModels.node.outputs :`bestModel`hyperParams`modelName`testScore`analyzeModel!"<!sf!"
