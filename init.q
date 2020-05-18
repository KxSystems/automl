\d .automl

// Load in the machine learning toolkit which should be located in $QHOME
// also load in some updates to the toolkit to be integrated at a later date
\l ml/ml.q
.ml.loadfile`:init.q
loadfile`:code/updml.q

// Load all approriate components of the automl platform
loadfile`:code/preproc/checkimport.p
loadfile`:code/preproc/utils.q
loadfile`:code/preproc/preproc.q
loadfile`:code/preproc/featextract.q
loadfile`:code/proc/utils.q
loadfile`:code/proc/proc.q
loadfile`:code/proc/xvgs.q
$[0~checkimport[0];
  [loadfile`:code/models/lib_support/keras.q;
   loadfile`:code/models/lib_support/keras.p];
  [-1"Requirements for Keras models not satisfied. Keras models will be excluded from model evaluation.";]]
$[0~checkimport[1];
  [loadfile`:code/models/lib_support/torch.q;
   loadfile`:code/models/lib_support/torch.p];
  [-1"Requirements for PyTorch models not satisfied. PyTorch models will be excluded from model evaluation.";]]
loadfile`:code/postproc/plots.q
loadfile`:code/postproc/saving.q
loadfile`:code/postproc/reports/report.q
loadfile`:code/postproc/utils.q
loadfile`:code/utils.q
loadfile`:code/aml.q
$[0~checkimport[2];
 [loadfile`:code/postproc/reports/latex.p;loadfile`:code/postproc/reports/latex.q];
 [-1"Requirements for latex report generation are not satisfied, report will use reportlab.";]]
