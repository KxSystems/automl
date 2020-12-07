\d .automl

// Update configuration to include default parameters. Check that various aspects of the
// dataset and configuration are suitable for running with AutoML

// @kind function
// @category node
// @fileoverview Retrieve any initial information that is needed for the generation of
// reports or running on new data
// @param cfg  {dict} Configuration information assigned by the user and related to the current run
// @param feat {tab}  The feature data as a table 
// @return     {dict} Symbol encoding, feature data and description
featureDescription.node.function:{[cfg;feats]
  symEncode  :featureDescription.symEncodeSchema[feats;10;cfg];
  dataSummary:featureDescription.dataDescription[feats];
  cfg[`logFunc]each (utils.printDict[`describe];dataSummary);
  `symEncode`dataDescription`features!(symEncode;dataSummary;feats)
  }

// Input information
featureDescription.node.inputs  :`config`features!"!+"

// Output information
featureDescription.node.outputs :`symEncode`dataDescription`features!"S++"
