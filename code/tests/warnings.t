\l automl.q
.automl.loadfile`:init.q
.automl.loadfile`:code/tests/utils.q

.automl.updateIgnoreWarnings[1]
.automl.updatePrinting[]

\S 42

// Create feature and target data
nGeneral:100
nFresh  :5000

featureDataNormal:([]nGeneral?1f;asc nGeneral?1f;nGeneral?`a`b`c)
featureDataFresh :([]nFresh?nGeneral?0p;nFresh?1f;asc nFresh?1f)
featureDataNLP   :([]nGeneral?1f;asc nGeneral?("generating";"sufficient tesing";"data"))

targetRegression :desc 100?1f
targetBinary     :100?0b
targetMulti      :100?4

newFreshParams:update valid:0b from .ml.fresh.params where pnum>0

//Create function to ensure fit runs correctly
.test.checkFit:{[params]fitReturn:(key;value)@\:.automl.fit . params;type[first fitReturn],type each last fitReturn}

// Create saveModel and config file
.automl.fit[featureDataNormal;targetBinary;`normal;`class;enlist[`savedModelName]!enlist "testModel"];
.automl.newConfig["testConfig"]

-1"\nTesting appropriate inputs when ignoreWarnings is 0\n";

.automl.updateIgnoreWarnings[0]

passingTest[.test.checkFit;(featureDataNormal;targetRegression;`normal;`reg  ;enlist[`saveModelName]!enlist "testModel");1b;11 99 104h]
passingTest[.test.checkFit;(featureDataFresh ;targetBinary    ;`fresh ;`class;enlist[`saveOption]!enlist 0);1b;11 101 104h]
passingTest[.test.checkFit;(featureDataNLP   ;targetMulti     ;`nlp   ;`class;enlist[`targetLimit]!enlist 10);1b;11 99 104h]

passingTest[.automl.newConfig;"testConfig";1b;::]

-1"\nTesting appropriate when inputs when ignoreWarnings is 1\n";

.automl.updateIgnoreWarnings[1]

passingTest[.test.checkFit;(featureDataNormal;targetBinary    ;`normal;`class;enlist[`saveModelName]!enlist "testModel");1b;11 99 104h]
passingTest[.test.checkFit;(featureDataFresh ;targetMulti     ;`fresh ;`class;enlist[`saveOption]!enlist 0);1b;11 101 104h]
passingTest[.test.checkFit;(featureDataNLP   ;targetRegression;`nlp   ;`reg  ;enlist[`targetLimit]!enlist 10);1b;11 99 104h]

passingTest[.automl.newConfig;"testConfig";1b;::]

-1"\nTesting inputs when ignoreWarnings is 2\n";

.automl.updateIgnoreWarnings[2]

overWriteError:"The savePath chosen already exists, this run will be exited"
configError   :"A configuration file of this name already exists"

failingTest[.test.checkFit;(featureDataNormal;targetMulti     ;`normal;`class;enlist[`saveModelName]!enlist "testModel");1b;overWriteError]
passingTest[.test.checkFit;(featureDataNormal;targetMulti     ;`normal;`class;`saveModelName`overWriteFiles!("testModel";1b));1b;11 99 104h]
passingTest[.test.checkFit;(featureDataFresh ;targetRegression;`fresh ;`reg  ;enlist[`saveOption]!enlist 0);1b;11 101 104h]
passingTest[.test.checkFit;(featureDataNLP   ;targetBinary    ;`nlp   ;`class;enlist[`targetLimit]!enlist 10);1b;11 99 104h]

failingTest[.automl.newConfig;"testConfig";1b;configError]

-1"\nRemoving any directories created";

savePath  :.automl.path,"/outputs/namedModels/testModel";
configPath:.automl.path,"code/customization/configuration/customConfig/testConfig"

// Remove any files created
system"rm -rf ",savePath;
system"rm -rf ",configPath;
