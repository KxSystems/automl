\d .automl

// The purpose of this file is to house  utilities that are useful across more
// than one node or as part of the automl run/new/savedefault functionality and graph

// @kind function
// @category Utility
// @fileoverview Load function from q. If function not found, try python 
// @param funcName {sym} Name of function to retrieve
// @return {function} Loaded function
utils.qpyFuncSearch:{[funcName]
  func:@[get;funcName;()];
  $[()~func;.p.get[funcName;<];func]
  }

// @kind function
// @category Utility
// @fileoverview Load NLP library if requirements met
// @params {null}
// @return {null} Library loaded if requirements met or statement printed to terminal
utils.loadNLP:{
  $[(0~checkimport[3])&(::)~@[{system"l ",x};"nlp/nlp.q";{0b}];
    .nlp.loadfile`:init.q;
    -1"Requirements for NLP models are not satisfied. gensim must be installed. NLP module will not be available.";
    ]
  }

// @kind function
// @category Utility
// @fileoverview Used throughout the library to convert linux/mac file names to windows equivalent
// @param path {str} the linux 'like' path
// @return {str} path modified to be suitable for windows systems
utils.ssrwin:{[path]
  $[.z.o like "w*";ssr[path;"/";"\\"];path]
  }
