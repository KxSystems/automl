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

start:.z.T

\S 10

// Data
feat:([]100?1f;100?1f;asc 100?1f)
targ:asc 100?`a`b`c

// Config
config:`startDate`startTime`featExtractType`problemType!(.z.D;.z.T;`normal;`class)

// Feature Description and Symbol Encoding
featDescOutput:.automl.featureDescription.node.function[config;feat]
descrip:featDescOutput`dataDescription
symEnc :featDescOutput`symEncode

// Feature Creation Time
creationTime:.z.T-start

// Significant Features
sigFeats:enlist`x2

// Symbol Mapping
symMap:.automl.labelEncode.node.function[targ]`symMap

// Feature Creation Model
featModel:()

// Train Test Split data
ttsData:.ml.traintestsplit[feat;targ;.2]

// Functions
outputKey:{[inputs]
  key .automl.preprocParams.node.function . inputs
  }
  
outputTyp:{[inputs]
  value type each .automl.preprocParams.node.function . inputs
  }

// Expected Output
passKey:`config`dataDescription`creationTime`sigFeats`symEncode`symMap`featModel`ttsObject
passTyp:99 99 -19 11 99 99 0 99h

-1"\nTesting all appropriate inputs to preprocParams";
passingTest[outputKey;(config;descrip;creationTime;sigFeats;symEnc;symMap;featModel;ttsData);1b;passKey]
passingTest[outputTyp;(config;descrip;creationTime;sigFeats;symEnc;symMap;featModel;ttsData);1b;passTyp]