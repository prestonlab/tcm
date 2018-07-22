# Introduction

This directory contains code for an implementation of the temporal context model in c++. It has mainly been used with MATLAB using MEX. A previous version was used to interface with RJAGS for Bayesian analysis using MCMC. However, the code for interfacing with JAGS has not been tested recently, and is currently not included here.

The c++ code could also potentially be called using other languages, such as python; this would require writing a new interface.

# Installation (Mac)

Preparing your system to compile the code may depend on which version of OS X you're using, but installing XCode and the command line tools for XCode will probably be sufficient. I found that clang++ and g++ work, but other compilers will probably work also. The code doesn't have any dependencies beyond the standard c++ library.

# Calling from MATLAB

In MATLAB, from the tcm/src directory, run

```matlab
mex tcm_matlab.cc parameters.cc paramArray.cc recall.cc network.cc weights.cc context.cc 
```

This should create a compiled mex file that is specific to your architecture. Then call logl_mex_tcm.m to calculate the likelihood of a free recall dataset. The C++ code has been developed in parallel with logl_tcm.m, and has a similar calling signature and supports most of the same features. To test that there are similar results for both implementations, run the test suite in MATLAB:

```matlab
result = run_tests_tcm;
table(result)
```

It's also a good idea to run both logl_tcm and logl_mex_tcm for your data and best-fitting parameters to make sure they are synced up. There is currently no implementation of a generative model in C++, so you must call gen_tcm.m for that. This generally isn't an issue, since generally the heaviest computational work is done during the maximum likelihood parameter search.

# Model development

When adding a parameter to the model, the interface needs to be updated. Change the following files:

* `param_vec_tcm.m` - change the "names" list to include the new parameter. If there are any fields with a non-numeric type, they should be converted to a number here.
* `parameters.cc` - change each method to include the new parameter. Make sure to assign the parameter to the same index in the param_vec as you specified in the parameter names list in param_vec_tcm.m.
* `parameters.h` - add the new parameter to the list of public variables declared here. Add a docstring to describe what it does.

Note, it's possible to read MATLAB struct variable directly into c++ code, so there should be a better way to pass parameters, and this may be reorganized in the future to make it easier to change the parameter set.

# Documentation

Documentation is automatically generated using doxygen. Run doxygen in the main directory to refresh the documentation. The reference can be viewed in any internet browser by opening docs/html/index.html.

# Authors

The project was written by Neal Morton, based partially on a MATLAB implementation of TCM written by Sean Polyn, Neal Morton, and James Kragel.
