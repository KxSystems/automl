// Preprocess the dataset prior to application of ML algos, this includes the application of Symbol
// encoding, handling of null data/infinities and removal of constant columns 
\d .automl

dataPreprocessing.node.inputs  :`config`features`target!"!+F"
dataPreprocessing.node.outputs :"+"
dataPreprocessing.node.function:{[cfg;feats;tgt]
  feats
  }

