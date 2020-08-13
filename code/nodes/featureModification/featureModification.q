// At present this function only provides the both the symbol encoding map which is used in the 
// application of automl on new datasets and the 'autotype' function used to remove columns which 
// cannot be handled by the problem type that the user is attempting to solve
\d .automl

featureModification.node.inputs  :`config`features!"!+"
featureModification.node.outputs :`symEncode`features!"S+"
featureModification.node.function:{[cfg;feats]
  `symEncode`features!(5?`abc`cab;feats)
  }
