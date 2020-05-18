# Ensure that a user that is attempting to use the framework
# has the required dependencies for neural network models
p)def< checkimport(x):
  if(x==0):
    try:
      import tensorflow;import keras;return(0)
    except:
      return(1)
  elif(x==1):
    try:
      import torch;return(0)
    except:
      return(1)
  elif(x==2):
    try:
      import pylatex;return(0)
    except:
      return(1)
  else:
    return(0)
