\d .automl

// Preprocess the dataset prior to application of ML algos, this includes the application of Symbol
// encoding, handling of null data/infinities and removal of constant columns 

// @kind function
// @category node
// @fileoverview Preprocess input data based on the type of problem being solved 
//   and the parameters supplied by the user
// @param cfg       {dict} Configuration information assigned by the user and related to the current run
// @param feat      {tab}  The feature data as a table 
// @param symEncode {dict} Columns to symbol encode and their required encoding
// @return {tab} feature table with the data preprocessed appropriately
dataPreprocessing.node.function:{[cfg;feat;symEncode]
  symTable:dataPreprocessing.symEncoding[feat;cfg;symEncode];
  dataPreprocessing.featPreprocess[symTable;cfg]
  }

// Input information
dataPreprocessing.node.inputs  :`config`features`symEncode!"!+S"

// Output information
dataPreprocessing.node.outputs :"+"
