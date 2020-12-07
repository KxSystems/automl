\d .automl

// Definitions of the main callable functions used in the application of .automl.trainTestSplit


// Configuration update

// @kind function
// @category trainTestSplit
// @fileoverview Apply TTS function
// @param cfg      {dict}  Location and method by which to retrieve the data
// @param feat     {tab}   The feature data as a table 
// @param tgt      {num[]} Numerical vector containing target data
// @param sigFeats {sym[]} Significant features
// @return         {dict}  Data separated into training and testing sets
trainTestSplit.applyTTS:{[cfg;feats;tgt;sigFeats]
  data:flip feats sigFeats;
  ttsFunc:utils.qpyFuncSearch cfg`trainTestSplit;
  ttsFunc[data;tgt;cfg`testingSize]
  }

// @kind function
// @category trainTestSplit
// @fileoverview Returns train test split object if dictionary. If not error will occur.
// @param tts  {dict} Feature and target data split into training and testing set
// @return {(Null;err)} Error on unsuitable TTS output otherwise generic null
trainTestSplit.ttsReturnType:{[tts]
  err:"Train test split function must return a dictionary with `xtrain`xtest`ytrain`ytest";
  $[99h<>type tts;
      'err;
    not`xtest`xtrain`ytest`ytrain~asc key tts;
      'err;
    ]
  }
