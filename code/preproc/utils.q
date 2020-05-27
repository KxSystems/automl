\d .automl

// For the following code the parameter naming convention
// defined here is applied to avoid repetition throughout the file
/* t   = input table
/* typ = symbol type of the problem being solved (this determines accepted types)
/* tgt = target data
/* p   = parameter dictionary passed as default or modified by user
/* c   = columns to apply the transformation, if c~(::) then apply to all appropriate columns 


// Utilities for preproc.q

// Automatic type checking
/. r   > the table with acceptable types only and error message with removed columns named
prep.i.autotype:{[t;typ;p]
  $[typ in `tseries`normal;
    [cls:.ml.i.fndcols[t;"sfihjbepmdznuvt"];
      tb:flip cls!t cls;
      prep.i.errcol[cols t;cls;typ]];
    typ=`fresh;
    // ignore the aggregating columns for FRESH as these can be of any type
    [aprcls:flip(l:p[`aggcols])_ flip t;
      cls:.ml.i.fndcols[aprcls;"sfiehjb"];
      // restore the aggregating columns 
      tb:flip(l!t l,:()),cls!t cls;
      prep.i.errcol[cols t;cols tb;typ]];
    typ=`nlp;
    [cls:.ml.i.fndcols[t;"sfihjbepmdznuvtC"];
      tb:flip cls!t cls;prep.i.errcol[cols t;cls;typ]];
    '`$"This form of feature extraction is not currently supported"];
  tb}

// Description of tabular data
/. r > keyed table with information about each of the columns
prep.i.describe:{[t]
  columns :`count`unique`mean`std`min`max`type;
  numcols :.ml.i.fndcols[t;"hijef"];
  timecols:.ml.i.fndcols[t;"pmdznuvt"];
  boolcols:.ml.i.fndcols[t;"b"];
  catcols :.ml.i.fndcols[t;"s"];
  textcols:.ml.i.fndcols[t;"C"];
  num  :prep.i.metafn[t;numcols ;(count;{count distinct x};avg;sdev;min;max;{`numeric})];
  symb :prep.i.metafn[t;catcols ;prep.i.nonnumeric[{`categorical}]];
  times:prep.i.metafn[t;timecols;prep.i.nonnumeric[{`time}]];
  bool :prep.i.metafn[t;boolcols;prep.i.nonnumeric[{`boolean}]];
  text :prep.i.metafn[t;textcols;prep.i.nonnumeric[{`text}]];
  flip columns!flip num,symb,times,bool,text
  }

// Length checking to ensure that the table and target are appropriate for the task being performed
/. r > on successful execution returns null, will return error if execution unsuccessful
prep.i.lencheck:{[t;tgt;typ;p]
  $[-11h=type typ;
    $[`fresh=typ;
      // Check that the number of unique aggregating sets is the same as number of targets
      if[count[tgt]<>count distinct $[1=count p`aggcols;t[p`aggcols];(,'/)t p`aggcols];
         '`$"Target count must equal count of unique agg values for fresh"];
      typ in`tseries`normal`nlp;
      if[count[tgt]<>count t;
         '`$"Must have the same number of targets as values in table"];
    '`$"Input for typ must be a supported type"];
    '`$"Input for typ must be a supported symbol"]}

prep.i.tgtcheck:{[tgt]
  if[not 0<var tgt;'"Target must have more than one unique value"]
  }

// Null encoding of table
/* fn = function to be applied to column from which the value to fill nulls is derived (med/min/max)
/. r  > the table will null values filled if required
prep.i.nullencode:{[t;fn]
  vals:l k:where 0<sum each l:flip null t;
  nms:`$string[k],\:"_null";
  // 0 filling needed if return value also null (encoding maintained through added columns)
  $[0=count k;t;flip 0^(fn each flip t)^flip[t],nms!vals]}

//  Symbol encoding function allowing encoding scheme to be persisted or encoding to be applied
/* n   = number of distinct values in a column after which we frequency encode
/* b   = boolean flag indicating if table is to be returned (0) or encoding type returned (1)
/* enc = how encoding is to be applied, if dictionary outlining encoding perform encoding accordingly
/*       otherwise, return a table with symbols encoded appropriately on all relevant columns
/*       or the dictionary outlining how the encoding would be performed (based on 'b' above)
/. r   > the data encoded appropriately for the task table with symbols 
/.       encoded or dictionary denoting how to encode the data (based on 'b' above)
prep.i.symencode:{[t;n;b;p;enc]
  $[99h=type enc;
    r:$[`fresh~p`typ;
        // Both frequency and one hot encoding is to be applied if true
        $[all {not ` in x}each value enc;
          // Encoding for FRESH is performed on aggregation sub table basis not entire columns
          .ml.onehot[raze .ml.freqencode[;enc`freq]each flip each 0!p[`aggcols]xgroup t;enc`ohe];
          // one hot encode if freq is empty
          ` in enc`freq;.ml.onehot[t;enc`ohe];
          // frequency encode if ohe is empty
          ` in enc`ohe;raze .ml.freqencode[;enc`freq]each flip each 0!p[`aggcols]xgroup t;
          t];
        p[`typ]in`nlp`normal;
        $[all {not ` in x}each value enc;
          .ml.onehot[.ml.freqencode[t;enc`freq];enc`ohe];
          ` in enc`freq;.ml.onehot[t;enc`ohe];
          ` in enc`ohe;raze .ml.freqencode[t;enc`fc];
          t];
        '`$"This form of encoding has yet to be implemented for the specified type of automl"];
    [sc:.ml.i.fndcols[t;"s"]except $[tp:`fresh~p`typ;acol:p`aggcols;(::)];
      // if no symbol columns return table or empty encoding schema
      if[0=count sc;r:$[b=1;`freq`ohe!``;t]];
      if[0<count sc;
        // list of frequency encoding columns
        fc:where n<count each distinct each sc!flip[t]sc;
        ohe:sc where not sc in fc;
        // return encoding schema or appy encoding as appropriate
        r:$[b=1;`freq`ohe!(fc;ohe);
            tp;.ml.onehot[raze .ml.freqencode[;fc]each flip each 0!acol xgroup t;ohe];
            .ml.onehot[.ml.freqencode[t;fc];ohe]]];
      if[b=0;r:flip sc _ flip r]]];
  r}


// Utilities to be used for Normal Feature Creation

// Perform bulk transformations of hij columns for all unique linear combinations of such columns
/. r > table with bulk transformtions applied appropriately
prep.i.bulktransform:{[t]
  c:.ml.i.fndcols[t;"hij"];
  // Name the columns based on the unique combinations
  n:raze(,'/)`$(raze each string c@:.ml.combs[count c;2]),\:/:("_multi";"_sum";"_div";"_sub");
  // Apply transforms based on naming conventions chosen and re-form the table with these appended
  flip flip[t],n!(,/)(prd;sum;{first(%)x};{last deltas x})@/:\:t c}

// Used for the recursive application of functions to a kdb+ table
/* t  = table
/* fn = function to be applied to the table
/. table with the desired transforms applied recursively
prep.i.applyfn:{[t;fn]typ:type fn;@[;t]$[-11h=typ;get[fn];100h=typ;fn;.automl.prep.i.default]}

// Perform a truncated single value decomposition on unique linear combinations of float columns
// https://scikit-learn.org/stable/modules/generated/sklearn.decomposition.TruncatedSVD.html
prep.i.truncsvd:{[t]
  c:.ml.i.fndcols[t;"f"];
  c@:.ml.combs[count c,:();2];
  svd:.p.import[`sklearn.decomposition;`:TruncatedSVD;`n_components pykw 1];
  flip flip[t],(`$(raze each string c),\:"_trsvd")!{raze x[`:fit_transform][flip y]`}[svd]each t c}

// Default behaviour for the system is to pass through the table without the application of
// any feature extraction procedures, this is for computational efficiency in initial builds
// of the system and may be augmented with a more intelligent system moving forward
prep.i.default:{[t]t}

// Utilities for Natural Language Processing

prep.i.nlp_proc:{[t;p;smdl;fp]
  strcol:.ml.i.fndcols[t;"C"];
  num_cols:1<count strcol;
  sents:$[num_cols;{" " sv x}each flip t[strcol];raze t[strcol]];
  fn:.p.import[`spacy][`:load]["en_core_web_sm"];
  ents:$[num_cols;{x@''flip y}[fn;];{x each y 0}[fn;]]t[strcol];
  ner_tab:prep.i.ner_tab[ents;strcol];
  corpus:prep.i.pos_tag[t;strcol;`isStop`tokens`uniPOS];
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

prep.i.col_naming:{`${string[x],\:"_",string y}[x]each y}
prep.i.nm_raze:{(,'/){xcol[x;y]}'[x;y]}
prep.i.col_check:{x where x like y}

prep.i.stop_tab:{[t;col_names]
  num_cols:1<count col_names;
  tdata:t[col_names];
  sdata:$[num_cols;{{sum[x]%count x}@''x};enlist{{sum[x]%count x}@'x 0}]@tdata;
  flip col_names!sdata
  }

prep.i.pos_tag:{[tab;col_names;fields]
  num_cols:1<count col_names;
  tdata:tab[col_names];
  parser:.nlp.newParser[`en;fields];
  parse_data:$[num_cols;{x@'y};{x@y 0}].(parser;tdata);
  parse_colnames:prep.i.col_naming[fields;col_names];
  $[num_cols;prep.i.nm_raze[parse_colnames;parse_data];parse_data]
  }

prep.i.unipos_tagging:{[t;col_names;fields]
  tab:t[fields];
  num_cols:1<count col_names;
  pos_types:.p.import[`builtins][`:dir][.p.import[`spacy][`:parts_of_speech]]`;
  unipos_types:`$pos_types where not 0 in/:pos_types ss\:"__";
  perc_fn:prep.i.percdict[;unipos_types];
  unipos_data:$[num_cols;perc_fn@''group@''tab;perc_fn each group each tab 0];
  col_naming:prep.i.col_naming[unipos_types;fields];
  $[num_cols;prep.i.nm_raze[col_naming;unipos_data];unipos_data]
  }

prep.i.ner_tab:{[ents;col_names]
  num_cols:1<count col_names;
  // Named entities being searched over
  named_ents:`PERSON`NORP`FAC`ORG`GPE`LOC`PRODUCT`EVENT`WORK_OF_ART`LAW,
             `LANGUAGE`DATE`TIME`PERCENT`MONEY`QUANTITY`ORDINAL`CARDINAL;
  perc_fn:prep.i.percdict[;named_ents];
  data:$[num_cols;flip;::]ents;
  ner_data:$[num_cols;
    {x@''count@'''group@''{`${(.p.wrap x)[`:label_]`}each x[`:ents]`}@''y};
    {x@'count@''group@'{`${(.p.wrap x)[`:label_]`}each x[`:ents]`}@'y}].(perc_fn;data);
  col_naming:prep.i.col_naming[named_ents;col_names];
  $[num_cols;prep.i.nm_raze[col_naming;ner_data];ner_data]
  }

prep.i.sent_tab:{[t;col_names;fields]
  num_cols:1<count col_names;
  sent_cols:prep.i.col_naming[fields;col_names];
  sent_vals:$[num_cols;{x@''y};{x each y 0}].(.nlp.sentiment;t col_names);
  $[num_cols;prep.i.nm_raze[sent_cols;sent_vals];sent_vals]
  }

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

prep.i.getw2vitem:{$[()~y;0;x[`:wv.__getitem__][y]`]}

// Utilities for feature significance testing

// Error message related to the 'refusal' of the feature significance tests to 
// find appropriate columns to explain the data from those produced
prep.i.freshsigerr:"The feature significance extraction process deemed none of the features",
  "to be important continuing anyway with all features"


// Utils.q utilities

// Error flag for removal of inappropriate columms
/* cl = entire column list
/* sl = sublist of columns to be used
prep.i.errcol:{[cl;sl;typ]
  if[count[cl]<>count sl;
  -1 "\n Removed the following columns due to type restrictions for ",string typ;
  0N!cl where not cl in sl]}

// Metadata information based on list of transforms and supplied columns
/* sl = sub list of columns to apply functions to
/* fl = list of functions which will provide the appropriate metadata
/. r  > dictionary with the appropriate metadata returned
prep.i.metafn:{[t;sl;fl]$[0<count sl;fl@\:/:flip(sl)#t;()]}

// Default list of functions to be applied in metadata function for non-numeric data
prep.i.nonnumeric:{[t](count;{count distinct x};{};{};{};{};t)}

// Get percentage of each attribute present in NLP
prep.i.percdict:{[attrs;lst]((lst!(count lst)#0f)),`float$(count each attrs)%sum count each attrs}

