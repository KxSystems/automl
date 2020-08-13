// Loading of the feature dataset, this can be from in process or several alternative datasources
\d .automl

featureData.node.inputs  :"!"
featureData.node.outputs :"+"
featureData.node.function:.ml.i.loaddset
