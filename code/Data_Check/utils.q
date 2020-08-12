\d .automl

// Error presentation

// Print to standard out flagging the removal of inappropriate columns
/* clist   = list of all columns in the dataset
/* slist   = sublist of columns appropriate for the use case
/* cfg     = configuration dictionary
/. returns > generic null if all columns suitable, appropriate print out
/.           in the case there are outstanding issues
i.errColumns:{[clist;slist;cfg]
  if[count[clist]<>count slist;
    -1 "\n Removed the following columns due to type restrictions for ",string cfg;
    0N!clist where not clist in slist
  ]
  }

// Parameter retrieval functionality

//  Function takes in a string which is the name of a parameter flatfile
/* nm = name of the file from which the dictionary is being extracted
/. r  > the dictionary as defined in a float file in models
i.getdict:{[nm]
  d:i.paramParse[nm;"/models/flat_parameters/"];
  idx:(k except`scf;
    k except`xv`gs`scf`seed;
    $[`xv in k;`xv;()],$[`gs in k;`gs;()];
    $[`scf in k;`scf;()];
    $[`seed in k:key d;`seed;()]);
  fnc:(key;
    {get string first x};
    {(x 0;get string x 1)};
    {key[x]!`$value x};
    {$[`rand_val~first x;first x;get string first x]});
  // Addition of empty dictionary entry needed as parsing
  // of file behaves oddly if only a single entry is given to the system
  if[sgl:1=count d;d:(enlist[`]!enlist""),d];
  d:{$[0<count y;@[x;y;z];x]}/[d;idx;fnc];
  if[sgl;d:1_d];
  d
  }

// Default parameters used in the population of parameters at the start of a run
// or in the creation of a new initialisation parameter flat file
/* None of these function take a parameter as input
/. r > default dictionaries which will be used by the automl
i.freshDefault:{`aggcols`funcs`xv`gs`prf`scf`seed`saveopt`hld`tts`sz`sigfeats!
  ({first cols x};`.ml.fresh.params;(`.ml.xv.kfshuff;5);(`.ml.gs.kfshuff;5);`.automl.xv.fitpredict;
   `class`reg!(`.ml.accuracy;`.ml.mse);`rand_val;2;0.2;`.ml.ttsnonshuff;0.2;
   `.automl.prep.freshsignificance)}
i.normalDefault:{`xv`gs`funcs`prf`scf`seed`saveopt`hld`tts`sz`sigfeats!
  ((`.ml.xv.kfshuff;5);(`.ml.gs.kfshuff;5);`.automl.prep.i.default;`.automl.xv.fitpredict;
   `class`reg!(`.ml.accuracy;`.ml.mse);`rand_val;2;0.2;`.ml.traintestsplit;0.2;
    `.automl.prep.freshsignificance)}
i.nlpDefault:{`xv`gs`funcs`prf`scf`seed`saveopt`hld`tts`sz`sigfeats!
  ((`.ml.xv.kfshuff;5);(`.ml.gs.kfshuff;5);`.automl.prep.i.default;`.automl.xv.fitpredict;
   `class`reg!(`.ml.accuracy;`.ml.mse);`rand_val;2;0.2;`.ml.traintestsplit;0.2;
   `.automl.prep.freshsignificance)}

// Parse the hyperparameter flat file
/* fileName = Name of the file to be parsed
/* filePath = File path to the 
/. returns  > dictionary mapping model name to possible hyper parameters 
i.paramParse:{[fn;fp]
  key[k]!(value@){(!).("S=;")0:x}each k:(!).("S*";"|")0:hsym`$.automl.path,filePath,fileName}
