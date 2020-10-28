\l automl.q
.automl.loadfile`:init.q

// The following utilities are used to test that a function is returning the expected
// error message or data, these functions will likely be provided in some form within
// the test.q script provided as standard for the testing of q and embedPy code


// @kind function
// @category tests
// @fileoverview Ensure that a test that is expected to fail, 
//   does so with an appropriate message
// @param function {(func;proj)} The function or projection to be tested
// @param data {any} The data to be applied to the function as an individual item for
//   unary functions or a list of variables for multivariant functions
// @param applyType {boolean} Is the function to be applied unary(1b) or multivariant(0b)
// @param expectedError {string} The expected error message on failure of the function
// @return {boolean} Function errored with appropriate message (1b), function failed
//   inappropriately or passed (0b)
failingTest:{[function;data;applyType;expectedError]
  // Is function to be applied unary or multivariant
  applyType:$[applyType;@;.];
  failureFunction:{[err;ret](`TestFailing;ret;err~ret)}[expectedError;];
  functionReturn:applyType[function;data;failureFunction];
  $[`TestFailing~first functionReturn;last functionReturn;0b]
  }


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

classReturn:`bestModel`hyperParams`testScore`analyzeModel!105 99 -9 99h
regReturn  :`bestModel`hyperParams`testScore`analyzeModel!105 99 -9 99h

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
