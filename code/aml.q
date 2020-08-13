\d .automl

run:{[graph;xdata;ydata;ftype;ptype;params]
  // Handle default parameters and retrieval from file path
  if[params~(::);params:()!()];
  if[type[params]in 10 -11h;params:enlist[`configPath]!enlist params];
  automlConfig:params,`featExtractType`problemType`startDate`startTime!(ftype;ptype;.z.D;.z.T);
  // Default = accept data from process. Overwritten if dictionary input
  xdata:$[99h=type xdata;xdata;`typ`data!(`process;xdata)];
  ydata:$[99h=type ydata;ydata;`typ`data!(`process;ydata)];
  graph:.ml.addCfg[graph;`automlConfig     ;automlConfig];
  graph:.ml.addCfg[graph;`featureDataConfig;xdata];
  graph:.ml.addCfg[graph;`targetDataConfig ;ydata];
  graph:.ml.connectEdge[graph;`automlConfig     ;`output;`configuration;`input];
  graph:.ml.connectEdge[graph;`featureDataConfig;`output;`featureData  ;`input];
  graph:.ml.connectEdge[graph;`targetDataConfig ;`output;`targetData   ;`input];
  .ml.execPipeline .ml.createPipeline[graph]
  }[graph]

// currently required in order to pass data check  
prep.i.default:{x}
xv.fitpredict:{x}
prep.freshsignificance:{x}
.ml.ttsnonshuff:{x}
