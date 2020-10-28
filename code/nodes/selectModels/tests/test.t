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


-1"\nTesting that keras models are removed when not appropriate to use";

-1"\nThe below tests assume that keras is not installed in the given environment";

// Suitable configuration for testing of configuration update
configReg     :enlist[`problemType]!enlist`reg
configClass   :enlist[`problemType]!enlist`class

// Generate model dictionaries 
modelDict     :.automl.modelGeneration.txtParse[;"/code/customization/"]
regModelDict  :modelDict configReg
classModelDict:modelDict configClass

// Generate model table
regModelTab  :flip`model`lib`fnc`seed`typ!flip key[regModelDict  ],'value regModelDict
classModelTab:flip`model`lib`fnc`seed`typ!flip key[classModelDict],'value classModelDict
binaryModelTab:select from classModelTab where typ=`binary
multiModelTab :select from classModelTab where typ=`multi 

// Target values
tgtReg       :100?1f
tgtClass     :100?0b
tgtMultiClass:100?3
tgtUnbalanced:(80?2),20?3

// Target data split into train and testing sets
ttsReg       :`ytrain`ytest!(80#tgtReg       ;-20#tgtReg)
ttsClass     :`ytrain`ytest!(80#tgtClass     ;-20#tgtClass)
ttsMultiClass:`ytrain`ytest!(80#tgtMultiClass;-20#tgtMultiClass)
ttsUnbalanced:`ytrain`ytest!(80#tgtUnbalanced;-20#tgtUnbalanced)

// Return model tables
regModelReturn   :delete from regModelTab where lib=`keras
binaryModelReturn:delete from binaryModelTab where lib=`keras
multiModelReturn :delete from multiModelTab where lib=`keras

passingTest[.automl.selectModels.targetKeras;(regModelTab   ;ttsReg       ;tgtReg       );0b;regModelReturn]
passingTest[.automl.selectModels.targetKeras;(binaryModelTab;ttsClass     ;tgtClass     );0b;binaryModelReturn]
passingTest[.automl.selectModels.targetKeras;(multiModelTab ;ttsMultiClass;tgtMultiClass);0b;multiModelReturn]
passingTest[.automl.selectModels.targetKeras;(multiModelTab ;ttsUnbalanced;tgtUnbalanced);0b;multiModelReturn]

-1"\nTesting that the number of target values < 10000 does not update the model table";

// Test all appropriate model tables and target values that are less than threshold
passingTest[.automl.selectModels.targetLimit;(regModelTab   ;tgtReg       );0b;regModelTab  ]
passingTest[.automl.selectModels.targetLimit;(binaryModelTab;tgtClass     );0b;binaryModelTab]
passingTest[.automl.selectModels.targetLimit;(multiModelTab ;tgtMultiClass);0b;multiModelTab]


-1"\nTesting that the number of target values > 10000 does update the model table";

// Target values that exceed the 10000 limit
tgtRegLarge       :20000?1f
tgtClassLarge     :20000?0b
tgtMultiClassLarge:20000?3

// Model table with inappropriate models removed for large target volumes
regModelUpd   :select from regModelTab where(lib<>`keras),not fnc in`neural_network`svm
binaryModelUpd:select from binaryModelTab where(lib<>`keras),not fnc in`neural_network`svm
multiModelUpd :select from multiModelTab where(lib<>`keras),not fnc in`neural_network`svm

// Test all appropriate model tables and target values that are greater than threshold
passingTest[.automl.selectModels.targetLimit;(regModelTab   ;tgtRegLarge       );0b;regModelUpd  ]
passingTest[.automl.selectModels.targetLimit;(binaryModelTab;tgtClassLarge     );0b;binaryModelUpd]
passingTest[.automl.selectModels.targetLimit;(multiModelTab ;tgtMultiClassLarge);0b;multiModelUpd]
