\l automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

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

-1"\nTesting that appropriate models are returned";

// Return value for unbalanced dataset
multiModelReturn :delete from multiModelTab where lib=`keras

// These tests assume that keras is installed in the environment
passingTest[.automl.selectModels.targetKeras;(regModelTab   ;ttsReg       ;tgtReg       );0b;regModelTab]
passingTest[.automl.selectModels.targetKeras;(binaryModelTab;ttsClass     ;tgtClass     );0b;binaryModelTab]
passingTest[.automl.selectModels.targetKeras;(multiModelTab ;ttsMultiClass;tgtMultiClass);0b;multiModelTab]
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
