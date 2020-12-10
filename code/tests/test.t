\l automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

nGeneral:100
nFresh  :5000

featureDataNormal:([]nGeneral?1f;asc nGeneral?1f;nGeneral?`a`b`c)
featureDataFresh :([]nFresh?nGeneral?0p;nFresh?1f;asc nFresh?1f)
featureDataNLP   :([]nGeneral?1f;asc nGeneral?("generating";"sufficient tesing";"data"))

targetRegression :desc 100?1f
targetBinary     :asc 100?0b
targetMulti      :desc 100?4

newFreshParams:update valid:0b from .ml.fresh.params where pnum>0

.test.checkFit:{[params]fitReturn:(key;value)@\:.automl.fit . params;type[first fitReturn],type each last fitReturn}

passingTest[.test.checkFit;(featureDataNormal;targetRegression;`normal;`reg  ;::);1b;11 99 104h]
passingTest[.test.checkFit;(featureDataNormal;targetBinary    ;`normal;`class;::);1b;11 99 104h]
passingTest[.test.checkFit;(featureDataNormal;targetMulti     ;`normal;`class;::);1b;11 99 104h]
passingTest[.test.checkFit;(featureDataNormal;targetRegression;`normal;`reg  ;enlist[`seed]!enlist 42);1b;11 99 104h]
passingTest[.test.checkFit;(featureDataNormal;targetBinary    ;`normal;`class;enlist[`targetLimit]!enlist 99);1b;11 99 104h]

passingTest[.test.checkFit;(featureDataFresh;targetRegression;`fresh;`reg  ;::);1b;11 99 104h]
passingTest[.test.checkFit;(featureDataFresh;targetBinary    ;`fresh;`class;::);1b;11 99 104h]
passingTest[.test.checkFit;(featureDataFresh;targetMulti     ;`fresh;`class;::);1b;11 99 104h]
passingTest[.test.checkFit;(featureDataFresh;targetRegression;`fresh;`reg  ;enlist[`aggregationColumns]!enlist`x);1b;11 99 104h]
passingTest[.test.checkFit;(featureDataFresh;targetMulti     ;`fresh;`class;enlist[`functions]!enlist`newFreshParams);1b;11 99 104h]

passingTest[.test.checkFit;(featureDataNLP;targetRegression;`nlp;`reg  ;::);1b;11 99 104h]
passingTest[.test.checkFit;(featureDataNLP;targetBinary    ;`nlp;`class;::);1b;11 99 104h]
passingTest[.test.checkFit;(featureDataNLP;targetMulti     ;`nlp;`class;::);1b;11 99 104h]
passingTest[.test.checkFit;(featureDataNLP;targetBinary    ;`nlp;`class;enlist[`crossValidationFunction]!enlist`.ml.xv.kfsplit);1b;11 99 104h]
passingTest[.test.checkFit;(featureDataNLP;targetMulti     ;`nlp;`class;enlist[`gridSearchArgument]!enlist 2);1b;11 99 104h]

fitNormal:.automl.fit[featureDataNormal;targetMulti     ;`normal;`class;`overWriteFiles`saveModelName!(1;"normalModel")]
fitFresh :.automl.fit[featureDataFresh ;targetBinary    ;`fresh ;`class;`overWriteFiles`saveModelName!(1;"freshModel")]
fitNLP   :.automl.fit[featureDataNLP   ;targetRegression;`nlp   ;`reg  ;`overWriteFiles`saveModelName!(1;"nlpModel")]

passingTest[type;fitNormal.predict[featureDataNormal];1b;7h]
passingTest[type;fitFresh.predict[featureDataFresh]  ;1b;1h]
passingTest[type;fitNLP.predict[featureDataNLP]      ;1b;9h]

normalModel:.automl.getModel[enlist[`savedModelName]!enlist "normalModel"]
freshModel:.automl.getModel[enlist[`savedModelName]!enlist "freshModel"]
nlpModel:.automl.getModel[enlist[`savedModelName]!enlist "nlpModel"]

passingTest[type;normalModel.predict[featureDataNormal];1b;7h]
passingTest[type;freshModel.predict[featureDataFresh]  ;1b;1h]
passingTest[type;nlpModel.predict[featureDataNLP]      ;1b;9h]
