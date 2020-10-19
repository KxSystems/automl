\d .automl

// Definitions of the main callable functions used in the application of .automl.dataPreprocessing

// @kind function
// @category dataPreprocessing
// @fileoverview Symbol encoding applied to feature data
// @param feat   {tab} the feature data as a table
// @param cfg    {dict} configuration information relating to the current run of AutoML
// @return {tab} the feature table encoded appropriately for the task
dataPreprocessing.symEncoding:{[feat;cfg;symEncode]
  typ:cfg`featExtractType;
  // if no symbol columns return table or empty encoding schema
  if[all {not ` in x}each value symEncode;
    if[count symEncode`freq;
      feat:$[`fresh~typ;
            raze .ml.freqencode[;symEncode`freq]each flip each 0!cfg[`aggcol] xgroup feat;
            .ml.freqencode[feat;symEncode`freq]
            ]; 
      ];
    feat:.ml.onehot[0!feat;symEncode`ohe];
    // Extract symbol columns from dictionary
    symbolCols:distinct raze symEncode;
    :flip symbolCols _ flip feat
    ];
  feat
  }

// @kind function
// @category dataPreprocessing
// @fileoverview  Apply preprocessing depending on feature extraction type
// @param feat    {tab} the feature data as a table
// @param cfg     {dict} configuration information relating to the current run of AutoML
// @return {tab} the feature table with appropriate feature preprocessing applied
dataPreprocessing.featPreprocess:{[feat;cfg]
  typ:cfg`featExtractType;
  // For FRESH the aggregate columns need to be excluded from the preprocessing
  // steps, this ensures that encoding is not performed on the aggregate columns
  // if this is a symbol and or if this column is constant in the case of new data
  if[`fresh=typ;
    aggData:(cfg[`aggcols],())#flip feat;
    feat:flip (cols[feat]except cfg[`aggcols])#flip feat
    ];
  featTable:$[not typ in`nlp;
             dataPreprocessing.nonTextPreprocess[feat];
             dataPreprocessing.textPreprocess[feat]
             ];
  // rejoin the separated aggregate columns for FRESH
  $[`fresh=typ;flip[aggData],';]featTable
  }

// @kind function
// @category dataPreprocessing
// @fileoverview  Apply preprocessing for non NLP feature extraction type
// @param feat    {tab} the feature data as a table
// @return {tab} the feature table with appropriate feature preprocessing applied
dataPreprocessing.nonTextPreprocess:{[feat]
  feat:.ml.dropconstant feat;
  feat:dataPreprocessing.nullEncode[feat;med];
  dataPreprocessing.infreplace feat
  }

// @kind function
// @category dataPreprocessing
// @fileoverview  Apply preprocessing for NLP feature extraction type
// @param feat    {tab} the feature data as a table
// @return {tab} the feature table with appropriate feature preprocessing applied
dataPreprocessing.textPreprocess:{[feat]
  if[count[cols feat]>count charCol:.ml.i.fndcols[feat;"C"];
    nonTextPreproc:dataPreprocessing.nonTextPreprocess charCol _feat;
    :?[feat;();0b;charCol!charCol],'nonTextPreproc
    ];
  feat
  }

// @kind function
// @category dataPreprocessingUtility
// @fileoverview null encoding of feature data 
// @param feat  {tab} the feature data as a table
// @param func  {lambda} function to be applied to column from which the value 
//   to fill nulls is derived (med/min/max)
// @return {tab} the feature table with null values filled if required
dataPreprocessing.nullEncode:{[feat;func]
  nullCheck :flip null feat;
  nullFeat  :where 0<sum each nullCheck;
  nullValues:nullCheck nullFeat;
  names     :`$string[nullFeat],\:"_null";
  // 0 filling needed if return value also null (encoding maintained through added columns)
  $[0=count nullFeat;
   feat;
   flip 0^(func each flip feat)^flip[feat],names!nullValues
   ]
  }


// Temporary infreplace function until toolkit is updated
dataPreprocessing.infreplace:{
  $[98=t:type x;
    [appCols:.ml.i.fndcols[x;"hijefpnuv"];
    typCols:type each dt:appCols!x appCols;
    flip flip[x]^dataPreprocessing.i.infrep'[dt;typCols]
    ];
    0=t;
     [appIndex:where all each string[type each x]in key i.inftyp;
      typIndex:type each dt:x appIndex;
     (x til[count x]except appIndex),dataPreprocessing.i.infrep'[dt;typIndex]
     ];
    98=type keyX:key x;
     [appCols:.ml.i.fndcols[x:value x;"hijefpnuv"];
     typCols:type each dt:appCols!x appCols;
     cols[keyX]xkey flip flip[keyX],flip[x]^dataPreprocessing.i.infrep'[dt;typCols]
     ];
    [appCols:.ml.i.fndcols[x:flip x;"hijefpnuv"];
    typCols:type each dt:appCols!x appCols;
     flip[x]^dataPreprocessing.i.infrep'[dt;typCols]
     ]
   ]
  }

// Utilities for functions to be added to the toolkit
dataPreprocessing.i.infrep:{
  // Character representing the type
  typ:.Q.t@abs y;
  // the relevant null+infs for type
  t:typ$(0N;-0w;0w);
  {[n;x;y;z]@[x;i;:;z@[x;i:where x=y;:;n]]}[t 0]/[x;t 1 2;(min;max)]
  }

