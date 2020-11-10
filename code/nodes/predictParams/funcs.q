\d .automl

// Definitions of the main callable functions used in the application of .automl.predictParams

// @kind function
// @category featureCreation
// @fileoverview Print the score achieved by the best model
// @param score {float} Score of model on testing data
// return {null} Print score of model
predictParams.printScore:{[score]
  -1"\nBest model fitting now complete - final score on testing set = ",string[score],"\n";
  }
