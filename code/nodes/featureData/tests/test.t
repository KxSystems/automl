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


-1"\nTesting inappropriate Feature data types";

// Generate data vectors for testing of the target data ingestion function
genData:{@[;0;string]x#/:prd[x]?/:(`6;`6;0Ng;.Q.a),("befhijxpdznuvt"$\:0)}
inapprArray     :genData[enlist 50]
inapprMatrix    :genData[(5;50)]
inapprDict      :(neg[5]?`5)!first inapprMatrix
inapprPandas    :.p.import[`pandas][`:DataFrame]flip inapprDict
procInapprDict  :`typ`data!`process,enlist inapprDict
procInapprPandas:`typ`data!`process,enlist inapprPandas
procInapprArray :{x!y}[`typ`data]each `process,/:enlist each inapprArray
procInapprMatrix:{x!y}[`typ`data]each `process,/:enlist each inapprMatrix

// Expected error message
errMsg:"Feature dataset must be a simple table for use with Automl"

// Testing of all inappropriately typed target data
failingTest[.automl.featureData.node.function;procInapprDict;1b;errMsg]
all failingTest[.automl.featureData.node.function;;1b;errMsg]each procInapprArray
all failingTest[.automl.featureData.node.function;;1b;errMsg]each procInapprMatrix


-1"\nTesting appropriate target data types";

// Generate appropriate data to be loaded from process
apprTable    :flip inapprDict
procApprTable:`typ`data!(`process;apprTable)

// Testing of all supported target data values
all passingTest[.automl.featureData.node.function;procApprTable;1b;apprTable]

