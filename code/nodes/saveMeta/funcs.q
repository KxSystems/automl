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
  mdlType :mdlMeta`mdlType;
  `modelLib`mdlType!(modelLib;mdlType)
   }

// @kind function
// @category saveMeta
// @fileoverview Save metaData
// @param mdlMeta {dict} Appropriate model meta data generated during the process
// @param params  {dict} All data generated during the process
// return {null} Save metadict to appropriate location
saveMeta.saveMeta:{[mdlMeta;params]
  mdlMeta:mdlMeta,params`config;
  `:metadata set mdlMeta;
  savePath:params[`config;`configSavePath]0;
  // move the metadata information to the appropriate location based on OS
  system$[.z.o like "w*";"move";"mv"]," metadata ",savePath;
  -1"Saving down model parameters to ",utils.ssrsv savePath;
  }
