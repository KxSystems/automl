\d .automl

run:{[graph;xdata;ydata;ftype;ptype;params]
  if[params=(::);params:()!()];
  // Consolidate custom information and generate appropriate config
  AutoMLCfg:params,`feat_extract_type`problem_type!(ftype;ptype);
  graph:.ml.addCfg[graph;`AutoML_Cfg]AutoMLCfg;
  // Default behavior of xdata/ydata = accept data from process, overwritten by dict input
  xdata:$[99h = type xdata;xdata;`typ`data!(`process;xdata)];
  ydata:$[99h = type ydata;ydata;`typ`data!(`process;ydata)];
  graph:.ml.addCfg[graph;`Feature_Data_Cfg;xdata];
  graph:.ml.addCfg[graph;`Target_Data_Cfg ;ydata];
  // Ensure that the appropriate edges have been connected to the required input nodes
  graph:.ml.connectEdge[graph;`AutoML_Cfg      ;`output;`Configuration;`input];
  graph:.ml.connectEdge[graph;`Feature_Data_Cfg;`output;`Feature_Data ;`input];
  graph:.ml.connectEdge[graph;`Target_Data_Cfg ;`output;`Target_Data  ;`input];
  // Generate and execute the pipeline end to end
  .ml.execPipeline .ml.createPipeline[graph]
  }[graph]
  

