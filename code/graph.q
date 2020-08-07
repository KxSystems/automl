\d .automl

// Generate an empty graph
graph:.ml.createGraph[]

// Populate all required Nodes for the graph
graph:.ml.addNode[graph;`Configuration       ;Configuration]
graph:.ml.addNode[graph;`Feature_Data        ;Feature_Data]
graph:.ml.addNode[graph;`Target_Data         ;Target_Data]
graph:.ml.addNode[graph;`Data_Check          ;Data_Check]
graph:.ml.addNode[graph;`Model_Generation    ;Model_Generation]
graph:.ml.addNode[graph;`Feature_Modification;Feature_Modification]
graph:.ml.addNode[graph;`Label_Encode        ;Label_Encode]
graph:.ml.addNode[graph;`Data_Preprocessing  ;Data_Preprocessing]
graph:.ml.addNode[graph;`Feature_Creation    ;Feature_Creation]
graph:.ml.addNode[graph;`Feature_Significance;Feature_Significance]
graph:.ml.addNode[graph;`Train_Test_Split    ;Train_Test_Split]
graph:.ml.addNode[graph;`Select_Models       ;Select_Models]
graph:.ml.addNode[graph;`Run_Models          ;Run_Models]
graph:.ml.addNode[graph;`Optimize_Models     ;Optimize_Models]
graph:.ml.addNode[graph;`Preproc_Params      ;Preproc_Params]
graph:.ml.addNode[graph;`Predict_Params      ;Predict_Params]
graph:.ml.addNode[graph;`Param_Consolidate   ;Param_Consolidate]
graph:.ml.addNode[graph;`Save_Graph          ;Save_Graph]
graph:.ml.addNode[graph;`Save_Meta           ;Save_Meta]
graph:.ml.addNode[graph;`Save_Report         ;Save_Report]


// Connect all possible edges prior to the data/config ingestion

// Data_Check
graph:.ml.connectEdge[graph;`Configuration;`output;`Data_Check;`Config];
graph:.ml.connectEdge[graph;`Feature_Data ;`output;`Data_Check;`Features];
graph:.ml.connectEdge[graph;`Target_Data  ;`output;`Data_Check;`Target];

// Model_Generation
graph:.ml.connectEdge[graph;`Data_Check;`Config;`Model_Generation;`Config]
graph:.ml.connectEdge[graph;`Data_Check;`Target;`Model_Generation;`Target]

// Feature_Modification
graph:.ml.connectEdge[graph;`Data_Check;`Config  ;`Feature_Modification;`Config]
graph:.ml.connectEdge[graph;`Data_Check;`Features;`Feature_Modification;`Features]

// Label_Encode
graph:.ml.connectEdge[graph;`Data_Check;`Target;`Label_Encode;`input]

// Data_Preprocessing
graph:.ml.connectEdge[graph;`Data_Check          ;`Config  ;`Data_Preprocessing;`Config]
graph:.ml.connectEdge[graph;`Feature_Modification;`Features;`Data_Preprocessing;`Features]
graph:.ml.connectEdge[graph;`Label_Encode        ;`output  ;`Data_Preprocessing;`Target]

// Feature_Creation
graph:.ml.connectEdge[graph;`Data_Preprocessing;`Features;`Feature_Creation;`Features]
graph:.ml.connectEdge[graph;`Data_Check        ;`Config  ;`Feature_Creation;`Config]

// Feature_Significance
graph:.ml.connectEdge[graph;`Feature_Creation;`Features;`Feature_Significance;`Features]
graph:.ml.connectEdge[graph;`Label_Encode    ;`output  ;`Feature_Significance;`Target]
graph:.ml.connectEdge[graph;`Data_Check      ;`Config  ;`Feature_Significance;`Config]

// Train_Test_Split
graph:.ml.connectEdge[graph;`Feature_Significance;`Features ;`Train_Test_Split;`Features]
graph:.ml.connectEdge[graph;`Feature_Significance;`Sig_Feats;`Train_Test_Split;`Sig_Feats]
graph:.ml.connectEdge[graph;`Label_Encode        ;`output   ;`Train_Test_Split;`Target]
graph:.ml.connectEdge[graph;`Data_Check          ;`Config   ;`Train_Test_Split;`Config]

// Select_Models
graph:.ml.connectEdge[graph;`Data_Check      ;`Config;`Select_Models;`Config]
graph:.ml.connectEdge[graph;`Train_Test_Split;`output;`Select_Models;`tts_obj]
graph:.ml.connectEdge[graph;`Model_Generation;`output;`Select_Models;`Models]

// Run_Models
graph:.ml.connectEdge[graph;`Select_Models;`tts_obj;`Run_Models;`tts_obj]
graph:.ml.connectEdge[graph;`Select_Models;`Models ;`Run_Models;`Models]
graph:.ml.connectEdge[graph;`Data_Check   ;`Config ;`Run_Models;`Config]

// Optimize_Models
graph:.ml.connectEdge[graph;`Run_Models   ;`Best_Model       ;`Optimize_Models;`Best_Model]
graph:.ml.connectEdge[graph;`Run_Models   ;`Best_Scoring_Name;`Optimize_Models;`Best_Scoring_Name]
graph:.ml.connectEdge[graph;`Select_Models;`Models           ;`Optimize_Models;`Models]
graph:.ml.connectEdge[graph;`Select_Models;`tts_obj          ;`Optimize_Models;`tts_obj]
graph:.ml.connectEdge[graph;`Data_Check   ;`Config           ;`Optimize_Models;`Config]


// Preproc_Params
graph:.ml.connectEdge[graph;`Data_Check          ;`Config          ;`Preproc_Params;`Config]
graph:.ml.connectEdge[graph;`Data_Preprocessing  ;`Data_Description;`Preproc_Params;`Data_Description]
graph:.ml.connectEdge[graph;`Feature_Creation    ;`Creation_Time   ;`Preproc_Params;`Creation_Time]
graph:.ml.connectEdge[graph;`Feature_Significance;`Sig_Feats       ;`Preproc_Params;`Sig_Feats]
graph:.ml.connectEdge[graph;`Feature_Modification;`Sym_Encode      ;`Preproc_Params;`Sym_Encode]

// Predict_Params
graph:.ml.connectEdge[graph;`Optimize_Models;`Best_Model ;`Predict_Params;`Best_Model]
graph:.ml.connectEdge[graph;`Optimize_Models;`Test_Score ;`Predict_Params;`Test_Score]
graph:.ml.connectEdge[graph;`Optimize_Models;`Predictions;`Predict_Params;`Predictions]

// Param_Consolidate
graph:.ml.connectEdge[graph;`Predict_Params;`output;`Param_Consolidate;`Prediction_Store]
graph:.ml.connectEdge[graph;`Preproc_Params;`output;`Param_Consolidate;`Preproc_Params]

// Save_Graph
graph:.ml.connectEdge[graph;`Param_Consolidate;`output;`Save_Graph;`input]

// Save_Meta
graph:.ml.connectEdge[graph;`Param_Consolidate;`output;`Save_Meta;`input]

// Save_Report
graph:.ml.connectEdge[graph;`Param_Consolidate;`output;`Save_Report;`input]

