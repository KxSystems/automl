\d .automl

// Definitions of the main callable functions used in the application of .automl.saveReport

// @kind function
// @category saveReport
// @fileoverview  Create a dictionary with image filenames for report generation
// @param params {dict} All data generated during the process
// @return {dict} Image filenames for report generation
saveReport.reportDict:{[params]
  config:params`config;
  saveImage:config`imagesSavePath;
  savedPlots:saveImage,/:string key hsym`$saveImage;
  plotNames:$[`class~config`problemType;`conf`data`impact;`data`impact`reg],`target;
  savedPlots:enlist[`savedPlots]!enlist plotNames!savedPlots;
  params,savedPlots
  }

// @kind function
// @category saveReport
// @fileoverview  Generate and save down procedure report
// @param params {dict} All data generated during the process
// @return {null} Report saved to appropriate location 
saveReport.saveReport:{[params]
  savePath :params[`config;`reportSavePath];
  modelName:params`modelName;
  filePath:savePath,"Report_",string modelName;
  -1"\nSaving down procedure report to ",savePath;
  $[0~checkimport[2];
    @[{saveReport.latexGenerate . x};
      (params;filePath);
      {[params;err] 
       -1"The following error occurred when attempting to run latex report generation";
       -1 err,"\n";
       saveReport.reportlabGenerate . params;
      }[(params;filePath)]
     ];
    saveReport.reportlabGenerate[params;filePath]
    ]
  }
