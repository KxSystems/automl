\d .automl

// Loading of the feature dataset, this can be from in process or several alternative datasources

// @kind function
// @category node
// @fileoverview Load feature dataset from a location defined by a user provided dictionary
//   and in accordance with the function .ml.i.loaddset
// @param cfg {dict} Dictionary outlining the location and method by which to retrieve the data
// @return    {tab} The feature data as a table
featureData.node.function:{[cfg]
  dset:.ml.i.loaddset cfg;
  $[98h<>type dset;
    '`$"Feature dataset must be a simple table for use with Automl";
    dset
  ]
  }

// Input information
featureData.node.inputs:"!"

// Output information
featureData.node.outputs:"+"
