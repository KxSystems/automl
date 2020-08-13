// This function contains the logic required to generate appropriate default/custom features
// for each of the problem types supported by the AutoML platform
\d .automl

featureCreation.node.inputs  :`config`features!"!+"
featureCreation.node.outputs :`creationTime`features!"t+"
featureCreation.node.function:{[cfg;feats]
  `creationTime`features!(.z.t;feats)
  }
