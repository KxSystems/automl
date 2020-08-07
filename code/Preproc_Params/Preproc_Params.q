// Collect all the parameters relevant for the generation of reports/graphs etc in the preprocessing phase
// such they can be consolidated into a single node later in the workflow
\d .automl

nodekeys:`function`inputs`outputs
i.Preproc_Params_inputs  :`Config`Data_Description`Creation_Time`Sig_Feats`Sym_Encode!"!+tSS"
i.Preproc_Params_outputs :"!"
i.Preproc_Params_function:{[cfg;descrip;ctime;sigfeat;symenc]
  `Config`Data_Description`Creation_Time`Sig_Feats`Sym_Encode!(cfg;descrip;ctime;sigfeat;symenc)}
Preproc_Params:nodekeys!(i.Preproc_Params_function;i.Preproc_Params_inputs;i.Preproc_Params_outputs)
