// Collect all the parameters relevant for the generation of reports/graphs etc in the preprocessing phase
// such they can be consolidated into a single node later in the workflow
\d .automl

inputKeys :`config`dataDescription`creationTime`sigFeats`symEncode`symMap`featModel`ttsObject
inputTypes:"!+tSS!<!"
preprocParams.node.inputs  :inputKeys!inputTypes
preprocParams.node.outputs :"!"
preprocParams.node.function:{[cfg;descrip;ctime;sigfeat;symenc;symmap;featmodel;ttsObject]
  preprocKeys:`config`dataDescription`creationTime`sigFeats`symEncode`symMap`ttsObject;
  preprocVals:(cfg;descrip;ctime;sigfeat;symenc;symmap;ttsObject);
  preprocKeys!preprocVals
  }
