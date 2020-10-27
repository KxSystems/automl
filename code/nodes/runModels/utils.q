\d .automl

// Utility functions for runmodels

// @kind function
// @category runModelsUtility
// @fileoverview Extraction of an appropriately valued dictionary from a non complex flat file
// @param nameMap  {sym} Name mapping to appropriate text file
// @param filePath {str} File path relative to .automl.path
// @return {dict} Parsed from an appropriate flat file
runModels.i.txtParse:{[nameMap;filePath]
  fileName:`$path,filePath,runModels.i.files nameMap;
  runModels.i.readFile each(!).("S*";"|")0:hsym fileName
  }

// @kind function
// @category runModelsUtility
// @fileoverview Extraction of data from a file
// @param filePath {str} File path from which to extract the data from 
// @return {dict} parsed from file
runModels.i.readFile:{[filePath]
  key(!).("S=;")0:filePath
  }

// @kind function
// @category runModelsUtility
// @fileoverview Fit and score custom model to holdout set
// @param bestModel {sym} The best scorinng model from xval
// @param tts       {dict} Feature and target data split into training and testing set
// @param mdls      {tab}  Models to be applied to feature data
// @param scoreFunc {<} Scoring metric applied to evaluate the model
// @param cfg       {dict} Configuration information assigned by the user and related to the current run
// @return {dict} The fitted model along with the predictions
runModels.i.customModel:{[bestModel;tts;mdls;scoreFunc;cfg]
  modelLib:first exec lib from mdls where model=bestModel;
  mdlType  :first exec typ from mdls where model=bestModel;
  if[(`keras~modelLib)&`multi~mdlType;
    tts[`ytrain`ytest]:runModels.i.prepMultiTarget tts
    ];
  modelDef:runModels.i.bestModelDef[mdls;bestModel]each`lib`fnc;
  customStr:".automl.models.",sv[".";string modelDef],".";
  model:get[customStr,"model"][tts;cfg`seed];
  modelFit:get[customStr,"fit"][tts;model];
  modelPred:get[customStr,"predict"][tts;fitModel];
  score:scoreFunc[modelPred;tts`ytest];
  `model`score!(modelFit;score)
  }

// @kind function
// @category runModelsUtility
// @fileoverview One hot encodes target values and converts to Numpy array
// @param tts       {dict} Feature and target data split into training and testing set
// @return {dict} Preprocessed target values
runModels.i.prepMultiTarget:{[tts]
  models.i.npArray flip@'value@'.ml.i.onehot1 each tts`ytrain`ytest
  }

// @kind function
// @category runModelsUtility
// @fileoverview Return column value based on best model
// @param mdls      {tab}  Models to be applied to feature data
// @param bestModel {sym} The best scoring model from xval
// @param col       {sym} Column to search
// @return {sym} Column value
runModels.i.bestModelDef:{[mdls;bestModel;col]
  first?[mdls;enlist(=;`model;enlist bestModel);();col]
  }

// @kind function
// @category runModelsUtility
// @fileoverview Fit and score sklearn model to holdout set
// @param bestModel {sym} The best scorinng model from xval
// @param tts       {dict} Feature and target data split into training and testing set
// @param mdls      {tab}  Models to be applied to feature data
// @param scoreFunc {<} Scoring metric applied to evaluate the model
// @return {dict} The fitted model along with the predictions
runModels.i.sklModel:{[bestModel;tts;mdls;scoreFunc]
  model:runModels.i.bestModelDef[mdls;bestModel;`minit][][];
  model[`:fit]. tts`xtrain`ytrain;
  modelPred:model[`:predict][tts`xtest]`;
  score:scoreFunc[modelPred;tts`ytest];
  `model`score!(model;score)
  }

// @kind function
// @category runModelsUtility
// Text files that can be parsed from within the models folder
runModels.i.files:`class`reg`score!("models/classmodels.txt";"models/regmodels.txt";"scoring/scoring.txt")
