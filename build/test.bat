if defined QLIC_KC (
        pip -q install -r requirements.txt
	git clone https://github.com/KxSystems/ml.git
	git clone https://github.com/KxSystems/nlp.git
	pip -q install -r nlp/requirements.txt
	python -m spacy download en
	pip install gensim
	pip install sobol-seq
        pip install pytorch
	pip install keras
	echo getting test.q from embedpy
        curl -fsSL -o test.q https://github.com/KxSystems/embedpy/raw/master/test.q
	env:PYTHONHASHSEED=0
        q test.q -q code/nodes/tests/ code/nodes/configuration/tests/ code/nodes/featureData/tests/ code/nodes/targetData/tests/ code/nodes/dataCheck/tests/ code/nodes/modelGeneration/tests/ code/nodes/featureDescription/tests/ code/nodes/labelEncode/tests/ code/nodes/dataPreprocessing/tests/ code/nodes/featureCreation/tests/ code/nodes/featureSignificance/tests/ code/nodes/trainTestSplit/tests/ code/nodes/runModels/tests/ code/nodes/selectModels/tests/ code/nodes/optimizeModels/tests/ code/nodes/preprocParams/tests/ code/nodes/predictParams/tests/ code/nodes/pathConstruct/tests/ code/nodes/saveGraph/tests/ code/nodes/saveMeta/tests/ code/nodes/saveReport/tests/ code/nodes/saveModels/tests/
)
