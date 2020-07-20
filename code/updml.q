// The purpose of this file is to act as a placer for functions which may be moved into the
// machine learning toolkit or which overwrite the present behaviour of functions in the
// toolkit

\d .ml


// Update to infreplace to handle types other than floats which is a limiting
// behaviour of the current version in the toolkit
infreplace:{
  $[98=t:type x;
      [m:type each dt:k!x k:.ml.i.fndcols[x;"hijefpnuv"];
        flip flip[x]^i.infrep'[dt;m]];
    0=t;
      [m:type each dt:x r:where all each string[type each x]in key i.inftyp;
        (x til[count x]except r),i.infrep'[dt;m]];
    98=type kx:key x;
      [m:type each dt:k!x k:.ml.i.fndcols[x:value x;"hijefpnuv"];
        cols[kx]xkey flip flip[kx],flip[x]^i.infrep'[dt;m]];
    [m:type each dt:k!x k:.ml.i.fndcols[x:flip x;"hijefpnuv"];flip[x]^i.infrep'[dt;m]]]}

// Encode the target data to be integer values which are computer readable
labelencode:{(asc distinct x)?x}

// Train-test split without shuffling set as the default for FRESH to ensure time ordering,
// similar to be implemented for the time series/time aware recipes
ttsnonshuff:{[x;y;sz]`xtrain`ytrain`xtest`ytest!raze(x;y)@\:/:(0,floor n*1-sz)_til n:count x}

// update to confmat showing true and pred values
conftab:{(`$"true_",/:sk)!flip(`$"pred_",/:sk:string key m)!flip value m:confmat[x;y]}

// Updated cross validation functions necessary for the application of hyperparameter search ordering correctly.
// Only change is expected input to the t variable of the function, previously this was a simple
// floating point values -1<x<1 which denotes how the data is to be split for the train-test split.
// Expected input is now at minimum t:enlist[`val]!enlist num, while for testing on the holdout sets this
// should be include the scoring function and ordering the model requires to find the best model
// `val`scf`ord!(0.2;`.ml.mse;asc) for example
xv.i.search:{[sf;k;n;x;y;f;p;t]
 if[0=t`val;:sf[k;n;x;y;f;p]];i:(0,floor count[y]*1-abs t`val)_$[0>t`val;xv.i.shuffle;til count@]y;
 (r;pr;[$[type[fn:get t`scf]in(100h;104h);
          [pykwargs pr:first key t[`ord]avg each fn[;].''];
          [pykwargs pr:first key desc avg each]]r:sf[k;n;x i 0;y i 0;f;p]](x;y)@\:/:i)}
xv.i.xvpf:{[pf;xv;k;n;x;y;f;p]p!(xv[k;n;x;y]f pykwargs@)@'p:pf p}
gs:1_xv.i.search@'xv.i.xvpf[{[p]key[p]!/:1_'(::)cross/value p}]@'xv.j
rs:1_xv.i.search@'xv.i.xvpf[{[p]rs.hpgen p}]@'xv.j

// generate random hyperparameters
/* x = dictionary with:
/*    - rs   = type of random search - sobol or random
/*    - seed = random seed, can be (::) - always the case for sobol
/*    - n    = number of points, can be (::)
/*    - p    = parameter list
rs.hpgen:{
  // set default values
  if[(::)~n:x`n;n:10];
  // set seed
  state:$[(::)~x`random_state;42;x`random_state];
  // find numerical parameters
  num:where any`uniform`loguniform=\:first each p:x`p;
  // find respective namespaces (ns) and append sequence or n pts to generate
  $[`sobol~typ:x`typ;
     [ns:`sbl;p,:num!p[num],'enlist each flip rs.i.sobol[count num;n]];
    typ~`random;
     [ns:`rdm;system"S ",string state;p,:num!p[num],'n];
    '"hyperparam type not supported"];
  // generate each hyperparameter
  flip rs.i.hpgen[ns;n]each p}

// sobol sequence generator from python
/* x = dimension
/* y = number of points
rs.i.sobol:.p.import[`sobol_seq;`:i4_sobol_generate;<]

// single list random hyperparameter generator
/* ns = namespace, either sbl or rdm
/* n  = number of points
/* p  = list of parameters
rs.i.hpgen:{[ns;n;p]
  // split parameters
  p:@[;0;first](0;1)_p,();
  // respective parameter generation
  typ:p 0;
  $[`boolean~typ;n?0b;
    typ~`symbol ;n?p[1]0;
    typ~`uniform;rs.i.uniform[ns]. p 1;
    typ~`loguniform;rs.i.loguniform[ns]. p 1;
    // addition of a random choice from list
    typ~`rand;n?(),p[1]0;
    '"please enter correct type"]}

// generate list of uniform numbers
/* ns  = namespace, either sbl or rdm
/* lo  = lower bound
/* hi  = higher bound
/* typ = type of parameter, e.g. "i", "f", etc
/* p   = additional parameters, e.g. sobol sequence (sbl) or number of points (rdm)
rs.i.uniform:{[ns;lo;hi;typ;p]
  if[hi<lo;'"upper bound must be greater than lower bound"];
  rs.i[ns][`uniform][lo;hi;typ;p]}

// generate list of log uniform numbers
/* params are same as rs.i.uniform, with lo and hi as powers of 10
rs.i.loguniform:xexp[10]rs.i.uniform::

// random uniform generator
rs.i.rdm.uniform:{[lo;hi;typ;n]lo+n?typ$hi-lo}

// sobol uniform generator
rs.i.sbl.uniform:{[lo;hi;typ;seq]typ$lo+(hi-lo)*seq}

// Utilities for functions to be added to the toolkit
i.infrep:{
  // Character representing the type
  typ:.Q.t@abs y;
  // the relevant null+infs for type
  t:typ$(0N;-0w;0W);
  {[n;x;y;z]@[x;i;:;z@[x;i:where x=y;:;n]]}[t 0]/[x;t 1 2;(min;max)]}

