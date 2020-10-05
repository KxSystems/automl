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


-1"\nTesting functionality for generation of symbol encoding schema";

// Tables for the testing of covering all encoding combinations
noEncodeTab          :([]10?1f;10?1f;10?5)
oheEncodeTab         :([]10?1f;10?`a`b`c;10?1f)
freqEncodeTab        :([]100?`4;100?1f;100?1f)
oheFreqEncodeTab     :([]100?1f;100?`4;100?`a`b`c;100?1f)
freshNoEncodeTab     :([idx:10?`4]10?1f;10?1f;10?1f)
freshOheEncodeTab    :([idx:10?`4]10?1f;10?`a`b`c;10?1f)
freshFreqEncodeTab   :([idx:100?`4]100?`4;100?1f;100?1f)
freshOheFreqEncodeTab:([idx:100?`4]100?1f;100?`4;100?`a`b`c;100?1f)

// Expected returns for the above tables
noEncodeReturn     :`freq`ohe!``
oheEncodeReturn    :`freq`ohe!(`$();enlist `x1)
freqEncodeReturn   :`freq`ohe!(enlist `x;`$())
oheFreqEncodeReturn:`freq`ohe!(enlist `x1;enlist`x2)

// Any configuration information required to run the function
nonFreshConfig:enlist[`featExtractType]!enlist`normal
freshConfig   :enlist[`featExtractType]!enlist`fresh

// Generate data lists for testing
nonFreshTabList:(noEncodeTab;oheEncodeTab;freqEncodeTab;oheFreqEncodeTab)
nonFreshData   :{(x;y;z)}[;10;nonFreshConfig]each nonFreshTabList
freshTabList   :(freshNoEncodeTab;freshOheEncodeTab;freshFreqEncodeTab;freshOheFreqEncodeTab)
freshData      :{(x;y;z)}[;10;nonFreshConfig]each nonFreshTabList
targetData     :(noEncodeReturn;oheEncodeReturn;freqEncodeReturn;oheFreqEncodeReturn)

all passingTest[.automl.featureDescription.symEncodeSchema;;0b;]'[nonFreshData;targetData]
all passingTest[.automl.featureDescription.symEncodeSchema;;0b;]'[freshData   ;targetData]


-1"\nTesting for application of function for summarizing feature data";

// Generate test table containing one of each category
testTab:([]a:1 2 1 2;b:`a`b`c`d;c:1 2 1 2f;d:4?0t;e:("abc";"def";"abc";"deg");f:4?0b)

// Generate the summary table to be returned
keyVals :`a`c`b`d`f`e
headers :`count`unique`mean`std`min`max`type
counts  :6#4
unique  :2 2 4 4 2 3
means   :(2#1.5),4#(::)
stdev   :(2#sdev 1 1 2 2),4#(::)
minvals :(1;1f),4#(::)
maxvals :(2;2f),4#(::)
typevals:`numeric`numeric`categorical`time`boolean`text
returnTab:keyVals!flip headers!(counts;unique;means;stdev;minvals;maxvals;typevals)

passingTest[.automl.featureDescription.dataDescription;testTab;1b;returnTab]
