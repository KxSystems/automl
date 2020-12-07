\d .automl

// Based on the problem type being solved and user defined configuration retrieve the full list of
// models which can be applied in the running of AutoML, the list of models to be run may be
// reduced following the processing of the data and splitting to comply with the model requirements

// @kind function
// @category node
// @fileoverview Create table of appropriate models for the problem type being solved
// @param cfg  {dict} Configuration information assigned by the user and related to the current run
// @param tgt  {(num[];sym[])} numerical or symbol vector containing the target dataset
// @return     {tab} Table with all information needed for appropriate models to be applied to data
modelGeneration.node.function:{[cfg;tgt]
  modelTable:modelGeneration.jsonParse cfg;
  modelGeneration.modelPrep[cfg;modelTable;tgt]
  }

// Input information
modelGeneration.node.inputs  :`config`target!"!F"

// Output information
modelGeneration.node.outputs :"+"
