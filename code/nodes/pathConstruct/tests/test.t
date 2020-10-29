\l automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

\S 42

// Generate data for preProc params 

// Generate Configuration dictionaries
configSave0:`saveopt`startTime`startDate!(0;"t"$0;"d"$1)
configSave1:`saveopt`startTime`startDate!(1;"t"$1;"d"$1)
configSave2:`saveopt`startTime`startDate!(2;"t"$2;"d"$1)

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

-1"\nTesting all appropriate directories are created";

// Generate function to check that all directories are created 
dirCheck:{[preProcParams;predictionStore;saveOpt]
  .automl.pathConstruct.node.function[preProcParams;predictionStore];
  outputDir:.automl.path,"/outputs/2000.01.02/run_00.00.00.00",saveOpt;
  outputDir:.automl.utils.ssrwin outputDir;
  @[{`$system $[.z.o like "w*";"dir ";"ls "],x};outputDir;{`}]
  }

returnDir0:`
returnDir1:`config`models
returnDir2:`config`images`models`report

// Testing all appropriate directories were created
passingTest[dirCheck;(preProcDict0;predictionStoreDict;"0");0b;`]
passingTest[dirCheck;(preProcDict1;predictionStoreDict;"1");0b;returnDir1]
passingTest[dirCheck;(preProcDict2;predictionStoreDict;"2");0b;returnDir2]

-1"\nTesting appropriate inputs for pathConstruct";

// Create function to extract keys of return dictionary
pathConstructFunc:{[preProcParams;predictionStore]
  returnDict:.automl.pathConstruct.node.function[preProcParams;predictionStore];
  key returnDict
  }

// Expected return dictionary
paramReturn:key[preProcDict],`config,key[predictionStoreDict]

// Testing appropriate inputs for pathConstruct
passingTest[pathConstructFunc;(preProcDict0;predictionStoreDict);0b;paramReturn]
passingTest[pathConstructFunc;(preProcDict1;predictionStoreDict);0b;paramReturn]
passingTest[pathConstructFunc;(preProcDict2;predictionStoreDict);0b;paramReturn]


-1"\nRemoving any directories created";

// Remove any folders created
rmPath:.automl.utils.ssrwin .automl.path,"/outputs/2000.01.02/";
system $[.z.o like "w*";"rmdir ",rmPath," /s";"rm -r ",rmPath];
