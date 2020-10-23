// Apply the user defined train test split functionality onto the users feature/target datasets returning
// the train-test split data as a list of (xtrain;ytrain;xtest;ytest)
\d .automl

trainTestSplit.node.inputs  :`config`features`target`sigFeats!"!+FS"
trainTestSplit.node.outputs :"!"
trainTestSplit.node.function:{[cfg;feats;tgt;sigfeats]
  `xtrain`ytrain`xtest`ytest!(80?1f;80?1f;20?1f;20?1f)
  }
