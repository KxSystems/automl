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
i.getDict:{[nm]
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
i.paramParse:{[fileName;filePath]
  key[k]!(value@){(!).("S=;")0:x}each k:(!).("S*";"|")0:hsym`$.automl.path,filePath,fileName}


// Save path generation functionality

// Create the folders that are required for the saving of the config,models, images and reports
/* cfg     = configuration dictionary
/. returns > the file paths in its full path format and truncated for use in outputs to terminal
i.pathConstruct:{[cfg]
  names:`configSavePath`modelsSavePath;
  if[cfg[`saveopt]=2;names:names,`imagesSavePath`reportSavePath]
  pname:{"/",ssr["outputs/",string[x`startDate],"/run_",string[x`startTime],"/",y,"/";":";"."]};
  paths:path,/:pname[cfg]each string names;
  paths:i.ssrWindows each paths;
  {[fnm]system"mkdir",$[.z.o like "w*";" ";" -p "],fnm}each paths;
  names!flip(paths;{count[path]_x}each paths)
  }

// Used throughout the library to convert linux/mac file names to windows equivalent
/* path = the linux 'like' path
/. r    > the path modified to be suitable for windows systems
i.ssrWindows:{[path]$[.z.o like "w*";ssr[path;"/";"\\"];path]}


// Retrieval of full list of default parameters and update with custom information
/* t       = tabular feature dataset
/* cfg     = custom configuration information as a dictionary or path to user defined config file
/* ptyp    = problem type being solved (`nlp/`normal/`fresh)
/. returns > configuration dictionary modified with any custom information
i.getCustomConfig:{[t;cfg;ptyp]
  d:$[ptyp=`fresh ;i.freshDefault[];
      ptyp=`normal;i.normalDefault[];
      ptyp=`nlp   ;i.nlpDefault[];
      '`$"Inappropriate type supplied"];
  d:$[(typ:type cfg)in 10 -11 99h;
      [if[10h~typ ;cfg:i.getDict cfg];
       if[-11h~typ;cfg:i.getDict$[":"~first cfg;1_;]cfg:string cfg];
       $[min key[cfg]in key d;d,cfg;'`$"Inappropriate key provided for configuration input"]
      ];
      not any cfg;d;
      '`$"cfg must be passed the identity `(::)`, a filepath to a parameter flatfile",
         " or a dictionary with appropriate key/value pairs"
    ];
  if[ptyp=`fresh;
     d[`aggcols]:$[100h~typagg:type d`aggcols;d[`aggcols]t;
                   11h~abs typagg;d`aggcols;
                   '`$"aggcols must be passed function or list of columns"
                 ];
  ]
  d,enlist[`tf]!enlist 1~checkimport[0]
  }
