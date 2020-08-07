// At present this function only provides the both the symbol encoding map which is used in the application 
// of automl on new datasets and the 'autotype' function used to remove columns which cannot be 
// handled by the problem type that the user is attempting to solve
\d .automl

nodekeys:`function`inputs`outputs
i.Feature_Mod_inputs  :`Config`Features!"!+"
i.Feature_Mod_outputs :`Sym_Encode`Features!"S+"
i.Feature_Mod_function:{[cfg;feats]`Sym_Encode`Features!(5?`abc`cab;feats)}
Feature_Modification:nodekeys!(i.Feature_Mod_function;i.Feature_Mod_inputs;i.Feature_Mod_outputs)
