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

\S 10

// Features and targets
featData :([]100?1f;100?1f;asc 100?1f)
targClass:asc 100?0b
targMulti:asc 100?`a`b`c
targReg  :asc 100?1f

// Configuration
cfg:enlist[`sigFeats]!enlist`.automl.featureSignificance.significance

// Main node function

-1"\nTesting all appropriate inputs for featureSignificance node";

// Gnerate testing function
sigFunction:{[cfg;feats;tgt] 
  sigFeats:.automl.featureSignificance.node.function[cfg;feats;tgt];
  (type sigFeats;key sigFeats)
  }

// Expected output from testing
expectedOutput:(99h;`sigFeats`features)

// Testing appropriate input values for feature significance node
passingTest[sigFunction;(cfg;featData;targClass);0b;expectedOutput]
passingTest[sigFunction;(cfg;featData;targMulti);0b;expectedOutput]
passingTest[sigFunction;(cfg;featData;targReg  );0b;expectedOutput]

// funcs.q functions

-1"\nTesting all appropriate inputs for feature significance function"; 

passingTest[.automl.featureSignificance.significance;(featData;targClass);0b;enlist`x2]
passingTest[.automl.featureSignificance.significance;(featData;targMulti);0b;enlist`x2]
passingTest[.automl.featureSignificance.significance;(featData;targReg  );0b;enlist`x2]

-1"\nTesting all appropriate inputs for correlation function";

// Generate correlation tables
corrTable1:([]asc 100?100;asc 100?100;asc 100?100;100?1f)
corrTable2:([]asc 100?100;asc 100?100;100?1f)
corrTable3:([]100?1f;100?3;100?0b)

// Test appropriate inputs for correlation function
passingTest[.automl.featureSignificance.correlationCols;corrTable1;1b;`x`x3   ]
passingTest[.automl.featureSignificance.correlationCols;corrTable2;1b;`x`x2   ]
passingTest[.automl.featureSignificance.correlationCols;corrTable3;1b;`x`x1`x2]
