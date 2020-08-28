\d .automl

// Definitions of the main callable functions used in the application of modelGeneration

/ @kind function
// @category modelGeneration
// @fileoverview Check that the text file exists for the given problem type
// @param cfg {dict} configuration information relating to the current run of AutoML
// @return    {(Null;err)} error indicating that the text file does not exist
modelGeneration.filesCheck:{[cfg]
  if[not cfg[`problemType]in key modelGeneration.files;'`$"text file not found"]
  }


// @kind function
// @category modelGeneration
// @fileoverview Extraction of an appropriately valued dictionary from a non complex flat file
// @param cfg {dict} configuration information relating to the current run of AutoML
// @param fp  {char} file path to directory containing text files 
// @return    {dict} dictionary of models extracted from text file
modelGeneration.txtParse:{[cfg;fp]
  filePath:`$path,fp,modelGeneration.files cfg[`problemType];
  readTxt:("S*";"|")0:hsym filePath;
  modelDict:{key(!).("S=;")0:x}each(!). readTxt;
  if[1b~cfg`tf;
    apprModels:key[modelDict]where `keras<>value modelDict[;0];
    modelDict:apprModels!modelDict apprModels
   ];
  modelDict
  }


// @kind function
// @category modelGeneration
// @fileoverview Extract appropriate models based on the problem type
// @param cfg     {dict} configuration information relating to the current run of AutoML
// @param mdlDict {dict} dictionary containing information on applicable models based on
// problem type
// @param tgt     {(num[];sym[])} numerical or symbol vector containing the target dataset
// @return        {tab} table containing appropriate models that can be used  based on 
//  target and problem type
modelGeneration.modelPrep:{[cfg;mdlDict;tgt]
  // Convert a parsed dictionary from flat file to an approprate tabular representation
  mdlTab:flip`model`lib`fnc`seed`typ!flip key[mdlDict],'value mdlDict;
  if[`class=cfg`problemType;
    // For classification tasks remove inappropriate classification models
    mdlTab:$[2<count distinct tgt;
        delete from mdlTab where typ=`binary;
        delete from mdlTab where lib=`keras,typ=`multi
       ]
    ];
  // Add a column with appropriate initialized models for each row
  mdlTab:update minit:.automl.modelGeneration.mdlFunc .'flip(lib;fnc;model)from mdlTab;
  mdlTab
  }


// @kind function
// @category modelGeneration
// @fileoverview Build up the model to be applied based on naming convention
// @param lib  {sym} library which forms the basis for the definition
// @param fnc  {sym} function name if keras or module from which model is derived for 
//  non keras models  
// @param mdl  {sym} the model being applied from within the library
// @return     {<} the appropriate function or projection in the case of sklearn
modelGeneration.mdlFunc:{[lib;fnc;mdl]
  $[`keras~lib;
    .automl.models.kerasFitScore;
    // construct the projection used for sklearn models eg '.p.import[`sklearn.svm][`:SVC]'
    {[x;y;z].p.import[x]y}[` sv lib,fnc;hsym mdl]
    ]
  }


// @kind function
// @category modelGeneration
// @fileoverview Update models available for use based on the number of rows in the target set
// @param tgt   {(num[];sym[])} numerical or symbol vector containing the target dataset
// @param mdls  {tab} table defining models which are to be applied to the dataset
// @return      {tab} model table with appropriate models removed if needed and 
//  model removal highlighted
modelGeneration.updModels:{[mdls;tgt]
 $[10000<count tgt;
   [-1"\nLimiting the models being applied due to number targets>10,000";
    -1"No longer running neural nets or svms\n";
    select from mdls where lib<>`keras,not fnc in`neural_network`svm
   ];
   mdls
   ]
  }

// Text files that can be parsed from within the models folder
modelGeneration.files:`class`reg!("classmodels.txt";"regmodels.txt")

