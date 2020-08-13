// Apply label encoding on symbolic data returning an encoded version of the data in this instance
// or the original dataset in the case that does not require this modification
\d .automl

labelEncode.node.inputs  :"F"
labelEncode.node.outputs :"F"
labelEncode.node.function:{[tgt]
  tgt
  }
