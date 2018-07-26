# TCM
A fast and flexible implementation of the Temporal Context Model/Context Maintenance and Retrieval model of free recall.

This toolbox is designed to fit data from free recall studies, where partipants study a list and are then asked to recall the items in any order. The model fits not just statistics of free recall, such as the percentage of items recalled in each list, but instead uses the exact sequence of recalls made on each list to estimate different properties of each individual's memory system. The fitted model can then be used to generate new, simulated data, which can be analyzed and compared to the real data.

![example fit](https://github.com/prestonlab/tcm/blob/master/figs/fit_example.png)
Top row: serial position curve, probability of first recall, temporal organization, and semantic organization for data from Morton et al. (2013). Bottom row: data simulated using TCM with maximum likelihood parameters estimated for each individual subject. See Morton & Polyn (2016) for model details.

The main code is implemented in Matlab for ease of use, but the most computationally intensive work is implemented in compiled code written in c++. This makes evaluating a model about 8-70X faster (depending on the version of the model used) than is possible using pure Matlab code, making data fitting much faster. For example, fitting 373 recall events from free recall of 30 lists, using a model with 11 parameters, takes about 30 seconds on a fast desktop computer. See `tcm/tests/run_logl_fit.m` for details.

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

To analyze real or simulated free recall data, get a copy of [EMBAM](https://github.com/seanpolyn/EMBAM). EMBAM is not required for running simulations or parameter fits, but is required to run some of the analysis code in `exp/cfrl`. Download or clone a copy, then cd to that directory and run init_embam to set your path to include all subdirectories.

## Getting Started

To get an idea of how to run a fit of the model to some free recall data, look at `tcm/tests/run_logl_fit.m`. It will fit a relatively simple version of TCM to some sample data (or other free recall data), determine the set of parameters that maximizes the likelihood of the data, and generate simulated data based on the best-fitting parameters. These simulated data can then be analyzed in a similar way to actual data, for example to calculate a serial position curve for both the data and the model.

## References

Morton, N. W., Kahana, M. J., Rosenberg, E. A., Baltuch, G. H., Litt, B. B., Sharan, A. D., et al. (2013). Category-specific neural oscillations predict recall organization during memory search. Cerebral Cortex, 23(10), 2407–2422. http://doi.org/10.1093/cercor/bhs229

Kragel, J. E., Morton, N. W., & Polyn, S. M. (2015). Neural activity in the medial temporal lobe reveals the fidelity of mental time travel. The Journal of Neuroscience : the Official Journal of the Society for Neuroscience, 35(7), 2914–2926. http://doi.org/10.1523/JNEUROSCI.3378-14.2015

Morton, N. W., & Polyn, S. M. (2016). A predictive framework for evaluating models of semantic organization in free recall. Journal of Memory and Language, 86, 119–140. http://doi.org/10.1016/j.jml.2015.10.002

Morton, N. W., & Polyn, S. M. (2017). Beta-band activity represents the recent past during episodic encoding. NeuroImage, 147, 692–702. http://doi.org/10.1016/j.neuroimage.2016.12.049
