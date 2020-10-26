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
  applyType:$[applyType;@;.];
  functionReturn:applyType[function;data];
  expectedReturn~functionReturn
  }

// Load Python version of .ml.traintestsplit
\l code/nodes/dataCheck/tests/pythonTTS.p

\S 10

// Features and targets
featData:([]100?1f;100?1f;asc 100?1f);
targData:100?0b;
sigFeats:`x`x2

// Utilities
matrixTTS:{[x;y;sz]
  value .ml.traintestsplit[x;y;sz]
  }
wrongKeyTTS:{[x;y;sz]
  `a`b`c`d!til 4
  }

// Config
cfg13      :`tts`sz!(`.ml.traintestsplit;.13)
cfg20      :`tts`sz!(`.ml.traintestsplit;.2)
cfg40      :`tts`sz!(`.ml.traintestsplit;.4)
cfgNeg1    :`tts`sz!(`.ml.traintestsplit;-1)
cfgMatrix  :`tts`sz!(`matrixTTS  ;.2)
cfgWrongKey:`tts`sz!(`wrongKeyTTS;.2)
cfgPy      :`tts`sz!(`python_train_test_split;.2)

// Expected output
keyTTSOut:`xtest`xtrain`ytest`ytrain
ttsOut13 :`xtrain`ytrain`xtest`ytest!87 87 13 13 
ttsOut20 :`xtrain`ytrain`xtest`ytest!80 80 20 20 
ttsOut40 :`xtrain`ytrain`xtest`ytest!60 60 40 40 

// Generate testing functions
getKey:{[cfg;featData;targData;sigFeats]
  asc key .automl.trainTestSplit.node.function[cfg;featData;targData;sigFeats]
  }

countFeat:{[cfg;featData;targData;sigFeats]
  count each .automl.trainTestSplit.node.function[cfg;featData;targData;sigFeats]
  }

-1"\nTesting appropriate input data for TrainTestSplit";

// Testing appropriate return for TrainTestSplit
passingTest[getKey   ;(cfg13;featData;targData;sigFeats);0b;keyTTSOut]
passingTest[countFeat;(cfg13;featData;targData;sigFeats);0b;ttsOut13 ]
passingTest[countFeat;(cfg20;featData;targData;sigFeats);0b;ttsOut20 ]
passingTest[countFeat;(cfg40;featData;targData;sigFeats);0b;ttsOut40 ]

// Python tests
passingTest[getKey   ;(cfgPy;featData;targData;sigFeats);0b;keyTTSOut]
passingTest[countFeat;(cfg20;featData;targData;sigFeats);0b;ttsOut20 ]

-1"\nTesting inappropriate input data for TrainTestSplit";

// Failing tests for TrainTestSplit
failingTest[.automl.trainTestSplit.node.function;(cfgMatrix;featData;targData;sigFeats);0b;"Train test split function must return a dictionary with `xtrain`xtest`ytrain`ytest"]
failingTest[.automl.trainTestSplit.node.function;(cfgWrongKey;featData;targData;sigFeats);0b;"Train test split function must return a dictionary with `xtrain`xtest`ytrain`ytest"]
