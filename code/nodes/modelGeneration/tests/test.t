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

// Suitable feature data and configuration for testing of configuration update
featData:([]100?1f;100?1f)
startDateTime:`startDate`startTime!(.z.D;.z.T)
configNLPReg     :startDateTime,`featExtractType`problemType!`nlp`reg
configNLPClass   :startDateTime,`featExtractType`problemType!`nlp`class
configFRESHReg   :startDateTime,`featExtractType`problemType!`fresh`reg
configFRESHClass :startDateTime,`featExtractType`problemType!`fresh`class
configNormalReg  :startDateTime,`featExtractType`problemType!`normal`reg
configNormalClass:startDateTime,`featExtractType`problemType!`normal`class

// list of input configurations
configList:(configNLPReg;configNLPClass;configFRESHReg;
            configFRESHClass;configNormalReg;configNormalClass)


-1"\nTesting inappropriate problem type to build models";

// Inappropriate config problem type
inapprConfig:configNormalClass,enlist[`problemType]!enlist`failTest

// inappropriate file error
fileError:"text file not found"

// Testing inappropriate problem type
failingTest[.automl.modelGeneration.filesCheck;inapprConfig;1b;fileError]


-1"\nTesting appropriate problem type to build models";

// Testing all appropriate problem types
all passingTest[.automl.modelGeneration.filesCheck;;1b;(::)]each configList


-1"\nTesting appropriate inputs to extract desired model dictionary";

// Appropriate configurations should return a dictionary
parsePathGen:.automl.modelGeneration.txtParse[;"/code/customization/"]
all 99h=/:type each parsePathGen each configList


-1"\nTesting appropriate input to extract correct models based on problem type";

// generate model dictionaries 
modelDict     :.automl.modelGeneration.txtParse[;"/code/customization/"]
regModelDict  :modelDict configNormalReg
classModelDict:modelDict configNormalClass

// target values
tgtReg       :100?1f
tgtClass     :100?0b
tgtMultiClass:100?3

// Testing that all problem types return a table
98h~type .automl.modelGeneration.modelPrep[configNormalReg  ;regModelDict  ;tgtReg       ]
98h~type .automl.modelGeneration.modelPrep[configNormalClass;classModelDict;tgtClass     ]
98h~type .automl.modelGeneration.modelPrep[configNormalClass;classModelDict;tgtMultiClass]


-1"\nTesting appropriate inputs to build up the model based on naming convention";

// Generate model table
regModelTab  :flip`model`lib`fnc`seed`typ!flip key[regModelDict  ],'value regModelDict
classModelTab:flip`model`lib`fnc`seed`typ!flip key[classModelDict],'value classModelDict

// Test that all inputs return a lambda or projection type
all (type each .automl.modelGeneration.mdlFunc .'flip regModelTab`lib`fnc`model  )in 100 104h 
all (type each .automl.modelGeneration.mdlFunc .'flip classModelTab`lib`fnc`model)in 100 104h
