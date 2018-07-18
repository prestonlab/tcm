#ifndef PARAMETERS_H_
#define PARAMETERS_H_

#include <string>

/**
 * @short Params used to determine the behavior of TCM
 *
 * Contains all parameters for the temporal context model. Sets
 * sensible defaults for parameters.
 */

class Parameters {
 public:
  double Benc; ///< Integration rate during encoding
  double Brec; ///< Integration rate during retrieval
  double P1; ///< Scale of primacy gradient
  double P2; ///< Decay rate of primacy gradient
  double T; ///< Sensitivity parameter for decision rule
  double X1; ///< Probability of recalling no items
  double X2; ///< Rate of increase of stop probability with output position
  double Afc; ///< Constant association strength
  double Dfc; ///< Item self-strengths
  double Sfc; ///< Scale of semantic similarity
  double Lfc; ///< Strength of experimental context retrieval
  double Acf;
  double Dcf;
  double Scf;
  double Lcf; ///< Learning rate of context-to-item associations
  unsigned int stop; ///< Stop rule type. 1: output position, 2: ratio
  double Bstart; ///< Integration rate for reactivating start list context
  double Bipi; ///< Integration rate retention interval
  double Bri; ///< Integration rate retention interval
  double I; ///< Weighting of item-based semantic cuing
  double init_item; ///< Whether to use item-based cuing for the initial recall
  double amin; ///< Minimum support for each item during recall
  double pmin; ///< Minimum choice probability during recall

  /**
   * Create a parameters object with default values.
   */
  Parameters ();

  /**
   * Set parameters based on a vector with a standard format.
   *
   * @param param_vec vector of parameter values.
   */
  Parameters (std::vector<double> &param_vec);

  /**
   * Create a string for a given parameter and its value.
   *
   * @param name name of the parameter.
   * @param val value of the paramter.
   */
  std::string toString (std::string name, double val) const;

  /**
   * Print the contents of a parameter object.
   */
  void print () const;
};

#endif
