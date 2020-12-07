\l p.q

\d .automl
version:@[{AUTOMLVERSION};`;`development]
path:{string`automl^`$@[{"/"sv -1_"/"vs ssr[;"\\";"/"](-3#get .z.s)0};`;""]}`
loadfile:{$[.z.q;;-1]"Loading ",x:_[":"=x 0]x:$[10=type x;;string]x;system"l ",path,"/",x;}

// @kind description
// @name commandLineParameters
// @desc Retrieve command line parameters and convert to a kdb+ dictionary
commandLineInput:first each .Q.opt .z.x

// @kind description
// @name commandLineExecution
// @desc If a user has defined both a config and run command 
//   line argument the interface will attempt to run the fully
//   automated automl by parsing the content of the json file
//   provided to retrieve the data appropriately via ipc/from disk
//   the q session will then exit.
if[all `config`run in lower key commandLineInput;
  loadfile`:init.q;
  .ml.updDebug[];
  runCommandLine[];
  exit 0]

