// Apply feature significance logic to data post feature extraction, returning the original dataset
// and a list of significant features to be used both for selection of data from new runs and 
// within the current run.

\d .automl

nodekeys:`function`inputs`outputs
i.Feature_Sig_inputs  :`Config`Features`Target!"!+F"
i.Feature_Sig_outputs :`Sig_Feats`Features!"S+"
i.Feature_Sig_function:{[cfg;feats;tgt]`Sig_Feats`Features!(`aaa`bbb`ccc;feats)}
Feature_Significance:nodekeys!(i.Feature_Sig_function;i.Feature_Sig_inputs;i.Feature_Sig_outputs)
