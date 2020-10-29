\d .automl

// Automated machine learning, generation of optimal models, running on new data and 
// generation of default flatfile configurations

// @kind function
// @category automl 
// @fileoverview AutoML pipeline application on training and testing datasets
//   applying cross validation and hyperparameter search methods across a range
//   of machine learning models. Saves a reports, models, metadata information and
//   graphics for oversight purposes. 
// @param  graph  {dict} fully connected nodes and edges of a the graph used for the 
//   application of the AutoML pipeline following the definition outline 
//   in `graph/Automl_Graph.png`
// @param  xdata  {(dict;table)} unkeyed tabular feature data or dictionary outlining
//   the instructions with which to retrieve the tabular feature data in
//   accordance with `.ml.i.loaddset`
// @param  ydata  {(dict;#any[])} Target vector of any type or dictionary outlining 
//   the instructions with which to retrieve the target data in accordance with `.ml.i.loaddset`
// @param  ftype  {sym} Feature extraction type (`nlp/`normal/`fresh)
// @param  ptype  {sym} Problem type being solved (`reg/`class)
// @param  params {(dict;char[];::)} One of 
//   1. Path relative to `.automl.path` pointing to a user defined flatfile for 
//      modifying default parameters,  
//   2. Dictionary containing the aspects of default behaviour which is to be overwritten
//   3. Null(::) allowing a user to run the AutoML framework using default parameters 
// @return        {table} The full graph executed to completeness or with a diagnostic error
//   highlight to the user.
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
  .ml.execPipeline .ml.createPipeline[graph];
  automlConfig`startDate`startTime
  }[graph]


// currently required in order to pass data check  
prep.i.default:{x}
xv.fitpredict:{x}
.ml.ttsnonshuff:{x}
