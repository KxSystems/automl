\d .automl

// Data and configuration checking 

// Ensure that non default functions are valid for application in automl
/* cfg     = configuration dictionary
/. returns > error indicating invalid fuctions otherwise generic null on success
check.functions:{[cfg]
  // List of possible areas where user may input a custom function
  function:raze cfg[`funcs`prf`tts`sigfeats],value[cfg`scf],first each cfg`xv`gs;
  // Ensure the custom inputs are suitably typed
  locs:@[{$[not type[get x]in(99h;100h;104h);'err;0b]};;{[err]err;1b}]each function;
  if[0<cnt:sum locs;
     functionList:{$[2<x;" ",y;"s ",sv[", ";y]]}[cnt]string function where locs;
    '`$"The function",/functionList," are not defined in your process\n"
  ]
  }

// Ensure that NLP functionality is available if a user needs to call it
/* cfg     = configuration dictionary
/. returns > error on issue otherwise generic null
check.NLPLoad:{[cfg]
  if[not `nlp~cfg`featExtractType;:()];
  if[not (0~checkimport[3]) & ((::)~@[{system"l ",x};"nlp/nlp.q";{0b}]);
    '"User attempting to run NLP models with insufficient requirements, see documentation"];
  }

// Ensure the data contains an appropriate type for application of NLP
/* t       = tabular feature dataset
/. returns > error indicating insufficient data or generic null on success
check.NLPSchema:{[cfg;t]
  if[not `nlp~cfg`featExtractType;:()];
  if[0~count .ml.i.fndcols[t;"C"];
    '`$"User wishing to apply nlp functionality must pass a table containing a character column."];
  }

// Remove columns from the feature dataset which do not fit conform to allowed schema
/* t       = tabular feature dataset
/* cfg     = configuration dictionary
/. returns > feature dataset with inappropriate columns removed and highlighted to user
check.featureTypes:{[t;cfg]
  typ:cfg`featExtractType;
  $[typ in `tseries`normal;
    [fCols:.ml.i.fndcols[t;"sfihjbepmdznuvt"];
     tab:flip fCols!t fCols
    ];
    typ=`fresh;
    // ignore the aggregating columns for FRESH as these can be of any type
    [apprCols:flip(aggCols:cfg[`aggcols])_ flip t;
      cls:.ml.i.fndcols[apprCols;"sfiehjb"];
      // restore the aggregating columns
      tab:flip(aggCols!t aggCols,:()),cls!t cls;
      fCols:cols tab
    ];
    typ=`nlp;
    [fCols:.ml.i.fndcols[t;"sfihjbepmdznuvtC"];
     tab:flip fCols!t fCols];
    '`$"This form of feature extraction is not currently supported"];
  i.errColumns[cols t;fCols;typ];
  tab
  }

// Ensure that the target data and final feature dataset are of the same length\
/* t       = tabular feature dataset
/* cfg     = configuration dictionary
/. returns > error on failing check otherwise generic null
check.length:{[t;tgt;cfg]
  typ:cfg`featExtractType;
  $[-11h=type typ;
    $[`fresh=typ;
      // Check that the number of unique aggregating sets is the same as number of targets
      if[count[tgt]<>count distinct $[1=count cfg`aggcols;t[cfg`aggcols];(,'/)t cfg`aggcols];
         '`$"Target count must equal count of unique agg values for fresh"
      ];
      typ in`tseries`normal`nlp;
      if[count[tgt]<>count t;'"Must have the same number of targets as values in table"];
      '"Input for typ must be a supported type"
    ];
    '"Input for typ must be a supported symbol"
  ]
  }

// Ensure target data contains more than one unique value
/* tgt     = target vector
/. returns > error on unsuitable target otherwise generic null
check.target:{[tgt]
  if[not 0<var tgt;'"Target must have more than one unique value"]
  }

