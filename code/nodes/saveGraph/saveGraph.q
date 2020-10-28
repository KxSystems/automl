\d .automl

// Save all the graphs relevant for the generation of reports and for prosperity

// @kind function
// @category node
// @fileoverview Save all graphs needed for reports 
// @param params {dict} All data generated during the preprocessing and
//  prediction stages
// @return {null} All graphs needed for reports are saved to appropriate location
saveGraph.node.function:{[params]
  if[0~params[`config]`saveopt;:params];
  savePath:params[`config]`imagesSavePath;
  saveGraph.targetPlot[params;savePath];
  saveGraph.resultPlot[params;savePath]
  saveGraph.impactPlot[params;savePath];
  params
  }

// Input information
saveGraph.node.inputs  :"!"

// Output information
saveGraph.node.outputs :"!"
