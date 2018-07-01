
Introduction
========

This directory contains code for an implementation of the temporal context model in c++. It can be called through a number of different interfaces. It can be called from the command line, through MATLAB using MEX, or interfaced with JAGS for Bayesian analysis using MCMC. It may also have other useful applications where execution speed is a priority.

The project has most recently been used to be run through MATLAB, so that interface is currently the most stable and developed. As of 2014-09-24, the other interfaces may be broken, and may need to be updated.

Installation (Mac)
===========

Preparing your system to compile the code may depend on which version of OS X you're using, but installing XCode and the command line tools for XCode will probably be sufficient. I found that clang++ and g++ work, but other compilers will probably work also. The code doesn't have any dependencies beyond the standard c++ library.

Calling from MATLAB
=============

In MATLAB, from the likelihood/mcmc/src directory, run

mex tcm_matlab.cc

This should create a compiled mex file that is specific to your architecture. Then call tcm_general_mex to calculate the likelihood of a free recall dataset. The C++ code has been developed in parallel with tcm_general.m, and has a similar calling signature and supports most of the same features. Compare your results to tcm_general.m to make sure you get the same log likelihood. There is currently no implementation of a generative model in C++, so you must call gen_tcm.m for that. This generally isn't an issue, since generally the heaviest computational work is done during the maximum likelihood parameter search.

When adding a parameter to the model, the interface needs to be updated. Change the following files:

param_vec_tcmbin.m - change the "names" list to include the new parameter. If there are any fields with a non-numeric type, they should be converted to a number here.

parameters.cc - change each method to include the new parameter. Make sure to assign the parameter to the same index in the param_vec as you specified in the parameter names list in param_vec_tcmbin.m.

parameters.h - add the new parameter to the list of public variables declared here. Add a docstring to describe what it does.

Calculating Likelihood from Command Line
===========================

First, you must write out some data to indicate the recall sequences to examine. This can be accomplished using write_bugs_full_tcm.m (in the likelihood/bugs directory of the CMR_sims project), using the 'text' option. The program can determine which recalls correspond to different lists, since every recall period is terminated with a stop code. However, there is currently no way to indicate that the model should behave differently depending on the item, participant, etc. Edit main.cc to fix the path specified there to point to the file you wrote. 

Parameters are specified in main.cc. Edit them to configure the model.

In the terminal, in the project directory, type

clang++ main.cc
./a.out

Here, a.out is the default name of the binary that clang produces. This should write a file, output.txt, in the current directory, which will contain all the recall event probabilties for all recall sequences.

Bayesian Analysis Using JAGS
===================

It is possible to write a JAGS script that will work out of the box without using any custom c++ code. However, implementing the model directly in JAGS is difficult, since there is no easy way to represent the recursion inherant in the model (each state of context depends on the previous state, and in JAGS, every state must be a separate variable or separate part of an array), and executes fairly slowly. Fortunately, JAGS is designed to be extensible, and it is relatively straightforward to incorporate custom c++ code to implement a new function in their scripting langauge. This function can then be called from a JAGS script, the same as any other function in their standard library.

Compiling JAGS from Source
-----------------------

In order to use MCMC to analyze the model, first compile JAGS from the original source code. See their documentation for instructions on doing this. Once you can compile to a working program, try adding in the custom code. To do this, use install_jags.sh. First, edit the script to set JAGS and SRC to point to those directories in CMR_sims/likelihood/bugs. Also change the line "make -j 16" to set the number to twice the number of processors in your machine. Then, in the base directory of the source code, run the script. It will copy the necessary source files into the distribution, configure the installation, and compile the source code with the custom TCM functions. 

Modifcations to JAGS
-----------------

I found that for some JAGS scripts, I had to disable some error checks. These seem to be internal sanity checks that are buggy, throwing errors even when the inputs should be OK based on their function documentation. I'm guessing this is because I'm making extensive use of the ArrayFunction class, which is only used by a few functions in the original code. The following are locations of throw statements that I commented out:

SymTab.cc, line 68
SymTab.cc, line 87
NodeArray.cc, line 161 (approximate; may differ in original source)
NodeArray.cc, line 250 (approximate; may differ in original source)

I also modified one check to make it work (this seemed to be a bug):

NodeArray.cc, line 63

Trailing dimensions were being dropped on one side of the if statement, and not on the other.

Calling the Custom Function
-----------------------

Then, TCM can be called inside a JAGS script using the recalltcm function:

p <- recalltcm(serialpos, r, Benc, Brec, C, G, X1, X2, P1, P2, T)

serialpos is a vector the same length as list length. The contents of the vector actually don't matter, but only its dimensions (this input is necessary due to how JAGS is organized internally); I set it to a vector of serial positions, where serialpos[i] = i. r is a vector of recall event codes (1-list length indicate a recalled item from that serial position; list length + 1 indicates a stopping event). The rest of the inputs set model parameters; see parameters.cc for descriptions.

Documentation
==========

Documentation is automatically generated using doxygen. Run doxygen in the main directory to refresh the documentation. The reference can be viewed in any internet browser by opening docs/html/index.html.

Authors
=====

The project was written by Neal Morton, based partially on a MATLAB implementation of TCM written by Sean Polyn, Neal Morton, and James Kragel.
