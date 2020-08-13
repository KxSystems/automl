\d .automl

run:{[graph;xdata;ydata;ftype;ptype;params]
  // Handle default parameters and retrieval from file path
  if[params~(::);params:()!()];
  if[type[params]in 10 -11h;params:enlist[`configPath]!enlist params];
  Automl_Config:params,`featExtractType`problemType`startDate`startTime!(ftype;ptype;.z.D;.z.T);
  // Default = accept data from process. Overwritten if dictionary input
  xdata:$[99h=type xdata;xdata;`typ`data!(`process;xdata)];
  ydata:$[99h=type ydata;ydata;`typ`data!(`process;ydata)];
  graph:.ml.addCfg[graph;`Automl_Config      ;Automl_Config];
  graph:.ml.addCfg[graph;`Feature_Data_Config;xdata];
  graph:.ml.addCfg[graph;`Target_Data_Config ;ydata];
  graph:.ml.connectEdge[graph;`Automl_Config      ;`output;`Configuration;`input];
  graph:.ml.connectEdge[graph;`Feature_Data_Config;`output;`Feature_Data ;`input];
  graph:.ml.connectEdge[graph;`Target_Data_Config ;`output;`Target_Data  ;`input];
  .ml.execPipeline .ml.createPipeline[graph]
  }[graph]

// currently required in order to pass data check  
prep.i.default:{x}
xv.fitpredict:{x}
prep.freshsignificance:{x}
.ml.ttsnonshuff:{x}
