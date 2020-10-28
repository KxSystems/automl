\d .automl

// Collect all the parameters relevant for the generation of reports/graphs etc in the prediction step
// such they can be consolidated into a single node later in the workflow

// @kind function
// @category node
// @fileoverview Collect all relevant parameters from previous prediction steps to 
//  be consolidated for report/graph generation
// @param bestModel     {<} The best model fitted 
// @param hyperParmams  {dict} Hyperparameters used for model (if any)
// @param testScore     {float} Score of model on testing data
// @param modelMetaData {dict} Meta data from finding best model
// @return {dict} Consolidated parameters to be passed to generate reports/graphs 
predictParams.node.function:{[bestModel;hyperParams;testScore;predictions;modelMetaData]
  predictParams.printScore[testScore];
  returnKeys:`bestModel`hyperParams`testScore`analyzeModels`modelMetaData;
  returnKeys!(bestModel;hyperParams;testScore;analyzeModels;modelMetaData)
  }

// Input information
predictParams.node.inputs  :`bestModel`hyperParams`testScore`analyzeModel`modelMetaData!"<!f!!"

// Output information
predictParams.node.outputs :"!"

