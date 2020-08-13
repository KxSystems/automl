// Apply feature significance logic to data post feature extraction, returning the original dataset
// and a list of significant features to be used both for selection of data from new runs and 
// within the current run.

\d .automl

featureSignificance.node.inputs  :`config`features`target!"!+F"
featureSignificance.node.outputs :`sigFeats`features!"S+"
featureSignificance.node.function:{[cfg;feats;tgt]
  `sigFeats`features!(`aaa`bbb`ccc;feats)
  }
