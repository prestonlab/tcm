# TCM
A fast and flexible implementation of the Temporal Context Model/Context Maintenance and Retrieval model of free recall.

![example fit](https://github.com/prestonlab/tcm/blob/master/figs/fit_example.png)
Top row: serial position curve, probability of first recall, temporal organization, and semantic organization for data from Morton et al. (2013). Bottom row: data simulated using TCM with maximum likelihood parameters. See Morton & Polyn (2016) for model details.

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

To get an idea of how to run a fit of the model to some free recall data, look at `tcm/tests/run_logl_fit.m`. It will fit a relatively simple version of TCM to some sample data (or other free recall data), determine the set of parameters that maximizes the likelihood of the data, and generate simulated data based on the best-fitting parameters. These simulated data can then be analyzed in a similar way to actual data, for example to calculate a serial position curve for both the data and the model.

## References

Morton, N. W., Kahana, M. J., Rosenberg, E. A., Baltuch, G. H., Litt, B. B., Sharan, A. D., et al. (2013). Category-specific neural oscillations predict recall organization during memory search. Cerebral Cortex, 23(10), 2407–2422. http://doi.org/10.1093/cercor/bhs229

Morton, N. W., & Polyn, S. M. (2016). A predictive framework for evaluating models of semantic organization in free recall. Journal of Memory and Language, 86, 119–140. http://doi.org/10.1016/j.jml.2015.10.002

Morton, N. W., & Polyn, S. M. (2017). Beta-band activity represents the recent past during episodic encoding. NeuroImage, 147, 692–702. http://doi.org/10.1016/j.neuroimage.2016.12.049
