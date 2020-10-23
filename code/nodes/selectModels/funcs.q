\d .automl

// Definitions of the main callable functions used in the application of .automl.selectModels

// @kind function
// @category selectModels
// @fileoverview Remove keras models if criteria met
// @param mdls {tab} Models which are to be applied to the dataset
// @param tts  {dict} Feature and target data split into train and testing sets
// @param tgt  {(num[];sym[])} numerical or symbol vector containing the target dataset
// @return {tab} Keras model removed if needed and removal highlighted
selectModels.targetKeras:{[mdls;tts;tgt]
  if[1~checkimport[0];
    :?[mdls;enlist(<>;`lib;enlist `keras);0b;()]
    ];
  multiCheck:`multi in mdls`typ;
  tgtCount:min count@'distinct each tts`ytrain`ytest;
  tgtCheck:count[distinct tgt]>tgtCount;
  if[multiCheck&tgtCheck;
    -1"\n Test set does not contain examples of each class. Removed any multi keras models";
    :delete from mdls where lib=`keras,typ=`multi
    ];
  mdls
  }


// @kind function
// @category selectModels
// @fileoverview Update models available for use based on the number of rows in the target set
// @param mdls {tab} Models which are to be applied to the dataset
// @param tgt  {(num[];sym[])} Numerical or symbol vector containing the target dataset
// @return {tab} Appropriate models removed if needed and model removal highlighted
selectModels.targetLimit:{[mdls;tgt]
 if[10000<count tgt;
    -1"\nLimiting the models being applied due to number targets>10,000";
    -1"No longer running neural nets or svms\n";
    :select from mdls where lib<>`keras,not fnc in`neural_network`svm
   ];
   mdls
  }
