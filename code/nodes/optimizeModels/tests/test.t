\l automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

// Generate Congifs for grid and random search
configDefault:`scf`prf`seed`trials`hld!((`class`reg!`.ml.accuracy`.ml.mse);`.automl.utils.fitPredict;1234;8;0.2)
configGrid  :configDefault,`gs`hp!((`.automl.gs.kfshuff;2);`grid)
configRandom:configDefault,`rs`hp!((`.automl.rs.kfshuff;2);`random)
configSobol :configDefault,`rs`hp!((`.automl.rs.kfshuff;5);`sobol)

// Suitable configuration for testing of configuration update
configReg     :enlist[`problemType]!enlist`reg
configClass   :enlist[`problemType]!enlist`class

// Generate model dictionaries 
modelDict     :.automl.modelGeneration.txtParse[;"/code/customization/"]
regModelDict  :modelDict configReg
classModelDict:modelDict configClass

feats:100 3#300?10f

// Target values
tgtReg  :100?1f
tgtClass:100?0b

// Target data split into train and testing sets
ttsFeat :        `xtrain`xtest!(80#feats   ;-20#feats)
ttsReg  :ttsFeat,`ytrain`ytest!(80#tgtReg  ;-20#tgtReg)
ttsClass:ttsFeat,`ytrain`ytest!(80#tgtClass;-20#tgtClass)

// Generate model table for reg and class types
regModelTab  :flip`model`lib`fnc`seed`typ!flip key[regModelDict  ],'value regModelDict
classModelTab:flip`model`lib`fnc`seed`typ!flip key[classModelDict],'value classModelDict
regModelTab  :update minit:.automl.modelGeneration.mdlFunc .'flip(lib;fnc;model)from regModelTab;
classModelTab:update minit:.automl.modelGeneration.mdlFunc .'flip(lib;fnc;model)from classModelTab;

// Random Forest best model
randomForestFit      :{[mdl;train;test].p.import[`sklearn.ensemble][mdl][][`:fit][train;test]}
randomForestClassMdl :randomForestFit[`:RandomForestClassifier;;] . ttsClass`xtrain`ytrain
randomForestRegMdl   :randomForestFit[`:RandomForestRegressor ;;] . ttsReg`xtrain`ytrain
randomForestClassName:`RandomForestClassifier
randomForestRegName  :`RandomForestRegressor

// Knn best model
knnFit      :{[mdl;train;test].p.import[`sklearn.neighbors][mdl][][`:fit][train;test]}
knnClassMdl :knnFit[`:KNeighborsClassifier;;] . ttsClass`xtrain`ytrain
knnRegMdl   :knnFit[`:KNeighborsRegressor ;;] . ttsReg`xtrain`ytrain
knnClassName:`KNeighborsClassifier
knnRegName  :`KNeighborsRegressor

// Generate function to check the types of element returned in the dictionary
optimizeFunc:{[cfg;mdls;bmdl;bname;tts]
 type each .automl.optimizeModels.node.function[cfg;mdls;bmdl;bname;tts]
  }

classReturn:`bestModel`hyperParams`modelName`testScore`analyzeModel!105 99 -11 -9 99h
regReturn  :`bestModel`hyperParams`modelName`testScore`analyzeModel!105 99 -11 -9 99h

-1"\nTesting appropriate optimization inputs for Random forest models";

// Test appropriate inputs for reg and class problems
passingTest[optimizeFunc;(configReg,configGrid    ;regModelTab  ;randomForestRegMdl  ;randomForestRegName  ;ttsReg  );0b;regReturn]
passingTest[optimizeFunc;(configReg,configRandom  ;regModelTab  ;randomForestRegMdl  ;randomForestRegName  ;ttsReg  );0b;regReturn]
passingTest[optimizeFunc;(configReg,configSobol   ;regModelTab  ;randomForestRegMdl  ;randomForestRegName  ;ttsReg  );0b;regReturn]
passingTest[optimizeFunc;(configClass,configGrid  ;classModelTab;randomForestClassMdl;randomForestClassName;ttsClass);0b;classReturn]
passingTest[optimizeFunc;(configClass,configRandom;classModelTab;randomForestClassMdl;randomForestClassName;ttsClass);0b;classReturn]
passingTest[optimizeFunc;(configClass,configSobol ;classModelTab;randomForestClassMdl;randomForestClassName;ttsClass);0b;classReturn]

-1"\nTesting appropriate optimization inputs for Knearest neighbor models";

// Test appropriate inputs for reg and class problems
passingTest[optimizeFunc;(configReg,configGrid    ;regModelTab  ;knnRegMdl  ;knnRegName  ;ttsReg  );0b;regReturn]
passingTest[optimizeFunc;(configReg,configRandom  ;regModelTab  ;knnRegMdl  ;knnRegName  ;ttsReg  );0b;regReturn]
passingTest[optimizeFunc;(configReg,configSobol   ;regModelTab  ;knnRegMdl  ;knnRegName  ;ttsReg  );0b;regReturn]
passingTest[optimizeFunc;(configClass,configGrid  ;classModelTab;knnClassMdl;knnClassName;ttsClass);0b;classReturn]
passingTest[optimizeFunc;(configClass,configRandom;classModelTab;knnClassMdl;knnClassName;ttsClass);0b;classReturn]
passingTest[optimizeFunc;(configClass,configSobol ;classModelTab;knnClassMdl;knnClassName;ttsClass);0b;classReturn]

-1"\nTesting inappropriate optimization inputs";

// Generate inappropriate config
inappConfig:configDefault,enlist[`hp]!enlist `inappType

// Expected return error
errReturn:"Unsupported hyperparameter generation method";

failingTest[optimizeFunc;(configReg,inappConfig;regModelTab;randomForestRegMdl;randomForestRegName;ttsReg);0b;errReturn]
