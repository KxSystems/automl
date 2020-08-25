// Apply label encoding on symbolic data returning an encoded version of the data in this instance
// or the original dataset in the case that does not require this modification
\d .automl

labelEncode.node.inputs  :"F"
labelEncode.node.outputs :`symMap`target!"!F"
labelEncode.node.function:{[tgt]
  `symMap`target!(`sym1`sym2!1 2;tgt)
  }
