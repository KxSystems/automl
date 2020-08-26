\d .automl

// Apply label encoding on symbolic data returning an encoded version of the data in this instance
// or the original dataset in the case that does not require this modification

// @kind function
// @category node
// @fileoverview Encode target data if target is a symbol vector 
// @param tgt  {(num[];sym[])} numerical or symbol vector containing the target dataset
// @return     {dict} The mapping to each symbol encoded data along with the symbol 
//   encoded target data 
labelEncode.node.function:{[tgt]
  symMap:()!();
  if[11h~type tgt;
     distinctTgt:distinct tgt;
     symMap:asc[distinctTgt]!til count distinctTgt;
     tgt:.ml.labelencode tgt;
     ];
  `symMap`target!(symMap;tgt)
  }

// Input information
labelEncode.node.inputs  :"F"

// Output information
labelEncode.node.outputs :`symMap`target!"!F"
