# TCM
A fast and flexible implementation of the Temporal Context Model/Context Maintenance and Retrieval model.

## Installation

Download or clone the code project to some local `project_directory`. If cloning, you may need to first install [git-lfs](https://git-lfs.github.com) to get the sample data files, which are used to run tests of the code. In Matlab:

```matlab
cd project_directory
init_tcm
```

This will add the necessary directories to your Matlab path. To compile the c++ code for your local machine:

```matlab
cd project_directory/src
mex tcm_matlab.cc parameters.cc paramArray.cc recall.cc network.cc weights.cc context.cc 
```

You may need to first specify some settings for your compiler. To test your installation, run:

```matlab
result = run_tests_tcm;
table(result)
```

This will run a set of tests on sample data and show the results. If any of the tests in test_logl failed, this may be due to a problem calling the binary version of TCM.

## Getting Started

To get an idea of how to run a fit of the model to some free recall data, look at `run_logl_fit.m`. It will fit a relatively simple version of TCM to some sample data (or other free recall data), determine the set of parameters that maximizes the likelihood of the data, and generate simulated data based on the best-fitting parameters. These simulated data can then be analyzed in a similar way to actual data, for example to calculate a serial position curve for both the data and the model.
