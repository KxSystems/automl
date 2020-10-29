\d .automl

// The functionality contained in this file covers the required and optional utilities for
// normal feature creation within the automated machine learning library.

// @kind function
// @category featureCreation
// @fileoverview Used in the recursive application of functions to a kdb+ table 
// @param feat {tab} The feature data as a table 
// @param func {(lambda;str)} function to be applied to the table
// return {table} with the desired transforms applied recursively
featureCreation.normal.applyFunc:{[feat;func]
  typ:type func;
  // util.qpyFuncSearch to be used here when tts addition made 
  func:$[-11h=typ;utils.qpyFuncSearch func;100h=typ;func;.automl.featureCreation.normal.default];
  returnTab:func feat;
  $[98h~type returnTab;
   returnTab;
   98h~type dfTab:@[.ml.df2tab;returnTab;returnTab];
    dfTab;
   '"Normal feature creation function did not return a simple table"
   ]
  }

// @kind function
// @category featureCreation
// @fileoverview Default behaviour for the system is to pass through the table without the application of
//  any feature extraction procedures, this is for computational efficiency in initial builds
//  of the system and may be augmented with a more intelligent system moving forward
// @param feat {tab} The feature data as a table
// return {tab} the original table
featureCreation.normal.default:{[feat]
  feat
  }

// Optional functionality:
// The functions beyond this point form the basis for demonstrations and operate as
// starting points for a number of potential workflows. These may form the basis for more
// central components to the workflow at a future point 

// @kind function
// @category featureCreation
// @fileoverview Perform bulk transformations of hij columns for all unique linear 
//  combinations of such columns
// @param feat {tab} The feature data as a table
// return {tab} bulk transformtions applied to appropriate columns
featureCreation.normal.bulkTransform:{[feat]
  bulkCols:.ml.i.fndcols[feat;"hij"];
  stringFunc:("_multi";"_sum";"_div";"_sub");
  // Name the columns based on the unique combinations
  colNames:`$("_" sv'string each bulkCols@:.ml.combs[count bulkCols;2]),\:/:stringFunc;
  joinCols:raze(,'/)colNames;
  // Apply transforms based on naming conventions chosen and re-form the table with these appended
  funcList:(prd;sum;{first(%)x};{last deltas x});
  flip flip[feat],joinCols!(,/)funcList@/:\:feat bulkCols
  }

// @kind function
// @category featureCreation
// @fileoverview Perform a truncated single value decomposition on unique linear combinations of float columns
//  https://scikit-learn.org/stable/modules/generated/sklearn.decomposition.TruncatedSVD.html
// @param feat {tab} The feature data as a table
// return {tab} truncated single value decomposition applied to feature table
featureCreation.normal.truncSingleDecomp:{[feat]
  truncCols:.ml.i.fndcols[feat;"f"];
  truncCols@:.ml.combs[count truncCols,:();2];
  decomposition:.p.import[`sklearn.decomposition;`:TruncatedSVD;`n_components pykw 1];
  fitDecomposition:{raze x[`:fit_transform][flip y]`}[decomposition]each feat truncCols;
  colsDecomposition:`$("_" sv'string each truncCols),\:"_trsvd";
  flip flip[feat],colsDecomposition!fitDecomposition
  }
