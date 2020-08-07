// Based on the problem type being solved and user defined configuration retrieve the full list of
// models which can be applied in the running of AutoML, the list of models to be run may be
// reduced following the processing of the data and splitting to comply with the model requirements
\d .automl

nodekeys:`function`inputs`outputs
i.Model_Gen_inputs  :`Config`Target!"!F"
i.Model_Gen_outputs :"+"
i.Model_Gen_function:{[cfg;feats]([5?`a`b`c]5?`abc`cab;5?1f)}
Model_Generation:nodekeys!(i.Model_Gen_function;i.Model_Gen_inputs;i.Model_Gen_outputs)
