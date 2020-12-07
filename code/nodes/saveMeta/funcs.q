\d .automl

// Definitions of the main callable functions used in the application of .automl.saveMeta

// @kind function
// @category saveMeta
// @fileoverview Extract appropriate model meta data
// @param params {dict} All data generated during the process
// return {dict} Appropriate model meta data extracted
saveMeta.extractMdlMeta:{[params]
  mdlMeta:params`modelMetaData;
  modelLib:mdlMeta`modelLib;
  mdlFunc :mdlMeta`mdlFunc;
  `modelLib`mdlFunc!(modelLib;mdlFunc)
   }

// @kind function
// @category saveMeta
// @fileoverview Save metaData
// @param mdlMeta {dict} Appropriate model meta data generated during the process
// @param params  {dict} All data generated during the process
// return {null} Save metadict to appropriate location
saveMeta.saveMeta:{[mdlMeta;params]
  mdlMeta:mdlMeta,params[`config],modelInfo!params modelInfo:`modelName`symEncode`sigFeats;
  `:metadata set mdlMeta;
  savePath:params[`config;`configSavePath];
  // move the metadata information to the appropriate location based on OS
  system$[.z.o like "w*";"move";"mv"]," metadata ",savePath;
  printPath:utils.printDict[`meta],savePath;
  mdlMeta[`logFunc] printPath;
  }
