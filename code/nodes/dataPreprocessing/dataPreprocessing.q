// Preprocess the dataset prior to application of ML algos, this includes the application of Symbol
// encoding, handling of null data/infinities, removal of constant columns and the description of
// the dataset contents
\d .automl

dataPreprocessing.node.inputs  :`config`features`target!"!+F"
dataPreprocessing.node.outputs :`dataDescription`features!"++"
dataPreprocessing.node.function:{[cfg;feats;tgt]
  `dataDescription`features!(([5?`a`b];5?1f);feats)
  }

