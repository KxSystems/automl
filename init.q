\d .automl

\l ml/ml.q
.ml.loadfile`:init.q

// Load all nodes required for graph based on init file within associated folder
nodelist:`Configuration`Feature_Data`Target_Data`Data_Check`Model_Generation`Feature_Modification,
         `Label_Encode`Data_Preprocessing`Feature_Creation`Feature_Significance`Train_Test_Split,
         `Run_Models`Optimize_Models`Preproc_Params`Predict_Params`Param_Consolidate`Save_Graph,
         `Save_Meta`Save_Report

{loadfile hsym `$"code/",string[x],"/init.q"}each nodelist
// loadfile`:code/graph.q
// loadfile`:code/aml.q

