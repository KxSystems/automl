// Collect all the parameters relevant for the generation of reports/graphs etc in the preprocessing phase
// such they can be consolidated into a single node later in the workflow
\d .automl

preprocParams.node.inputs  :`config`dataDescription`creationTime`sigFeats`symEncode!"!+tSS"
preprocParams.node.outputs :"!"
preprocParams.node.function:{[cfg;descrip;ctime;sigfeat;symenc]
  `config`dataDescription`creationTime`sigFeats`symEncode!(cfg;descrip;ctime;sigfeat;symenc)}
