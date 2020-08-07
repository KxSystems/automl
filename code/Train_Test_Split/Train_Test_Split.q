// Apply the user defined train test split functionality onto the users feature/target datasets returning
// the train-test split data as a list of (xtrain;ytrain;xtest;ytest)
\d .automl

nodekeys:`function`inputs`outputs
i.TTS_inputs  :`Config`Features`Target`Sig_Feats!"!+FS"
i.TTS_outputs :" "
i.TTS_function:{[cfg;feats;tgt;sigfeats](80?1f;80?1f;20?1f;20?1f)}
Train_Test_Split:nodekeys!(i.TTS_function;i.TTS_inputs;i.TTS_outputs)
