\d .automl

// Generate an empty graph
graph:createGraph[]

// Populate all required Nodes for the graph
graph:addNode[graph;`Configuration       ;Configuration]
graph:addNode[graph;`Feature_Data        ;Feature_Data]
graph:addNode[graph;`Target_Data         ;Target_Data]
graph:addNode[graph;`Data_Check          ;Data_Check]
graph:addNode[graph;`Model_Generation    ;Model_Generation]
graph:addNode[graph;`Feature_Modification;Feature_Modification]
graph:addNode[graph;`Label_Encode        ;Label_Encode]
graph:addNode[graph;`Data_Preprocessing  ;Data_Preprocessing]
graph:addNode[graph;`Feature_Creation    ;Feature_Creation]
graph:addNode[graph;`Feature_Significance;Feature_Significance]
graph:addNode[graph;`Train_Test_Split    ;Train_Test_Split]
graph:addNode[graph;`Select_Models       ;Select_Models]
graph:addNode[graph;`Run_Models          ;Run_Models]
graph:addNode[graph;`Optimize_Models     ;Optimize_Models]
graph:addNode[graph;`Preproc_Params      ;Preproc_Params]
graph:addNode[graph;`Predict_Params      ;Predict_Params]
graph:addNode[graph;`Param_Consolidate   ;Param_Consolidate]
graph:addNode[graph;`Save_Graph          ;Save_Graph]
graph:addNode[graph;`Save_Meta           ;Save_Meta]
graph:addNode[graph;`Save_Report         ;Save_Report]


// Connect all possible edges prior to the data/config ingestion

// Data_Check
graph:connectEdge[graph;`Configuration;`output;`Data_Check;`Config];
graph:connectEdge[graph;`Feature_Data ;`output;`Data_Check;`Features];
graph:connectEdge[graph;`Target_Data  ;`output;`Data_Check;`Target];

// Model_Generation
graph:connectEdge[graph;`Data_Check;`Config;`Model_Generation;`Config]
graph:connectEdge[graph;`Data_Check;`Target;`Model_Generation;`Target]

// Feature_Modification
graph:connectEdge[graph;`Data_Check;`Config  ;`Feature_Modification;`Config]
graph:connectEdge[graph;`Data_Check;`Features;`Feature_Modification;`Features]

// Label_Encode
graph:connectEdge[graph;`Data_Check;`Target;`Label_Encode;`input]

// Data_Preprocessing
graph:connectEdge[graph;`Data_Check          ;`Config  ;`Data_Preprocessing;`Config]
graph:connectEdge[graph;`Feature_Modification;`Features;`Data_Preprocessing;`Features]
graph:connectEdge[graph;`Label_Encode        ;`output  ;`Data_Preprocessing;`Target]

// Feature_Creation
graph:connectEdge[graph;`Data_Preprocessing;`Features;`Feature_Creation;`Features]
graph:connectEdge[graph;`Data_Check        ;`Config  ;`Feature_Creation;`Config]

// Feature_Significance
graph:connectEdge[graph;`Feature_Creation;`Features;`Feature_Significance;`Features]
graph:connectEdge[graph;`Label_Encode    ;`output  ;`Feature_Significance;`Target]
graph:connectEdge[graph;`Data_Check      ;`Config  ;`Feature_Significance;`Config]

// Train_Test_Split
graph:connectEdge[graph;`Feature_Significance;`Features ;`Train_Test_Split;`Features]
graph:connectEdge[graph;`Feature_Significance;`Sig_Feats;`Train_Test_Split;`Sig_Feats]
graph:connectEdge[graph;`Label_Encode        ;`output   ;`Train_Test_Split;`Target]
graph:connectEdge[graph;`Data_Check          ;`Config   ;`Train_Test_Split;`Config]

// Select_Models
graph:connectEdge[graph;`Data_Check      ;`Config;`Select_Models;`Config]
graph:connectEdge[graph;`Train_Test_Split;`output;`Select_Models;`tts_obj]
graph:connectEdge[graph;`Model_Generation;`output;`Select_Models;`Models]

// Run_Models
graph:connectEdge[graph;`Select_Models;`tts_obj;`Run_Models;`tts_obj]
graph:connectEdge[graph;`Select_Models;`Models ;`Run_Models;`Models]
graph:connectEdge[graph;`Data_Check   ;`Config ;`Run_Models;`Config]

// Optimize_Models
graph:connectEdge[graph;`Run_Models   ;`Best_Model       ;`Optimize_Models;`Best_Model]
graph:connectEdge[graph;`Run_Models   ;`Best_Scoring_Name;`Optimize_Models;`Best_Scoring_Name]
graph:connectEdge[graph;`Select_Models;`Models           ;`Optimize_Models;`Models]
graph:connectEdge[graph;`Select_Models;`tts_obj          ;`Optimize_Models;`tts_obj]
graph:connectEdge[graph;`Data_Check   ;`Config           ;`Optimize_Models;`Config]


// Preproc_Params
graph:connectEdge[graph;`Data_Check          ;`Config          ;`Preproc_Params;`Config]
graph:connectEdge[graph;`Data_Preprocessing  ;`Data_Description;`Preproc_Params;`Data_Description]
graph:connectEdge[graph;`Feature_Creation    ;`Creation_Time   ;`Preproc_Params;`Creation_Time]
graph:connectEdge[graph;`Feature_Significance;`Sig_Feats       ;`Preproc_Params;`Sig_Feats]
graph:connectEdge[graph;`Feature_Modification;`Sym_Encode      ;`Preproc_Params;`Sym_Encode]

// Predict_Params
graph:connectEdge[graph;`Optimize_Models;`Best_Model ;`Predict_Params;`Best_Model]
graph:connectEdge[graph;`Optimize_Models;`Test_Score ;`Predict_Params;`Test_Score]
graph:connectEdge[graph;`Optimize_Models;`Predictions;`Predict_Params;`Predictions]

// Param_Consolidate
graph:connectEdge[graph;`Predict_Params;`output;`Param_Consolidate;`Prediction_Store]
graph:connectEdge[graph;`Preproc_Params;`output;`Param_Consolidate;`Preproc_Params]
graph:connectEdge[graph;`Data_Check    ;`Config;`Param_Consolidate;`Config]

// Save_Graph
graph:connectEdge[graph;`Param_Consolidate;`output;`Save_Graph;`input]

// Save_Meta
graph:connectEdge[graph;`Param_Consolidate;`output;`Save_Meta;`input]

// Save_Report
graph:connectEdge[graph;`Param_Consolidate;`output;`Save_Report;`input]

