\l automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

// Generate input data to be passed to saveMeta

-1"\nCreating output directory";
// Generate a path to save images to
filePath:"/outputs/testing/configs"
savePath:.automl.utils.ssrWindows .automl.path,filePath
system"mkdir",$[.z.o like"w*";" ";" -p "],savePath;

// Generate model meta data
mdlMetaData:`modelLib`mdlType!`sklearn`class

// Generate config data
configSave :enlist[`configSavePath]!enlist(savePath;0)
configDict0:configSave,`saveopt`featExtractType`problemType!(0;`normal;`reg)
configDict1:configSave,`saveopt`featExtractType`problemType!(1;`fresh ;`class)
configDict2:configSave,`saveopt`featExtractType`problemType!(2;`nlp   ;`reg)

paramDict0:`modelMetaData`config!(mdlMetaData;configDict0)
paramDict1:`modelMetaData`config!(mdlMetaData;configDict1)
paramDict2:`modelMetaData`config!(mdlMetaData;configDict2)

-1"\nTesting appropriate inputs to saveMeta";

// Generate function to check if metadata is saved
metaCheck:{[params;savePath]
  .automl.saveMeta.node.function[params];
  @[{get hsym x};`$savePath,"/metadata";{"No metadata"}]
  }

passingTest[metaCheck;(paramDict0;savePath);0b;"No metadata"]
passingTest[metaCheck;(paramDict1;savePath);0b;raze paramDict1]
passingTest[metaCheck;(paramDict2;savePath);0b;raze paramDict2]

-1"\nRemoving any directories created";

// Remove any directories made
rmPath:.automl.utils.ssrWindows .automl.path,"/outputs/testing/";
system"rm -r ",rmPath;
