// Join together all information collected during preprocessing, processing and configuration creation
// in order to provide all information required for the generation of report/meta/graph/model saving
\d .automl

paramConsolidate.node.inputs  :`preprocParams`predictionStore!"!!"
paramConsolidate.node.outputs :"!"
paramConsolidate.node.function:{[prep;pred]prep,pred}
