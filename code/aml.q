\d .automl

run:{[graph;xdata;ydata;ftype;ptype;params]
  if[params=(::);params:()!()];
  amlConfig:params,`featExtractType`problemType`startDate`startTime!(ftype;ptype;.z.D;.z.T);
  // Default = accept data from process. Overwritten if dictionary input
  xdata:$[99h=type xdata;xdata;`typ`data!(`process;xdata)];
  ydata:$[99h=type ydata;ydata;`typ`data!(`process;ydata)];
  graph:.ml.addCfg[graph;`automlConfig     ;amlConfig];
  graph:.ml.addCfg[graph;`featureDataConfig;xdata];
  graph:.ml.addCfg[graph;`targetDataConfig ;ydata];
  graph:.ml.connectEdge[graph;`automlConfig     ;`output;`Configuration;`input];
  graph:.ml.connectEdge[graph;`featureDataConfig;`output;`Feature_Data ;`input];
  graph:.ml.connectEdge[graph;`targetDataConfig ;`output;`Target_Data  ;`input];
  .ml.execPipeline .ml.createPipeline[graph]
  }[graph]

// currently required in order to pass data check  
prep.i.default:{x}
xv.fitpredict:{x}
prep.freshsignificance:{x}
.ml.ttsnonshuff:{x}
