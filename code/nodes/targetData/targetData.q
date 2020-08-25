\d .automl

// Loading of the target dataset, data can be loaded from in process or alternative data sources

// @kind function
// @category node
// @fileoverview Load target dataset from a location defined by a user provided dictionary
//   and in accordance with the function .ml.i.loaddset
// @param cfg {dict} Dictionary outlining the location and method by which to retrieve the data
// @return    {(num[];sym[])} numerical or symbol vector containing the target dataset
targetData.node.function:{[cfg]
  dset:.ml.i.loaddset cfg;
  $[.Q.ty[dset]in "befhijs";
    dset;
    '`$"Dataset not of a suitable type only 'befhijs' currently supported"
  ]
  }

// Input information
targetData.node.inputs:"!"

// Output information
targetData.node.outputs:"F"
