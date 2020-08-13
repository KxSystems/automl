\l ml/ml.q
.ml.loadfile`:init.q

\d .automl 

// Load all nodes required for graph based on init file within associated folder
nodelist:`configuration`featureData`targetData`dataCheck`modelGeneration`featureModification,
         `labelEncode`dataPreprocessing`featureCreation`featureSignificance`trainTestSplit,
         `runModels`selectModels`optimizeModels`preprocParams`predictParams`paramConsolidate,
         `saveGraph`saveMeta`saveReport

{loadfile hsym `$"code/nodes/",string[x],"/init.q"}each nodelist;
loadfile`:code/graph.q
loadfile`:code/aml.q

