\d .automl

// Create features for 'normal problems' 

// @kind function
// @category featureCreation
// @fileoverview Create features for 'normal problems' -> one target for each row, no time dependency
//  or fresh like structure
// @param feat {tab} The feature data as a table
// @param cfg  {dict} Configuration information assigned by the user and related to the current run
// @return {tab} features created in accordance with the normal feature creation procedure
featureCreation.normal.create:{[feat;cfg]
  featureExtractStart:.z.T;
  // Time columns are extracted such that constituent parts can be used
  // but are not transformed according to remaining procedures
  timeCols:.ml.i.fndcols[feat;"dmntvupz"];
  featTable:(cols[feat]except timeCols)#feat;
  // apply user defined functions to the table
  featTable:featureCreation.normal.applyFunc/[featTable;cfg`funcs];
  featTable:dataPreprocessing.infreplace featTable;
  featTable:dataPreprocessing.nullEncode[featTable;med];
  featTable:.ml.dropconstant featTable;
  // Apply the transform of time specific columns as appropriate
  if[0<count timeCols;
    featTable^:.ml.timesplit[timeCols#feat;::]
    ];
  featureExtractEnd:.z.T-featureExtractStart;
  `creationTime`features`featModel!(featureExtractEnd;featTable;())
  }
