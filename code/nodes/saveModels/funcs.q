\d .automl

// Definitions of the main callable functions used in the application of .automl.saveModels

// @kind function
// @category saveGraph
// @fileoverview Save best Model
// @param params   {dict} All data generated during the process
// @param savePath {str} Path where images are to be saved
// return {null} Save best model to appropriate location
saveModels.saveModel:{[params;savePath]
  modelLib :params[`modelMetaData]`modelLib;
  bestModel:params`bestModel;
  modelName:string params`modelName;
  filePath:savePath,"/",modelName;
  joblib:.p.import`joblib;
  $[`sklearn~modelLib;
       joblib[`:dump][bestModel;filePath];
    `keras~modelLib;
       bestModel[`:save][filePath,".h5"];
       `torch~modelLib;
      torch[`:save][bestModel;filePath,".pt"];
    -1"\nSaving of non keras/sklearn/torch models types is not currently supported\n"
  ]; 
  -1"\nSaving down ",modelName," model to ",savePath,"\n";
  }


// @kind function
// @category saveGraph
// @fileoverview Save nlp w2v model
// @param params   {dict} All data generated during the process
// @param savePath {str} Path where images are to be saved
// return {null} Save nlp w2v to appropriate location
saveModels.saveW2V:{[params;savePath]
  extractType:params[`config]`featExtractType;
  if[not extractType~`nlp;:(::)];
  w2vModel:params`featModel;
  w2vModel[`:save][savePath,"w2v.model"];
  } 
