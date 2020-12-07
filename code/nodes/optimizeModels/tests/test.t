\l automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

// Generate Congifs for grid and random search
configDefault:`scoringFunctionClassification`scoringFunctionRegression`predictionFunction`seed`numberTrials`holdoutSize!(`.ml.accuracy;`.ml.mse;`.automl.utils.fitPredict;1234;8;0.2)
configGrid  :configDefault,`gridSearchFunction`gridSearchArgument`hyperparameterSearchType!(`.automl.gs.kfshuff;2;`grid)
configRandom:configDefault,`randomSearchFunction`randomSearchArgument`hyperparameterSearchType!(`.automl.rs.kfshuff;2;`random)
configSobol :configDefault,`randomSearchFunction`randomSearchArgument`hyperparameterSearchType!(`.automl.rs.kfshuff;5;`sobol)

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
randomForestMdl      :{[mdl;train;test].p.import[`sklearn.ensemble][mdl][][`:fit][train;test]}
randomForestClassFit :randomForestMdl[`:RandomForestClassifier;;] . ttsClass`xtrain`ytrain
randomForestRegFit   :randomForestMdl[`:RandomForestRegressor ;;] . ttsReg`xtrain`ytrain
randomForestClassName:`RandomForestClassifier
randomForestRegName  :`RandomForestRegressor

// Knn best model
knnMdl      :{[mdl;train;test].p.import[`sklearn.neighbors][mdl][][`:fit][train;test]}
knnClassFit :knnMdl[`:KNeighborsClassifier;;] . ttsClass`xtrain`ytrain
knnRegFit   :knnMdl[`:KNeighborsRegressor ;;] . ttsReg`xtrain`ytrain
knnClassName:`KNeighborsClassifier
knnRegName  :`KNeighborsRegressor

// Keras best model
kerasClass    :.automl.models.keras.binary
kerasReg      :.automl.models.keras.reg
kerasClassMdl :kerasClass[`model][ttsClass;1234]
kerasRegMdl   :kerasReg[`model][ttsReg;1234]
kerasClassFit :kerasClass[`fit][ttsClass;kerasClassMdl]
kerasRegFit   :kerasReg[`fit][ttsReg;kerasRegMdl]
kerasClassName:`binarykeras
kerasRegName  :`regkeras


// Generate function to check the types of element returned in the dictionary
optimizeFunc:{[cfg;mdls;bmdl;bname;tts]
 type each .automl.optimizeModels.node.function[cfg;mdls;bmdl;bname;tts]
  }

classReturn:`bestModel`hyperParams`modelName`testScore`analyzeModel!105 99 -11 -9 99h
regReturn  :`bestModel`hyperParams`modelName`testScore`analyzeModel!105 99 -11 -9 99h

-1"\nTesting appropriate optimization inputs for Random forest models";

// Test appropriate inputs for reg and class problems
passingTest[optimizeFunc;(configReg,configGrid    ;regModelTab  ;randomForestRegFit  ;randomForestRegName  ;ttsReg  );0b;regReturn]
passingTest[optimizeFunc;(configReg,configRandom  ;regModelTab  ;randomForestRegFit  ;randomForestRegName  ;ttsReg  );0b;regReturn]
passingTest[optimizeFunc;(configReg,configSobol   ;regModelTab  ;randomForestRegFit  ;randomForestRegName  ;ttsReg  );0b;regReturn]
passingTest[optimizeFunc;(configClass,configGrid  ;classModelTab;randomForestClassFit;randomForestClassName;ttsClass);0b;classReturn]
passingTest[optimizeFunc;(configClass,configRandom;classModelTab;randomForestClassFit;randomForestClassName;ttsClass);0b;classReturn]
passingTest[optimizeFunc;(configClass,configSobol ;classModelTab;randomForestClassFit;randomForestClassName;ttsClass);0b;classReturn]

-1"\nTesting appropriate optimization inputs for Knearest neighbor models";

// Test appropriate inputs for reg and class problems
passingTest[optimizeFunc;(configReg,configGrid    ;regModelTab  ;knnRegFit  ;knnRegName  ;ttsReg  );0b;regReturn]
passingTest[optimizeFunc;(configReg,configRandom  ;regModelTab  ;knnRegFit  ;knnRegName  ;ttsReg  );0b;regReturn]
passingTest[optimizeFunc;(configReg,configSobol   ;regModelTab  ;knnRegFit  ;knnRegName  ;ttsReg  );0b;regReturn]
passingTest[optimizeFunc;(configClass,configGrid  ;classModelTab;knnClassFit;knnClassName;ttsClass);0b;classReturn]
passingTest[optimizeFunc;(configClass,configRandom;classModelTab;knnClassFit;knnClassName;ttsClass);0b;classReturn]
passingTest[optimizeFunc;(configClass,configSobol ;classModelTab;knnClassFit;knnClassName;ttsClass);0b;classReturn]

-1"\nTesting appropriate optimization inputs for Keras models";

// Test appropriate inputs for reg and class problems, assuming that keras is installed in the environment
passingTest[optimizeFunc;(configReg,configGrid    ;regModelTab  ;kerasRegFit  ;kerasRegName  ;ttsReg  );0b;regReturn]
passingTest[optimizeFunc;(configReg,configRandom  ;regModelTab  ;kerasRegFit  ;kerasRegName  ;ttsReg  );0b;regReturn]
passingTest[optimizeFunc;(configReg,configSobol   ;regModelTab  ;kerasRegFit  ;kerasRegName  ;ttsReg  );0b;regReturn]
passingTest[optimizeFunc;(configClass,configGrid  ;classModelTab;kerasClassFit;kerasClassName;ttsClass);0b;classReturn]
passingTest[optimizeFunc;(configClass,configRandom;classModelTab;kerasClassFit;kerasClassName;ttsClass);0b;classReturn]
passingTest[optimizeFunc;(configClass,configSobol ;classModelTab;kerasClassFit;kerasClassName;ttsClass);0b;classReturn]

-1"\nTesting inappropriate optimization inputs";

// Generate inappropriate config
inappConfig:configDefault,enlist[`hyperparameterSearchType]!enlist `inappType

// Expected return error
errReturn:"Unsupported hyperparameter generation method";

failingTest[optimizeFunc;(configReg,inappConfig;regModelTab;randomForestRegFit;randomForestRegName;ttsReg);0b;errReturn]
