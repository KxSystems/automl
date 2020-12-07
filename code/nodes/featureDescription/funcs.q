\d .automl

// Definition of the main callable functions used in the application of .automl.featureDescription


// @kind function
// @category featureDescription
// @fileoverview  Symbol encoding function to generate the encoding map 
//   used when applying this workflow to new data
// @param feat  {tab} The feature data as a table
// @param nVals {integer} The number of distinct symbols in a column which can be one-hot encoded.
//   If a column has more than this number of symbols the column will be frequency encoded.
// @param cfg   {dict} configuration dictionary containing all information required for running
//   of the symbol encoding function
// @returns {dict} Mapping of the columns which require symbol encoding and denoting if these
//   columns are to be frequency or one-hot encoded based on the number of unique symbols allowing
//   a user to appropriately encode data when running on new datasets
featureDescription.symEncodeSchema:{[feat;nVals;cfg]
  aggcols:$[`fresh~cfg`featureExtractionType;cfg`aggregationColumns;(::)];
  symbolCols:.ml.i.fndcols[feat;"s"]except aggcols;
  $[0=count symbolCols;
    `freq`ohe!``;
    [
     // list of frequency encoding columns
     frequencyCols:where nVals<count each distinct each symbolCols!flip[feat]symbolCols;
     // list of one hot encoded columns
     oneHotCols:symbolCols where not symbolCols in frequencyCols;
     // return encoding schema or appy encoding as appropriate
     `freq`ohe!(frequencyCols;oneHotCols)
    ]
  ]
  }

// @kind function
// @category featureDescription
// @fileoverview Outline statistics for the feature dataset being supplied for the current run
// @param feat {tab} The feature data as a table
// @returns {keyed tab} Description of the feature dataset content highlighting useful statistics this
//   includes: min/max/avg/unique values/type/standart deviation/count
featureDescription.dataDescription:{[feat]
  columns :`count`unique`mean`std`min`max`type;
  // Find columns based on their type
  numcols :.ml.i.fndcols[feat;"hijef"];
  timecols:.ml.i.fndcols[feat;"pmdznuvt"];
  boolcols:.ml.i.fndcols[feat;"b"];
  catcols :.ml.i.fndcols[feat;"s"];
  textcols:.ml.i.fndcols[feat;"cC"];
  // Projection for the retrieval of appropriate metadata information
  featureMeta:featureDescription.i.metaData[feat;;];
  // Apply metadata retrieval to different columns types
  num  :featureMeta[numcols ;(count;{count distinct x};avg;sdev;min;max;{`numeric})];
  symb :featureMeta[catcols ;featureDescription.i.nonNumeric[{`categorical}]];
  times:featureMeta[timecols;featureDescription.i.nonNumeric[{`time}]];
  text :featureMeta[textcols;featureDescription.i.nonNumeric[{`text}]];
  bool :featureMeta[boolcols;featureDescription.i.nonNumeric[{`boolean}]];
  flip columns!flip num,symb,times,bool,text
  }


// Utility functions

// @private
// @kind function
// @category featureDescription
// @fileoverview Apply data from a table relating to a subset of columns to a list of aggregating
//   functions in order to retrieve relevant statistics to describe the dataset
// @param  feat     {tab}  The feature data as a table
// @param  colList  {sym[]} Column list on which the functions are to be applied
// @param  funcList {lambda[]} List of functions to apply to relevant data
// @return {mat[]} matrix containing the descriptive statistics and information
featureDescription.i.metaData:{[feat;colList;funcList]
  $[0<count colList;
    funcList@\:/:flip colList#feat;
    ()
  ]
  }

// @private
// @kind function
// @category featureDescription
// @fileoverview Generate a list of functions to be applied to the dataset for non numeric data
// @param typ {lambda} A function returning as its argument the name to be associated with
//   the rows being described
// @return {lambda[]} List of functions to be applied to relevant data
featureDescription.i.nonNumeric:{[typ]
  (count;{count distinct x};{};{};{};{};typ)
  }
