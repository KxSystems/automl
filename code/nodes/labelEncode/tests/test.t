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


-1"\nTesting appropriate labelencoding";

// Appropriate target data that can be passed to be labelencoded;
apprSymTgt   :`a`b`c`b`b`a`c`b
apprNonSymTgt:{x#/:prd[x]?/:("befhij"$\:0)}[enlist 50]
dictKeys:`symMap`target

// Appropriate return for each target value
apprSymReturn:dictKeys!(`a`b`c!0 1 2;0 1 2 1 1 0 2 1)
apprNonSymReturn:{x!(()!();y)}[dictKeys]each apprNonSymTgt

passingTest[.automl.labelEncode.node.function;apprSymTgt;1b;apprSymReturn]
all passingTest[.automl.labelEncode.node.function;;1b;]'[apprNonSymTgt;apprNonSymReturn]
