\d .automl

// @kind function
// @category featureCreate 
// @fileoverview Create features using the FRESH algorithm
// @param feat {tab} The feature data as a table 
// @param cfg  {dict} Configuration information assigned by the user and related to the current run
// @return {tab} features created in accordance with the FRESH feature creation procedure.
featureCreation.fresh.create:{[feat;cfg]
  aggCols:cfg`aggregationColumns;
  problemFunctions:cfg`functions;
  params:$[type[problemFunctions]in -11 11h;get;
    99h=type problemFunctions;;
    '"Inappropriate type for FRESH parameter data"
    ]problemFunctions;
  // Feature extraction should be performed on all columns that are non aggregate
  cols2use:cols[feat]except aggCols;
  featExtractStart:.z.T;
  // Apply feature creation and encode nulls with the median value of the column
  feat:value .ml.fresh.createfeatures[feat;aggCols;cols2use;params];
  feat:dataPreprocessing.nullEncode[feat;med];
  feat:dataPreprocessing.infreplace feat;
  feat:0^.ml.dropconstant feat;
  featExtractEnd:.z.T-featExtractStart;
  `creationTime`features`featModel!(featExtractEnd;feat;())
  }
