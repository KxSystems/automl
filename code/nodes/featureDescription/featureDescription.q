// Retrieve any initial information that is needed for the generation of reports or
// running on new data

\d .automl

featureDescription.node.inputs  :`config`features!"!+"
featureDescription.node.outputs :`symEncode`dataDescription`features!"S++"
featureDescription.node.function:{[cfg;feats]
  symEncode  :featureDescription.symEncodeSchema[feats;10;cfg];
  dataSummary:featureDescription.dataDescription[feats];
  `symEncode`dataDescription`features!(symEncode;dataSummary;feats)
  }
