// Collect all the parameters relevant for the generation of reports/graphs etc in the preprocessing phase
// such they can be consolidated into a single node later in the workflow
\d .automl

inputKeys :`config`dataDescription`creationTime`sigFeats`symEncode`symMap`featModel
inputTypes:"!+tSS!<"
preprocParams.node.inputs  :inputKeys!inputTypes
preprocParams.node.outputs :"!"
preprocParams.node.function:{[cfg;descrip;ctime;sigfeat;symenc;symmap;featmodel]
  preprocKeys:`config`dataDescription`creationTime`sigFeats`symEncode`symMap;
  preprocVals:(cfg;descrip;ctime;sigfeat;symenc;symmap);
  preprocKeys!preprocVals
  }
