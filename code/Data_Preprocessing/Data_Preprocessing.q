// Preprocess the dataset prior to application of ML algos, this includes the application of
// Symbol encoding, handling of null data/infinities, removal of constant columns and the description of
// the dataset contents
\d .automl

nodekeys:`function`inputs`outputs
i.Data_Preproc_inputs  :`Config`Features`Target!"!+F"
i.Data_Preproc_outputs :`Data_Description`Features!"++"
i.Data_Preproc_function:{[cfg;feats;tgt]`Data_Description`Features([5?`a`b];5?1f;5?1f);feats}
Data_Preprocessing:nodekeys!(i.Data_Preproc_function;i.Data_Preproc_inputs;i.Data_Preproc_outputs)
