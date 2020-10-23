\l automl.q
.automl.loadfile`:init.q

// The following utilities are used to test that a function is returning the expected
// error message or data, these functions will likely be provided in some form within
// the test.q script provided as standard for the testing of q and embedPy code

// @kind function
// @category tests
// @fileoverview Ensure that a test that is expected to pass, 
//   does so with an appropriate return
// @param function {(func;proj)} The function or projection to be tested
// @param data {any} The data to be applied to the function as an individual item for
//   unary functions or a list of variables for multivariant functions
// @param applyType {boolean} Is the function to be applied unary(1b) or multivariant(0b)
// @param expectedReturn {string} The data expected to be returned on 
//   execution of the function with the supplied data
// @return {boolean} Function returned the appropriate output (1b), function failed 
//   or executed with incorrect output (0b)
passingTest:{[function;data;applyType;expectedReturn]
  // Is function to be applied unary or multivariant
  applyType:$[applyType;@;.];
  functionReturn:applyType[function;data];
  expectedReturn~functionReturn
  }

\S 42

// Generate data for preProc params 

// Generate Configuration dictionaries
configSave0:`saveopt`startTime`startDate!(0;"t"$1;"d"$1)
configSave1:`saveopt`startTime`startDate!(1;"t"$1;"d"$1)
configSave2:`saveopt`startTime`startDate!(2;"t"$1;"d"$1)

// Generate preProcParams dictionary
preProcKeys:`dataDescription`symMap`creationTime`sigFeats`featModel
preProcVals:(([]col1:10?10;col2:10?1f);`freq`ohe!`col1`col2;1?1t;`feat1`feat2;.p.import`gensim)
preProcDict :preProcKeys!preProcVals

preProcDict0:preProcDict,enlist[`config]!enlist configSave0
preProcDict1:preProcDict,enlist[`config]!enlist configSave1
preProcDict2:preProcDict,enlist[`config]!enlist configSave2

// Generate data for prediction params

// Feature Data
feats:100 3#300?10f

// Target values
tgtClass:100?0b

// Target data split into train and testing sets
ttsFeat :        `xtrain`xtest!(80#feats   ;-20#feats)
ttsClass:ttsFeat,`ytrain`ytest!(80#tgtClass;-20#tgtClass)

// Random Forest best model
randomForestFit:{[mdl;train;test].p.import[`sklearn.ensemble][mdl][][`:fit][train;test]}
randomForestMdl:randomForestFit[`:RandomForestClassifier;;] . ttsClass`xtrain`ytrain

// Generate meta data from running models
modelMetaKeys:`holdoutScore`modelScores`metric`xValTime`holdoutTime
modelMetaVals:(1?100f;`mdl1`mdl2`mdl3!3?100f;`accuracy;1?1t;1?1t)
modelMetaData:modelMetaKeys!modelMetaVals

// Generate prediction params dictionary
predictionStoreKeys:`bestModel`hyperParams`testScore`predictions`modelMetaData
predictionStoreVals:(randomForestMdl;`feat1`feat2!1 2;100;100?0b;modelMetaData)
predictionStoreDict:predictionStoreKeys!predictionStoreVals


-1"\nTesting appropriate inputs for pathConstruct";

// Create function to extract keys of return dictionary
pathConstructFunc:{[preProcParams;predictionStore]
  returnDict:.automl.pathConstruct.node.function[preProcParams;predictionStore];
  key returnDict
  }

// Expected return dictionary
paramReturn:key[preProcDict],`config,key[predictionStoreDict],`pathDict

// Testing appropriate inputs for pathConstruct
passingTest[pathConstructFunc;(preProcDict0;predictionStoreDict);0b;paramReturn]
passingTest[pathConstructFunc;(preProcDict1;predictionStoreDict);0b;paramReturn]
passingTest[pathConstructFunc;(preProcDict2;predictionStoreDict);0b;paramReturn]


-1"\nTesting appropriate paths are constructed for each saveOpt";

// Generate function to check what paths were created
pathConstructChk:{[preProcParams;predictionStore]
  returnDict:.automl.pathConstruct.node.function[preProcParams;predictionStore];
  key returnDict[`pathDict]
  }

// Expected return values
paramReturn0:()
paramReturn1:`config`models
paramReturn2:paramReturn1,`images`report

// Test that appropriate paths are created for saveOpt
passingTest[pathConstructChk;(preProcDict0;predictionStoreDict);0b;paramReturn0]
passingTest[pathConstructChk;(preProcDict1;predictionStoreDict);0b;paramReturn1]
passingTest[pathConstructChk;(preProcDict2;predictionStoreDict);0b;paramReturn2]

// Remove any folders created
rmPath:.automl.utils.ssrwin .automl.path,"/outputs/2000.01.02/";
system $[.z.o like "w*";"rmdir ",rmPath," /s";"rm -r ",rmPath];
