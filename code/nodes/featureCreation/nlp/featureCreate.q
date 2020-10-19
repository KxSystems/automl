\d .automl

// Apply NLP specific feature extraction on string characters and normal preprcoessing
// methods to remaining data

// @kind function
// @category featureCreate
// @fileoverview Apply word2vec on string data for nlp problems
// @param feat      {tab} The feature data as a table 
// @param cfg       {dict} Configuration information assigned by the user and related to the current run
// @return {tab} features created in accordance with the nlp feature creation procedure
featureCreation.nlp.create:{[feat;cfg] 
  featExtractStart:.z.T;
  // Preprocess the character data
  charPrep:featureCreation.nlp.proc[feat;cfg;0b;(::)];
  // Table returned with NLP feature creation, any constant columns are dropped
  featNLP:charPrep`feat;
  featNLP:.ml.dropconstant featNLP;
  // run normal feature creation on numeric datasets and add to nlp features if relevant
  cols2use:cols[feat]except charPrep`stringCols;
  if[0<count cols2use;
    nonTextFeat:charPrep[`stringCols]_feat;
    featNLP:featNLP,'featureCreation.normal.create[nonTextFeat;cfg]`features
    ];
  featureExtractEnd:.z.T-featExtractStart;
  `creationTime`features`featModel!(featureExtractEnd;featNLP;charPrep`model)
  }
