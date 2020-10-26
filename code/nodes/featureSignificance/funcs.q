\d .automl

// Definitions of the main callable functions used in the application of .automl.featureSignificance

// @kind function
// @category featureSignificance
// @fileoverview Extract feature significant tests and apply to feature data
// @param cfg   {dict}  Configuration information assigned by the user and related to the current run
// @param feats {tab}   The feature data as a table 
// @param tgt   {num[]} Numerical vector containing target data
// @return {sym[]} Significant features or error if function does not exist
featureSignificance.applySigFunc:{[cfg;feats;tgt]
  sigFunc:utils.qpyFuncSearch cfg`sigFeats;
  sigFunc[feats;tgt]
  }

// @kind function
// @category featureSignificance
// @fileoverview Apply feature significance function to data post feature extraction
// @param cfg   {dict}          Configuration information assigned by the user and related to the current run
// @param feats {tab}           The feature data as a table 
// @param tgt   {num[]} Numerical vector containing target data
// @return      {sym[]}         Significant features
featureSignificance.significance:{[feats;tgt]
  sigFeats:.ml.fresh.significantfeatures[feats;tgt;.ml.fresh.benjhoch .05];
  if[0=count sigFeats;
    sigFeats:.ml.fresh.significantfeatures[feats;tgt;.ml.fresh.percentile .25]];
  sigFeats
  }

// @kind function
// @category featureSignificance
// @fileoverview Find any correlated columns and remove them
// @param sigFeats {tab} Significant data features
// @return {sym[]} Significant columns
featureSignificance.correlationCols:{[sigFeats]
  thres:0.95;
  sigCols:cols sigFeats;
  corrMat:abs .ml.corrmat sigFeats;
  boolMat:t>\:t:til count first sigFeats;
  sigCols:featureSignificance.threshVal[thres;sigCols]'[corrMat;boolMat];
  raze distinct 1#'asc each key[sigCols],'value sigCols
  }

// @kind function
// @category featureSignificance
// @fileoverview Find any corrlated columns within threshold
// @param thres   {float}   Threshold value to search within
// @param sigCols {sym[]}   Significant columns
// @param corr    {float[]} Correlation values
// @param bool    {float[]} Lower traingle booleans
// @return {sym[]} Columns within threshold
featureSignificance.threshVal:{[thres;sigCols;corr;bool]
  $[any thres<value[corr]idx:where bool;sigCols idx;()]
  }
