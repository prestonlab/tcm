#ifndef PARAMARRAY_H_
#define PARAMARRAY_H_

#include "parameters.h"

/**
 * @short Set of parameters to use for different lists in a simulation.
 *
 * Array of parameters. Allows different parameters to be specified
 * for different conditions, participants, etc.
 */

class ParamArray {
  std::vector<Parameters> params;
 public:
  /**
   * Blank constructor.
   */
  ParamArray ();

  /**
   * Constructor that allocates for a specified number of parameter sets.
   */
  ParamArray (unsigned int n_sets);

  /**
   * Set the parameters in a specified position in the array.
   */
  void setParam (Parameters param, unsigned int index);

  /**
   * Add a set of parameters to the array.
   *
   * @param param set of parameters.
   */
  void add (Parameters param);

  /**
   * Add multiple sets of parameters to the array.
   *
   * @param n_sets number of sets being added.
   *
   * @param param_mat vector of pointers to arrays with parameter
   * values in the standard order.
   */
  void addVector (unsigned int n_sets,
		  std::vector<double const *> param_mat);

  /**
   * Get a specified parameters object.
   *
   * @param index index of the parameters in the array.
   */
  Parameters getParam (unsigned int index);

  /**
   * Print all parameters stored in the array.
   */
  void print ();
};

#endif
