// This function contains the logic required to generate appropriate default/custom features
// for each of the problem types supported by the AutoML platform
\d .automl

nodekeys:`function`inputs`outputs
i.Feature_Creation_inputs  :`Config`Features!"!+"
i.Feature_Creation_outputs :`Creation_Time`Features!"t+"
i.Feature_Creation_function:{[cfg;feats]`Creation_Time`Features!(.z.t;feats)}
Feature_Creation:nodekeys!(i.Feature_Creation_function;i.Feature_Creation_inputs;i.Feature_Creation_outputs)
