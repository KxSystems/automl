if defined QLIC_KC (
        pip -q install -r requirements.txt
	pip install gensim
	echo getting test.q from embedpy
        git clone https://github.com/KxSystems/ml.git
        curl -fsSL -o test.q https://github.com/KxSystems/embedpy/raw/master/test.q
	env:PYTHONHASHSEED=0
        q test.q -q
)
