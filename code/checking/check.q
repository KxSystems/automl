// This file includes the logic for requirement checks and loading of optional
// functionality within the framework, namely dependancies for deep learning/nlp models etc.

\d .automl

i.loadkeras:{
  $[0~checkimport[0];
    [loadfile`:code/models/lib_support/keras.q;loadfile`:code/models/lib_support/keras.p];
    [-1"Requirements for Keras models not satisfied. Keras models will be excluded from model evaluation.";]]}

i.loadtorch:{
  $[0~checkimport[1];
    [loadfile`:code/models/lib_support/torch.q;loadfile`:code/models/lib_support/torch.p];
    [-1"Requirements for PyTorch models not satisfied. PyTorch models will be excluded from model evaluation.";]]}

i.loadnlp:{
  $[(0~checkimport[3])&(::)~@[{system"l ",x};"nlp/nlp.q";{0b}];
   .nlp.loadfile`:init.q;
   [-1"Requirements for NLP models are not satisfied, see documentation for requirements and install instructions";]]}

i.loadlatex:{
  $[0~checkimport[2];
    [loadfile`:code/postproc/reports/latex.p;loadfile`:code/postproc/reports/latex.q];
    [-1"Requirements for latex report generation are not satisfied, see documentation for requirements. Report will use reportlab.";]]}


// Early exiting functionality if a user is trying to run nlp after already being told
// that they do not have the explicit requirements
i.nlpcheck:{
  if[not(0~checkimport[3])&(::)~@[{system"l ",x};"nlp/nlp.q";{0b}];
   '"User attempting to run NLP models with insufficient requirements, see documentation"]
  }
