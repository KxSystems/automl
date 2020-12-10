\d .automl

// Definitions of the main callable functions used in the application of modelGeneration

// @kind function
// @category modelGeneration
// @fileoverview Extraction of an appropriately valued dictionary from a json file
// @param cfg {dict} configuration information relating to the current run of AutoML
// @return    {table} table of models extracted from json file
modelGeneration.jsonParse:{[cfg]
  typ:$[`class~cfg`problemType;`classification;`regression];
  jsonPath:hsym`$.automl.path,"/code/customization/models/modelConfig/models.json";
  // Read in JSON file and select models based on problem type
  mdlTab:.j.k[raze read0 jsonPath]typ;
  // Convert to desired structure and convert all values to symbols
  mdlTab:`model`lib`fnc`seed`typ`apply xcol([]model:key mdlTab),'value mdlTab;
  // Convert to seed to either `seed or (::)
  seed:mdlTab`seed;
  toSeed:{@[x;y;:;z]}/[count[seed]#();(where;where not::)@\:seed;(`seed;::)];
  mdlTab:update seed:toSeed from mdlTab;
  // Convert rest of table to symbol values
  mdlTab:{![x;();0b;enlist[y]!enlist($;enlist`;y)]}/[mdlTab;`lib`fnc`typ];
  select from mdlTab where apply
  }

// @kind function
// @category modelGeneration
// @fileoverview Extract appropriate models based on the problem type
// @param cfg    {dict} configuration information relating to the current run of AutoML
// @param mdlTab {dict} table containing information on applicable models based on
// problem type
// @param tgt    {(num[];sym[])} numerical or symbol vector containing the target dataset
// @return       {tab} table containing appropriate models that can be used  based on 
//  target and problem type
modelGeneration.modelPrep:{[cfg;mdlTab;tgt]
  if[`class=cfg`problemType;
    // For classification tasks remove inappropriate classification models
    mdlTab:$[2<count distinct tgt;
        delete from mdlTab where typ=`binary;
        delete from mdlTab where lib=`keras,typ=`multi
       ]
    ];
  // Add a column with appropriate initialized models for each row
  update minit:.automl.modelGeneration.mdlFunc .'flip(lib;fnc;model)from mdlTab
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
  $[lib in key models;
    get".automl.models.",string[lib],".fitScore";
    // construct the projection used for sklearn models eg '.p.import[`sklearn.svm][`:SVC]'
    {[x;y;z].p.import[x]y}[` sv lib,fnc;hsym mdl]
    ]
  }
