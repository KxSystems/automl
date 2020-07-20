// The functionality contained in this file pertains to the application of natural
// language processing methods to kdb+

\d .automl

// This function is a utility function used both in the application of NLP on the initial run
// and on new data, it covers sentiment analysis, named entity recognition, word2vec and stop
// word analysis.

/* t = input table
/* p = parameter dictionary passed as default or modified by user
/* smdl = Use a saved model or not (required to differentiate new/run logic)
/* fp = File path to the location where the word2vec model is saved for a specified run
prep.i.nlp_proc:{[t;p;smdl;fp]
  strcol:.ml.i.fndcols[t;"C"];
  num_cols:1<count strcol;
  sents:$[num_cols;{" " sv x}each flip t[strcol];raze t[strcol]];
  fn:.p.import[`spacy][`:load]["en_core_web_sm"];
  sents:$[num_cols;{x@''flip y}[fn;];{x each y 0}[fn;]]t[strcol];
  ner_tab:prep.i.ner_tab[sents;strcol];
  corpus:prep.i.corpus[t;strcol;`isStop`tokens`uniPOS];
  unipos_cols:prep.i.col_check[cols corpus;"uniPOS*"];
  token_cols:prep.i.col_check[cols corpus;"tokens*"];
  stop_cols:prep.i.col_check[cols corpus;"isStop*"];
  uni_tab:prep.i.unipos_tagging[corpus;strcol;unipos_cols];
  sent_tab:prep.i.sent_tab[t;strcol;`compound`pos`neg`neu];
  stop_tab:prep.i.stop_tab[corpus;stop_cols];
  tokens:string(,'/)corpus[token_cols];
  w2v_tab:prep.i.word2vec[tokens;p;fp;smdl];
  `tb`strcol`mdl!((,'/)(uni_tab;sent_tab;w2v_tab 0;ner_tab;stop_tab);strcol;w2v_tab 1)
  }


// Utility functions and wrapped functions used above, a number of these may be useful additions to
// the NLP library at a future date.

// Table showing the percentage of the words in a vector that are members of the 'stop list'
// these are the most common words for the language in question thus gives some idea of sentence
// complexity
prep.i.stop_tab:{[t;col_names]
  num_cols:1<count col_names;
  tdata:t[col_names];
  sdata:{sum[x]%count x}@''tdata;
  flip col_names!sdata
  }


// Parsing of data into the appropriate corpus for use with word2vec, stop word and unipos analysis
/* fields = list of items to be retrieved from newParser, also used in the naming of columns
/. r > a table with columns relating to the parsed information from the character columns of the table
prep.i.corpus:{[tab;col_names;fields]
  num_cols:1<count col_names;
  tdata:tab[col_names];
  parser:.nlp.newParser[`en;fields];
  parse_data:$[num_cols;{x@'y};{x@y 0}].(parser;tdata);
  parse_colnames:prep.i.col_naming[fields;col_names];
  $[num_cols;prep.i.nm_raze[parse_colnames;parse_data];parse_data]
  }

// Part of speech tagging, return the percentage of words in within a sentence/row that
// are of a particular part of speech
/. r > a table containing the part of speech components as a percentage of the total parts of speech
prep.i.unipos_tagging:{[t;col_names;fields]
  tab:t[fields];
  num_cols:1<count col_names;
  // retrieve all relevant part of speech types
  pos_types:.p.import[`builtins][`:dir][.p.import[`spacy][`:parts_of_speech]]`;
  unipos_types:`$pos_types where not 0 in/:pos_types ss\:"__";
  // encode the percentage of each sentance which is of a specific part of speech
  perc_fn:prep.i.percdict[;unipos_types];
  unipos_data:$[num_cols;perc_fn@''group@''tab;perc_fn each group each tab 0];
  col_naming:prep.i.col_naming[unipos_types;fields];
  $[num_cols;prep.i.nm_raze[col_naming;unipos_data];unipos_data]
  }

// Apply named entity recognition on the datasets, retrieving information about the content of
// a sentence/paragraph, allowing for context to be provided for a sentence.
/* sents = sentences on which named entity recognition is to be applied
/. r > table containing the percentage of each sentence belonging to particular named entities
prep.i.ner_tab:{[sents;col_names]
  num_cols:1<count col_names;
  // Named entities being searched over
  named_ents:`PERSON`NORP`FAC`ORG`GPE`LOC`PRODUCT`EVENT`WORK_OF_ART`LAW,
             `LANGUAGE`DATE`TIME`PERCENT`MONEY`QUANTITY`ORDINAL`CARDINAL;
  perc_fn:prep.i.percdict[;named_ents];
  data:$[num_cols;flip;::]sents;
  ner_data:$[num_cols;
    {x@''count@'''group@''{`${(.p.wrap x)[`:label_]`}each x[`:ents]`}@''y};
    {x@'count@''group@'{`${(.p.wrap x)[`:label_]`}each x[`:ents]`}@'y}].(perc_fn;data);
  col_naming:prep.i.col_naming[named_ents;col_names];
  $[num_cols;prep.i.nm_raze[col_naming;ner_data];ner_data]
  }

// Apply sentiment analysis to an input table
/. r > table containing information about the pos/neg/compound sentiment of each column
prep.i.sent_tab:{[t;col_names;fields]
  num_cols:1<count col_names;
  sent_cols:prep.i.col_naming[fields;col_names];
  sent_vals:$[num_cols;{x@''y};{x each y 0}].(.nlp.sentiment;t col_names);
  $[num_cols;prep.i.nm_raze[sent_cols;sent_vals];sent_vals]
  }

// Create/load a word2vec model for the corpus and apply this analysis to the sentences
// to encode the sentence information into a numerical representation which can
// provide context to the meaning of a sentence.
/* tokens = all the corpus tokens retrieved from the application of .nlp.newParser
/* p      = parameter dictionary which may be modified by the user
/* fp     = file path pointing to the location of a saved word2vec model
/* smdl   = Is a saved model being used or is a word2vec model required
prep.i.word2vec:{[tokens;p;fp;smdl]
  // Not sure if this should be `count distinct raze tokens`?
  size:300&count raze distinct tokens;
  // tokens per line, would `avg count each distinct each tokens` be a better representations?
  tkpl:avg count each tokens;
  window:$[30<tkpl;10;10<tkpl;5;2];
  gen_mdl:.p.import[`gensim.models];
  args:`size`window`seed`workers!(size;window;p`seed;1);
  model:$[smdl;
          gen_mdl[`:load][i.ssrwin[fp,"/w2v.model"]];
          gen_mdl[`:Word2Vec][tokens;pykwargs args]];
  // Word2Vec indices
  w2vind:where each tokens in model[`:wv.index2word]`;
  sentvec:{x[y;z]}[tokens]'[til count w2vind;w2vind];
  avg_vec:avg each{$[()~y;0;x[`:wv.__getitem__][y]`]}[model]each sentvec;
  (flip(`$"col",/:string til size)!flip avg_vec;model)
  }

// Utilities used within the generation of the component tables

// Retrieve the word2vec items for sentences based on the model  
prep.i.getw2vitem:{$[()~y;0;x[`:wv.__getitem__][y]`]}

// Get percentage of each attribute present in NLP
prep.i.percdict:{(y!count[y]#0f),`float$(count each x)%sum count each x}

// Generate column names based on a fixed list and multiple options
prep.i.col_naming:{`${string[x],\:"_",string y}[x]each y}

// Rename columns and raze individual columns together
prep.i.nm_raze:{(,'/){xcol[x;y]}'[x;y]}

// Find all named according to a regex search
prep.i.col_check:{x where x like y}
