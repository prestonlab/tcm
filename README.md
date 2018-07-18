# TCM
A fast and flexible implementation of the Temporal Context Model/Context Maintenance and Retrieval model.

## Installation

Download or clone the code project to some local `project_directory`. If cloning, you may need to first install [git-lfs](https://git-lfs.github.com). In Matlab:

```matlab
cd project_directory
init_tcm
```

This will add the necessary directories to your Matlab path. To compile the c++ code for your local machine:

```matlab
cd project_directory/src
mex tcm_matlab.cc
```

You may need to first specify some settings for your compiler. To test your installation, run:

```matlab
result = run_tests_tcm;
table(result)
```

This will run a set of tests on sample data and show the results. If any of the tests in test_logl failed, this may be due to a problem calling the binary version of TCM.
