\d .automl

// Load in the machine learning toolkit which should be located in $QHOME
// also load in some updates to the toolkit to be integrated at a later date
\l ml/ml.q
.ml.loadfile`:init.q
loadfile`:code/updml.q

loadfile`:code/checking/checkimport.p
loadfile`:code/checking/check.q

// Load all approriate components of the automl platform
loadfile`:code/preproc/utils.q
loadfile`:code/preproc/preproc.q
loadfile`:code/preproc/featextract.q

loadfile`:code/proc/utils.q
loadfile`:code/proc/proc.q
loadfile`:code/proc/xvgs.q

loadfile`:code/postproc/plots.q
loadfile`:code/postproc/saving.q
loadfile`:code/postproc/reports/report.q
loadfile`:code/postproc/utils.q

i.loadkeras[]
i.loadtorch[]
i.loadlatex[]
loadfile`:code/utils.q
loadfile`:code/aml.q

\d .nlp
.automl.i.loadnlp[]
\d .automl

