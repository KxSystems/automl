\d .automl

// The functionality below pertains to the application of NLP methods to kdb+

// @kind function
// @category featureCreation
// @fileoverview Utility function used both in the application of NLP on the initial run and on new data
//   It covers sentiment analysis, named entity recognition, word2vec and stop word analysis
// @param feat       {tab} The feature data as a table 
// @param cfg        {dict} Configuration information assigned by the user and related to the current run
// @param savedModel {<} use a saved model or not (required to differentiate new/run logic)
// @param filePath   {str} file path to the location where the word2vec model is saved for a specified run
// @return {dict} with the updated table with NLP created features included along with the string
//  columns and word2vec model
featureCreation.nlp.proc:{[feat;cfg;savedModel;filePath]
  stringCols:.ml.i.fndcols[feat;"C"];
  spacyLoad:.p.import[`spacy;`:load]"en_core_web_sm";
  args:(spacyLoad;feat stringCols);
  sentences:$[1<count stringCols;
    {x@''flip y};
    {x each y 0}
    ]. args;
  regexTab      :featureCreation.nlp.regexTab[feat;stringCols;featureCreation.nlp.i.regexList];
  namedEntityTab:featureCreation.nlp.getNamedEntity[sentences;stringCols];
  sentimentTab  :featureCreation.nlp.sentimentCreate[feat;stringCols;`compound`pos`neg`neu];
  corpus        :featureCreation.nlp.corpus[feat;stringCols;`isStop`tokens`uniPOS`likeNumber];
  colsCheck     :featureCreation.nlp.i.colCheck[cols corpus;];
  uniposTab     :featureCreation.nlp.uniposTagging[corpus;stringCols]colsCheck"uniPOS*";
  stopTab       :featureCreation.nlp.boolTab[corpus]colsCheck"isStop*";
  numTab        :featureCreation.nlp.boolTab[corpus]colsCheck"likeNumber*";
  countTokens   :flip enlist[`countTokens]!enlist count each corpus`tokens;
  tokens        :string(,'/)corpus colsCheck"tokens*";
  w2vTab        :featureCreation.nlp.word2vec[tokens;cfg;savedModel;filePath];
  nlpTabList    :(uniposTab;sentimentTab;w2vTab 0;namedEntityTab;regexTab;stopTab;numTab;countTokens);
  nlpTab        :(,'/)nlpTabList;
  nlpKeys       :`feat`stringCols`model;
  nlpValues     :(nlpTab;stringCols;w2vTab 1);
  nlpKeys!nlpValues
  }

// @kind function
// @category featureCreation
// @fileoverview Calculate percentage of positive booleans in a column
// @param feat {tab} The feature data as a table 
// @param col  {string} column containing list of booleans 
// @return {tab} Updated feat table indicating percentage of true values
//  within a column
featureCreation.nlp.boolTab:{[feat;col]
  flip col!{sum[x]%count x}@''feat col
  }

// @kind function
// @category featureCreation
// @fileoverview Utility function used both in the application of NLP on the initial run and on new data
// @param feat       {tab} The feature data as a table 
// @param stringCols {str} string columns within the table
// @param fields     {str[]} items to retrieve from newParser - also used in the naming of columns 
// @return {tab} parsed character data in appropriate corpus for word2vec/stop word/unipos analysis
featureCreation.nlp.corpus:{[feat;stringCols;fields]
  parseCols:featureCreation.nlp.i.colNaming[fields;stringCols];
  newParser:.nlp.newParser[`en;fields];
  // apply new parser to table data
  $[1<count stringCols;
    featureCreation.nlp.i.nameRaze[parseCols]newParser@'feat stringCols;
    newParser@feat[stringCols]0
    ]
  }

// @kind function
// @category featureCreation
// @fileoverview Calculate percentage of each uniPOS tagging element present
// @param feat       {tab} The feature data as a table 
// @param stringCols {str} string columns within the table
// @param fields     {str[]} uniPOS elements created from parser 
// @return {tab} part of speech components as a percentage of the total parts of speech 
featureCreation.nlp.uniposTagging:{[feat;stringCols;fields]
  // retrieve all relevant part of speech types
  pyDir:.p.import[`builtins;`:dir];
  uniposTypes:pyDir[.p.import[`spacy]`:parts_of_speech]`;
  uniposTypes:`$uniposTypes where not 0 in/:uniposTypes ss\:"__";
  table:feat fields;
  // encode the percentage of each sentance which is of a specific part of speech
  percentageFunc:featureCreation.nlp.i.percentDict[;uniposTypes];
  $[1<count stringCols;
    [colNames:featureCreation.nlp.i.colNaming[uniposTypes;fields];
     percentageTable:percentageFunc@''group@''table;
     featureCreation.nlp.i.nameRaze[colNames;percentageTable]
     ];
    percentageFunc each group each table 0
    ]
  }

// @kind function
// @category featureCreation
// @fileoverview Apply named entity recognition to retrieve information about the content of
//  a sentence/paragraph, allowing for context to be provided for a sentence
// @param sentences  {str} sentences on which named entity recognition is to be applied
// @param stringCols {str} string columns within the table 
// @return {tab} percentage of each sentence belonging to particular named entity
featureCreation.nlp.getNamedEntity:{[sentences;stringCols]
  // Named entities being searched over
  namedEntity:`PERSON`NORP`FAC`ORG`GPE`LOC`PRODUCT`EVENT`WORK_OF_ART`LAW,
              `LANGUAGE`DATE`TIME`PERCENT`MONEY`QUANTITY`ORDINAL`CARDINAL;
  percentageFunc:featureCreation.nlp.i.percentDict[;namedEntity];
  data:$[countCols:1<count stringCols;flip;::]sentences;
  labelFunc:{`${(.p.wrap x)[`:label_]`}each x[`:ents]`};
  nerData:$[countCols;
    {x@''count@'''group@''z@''y}[;;labelFunc];
    {x@'count@''group@'z@'y}[;;labelFunc]
    ].(percentageFunc;data);
  $[countCols;
    [colNames:featureCreation.nlp.i.colNaming[namedEntity;stringCols];
     featureCreation.nlp.i.nameRaze colNames
     ];
    ]nerData
  }

// @kind function
// @category featureCreation
// @fileoverview Apply sentiment analysis to an input table
// @param feat       {tab} The feature data as a table 
// @param stringCols {str} string columns within the table
// @param fields     {str[]} sentiments to extract 
// @return {tab} information about the pos/neg/compound sentiment of each column
featureCreation.nlp.sentimentCreate:{[feat;stringCols;fields]
  sentimentCols:featureCreation.nlp.i.colNaming[fields;stringCols];
  // get sentiment values
  $[1<count stringCols;
    featureCreation.nlp.i.nameRaze[sentimentCols].nlp.sentiment@''feat stringCols;
    .nlp.sentiment each feat[stringCols]0
    ]
  }

// @kind function
// @category featureCreation
// @fileoverview Find Regualar expressions within the text
// @param feat       {tab} The feature data as a table 
// @param stringCols {str} string columns within the table
// @param fields     {str[]}  expressions to search for within the text
// @return {tab} count of each expression found 
featureCreation.nlp.regexTab:{[feat;stringCols;fields]
  regexCols:featureCreation.nlp.i.colNaming[fields;stringCols];
  // get regex values
  $[1<count stringCols;
    [regexCount:featureCreation.nlp.i.regexCheck@''feat stringCols;
     featureCreation.nlp.i.nameRaze[regexCols;regexCount]
     ];
    featureCreation.nlp.i.regexCheck each feat[stringCols]0
    ]
  }

// @kind function
// @category featureCreation
// @fileoverview Create/load a word2vec model for the corpus and apply this analysis to the sentences
// to encode the sentence information into a numerical representation which can
// provide context to the meaning of a sentence.
// @param tokens     {tab} The feature data as a table 
// @param cfg        {dict} Configuration information assigned by the user and related to the current run
// @param savedModel {<} use a saved model or not (required to differentiate new/run logic)
// @param filePath   {str} file path to the location where the word2vec model is saved for a specified run
// @return {tab} word2vec applied to the string column
featureCreation.nlp.word2vec:{[tokens;cfg;savedModel;filePath]
  size:300&count raze distinct tokens;
  tokenCount:avg count each tokens;
  window:$[30<tokenCount;10;10<tokenCount;5;2];
  gensimModel:.p.import`gensim.models;
  args:`size`window`sg`seed`workers!(size;window;cfg`w2v;cfg`seed;1);
  model:$[savedModel;
    gensimModel[`:load]utils.ssrwin filePath,"/w2v.model";
    @[gensimModel[`:Word2Vec] .;(tokens;pykwargs args);{'"\nGensim returned the following error\n",x,
      "\nPlease review your input NLP data\n"}]
    ];
  w2vIndex:where each tokens in model[`:wv.index2word]`;
  sentenceVector:featureCreation.nlp.i.w2vTokens[tokens]'[til count w2vIndex;w2vIndex]; 
  avgVector:avg each featureCreation.nlp.i.w2vItem[model]each sentenceVector;
  w2vTable:flip(`$"col",/:string til size)!flip avgVector;
  (w2vTable;model)
  }
