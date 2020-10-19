\d .automl

// Error presentation

// @kind function
// @category dataCheckUtility
// @fileoverview print to standard out flagging the removal of inappropriate columns
// @param clist {sym[]} list of all columns in the dataset
// @param slist {sym[]} sublist of columns appropriate for the use case
// @param cfg   {dict} configuration information assigned by the user and related to the current run
// @return      {(Null;stdout)} generic null if all columns suitable, appropriate print out
//   in the case there are outstanding issues
dataCheck.i.errColumns:{[clist;slist;cfg]
  if[count[clist]<>count slist;
    -1 "\n Removed the following columns due to type restrictions for ",string cfg;
    0N!clist where not clist in slist
  ]
  }


// Parameter retrieval functionality

// @kind function
// @category dataCheckUtility
// @fileoverview retrieve a parameter flatfile from disk 
// @param  fileName {char[]} name of the file from which the dictionary is being extracted
// @return          {dict} configuration dictionary retrieved from a flatfile
dataCheck.i.getDict:{[fileName]
  d:dataCheck.i.paramParse[fileName;"/models/flat_parameters/"];
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

// @kind function
// @category dataCheckUtility
// @fileoverview retrieve default parameters and update with custom information
// @param cfg  {dict} Configuration information assigned by the user and related to the current run
// @param feat {tab} The feature data as a table
// @param ptyp {sym} problem type being solved (`nlp/`normal/`fresh)
/. returns > configuration dictionary modified with any custom information
dataCheck.i.getCustomConfig:{[feat;cfg;ptyp]
  d:$[ptyp=`fresh ;dataCheck.i.freshDefault[];
      ptyp=`normal;dataCheck.i.normalDefault[];
      ptyp=`nlp   ;dataCheck.i.nlpDefault[];
      '`$"Inappropriate type supplied"
    ];
  d:$[(typ:type cfg)in 10 -11 99h;
      [if[10h~typ ;cfg:dataCheck.i.getDict cfg];
       if[-11h~typ;cfg:dataCheck.i.getDict$[":"~first cfg;1_;]cfg:string cfg];
       $[min key[cfg]in key d;d,cfg;'`$"Inappropriate key provided for configuration input"]
      ];
      not any cfg;d;
      '`$"cfg must be passed the identity `(::)`, a filepath to a parameter flatfile",
         " or a dictionary with appropriate key/value pairs"
    ];
  if[ptyp=`fresh;
     d[`aggcols]:$[100h~typagg:type d`aggcols;d[`aggcols]feat;
                   11h~abs typagg;d`aggcols;
                   '`$"aggcols must be passed function or list of columns"
                 ]
  ];
  d,enlist[`tf]!enlist 1~checkimport[0]
  }

// @kind function
// @category dataCheckUtility
// @fileoverview default parameters used in the application of 'FRESH' AutoML
// @return {dict} default dictionary which will be used if no user updates are supplied
dataCheck.i.freshDefault:{`aggcols`funcs`xv`gs`prf`scf`seed`saveopt`hld`tts`sz`sigfeats!
  ({first cols x};`.ml.fresh.params;(`.ml.xv.kfshuff;5);(`.ml.gs.kfshuff;5);
   `.automl.xv.fitpredict;`class`reg!(`.ml.accuracy;`.ml.mse);`rand_val;2;
   0.2;`.ml.ttsnonshuff;0.2;`.automl.prep.freshsignificance)
  }

// @kind function
// @category dataCheckUtility
// @fileoverview default parameters used in the application of 'normal' AutoML 
// @return {dict} default dictionary which will be used if no user updates are supplied
dataCheck.i.normalDefault:{`xv`gs`funcs`prf`scf`seed`saveopt`hld`tts`sz`sigfeats!
  ((`.ml.xv.kfshuff;5);(`.ml.gs.kfshuff;5);`.automl.prep.i.default;
   `.automl.xv.fitpredict; `class`reg!(`.ml.accuracy;`.ml.mse);
   `rand_val;2;0.2;`.ml.traintestsplit;0.2;`.automl.prep.freshsignificance)
  }

// @kind function
// @category dataCheckUtility
// @fileoverview default parameters used in the application of 'NLP' AutoML
// @return {dict} default dictionary which will be used if no user updates are supplied
dataCheck.i.nlpDefault:{`xv`gs`funcs`prf`scf`seed`saveopt`hld`tts`sz`sigfeats`w2v!
  ((`.ml.xv.kfshuff;5);(`.ml.gs.kfshuff;5);`.automl.prep.i.default;
   `.automl.xv.fitpredict;`class`reg!(`.ml.accuracy;`.ml.mse);
   `rand_val;2;0.2;`.ml.traintestsplit;0.2;`.automl.prep.freshsignificance;0)
  }

// @kind function
// @category dataCheckUtility
// @fileoverview parse the hyperparameter flat file
// @param fileName {char[]} name of the file to be parsed
// @param filePath {char[]} file path to the hyperparmeter file relative to `.automl.path`
/. returns  > dictionary mapping model name to possible hyper parameters 
dataCheck.i.paramParse:{[fileName;filePath]
  key[k]!(value@){(!).("S=;")0:x}each k:(!).("S*";"|")0:hsym`$.automl.path,filePath,fileName
  }


// Save path generation functionality

// @kind function
// @category dataCheckUtility
// @fileoverview create the folders that are required for the saving of the config,
//   models, images and reports
// @param cfg {dict} Configuration information assigned by the user and related to the current run
// @return the file paths relevant for saving reports/config etc to file, both as full path format 
//   and truncated for use in outputs to terminal
dataCheck.i.pathConstruct:{[cfg]
  names:`configSavePath`modelsSavePath;
  if[cfg[`saveopt]=2;names:names,`imagesSavePath`reportSavePath];
  pname:path,"/",ssr["outputs/",string[cfg`startDate],"/run_",string[cfg`startTime],"/";":";"."];
  paths:pname,/:string[names],\:"/";
  if[all b:names in key hsym`$pname;
    paths:dataCheck.i.ssrWindows each paths;
    // Generate folders in which to place saved information
    {[fnm;b]$[not b;system"mkdir",$[.z.o like "w*";" ";" -p "],fnm;]}'[paths;b]];
  names!flip(paths;{count[path]_x}each paths)
  }

// @kind function
// @category dataCheckUtility
// @fileoverview convert linux/mac type file name to windows complient file names
// @param path {char[]} a linux/mac conformant file path
// @return     {char[]} the path modified to be suitable for windows systems
dataCheck.i.ssrWindows:{[path]
  $[.z.o like "w*";ssr[path;"/";"\\"];path]
  }

