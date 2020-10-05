\d .automl

// @kind function
// @category models
// @fileoverview Fit model on training data and score using test data
// @param data  {dict} containing training and testing data according to keys
//   `xtrn`ytrn`xtst`ytst
// @param seed  {int} seed used for initialising the same model
// @param mname {sym} name of the model being applied
// @return      {int;float;bool} the predicted values for a given model as applied to input data
models.keras.fitScore:{[data;seed;mname]
  mdl:get[".automl.models.keras.",string[mname]".model"][data;seed];
  mdl:get[".automl.models.keras.",string[mname],".fit"][data;mdl];
  get[".automl.models.",string[mname],".predict"][data;mdl]
  }

// @kind function
// @category models
// @fileoverview Fit a vanilla keras model to data
// @param data  {dict} containing training and testing data according to keys
//   `xtrn`ytrn`xtst`ytst
// @param mdl   {<} model object being passed through the system (compiled/fitted)
// @return      {<} a vanilla fitted keras model
models.keras.binary.fit:models.keras.reg.fit:models.keras.multi.fit:{[data;mdl]
  mdl[`:fit][models.i.npArray data`xtrn;data`ytrn;`batch_size pykw 32;`verbose pykw 0];
  mdl
  }

// @kind function
// @category models
// @fileoverview Compile a keras model for binary problems
// @param data  {dict} containing training and testing data according to keys
//   `xtrn`ytrn`xtst`ytst
// @param seed  {int} seed used for initialising the same model
// @return      {<} the compiled keras models
models.keras.binary.model:{[data;seed]
  models.i.numpySeed[seed];
  models.i.tensorflowSeed[seed];
  mdl:models.i.kerasSeq[];
  mdl[`:add]models.i.kerasDense[32;`activation pykw"relu";`input_dim pykw count first data`ytrn];
  mdl[`:add]models.i.kerasDense[1;`activation pykw "sigmoid"];
  mdl[`:compile][`loss pykw "binary_crossentropy";`optimizer pykw "rmsprop"];
  mdl
  }

// @kind function
// @category models
// @fileoverview Predict test data values using a compiled model
//  for binary problem types
// @param data  {dict} containing training and testing data according to keys
//   `xtrn`ytrn`xtst`ytst
// @param mdl   {<} model object being passed through the system (compiled/fitted)
// @return      {bool} the predicted values for a given model
models.keras.binary.predict:{[data;mdl]
  .5<raze mdl[`:predict][models.i.npArray data`xtst]`
  }

// @kind function
// @category models
// @fileoverview Compile a keras model for regression problems
// @param data  {dict} containing training and testing data according to keys
//   `xtrn`ytrn`xtst`ytst
// @param seed  {int} seed used for initialising the same model
// @return      {<} the compiled keras models
models.keras.reg.model:{[data;seed]
  models.i.numpySeed[seed];
  models.i.tensorflowSeed[seed];
  mdl:models.i.kerasSeq[];
  mdl[`:add]models.i.kerasDense[32;`activation pykw "relu";`input_dim pykw count first data`xtrn];
  mdl[`:add]models.i.kerasDense[1 ;`activation pykw "relu"];
  mdl[`:compile][`loss pykw "mse";`optimizer pykw "rmsprop"];
  mdl
  }

// @kind function
// @category models
// @fileoverview Predict test data values using a compiled model
//  for regression problem types
// @param data  {dict} containing training and testing data according to keys
//   `xtrn`ytrn`xtst`ytst
// @param mdl   {<} model object being passed through the system (compiled/fitted)
// @return      {int;float} the predicted values for a given model
models.keras.reg.predict:{[data;mdl]
  raze mdl[`:predict][models.i.npArray data`xtst]`
  }

// @kind function
// @category models
// @fileoverview Compile a keras model for multiclass problems
// @param data  {dict} containing training and testing data according to keys
//   `xtrn`ytrn`xtst`ytst
// @param seed  {int} seed used for initialising the same model
// @return      {<} the compiled keras models
models.keras.multi.model:{[data;seed]
  data`ytrn:models.i.npArray flip value .ml.i.onehot1  data`ytrn; 
  models.i.numpySeed[seed];
  models.i.tensorflowSeed[seed];
  mdl:models.i.kerasSeq[];
  mdl[`:add]models.i.kerasDense[32;`activation pykw "relu";`input_dim pykw count first data`xtrn];
  mdl[`:add]models.i.kerasDense[count distinct data[`ytrn]`;`activation pykw "softmax"];
  mdl[`:compile][`loss pykw "categorical_crossentropy";`optimizer pykw "rmsprop"];
  mdl
  }

// @kind function
// @category models
// @fileoverview Predict test data values using a compiled model
//  for multiclass problem types
// @param data  {dict} containing training and testing data according to keys
//   `xtrn`ytrn`xtst`ytst
// @param mdl   {<} model object being passed through the system (compiled/fitted)
// @return      {int;float;bool} the predicted values for a given model
models.keras.multi.predict:{[data;mdl]
  mdl[`:predict_classes][models.i.npArray data`xtst]`
  }

// load required python modules
models.i.npArray   :.p.import[`numpy       ]`:array;
models.i.kerasSeq  :.p.import[`keras.models]`:Sequential;
models.i.kerasDense:.p.import[`keras.layers]`:Dense;
models.i.numpySeed :.p.import[`numpy.random]`:seed;

// import appropriate random seed depending on tensorflow version
models.i.tf:.p.import[`tensorflow];
models.i.tfType:$[2>"I"$first models.i.tf[`:__version__]`;`:set_random_seed;`:random.set_seed];
models.i.tensorflowSeed:models.i.tf models.i.tfType;

// allow multiprocess
.ml.loadfile`:util/mproc.q
if[0>system"s";
 .ml.mproc.init[abs system"s"]("system[\"l automl/automl.q\"]";".automl.loadfile`:init.q")
 ];

