\d .automl

// The following is a naming convention used in this file
/* d = data as a mixed list containing training and testing data ((xtrn;ytrn);(xtst;ytst))
/* s = seed used for initialising the same model
/* o = one-hot encoding for multi-classification example
/* m = model object being passed through the system (compiled/fitted)
/* mtype = model type

// These are the names of all the keras models that are defined within most vanilla
// workflow, a user wishing to add their own models must augment this list to ensure
// that this list is appropriately updated.
i.keraslist:`regkeras`multikeras`binarykeras

/. r > the fit functionality used for all the vanilla keras models
binaryfit:regfit:multifit:{[d;m]m[`:fit][npa d[0]0;d[0]1;`batch_size pykw 32;`verbose pykw 0];m}

/. r > the compiled keras models
binarymdl:{[d;s;mtype]
  nps[s];
  if[0~checkimport[0];tfs[s]];
  m:seq[];
  m[`:add]dns[32;`activation pykw"relu";`input_dim pykw count first d[0]0];
  m[`:add]dns[1;`activation pykw "sigmoid"];
  m[`:compile][`loss pykw "binary_crossentropy";`optimizer pykw "rmsprop"];m}
binarypredict:{[d;m].5<raze m[`:predict][npa d[1]0]`}

regmdl:{[d;s;mtype]
  nps[s];
  if[0~checkimport[0];tfs[s]];
  m:seq[];
  m[`:add]dns[32;`activation pykw "relu";`input_dim pykw count first d[0]0];
  m[`:add]dns[1 ;`activation pykw "relu"];
  m[`:compile][`loss pykw "mse";`optimizer pykw "rmsprop"];m}
regpredict   :{[d;m]raze m[`:predict][npa d[1]0]`}

multimdl:{[d;s;mtype]
  nps[s];
  if[0~checkimport[0];tfs[s]];
  m:seq[];
  m[`:add]dns[32;`activation pykw "relu";`input_dim pykw count first d[0]0];
  m[`:add]dns[count distinct (d[0]1)`;`activation pykw "softmax"];
  m[`:compile][`loss pykw "categorical_crossentropy";`optimizer pykw "rmsprop"];m}
multipredict :{[d;m]m[`:predict_classes][npa d[1]0]`}

npa:.p.import[`numpy]`:array;
seq:.p.import[`keras.models]`:Sequential;
dns:.p.import[`keras.layers]`:Dense;
nps:.p.import[`numpy.random][`:seed];
if[0~checkimport[0];
  tf:.p.import[`tensorflow];
  tfs:tf$[2>"I"$first tf[`:__version__]`;[`:set_random_seed];[`:random.set_seed]]];
