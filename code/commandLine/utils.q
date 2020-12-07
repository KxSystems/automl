\d .automl

// @kind function
// @category cliUtility
// @fileoverview Retrieve the path to a custom json file to be used on command line or
//   as the final parameter to the .automl.run function, this file must exist either in
//   the users defined path relative to 'pwd' or in 
//   "/code/customization/configuration/customConfig/"
// @param fileName {str} Name of a json file to be retrieved or path to this file
// @return  {str} The full path to the json file if it exists or an error indicating
//   the file could not be found.
cli.i.checkCustom:{[fileName]
  fileName:raze fileName;
  if[not ()~key hsym `$fpath:path,"/code/customization/configuration/customConfig/",fileName;:fpath];
  if[not ()~key hsym `$fpath:"./",fileName;:fpath];
  'fileName," doesn't exist in current or '",path,"code/configuration/customConfig' directories";
  }

// @kind function
// @category cliUtility
// @fileoverview Parse the contents of the 'problemParameters' sections of the json file
//   used to define command line input and convert to an appropriate kdb+ type
// @param cliInput    {str} The parsed content of the JSON file using .j.k which have yet
//   to be transformed into their final kdb+ type
// @param sectionType {sym} Name of the section within the 'problemParameters'
//   section to be parsed
// @returns {dict} a dictionary mapping a parameter required by automl
//   to an assigned value cast appropriately
cli.i.parseParameters:{[cliInput;sectionType]
  section:cliInput[`problemParameters;sectionType];
  cli.i.convertParameters each section
  }

// @kind function
// @category cliUtility
// @fileoverview Main parsing function for the json parsing functionality this applys
//   the approriate conversion logic to the value provided based on a user assigned type
// @param param {dict} A dictionary associated with a parameter required by specific sections
//   of automl containing the value which is to be used and the final kdb+ type that is expected
// @returns {dict} A dictionary mapping the parameter name needed for automl to the appropriately
//   type converted parameter value
cli.i.convertParameters:{[param]
  $["symbol"~param`type;`$param`value;
    "lambda"~param`type;get param`value;
    "string"~param`type;param`value;
    (`$param`type)$param`value
  ]
  }
