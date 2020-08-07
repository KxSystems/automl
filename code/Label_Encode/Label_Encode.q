// Apply label encoding on symbolic data returning an encoded version of the data in this instance
// or the original dataset in the case that does not require this modification
\d .automl

nodekeys:`function`inputs`outputs
i.Label_Encode_inputs  :"F"
i.Label_Encode_outputs :"F"
i.Label_Encode_function:{[tgt]tgt}
Label_Encode:nodekeys!(i.Label_Encode_function;i.Label_Encode_inputs;i.Label_Encode_outputs)
