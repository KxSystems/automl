\d .automl

// These are the names of all the keras models that are defined within most vanilla
// workflow, a user wishing to add their own models must augment this list to ensure
// that this list is appropriately updated.
models.i.keraslist:`regkeras`multikeras`binarykeras

// @kind function
// @category models
// @fileoverview Fit model on training data and score using test data
// @param data  {list} data as a mixed list containing training and testing data 
//  ((xtrn;ytrn);(xtst;ytst))
// @param seed  {int} seed used for initialising the same model
// @param mtype {sym} model type
// @return      {int;float;bool} the predicted values for a given model as applied to input data
models.fitscore:{[data;seed;mtype]
  // encode multi-class labels appropriately
  if[mtype~`multi;
   data[;1]:npa@'flip@'./:[;((::;0);(::;1))](0,count data[0]1)_/:value .ml.i.onehot1(,/)data[;1]
   ];
  mdl:get[".automl.",string[mtype],"mdl"][data;seed;mtype];
  mdl:get[".automl.",string[mtype],"fit"][data;mdl];
  get[".automl.",string[mtype],"predict"][data;mdl]
  }

// @kind function
// @category models
// @fileoverview Fit a vanilla keras model to data
// @param data  {list} data as a mixed list containing training and testing data 
//  ((xtrn;ytrn);(xtst;ytst))
// @param mdl   {<} model object being passed through the system (compiled/fitted)
// @return      {<} a vanilla fitted keras model
models.binaryfit:regfit:multifit:{[data;mdl]
  mdl[`:fit][npa data[0]0;data[0]1;`batch_size pykw 32;`verbose pykw 0];
  mdl
  }

// @kind function
// @category models
// @fileoverview Compile a keras model for binary problems
// @param data  {list} data as a mixed list containing training and testing data 
//  ((xtrn;ytrn);(xtst;ytst))
// @param seed  {int} seed used for initialising the same model
// @param mtype {sym} model type
// @return      {<} the compiled keras models
models.binarymdl:{[data;seed;mtype]
  nps[seed];
  if[0~checkimport[0];
   tfs[seed]
   ];
  mdl:seq[];
  mdl[`:add]dns[32;`activation pykw"relu";`input_dim pykw count first data[0]0];
  mdl[`:add]dns[1;`activation pykw "sigmoid"];
  mdl[`:compile][`loss pykw "binary_crossentropy";`optimizer pykw "rmsprop"];
  mdl
  }

// @kind function
// @category models
// @fileoverview Predict test data values using a compiled model
//  for binary problem types
// @param data  {list} data as a mixed list containing training and testing data 
//  ((xtrn;ytrn);(xtst;ytst))
// @param mdl   {<} model object being passed through the system (compiled/fitted)
// @return      {int;float;bool} the predicted values for a given model
models.binarypredict:{[data;mdl]
  .5<raze mdl[`:predict][npa data[1]0]`
  }

// @kind function
// @category models
// @fileoverview Compile a keras model for regression problems
// @param data  {list} data as a mixed list containing training and testing data 
//  ((xtrn;ytrn);(xtst;ytst))
// @param seed  {int} seed used for initialising the same model
// @param mtype {sym} model type
// @return      {<} the compiled keras models
models.regmdl:{[data;seed;mtype]
  nps[seed];
  if[0~checkimport[0];tfs[seed]];
  mdl:seq[];
  mdl[`:add]dns[32;`activation pykw "relu";`input_dim pykw count first data[0]0];
  mdl[`:add]dns[1 ;`activation pykw "relu"];
  mdl[`:compile][`loss pykw "mse";`optimizer pykw "rmsprop"];
  mdl
  }

// @kind function
// @category models
// @fileoverview Predict test data values using a compiled model
//  for regression problem types
// @param data  {list} data as a mixed list containing training and testing data 
//  ((xtrn;ytrn);(xtst;ytst))
// @param mdl   {<} model object being passed through the system (compiled/fitted)
// @return      {int;float;bool} the predicted values for a given model
models.regpredict:{[data;mdl]
  raze mdl[`:predict][npa data[1]0]`
  }

// @kind function
// @category models
// @fileoverview Compile a keras model for multiclass problems
// @param data  {list} data as a mixed list containing training and testing data 
//  ((xtrn;ytrn);(xtst;ytst))
// @param seed  {int} seed used for initialising the same model
// @param mtype {sym} model type
// @return      {<} the compiled keras models
models.multimdl:{[data;seed;mtype]
  nps[seed];
  if[0~checkimport[0];
  tfs[seed]
  ];
  mdl:seq[];
  mdl[`:add]dns[32;`activation pykw "relu";`input_dim pykw count first data[0]0];
  mdl[`:add]dns[count distinct (data[0]1)`;`activation pykw "softmax"];
  mdl[`:compile][`loss pykw "categorical_crossentropy";`optimizer pykw "rmsprop"];
  mdl
  }

// @kind function
// @category models
// @fileoverview Predict test data values using a compiled model
//  for multiclass problem types
// @param data  {list} data as a mixed list containing training and testing data 
//  ((xtrn;ytrn);(xtst;ytst))
// @param mdl   {<} model object being passed through the system (compiled/fitted)
// @return      {int;float;bool} the predicted values for a given model
models.multipredict:{[data;mdl]
  mdl[`:predict_classes][npa data[1]0]`
  }

// load required python modules
npa:.p.import[`numpy]`:array;
seq:.p.import[`keras.models]`:Sequential;
dns:.p.import[`keras.layers]`:Dense;
nps:.p.import[`numpy.random]`:seed;

// import appropriate random seed depending on tensorflow version
if[0~checkimport[0];
  tf:.p.import[`tensorflow];
  tfs:tf$[2>"I"$first tf[`:__version__]`;
         [`:set_random_seed];
         [`:random.set_seed]
    ]
  ];

// allow multiprocess
.ml.loadfile`:util/mproc.q
if[0>system"s";
 .ml.mproc.init[abs system"s"]("system[\"l automl/automl.q\"]";".automl.loadfile`:init.q")
 ];

