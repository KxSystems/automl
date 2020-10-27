\d .automl

// @kind function
// @category node
// @fileoverview Collect all the parameters relevant for the generation of reports/graphs 
//   etc in the preprocessing phase such they can be consolidated into a single node 
//   later in the workflow
// @param cfg       {dict}    Location and method by which to retrieve the data
// @param descrip   {table}   Symbol encoding, feature data and description
// @param cTime     {time}    Time taken for feature creation
// @param sigFeats  {sym[]}   Significant features
// @param symEncode {dict}    Columns to symbol encode and their required encoding
// @param symMap    {dict}    Mapping of symbol encoded target data
// @param featModel {embedPy} NLP feature creation model used (if required)
// @param tts       {dict}    Feature and target data split into training and testing set
// @return {dict} Consolidated parameters to be passed to generate reports/graphs 
preprocParams.node.function:{[cfg;descrip;cTime;sigFeats;symEncode;symMap;featModel;tts]
  preprocKeys:`config`dataDescription`creationTime`sigFeats`symEncode`symMap`featModel`ttsObject;
  preprocKeys!(cfg;descrip;cTime;sigFeats;symEncode;symMap;featModel;tts)
  }

// Input information
inputKeys :`config`dataDescription`creationTime`sigFeats`symEncode`symMap`featModel`ttsObject
inputTypes:"!+tSS!<!"
preprocParams.node.inputs  :inputKeys!inputTypes

// Output information
preprocParams.node.outputs :"!"