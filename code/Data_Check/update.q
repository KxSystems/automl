\d .automl

// Update info from Configuration node based on feature dataset
/* t       = tabular information
/* cfg     = configuration dictionary based on user input and start date/time
/. returns > full configuration info needed augmenting cfg with default info
update.config:{[t;cfg]
  typ:cfg`featExtractType;
  standardCfg:`startDate`startTime`featExtractType`problemType # cfg;
  customCfg  :`startDate`startTime`featExtractType`problemType _ cfg;
  updateCfg  :$[typ=`fresh;
    {[t;cfg]
      d:i.freshDefault[];
      d:$[(typ:type cfg)in 10 -11 99h;
          [if[10h~typ ;cfg:i.getdict cfg];
           if[-11h~typ;cfg:i.getdict$[":"~first cfg;1_;]cfg:string cfg];
           $[min key[cfg]in key d;d,cfg;'`$"You can only pass appropriate keys to fresh"]
          ];
          not any cfg;d;
          '`$"cfg must be passed the identity `(::)`, a filepath to a parameter flatfile",
             " or a dictionary with appropriate key/value pairs"
        ];
      d[`aggcols]:$[100h~typagg:type d`aggcols;d[`aggcols]t;
                    11h~abs typagg;d`aggcols;
                    '`$"aggcols must be passed function or list of columns"];
      d,enlist[`tf]!enlist 1~checkimport[0]
    }[t;customCfg];
    typ=`normal;
    {[t;cfg]
      d:i.normalDefault[];
      d:$[(typ:type cfg)in 10 -11 99h;
          [if[10h~typ ;cfg:i.getdict cfg];
           if[-11h~typ;cfg:i.getdict$[":"~first cfg;1_;]cfg:string cfg];
           $[min key[cfg]in key d;d,cfg;'`$"You can only pass appropriate keys to normal"]
          ];
          not any cfg;d;
          '`$"cfg must be passed the identity `(::)`, a filepath to a parameter flatfile",
             " or a dictionary with appropriate key/value pairs"
        ];
      d,enlist[`tf]!enlist 1~checkimport[0]
    }[t;customCfg];
    typ=`nlp;
    {[t;cfg]
      i.checkNLPType[t];
      d:i.nlpDefault[];
      d:$[(typ:type p)in 10 -11 99h;
          [if[10h~typ ;cfg:i.getdict cfg];
           if[-11h~typ;cfg:i.getdict$[":"~first cfg;1_;]cfg:string cfg];
           $[min key[cfg]in key d;d,cfg;'`$"You can only pass appropriate keys to nlp"]
          ];
          not any cfg;d;
          '`$"cfg must be passed the identity `(::)`, a filepath to a parameter flatfile",
             " or a dictionary with appropriate key/value pairs"
        ];
      d,enlist[`tf]!enlist 1~checkimport[0]
    }[t;customCfg];
    typ=`tseries;
    '`$"This will need to be added once the time-series recipe is in place";
    '`$"Incorrect input type"];
  standardCfg,updateCfg
  }
