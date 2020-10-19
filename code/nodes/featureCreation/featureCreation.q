\d .automl

// This function contains the logic required to generate appropriate default/custom features
// for each of the problem types supported by the AutoML platform

// @kind function
// @category node
// @fileoverview Apply feature creation based on problem type. Individual functions relating to this
//  functionality are use case dependant and contained within [fresh/normal/nlp]/featureCreate.q
// @param feat {tab} The feature data as a table 
// @param cfg  {dict} Configuration information assigned by the user and related to the current run
// @return {dict} table with appropriate feature creation along with time taken and any saved models 
featureCreation.node.function:{[cfg;feat]
  typ:cfg`featExtractType;
  $[typ=`fresh;
      featureCreation.fresh.create[feat;cfg];
    typ=`normal;
      featureCreation.normal.create[feat;cfg];
    typ=`nlp;
      featureCreation.nlp.create[feat;cfg];
    '"Feature extraction type is not currently supported"
    ]
  }

// Input information
featureCreation.node.inputs  :`config`features!"!+"

// Output information
featureCreation.node.outputs :`creationTime`features`featModel!"t+<"

