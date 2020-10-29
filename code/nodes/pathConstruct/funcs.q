\d .automl

// Definitions of the main callable functions used in the application of .automl.pathConstruct

// @kind function
// @category pathConstruct
// @fileoverview Create the folders that are required for the saving of the config,models, 
//  images and reports
// @param preProcParams {dict} Data generated during the preprocess stage
// @return {dict} File path where paths/graphs are to be saved
pathConstruct.constructPath:{[preProcParams]
  cfg:preProcParams`config;
  saveOpt:cfg`saveopt;
  if[saveOpt=0;:()!()];
  fileNames:`config`models;
  if[saveOpt=2;fileNames,:`images`report];
  pathNames:pathConstruct.pathName[cfg`startTime;cfg`startDate]each string fileNames;
  pathName:path,/:pathNames;
  pathName:utils.ssrWindows each pathName;
  pathConstruct.createFile each pathName;
  }


// @kind function
// @category pathConstruct
// @fileoverview Generate path that is to be created
// @param startTime {time} The initial time of the run
// @param startDate {sate} The date of the run
// @return {str} Location that the files are to be created 
pathConstruct.pathName:{[startTime;startDate;fileName]
  outputs:"outputs/",string[startDate];
  run:"/run_",string[startTime];
  file:"/",fileName,"/";
  "/",ssr[outputs,run,file;":";"."]
  }

// @kind function
// @category pathConstruct
// @fileoverview Create the folders that are required for the saving of the config,models, 
//  images and reports
// @param pathName {str} Name of paths that are to be created
// @return {null} File paths are created
pathConstruct.createFile:{[pathName]
  windowsChk:$[.z.o like "w*";" ";" -p "];
  system"mkdir",windowsChk,pathName
  }
